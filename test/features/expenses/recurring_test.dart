import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/db/db_settings.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/core/security/roles.dart';
import 'package:agentkhata/features/expenses/recurrence.dart';
import 'package:agentkhata/features/expenses/recurring_expense_service.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  group('Recurrence', () {
    test('monthly: this month if not passed, else next', () {
      const r = Recurrence.monthly(5);
      expect(r.firstOnOrAfter('2026-10-01'), '2026-10-05');
      expect(r.firstOnOrAfter('2026-10-05'), '2026-10-05');
      expect(r.firstOnOrAfter('2026-10-06'), '2026-11-05');
      expect(r.firstOnOrAfter('2026-12-20'), '2027-01-05');
    });

    test('monthly: short months clamp, the original day returns', () {
      const r = Recurrence.monthly(31);
      expect(r.firstOnOrAfter('2026-02-10'), '2026-02-28');
      expect(r.nextAfter('2026-02-28'), '2026-03-31');
      expect(r.nextAfter('2026-03-31'), '2026-04-30');
      expect(r.firstOnOrAfter('2028-02-01'), '2028-02-29'); // leap year
    });

    test('weekly: finds the weekday and steps by seven days', () {
      const r = Recurrence.weekly(DateTime.saturday); // 6
      // 2026-10-17 is a Saturday.
      expect(r.firstOnOrAfter('2026-10-17'), '2026-10-17');
      expect(r.firstOnOrAfter('2026-10-18'), '2026-10-24');
      expect(r.firstOnOrAfter('2026-10-12'), '2026-10-17');
      expect(r.nextAfter('2026-10-17'), '2026-10-24');
      expect(r.nextAfter('2026-12-26'), '2027-01-02');
    });

    test('dueCount counts missed periods, capped', () {
      const r = Recurrence.monthly(1);
      expect(r.dueCount('2026-10-01', '2026-09-30'), 0);
      expect(r.dueCount('2026-10-01', '2026-10-01'), 1);
      expect(r.dueCount('2026-08-01', '2026-10-15'), 3);
      expect(r.dueCount('2020-01-01', '2026-10-15'), 12);
    });
  });

  group('service', () {
    late LedgerFixture f;
    late RecurringExpenseService service;
    var now = DateTime.utc(2026, 10, 20, 10); // 16:00 in Dhaka, the 20th

    RecurringExpenseService build({SessionReader? session}) =>
        RecurringExpenseService(
          db: f.db,
          txns: f.txns,
          audit: AuditLogger(f.db, f.ids, clock: f.clock),
          ids: f.ids,
          clock: () => now,
          session: session,
        );

    setUp(() async {
      now = DateTime.utc(2026, 10, 20, 10);
      f = await LedgerFixture.create();
      await DbSettings(f.db).set(DbSettings.dayRolloverHourKey, '0');
      service = build();
    });
    tearDown(() => f.dispose());

    test(
      'create schedules the first occurrence and nothing is due early',
      () async {
        await service.create(
          categoryAccountId: f.rent,
          sourceAccountId: f.cash,
          amount: const Money.taka(15000),
          recurrence: const Recurrence.monthly(1),
        );
        final all = await service.watchAll().first;
        expect(all.single.nextDueDate, '2026-11-01');
        expect(all.single.categoryLabel, 'Rent');
        expect(await service.due(), isEmpty);
      },
    );

    test('due on or after the date; record posts and advances', () async {
      final id = await service.create(
        categoryAccountId: f.rent,
        sourceAccountId: f.cash,
        amount: const Money.taka(15000),
        recurrence: const Recurrence.monthly(20), // today
        note: 'shop',
      );
      expect((await service.due()).single.id, id);

      final txn = await service.record(id);
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(-5000));
      final row = (await f.db.select(f.db.txns).get()).single;
      expect(row.id, txn);
      expect(row.type, 'expense');
      expect(row.note, 'recurring: shop');

      expect((await service.byId(id))!.nextDueDate, '2026-11-20');
      expect(await service.due(), isEmpty);
    });

    test('catching up: each confirmation clears one missed period', () async {
      final id = await service.create(
        categoryAccountId: f.rent,
        sourceAccountId: f.cash,
        amount: const Money.taka(100),
        recurrence: const Recurrence.monthly(1),
      );
      now = DateTime.utc(2027, 1, 15, 10); // two months later: Nov, Dec, Jan
      expect((await service.byId(id))!.nextDueDate, '2026-11-01');
      expect(await service.due(), hasLength(1));

      await service.record(id);
      await service.skip(id);
      expect((await service.byId(id))!.nextDueDate, '2027-01-01');
      expect(await service.due(), hasLength(1));
      await service.skip(id);
      expect(await service.due(), isEmpty);
      expect((await service.byId(id))!.nextDueDate, '2027-02-01');
    });

    test('skip records nothing', () async {
      final id = await service.create(
        categoryAccountId: f.rent,
        sourceAccountId: f.cash,
        amount: const Money.taka(100),
        recurrence: const Recurrence.monthly(20),
      );
      await service.skip(id);
      expect(await f.db.select(f.db.txns).get(), isEmpty);
      expect((await service.byId(id))!.nextDueDate, '2026-11-20');
    });

    test('inactive templates are neither due nor recordable', () async {
      final id = await service.create(
        categoryAccountId: f.rent,
        sourceAccountId: f.cash,
        amount: const Money.taka(100),
        recurrence: const Recurrence.monthly(20),
      );
      await service.update(id, isActive: false);
      expect(await service.due(), isEmpty);
      await expectLater(
        service.record(id),
        throwsA(
          isA<RecurringException>().having((e) => e.code, 'code', 'inactive'),
        ),
      );
    });

    test('changing the schedule recomputes the next date', () async {
      final id = await service.create(
        categoryAccountId: f.rent,
        sourceAccountId: f.cash,
        amount: const Money.taka(100),
        recurrence: const Recurrence.monthly(1),
      );
      await service.update(id, recurrence: const Recurrence.monthly(25));
      expect((await service.byId(id))!.nextDueDate, '2026-10-25');
      await service.update(id, amount: const Money.taka(250));
      expect((await service.byId(id))!.amount, const Money.taka(250));
    });

    test(
      'a closed business day refuses to record, and nothing advances',
      () async {
        final id = await service.create(
          categoryAccountId: f.rent,
          sourceAccountId: f.cash,
          amount: const Money.taka(100),
          recurrence: const Recurrence.monthly(20),
        );
        await f.db.customStatement(
          "INSERT INTO day_close (id, business_date, status) VALUES ('dc', '2026-10-20', 'closed')",
        );
        await expectLater(
          service.record(id),
          throwsA(isA<DayLockedException>()),
        );
        expect((await service.byId(id))!.nextDueDate, '2026-10-20');
      },
    );

    test(
      'only the owner manages templates; amounts must be positive',
      () async {
        final staff = build(
          session: () =>
              const Session(id: 's', name: 'S', role: UserRole.staff),
        );
        await expectLater(
          staff.create(
            categoryAccountId: f.rent,
            sourceAccountId: f.cash,
            amount: const Money.taka(100),
            recurrence: const Recurrence.monthly(1),
          ),
          throwsA(isA<PermissionDenied>()),
        );
        await expectLater(
          service.create(
            categoryAccountId: f.rent,
            sourceAccountId: f.cash,
            amount: Money.zero,
            recurrence: const Recurrence.monthly(1),
          ),
          throwsA(isA<RecurringException>()),
        );
      },
    );
  });
}
