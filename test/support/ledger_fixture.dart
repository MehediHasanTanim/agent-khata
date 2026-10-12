import 'package:agentkhata/core/audit/audit_logger.dart';
import 'package:agentkhata/core/db/app_database.dart';
import 'package:agentkhata/core/ledger/account_kind.dart';
import 'package:agentkhata/core/ledger/strategies.dart';
import 'package:agentkhata/core/ledger/transaction_draft.dart';
import 'package:agentkhata/core/ledger/transaction_type.dart';
import 'package:agentkhata/core/money/money.dart';
import 'package:agentkhata/core/utils/uuid_v7.dart';
import 'package:agentkhata/features/accounts/account_repository.dart';
import 'package:agentkhata/features/transactions/transaction_repository.dart';

/// Deterministic IDs: `id-000001`, ...
class SequentialIds implements IdGenerator {
  int _n = 0;
  @override
  String next() => 'id-${(++_n).toString().padLeft(6, '0')}';
}

/// In-memory DB with a standard set of accounts and wired repositories.
class LedgerFixture {
  LedgerFixture._(this.db, this.ids, this.accounts, this.txns, this.clock);

  final AppDatabase db;
  final SequentialIds ids;
  final AccountRepository accounts;
  final TransactionRepository txns;
  DateTime Function() clock;

  late String cash;
  late String bkash;
  late String nagad;
  late String gpLoad;
  late String bank;
  late String rent;

  static Future<LedgerFixture> create({
    DateTime? now,
    Money openingCash = const Money.taka(10000),
    Money openingBkash = const Money.taka(50000),
  }) async {
    final fixedNow = now ?? DateTime.utc(2026, 10, 20, 10);
    final db = AppDatabase.memory();
    final ids = SequentialIds();
    DateTime clock() => fixedNow;
    final accounts = AccountRepository(db, ids, clock: clock);
    final txns = TransactionRepository(
      db: db,
      registry: PostingRegistry.standard(),
      ids: ids,
      audit: AuditLogger(db, ids, clock: clock),
      deviceId: 'test-device',
      clock: clock,
    );
    final f = LedgerFixture._(db, ids, accounts, txns, clock);
    await accounts.ensureSystemAccounts();
    f.cash = await accounts.create(
      kind: AccountKind.cash,
      label: 'Cash',
      opening: openingCash,
    );
    f.bkash = await accounts.create(
      kind: AccountKind.wallet,
      label: 'bKash',
      provider: 'bkash',
      opening: openingBkash,
    );
    f.nagad = await accounts.create(
      kind: AccountKind.wallet,
      label: 'Nagad',
      provider: 'nagad',
      opening: const Money.taka(20000),
    );
    f.gpLoad = await accounts.create(
      kind: AccountKind.load,
      label: 'GP load',
      provider: 'gp',
      opening: const Money.taka(5000),
    );
    f.bank = await accounts.create(
      kind: AccountKind.bank,
      label: 'Bank',
      opening: const Money.taka(100000),
    );
    f.rent = await accounts.create(kind: AccountKind.expense, label: 'Rent');
    return f;
  }

  /// Cash-out of [taka] through [wallet] (default bKash), at [at].
  TransactionDraft cashOutDraft(int taka, {String? wallet, DateTime? at}) =>
      TransactionDraft(
        type: TransactionType.cashOut,
        occurredAt: at ?? clock(),
        amount: Money.taka(taka),
        fromAccountId: cash,
        toAccountId: wallet ?? bkash,
        commission: Money.paisa(taka * 4),
      );

  /// Cash-in of [taka] through [wallet] (default bKash), at [at].
  TransactionDraft cashInDraft(int taka, {String? wallet, DateTime? at}) =>
      TransactionDraft(
        type: TransactionType.cashIn,
        occurredAt: at ?? clock(),
        amount: Money.taka(taka),
        fromAccountId: wallet ?? bkash,
        toAccountId: cash,
      );

  Future<void> dispose() => db.close();
}
