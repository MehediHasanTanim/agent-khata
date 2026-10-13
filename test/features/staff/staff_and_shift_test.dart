import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/ledger/strategies.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/core/security/key_value_store.dart';
import 'package:agentkhata/core/security/lockout_policy.dart';
import 'package:agentkhata/core/security/pin_hasher.dart';
import 'package:agentkhata/core/security/pin_service.dart';
import 'package:agentkhata/core/security/roles.dart';
import 'package:agentkhata/features/closeday/day_close_service.dart';
import 'package:agentkhata/features/commission/commission_rule.dart';
import 'package:agentkhata/features/commission/commission_rule_repository.dart';
import 'package:agentkhata/features/shifts/shift_service.dart';
import 'package:agentkhata/features/staff/staff_service.dart';
import 'package:agentkhata/features/transactions/history_filter.dart';
import 'package:agentkhata/features/transactions/history_queries.dart';
import 'package:agentkhata/features/transactions/transaction_queries.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_fixture.dart';

void main() {
  late LedgerFixture f;
  late PinService pins;
  late StaffService staff;
  late ShiftService shifts;

  // Mutable "who is logged in" for permission tests.
  var current = Session.owner;
  Session who() => current;

  setUp(() async {
    current = Session.owner;
    f = await LedgerFixture.create();
    pins = PinService(
      store: MemoryKeyValueStore(),
      hasher: PinHasher(iterations: 10),
      policy: const LockoutPolicy(),
      clock: f.clock,
    );
    await pins.setPin('1111');
    staff = StaffService(
      db: f.db,
      pins: pins,
      ids: f.ids,
      clock: f.clock,
      session: who,
    );
    await staff.ensureOwner();
    shifts = ShiftService(
      db: f.db,
      txns: f.txns,
      audit: AuditLogger(f.db, f.ids, clock: f.clock),
      clock: f.clock,
    );
  });
  tearDown(() => f.dispose());

  TransactionRepository repoFor(Session s) => TransactionRepository(
    db: f.db,
    registry: PostingRegistry.standard(),
    ids: f.ids,
    audit: AuditLogger(f.db, f.ids, clock: f.clock),
    deviceId: 'test-device',
    clock: f.clock,
    session: () => s,
  );

  TransactionDraft cashOutBy(String userId, int taka) => TransactionDraft(
    type: TransactionType.cashOut,
    occurredAt: f.clock(),
    amount: Money.taka(taka),
    fromAccountId: f.cash,
    toAccountId: f.bkash,
    commission: Money.paisa(taka * 4),
    createdBy: userId,
  );

  group('staff accounts', () {
    test('owner row is created once', () async {
      await staff.ensureOwner();
      final all = await staff.watchAll().first;
      expect(all.single.id, kOwnerUserId);
      expect(all.single.role, UserRole.owner);
      expect(all.single.canSeeProfit, isTrue);
    });

    test('create, list and toggle permissions', () async {
      final id = await staff.create(
        name: ' Rahim ',
        pin: '2222',
        canCloseDay: true,
      );
      var m = (await staff.byId(id))!;
      expect(m.name, 'Rahim');
      expect(m.canSeeProfit, isFalse);
      expect(m.canCloseDay, isTrue);
      expect(m.hasPin, isTrue);
      expect(m.toSession().role, UserRole.staff);

      await staff.update(id, canSeeProfit: true, canCloseDay: false);
      m = (await staff.byId(id))!;
      expect(m.canSeeProfit, isTrue);
      expect(m.canCloseDay, isFalse);

      expect((await staff.activeStaff()).map((s) => s.name), ['Rahim']);
      await staff.update(id, isActive: false);
      expect(await staff.activeStaff(), isEmpty);
      expect(await staff.pinHashOf(id), isNull);
    });

    test('PINs must be valid and distinct', () async {
      await expectLater(
        staff.create(name: 'A', pin: '12'),
        throwsA(isA<StaffException>().having((e) => e.code, 'c', 'bad_pin')),
      );
      await expectLater(
        staff.create(name: 'A', pin: '1111'), // the owner's PIN
        throwsA(isA<StaffException>().having((e) => e.code, 'c', 'pin_in_use')),
      );
      await staff.create(name: 'A', pin: '2222');
      await expectLater(
        staff.create(name: 'B', pin: '2222'),
        throwsA(isA<StaffException>().having((e) => e.code, 'c', 'pin_in_use')),
      );
      await expectLater(
        staff.create(name: ' ', pin: '3333'),
        throwsA(
          isA<StaffException>().having((e) => e.code, 'c', 'name_required'),
        ),
      );
    });

    test('a staff PIN logs in through the shared lockout', () async {
      final id = await staff.create(name: 'A', pin: '2222');
      final hash = await staff.pinHashOf(id);
      expect(await pins.verifyAgainst('2222', hash), isA<PinVerified>());

      for (var i = 0; i < 4; i++) {
        expect(await pins.verifyAgainst('0000', hash), isA<PinWrong>());
      }
      final fifth = await pins.verifyAgainst('0000', hash) as PinWrong;
      expect(fifth.delay, greaterThan(Duration.zero));
      // The owner is locked out by the same counter.
      expect(await pins.verify('1111'), isA<PinLockedOut>());
    });

    test('resetPin replaces the PIN but keeps it distinct', () async {
      final id = await staff.create(name: 'A', pin: '2222');
      await staff.resetPin(id, '3333');
      final hash = await staff.pinHashOf(id);
      expect(await pins.verifyHash('3333', hash!), isTrue);
      expect(await pins.verifyHash('2222', hash), isFalse);
      // The same PIN may be re-set for the same person.
      await staff.resetPin(id, '3333');
    });

    test('only the owner manages staff', () async {
      current = const Session(id: 's', name: 'S', role: UserRole.staff);
      await expectLater(
        staff.create(name: 'X', pin: '4444'),
        throwsA(isA<PermissionDenied>()),
      );
    });

    test('the built-in owner cannot be edited as staff', () async {
      await expectLater(
        staff.update(kOwnerUserId, name: 'Boss'),
        throwsA(isA<StaffException>()),
      );
    });
  });

  group('shifts', () {
    test('the first entry opens a shift; later entries share it', () async {
      expect(await shifts.currentOpen(), isNull);
      final a = await f.txns.post(cashOutBy('owner', 100));
      final b = await f.txns.post(cashOutBy('owner', 200));
      final open = (await shifts.currentOpen())!;
      expect(open.userId, 'owner');
      final rows = await f.db.select(f.db.txns).get();
      expect(rows.where((t) => t.id == a || t.id == b).map((t) => t.shiftId), [
        open.id,
        open.id,
      ]);
    });

    test('handover counts the drawer and attributes the shortage', () async {
      await f.txns.post(cashOutBy('owner', 2000)); // cash 8000
      final opened = (await shifts.currentOpen())!;

      // Cash is ৳300 short; everything else matches.
      final id = await shifts.handover(
        actuals: {f.cash: const Money.taka(7700)},
        resolutions: {
          f.cash: const VarianceResolution(AdjustmentReason.shortage),
        },
        userId: 'owner',
      );
      expect(id, opened.id);
      expect(await shifts.currentOpen(), isNull);
      expect(await f.accounts.balanceOf(f.cash), const Money.taka(7700));

      final info = (await shifts.recent()).single;
      expect(info.isOpen, isFalse);
      expect(info.totalVariance, const Money.taka(-300));

      // The next entry starts a new shift for its operator.
      await f.txns.post(cashOutBy('s1', 100));
      final next = (await shifts.currentOpen())!;
      expect(next.id, isNot(id));
      expect(next.userId, 's1');
    });

    test('a variance needs a reason unless within tolerance', () async {
      await f.txns.post(cashOutBy('owner', 100));
      await expectLater(
        shifts.handover(
          actuals: {f.cash: const Money.taka(9895)},
          userId: 'owner',
        ),
        throwsA(isA<MissingVarianceReason>()),
      );
      expect(await shifts.currentOpen(), isNotNull);

      await shifts.handover(
        actuals: {f.cash: const Money.taka(9898)}, // off by 2, tolerance 5
        toleranceTaka: 5,
        userId: 'owner',
      );
      expect(await shifts.currentOpen(), isNull);
    });

    test('handover with no open shift is an error', () async {
      await expectLater(
        shifts.handover(actuals: const {}, userId: 'owner'),
        throwsA(isA<ShiftException>()),
      );
    });

    test(
      'summary covers only that shift and variance by operator adds up',
      () async {
        await f.txns.post(cashOutBy('owner', 1000));
        final first = (await shifts.currentOpen())!.id;
        await shifts.handover(
          actuals: {f.cash: const Money.taka(8900)}, // 100 short
          resolutions: {
            f.cash: const VarianceResolution(AdjustmentReason.shortage),
          },
          userId: 'owner',
        );
        await f.txns.post(cashOutBy('s1', 500));
        await f.txns.post(cashOutBy('s1', 300));
        final second = (await shifts.currentOpen())!.id;
        await shifts.handover(
          actuals: {f.cash: const Money.taka(8200)}, // 100 over (8100 expected)
          resolutions: {
            f.cash: const VarianceResolution(AdjustmentReason.excess),
          },
          userId: 's1',
        );

        final s1 = await shifts.summary(first);
        expect(s1.count, 1);
        expect(s1.cashOutVolume, const Money.taka(1000));
        final s2 = await shifts.summary(second);
        expect(s2.count, 2);
        expect(s2.cashOutVolume, const Money.taka(800));

        final byOp = await shifts.varianceByOperator(
          DateTime.utc(2000),
          DateTime.utc(2100),
        );
        final owner = byOp.firstWhere((o) => o.userId == 'owner');
        final s1op = byOp.firstWhere((o) => o.userId == 's1');
        expect(owner.shortage, const Money.taka(-100));
        expect(owner.total, const Money.taka(-100));
        expect(s1op.shortage, Money.zero);
        expect(s1op.total, const Money.taka(100));
      },
    );

    test('closing the day ends the open shift with the day figures', () async {
      await f.db.customStatement(
        "INSERT INTO setting (key, value) VALUES ('day_rollover_hour', '0')",
      );
      await f.txns.post(cashOutBy('s1', 1000)); // today, 10:00 UTC
      final dayClose = DayCloseService(
        db: f.db,
        txns: f.txns,
        audit: AuditLogger(f.db, f.ids, clock: f.clock),
        ids: f.ids,
        clock: f.clock,
      );
      await dayClose.close(
        businessDate: '2026-10-20',
        actuals: {f.cash: const Money.taka(8950)},
        resolutions: {
          f.cash: const VarianceResolution(AdjustmentReason.shortage),
        },
      );
      expect(await shifts.currentOpen(), isNull);
      final info = (await shifts.recent()).single;
      expect(info.userId, 's1');
      expect(info.totalVariance, const Money.taka(-50));
    });
  });

  group('permission enforcement in services', () {
    const staffSession = Session(id: 's1', name: 'S', role: UserRole.staff);

    test('staff add entries but cannot post adjustments', () async {
      final repo = repoFor(staffSession);
      await repo.post(cashOutBy('s1', 100));
      await expectLater(
        repo.post(
          TransactionDraft(
            type: TransactionType.adjustment,
            occurredAt: f.clock(),
            amount: const Money.taka(5),
            toAccountId: f.cash,
            note: 'x',
          ),
        ),
        throwsA(isA<PermissionDenied>()),
      );
    });

    test('staff may void their own entries but not the owner\'s', () async {
      final own = await repoFor(staffSession).post(cashOutBy('s1', 100));
      final others = await f.txns.post(cashOutBy('owner', 100));

      await repoFor(staffSession)
          .voidTransaction(own, reason: 'typo', userId: 's1');
      await expectLater(
        repoFor(staffSession)
            .voidTransaction(others, reason: 'x', userId: 's1'),
        throwsA(isA<PermissionDenied>()),
      );
      await expectLater(
        repoFor(staffSession).edit(others, cashOutBy('s1', 50), userId: 's1'),
        throwsA(isA<PermissionDenied>()),
      );
      // The owner can void anyone's entry.
      final theirs = await repoFor(staffSession).post(cashOutBy('s1', 70));
      await f.txns.voidTransaction(theirs, reason: 'x', userId: 'owner');
    });

    test('day close and reopen follow the permission switches', () async {
      await f.db.customStatement(
        "INSERT INTO setting (key, value) VALUES ('day_rollover_hour', '0')",
      );
      await f.txns.post(cashOutBy('owner', 100));
      DayCloseService closeAs(Session s) => DayCloseService(
        db: f.db,
        txns: f.txns,
        audit: AuditLogger(f.db, f.ids, clock: f.clock),
        ids: f.ids,
        clock: f.clock,
        session: () => s,
      );

      await expectLater(
        closeAs(staffSession)
            .close(businessDate: '2026-10-20', actuals: const {}),
        throwsA(isA<PermissionDenied>()),
      );
      const closer = Session(
        id: 's2',
        name: 'C',
        role: UserRole.staff,
        canCloseDay: true,
      );
      await closeAs(closer)
          .close(businessDate: '2026-10-20', actuals: const {});
      await expectLater(
        closeAs(closer).reopen('2026-10-20', reason: 'x'),
        throwsA(isA<PermissionDenied>()),
      );
      await closeAs(Session.owner).reopen('2026-10-20', reason: 'fix');
    });

    test('staff cannot change commission rates', () async {
      final rules = CommissionRuleRepository(
        f.db,
        f.ids,
        AuditLogger(f.db, f.ids, clock: f.clock),
        session: () => staffSession,
      );
      await expectLater(
        rules.setRate(
          provider: 'bkash',
          type: TransactionType.cashOut,
          mode: CommissionMode.fixed,
          value: 100,
          at: f.clock(),
        ),
        throwsA(isA<PermissionDenied>()),
      );
    });
  });

  group('own-entries views', () {
    test('history and today totals can be limited to one user', () async {
      await f.txns.post(cashOutBy('owner', 1000));
      await f.txns.post(cashOutBy('s1', 200));
      await f.txns.post(cashOutBy('s1', 300));

      final mine = await HistoryQueries(f.db)
          .page(const HistoryFilter(createdBy: 's1'));
      expect(mine.map((i) => i.amount.wholeTaka).toSet(), {200, 300});

      final totals = await HistoryQueries(f.db)
          .totals(const HistoryFilter(createdBy: 's1'));
      expect(totals.count, 2);
      expect(totals.amount, const Money.taka(500));

      final summary = await TransactionQueries(f.db)
          .watchSummary(
            DateTime.utc(2026, 10, 20),
            DateTime.utc(2026, 10, 21),
            createdBy: 's1',
          )
          .first;
      expect(summary.count, 2);
      expect(summary.cashOutVolume, const Money.taka(500));
    });
  });
}
