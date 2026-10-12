import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_database.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_draft.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../commission/commission_engine.dart';
import '../commission/commission_rule.dart';
import '../transactions/integrity_checker.dart';

/// Dev-flavor-only screen (S1-11) for exercising the ledger by hand: seed
/// demo accounts, post one of each transaction type, void, inspect balances,
/// the audit log and the integrity check. Not localized on purpose.
class LedgerDebugScreen extends ConsumerStatefulWidget {
  const LedgerDebugScreen({super.key});

  @override
  ConsumerState<LedgerDebugScreen> createState() => _LedgerDebugScreenState();
}

class _LedgerDebugScreenState extends ConsumerState<LedgerDebugScreen> {
  final _amount = TextEditingController(text: '1000');
  String? _lastTxnId;
  String? _message;

  static const _money = MoneyFormatter();
  static const _engine = CommissionEngine();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _seed() async {
    final repo = ref.read(accountRepositoryProvider);
    final rules = ref.read(commissionRuleRepositoryProvider);
    final ids = ref.read(idGeneratorProvider);
    await repo.ensureSystemAccounts();
    await repo.create(
      kind: AccountKind.cash,
      label: 'Cash',
      opening: const Money.taka(10000),
    );
    await repo.create(
      kind: AccountKind.wallet,
      label: 'bKash',
      provider: 'bkash',
      opening: const Money.taka(50000),
    );
    await repo.create(
      kind: AccountKind.wallet,
      label: 'Nagad',
      provider: 'nagad',
      opening: const Money.taka(20000),
    );
    await repo.create(
      kind: AccountKind.load,
      label: 'GP load',
      provider: 'gp',
      opening: const Money.taka(5000),
    );
    await repo.create(kind: AccountKind.bank, label: 'Bank');
    await repo.create(kind: AccountKind.expense, label: 'Rent');
    final epoch = DateTime.utc(2020);
    await rules.insert(
      CommissionRule(
        id: ids.next(),
        provider: 'bkash',
        txnType: TransactionType.cashOut,
        mode: CommissionMode.perThousand,
        value: 410,
        effectiveFrom: epoch,
      ),
    );
    await rules.insert(
      CommissionRule(
        id: ids.next(),
        provider: 'gp',
        txnType: TransactionType.flexiload,
        mode: CommissionMode.percent,
        value: 300,
        effectiveFrom: epoch,
      ),
    );
    setState(() => _message = 'Seeded demo accounts and sample rates.');
  }

  Future<List<Account>> _accounts() async {
    final rows = await ref
        .read(databaseProvider)
        .select(ref.read(databaseProvider).accounts)
        .get();
    return [
      for (final r in rows)
        Account(
          id: r.id,
          kind: AccountKind.fromDb(r.kind),
          label: r.label,
          provider: r.provider,
          isActive: r.isActive,
        ),
    ];
  }

  Future<void> _post(TransactionType type) async {
    final amount = Money.tryParse(_amount.text);
    if (amount == null || !amount.isPositive) {
      setState(() => _message = 'Enter a positive amount.');
      return;
    }
    final accounts = await _accounts();
    Account? pick(AccountKind kind, {String? provider, int skip = 0}) {
      final matches = accounts
          .where(
            (a) =>
                a.kind == kind && (provider == null || a.provider == provider),
          )
          .toList();
      return matches.length > skip ? matches[skip] : null;
    }

    final cash = pick(AccountKind.cash);
    final bkash = pick(AccountKind.wallet, provider: 'bkash');
    final nagad = pick(AccountKind.wallet, provider: 'nagad');
    final gp = pick(AccountKind.load);
    final bank = pick(AccountKind.bank);
    final rent = pick(AccountKind.expense);
    if (cash == null || bkash == null) {
      setState(() => _message = 'Seed accounts first.');
      return;
    }

    final at = DateTime.now().toUtc();
    final rules = await ref.read(commissionRuleRepositoryProvider).all();
    Money commissionFor(String provider) => _engine
        .compute(
          rules: rules,
          provider: provider,
          type: type,
          amount: amount,
          at: at,
        )
        .amount;

    String? from;
    String? to;
    var commission = Money.zero;
    String? note;
    switch (type) {
      case TransactionType.cashIn:
      case TransactionType.sendMoney:
      case TransactionType.billPay:
        from = bkash.id;
        to = cash.id;
      case TransactionType.cashOut:
        from = cash.id;
        to = bkash.id;
        commission = commissionFor('bkash');
      case TransactionType.flexiload:
        from = gp?.id;
        to = cash.id;
        commission = commissionFor('gp');
      case TransactionType.floatPurchase:
        from = cash.id;
        to = bkash.id;
      case TransactionType.floatTransfer:
        from = bkash.id;
        to = nagad?.id;
      case TransactionType.bankDeposit:
        from = cash.id;
        to = bank?.id;
      case TransactionType.expense:
        from = cash.id;
        to = rent?.id;
      case TransactionType.adjustment:
        to = cash.id;
        note = 'debug adjustment';
    }

    try {
      _lastTxnId = await ref
          .read(transactionRepositoryProvider)
          .post(
            TransactionDraft(
              type: type,
              occurredAt: at,
              amount: amount,
              fromAccountId: from,
              toAccountId: to,
              commission: commission,
              note: note,
            ),
          );
      setState(() => _message = 'Posted ${type.dbName}.');
    } on Exception catch (e) {
      setState(() => _message = '$e');
    }
  }

  Future<void> _voidLast() async {
    final id = _lastTxnId;
    if (id == null) return;
    try {
      await ref
          .read(transactionRepositoryProvider)
          .voidTransaction(id, reason: 'debug void', userId: 'owner');
      setState(() {
        _lastTxnId = null;
        _message = 'Voided last transaction.';
      });
    } on Exception catch (e) {
      setState(() => _message = '$e');
    }
  }

  Future<void> _check() async {
    final report = await LedgerIntegrityChecker(ref.read(databaseProvider))
        .run();
    setState(
      () => _message = report.isHealthy
          ? 'Books verified: all transactions balance.'
          : 'INTEGRITY PROBLEM: ${report.unbalancedTxnIds.length} unbalanced, '
                '${report.balanceMismatches.length} balance mismatches, '
                '${report.orphanEntryCount} orphans.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ledger debug harness')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: _seed, child: const Text('Seed demo')),
              OutlinedButton(
                onPressed: _check,
                child: const Text('Integrity check'),
              ),
              OutlinedButton(
                onPressed: _lastTxnId == null ? null : _voidLast,
                child: const Text('Void last'),
              ),
            ],
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_message!, style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (taka)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in TransactionType.values)
                FilledButton.tonal(
                  onPressed: () => _post(t),
                  child: Text(t.dbName),
                ),
            ],
          ),
          const Divider(height: 32),
          Text('Balances', style: theme.textTheme.titleMedium),
          StreamBuilder<Map<String, Money>>(
            stream: ref.watch(accountRepositoryProvider).watchBalances(),
            builder: (context, snap) {
              final balances = snap.data ?? const {};
              return FutureBuilder<List<Account>>(
                future: _accounts(),
                builder: (context, accSnap) {
                  final accounts = accSnap.data ?? const [];
                  return Column(
                    children: [
                      for (final a in accounts)
                        ListTile(
                          dense: true,
                          title: Text('${a.label} (${a.kind.name})'),
                          trailing: Text(
                            _money.format(balances[a.id] ?? Money.zero),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(height: 32),
          Text('Audit log (latest 15)', style: theme.textTheme.titleMedium),
          StreamBuilder<List<AuditLogRow>>(
            stream:
                (db.select(db.auditLogs)
                      ..orderBy([(t) => OrderingTerm.desc(t.at)])
                      ..limit(15))
                    .watch(),
            builder: (context, snap) => Column(
              children: [
                for (final row in snap.data ?? const <AuditLogRow>[])
                  ListTile(
                    dense: true,
                    title: Text('${row.action} ${row.entity}'),
                    subtitle: Text(row.afterJson ?? row.reason ?? ''),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
