import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../l10n/gen/app_localizations.dart';
import '../accounts/account_ledger_screen.dart';
import '../backup/backup_screen.dart';
import '../closeday/close_day_screen.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../entry/entry_screen.dart';
import '../transactions/transaction_queries.dart';
import 'balance_cards.dart';

final _recentProvider = StreamProvider.autoDispose<List<RecentTxn>>(
  (ref) => ref.watch(transactionQueriesProvider).watchRecent(),
);

final _todayProvider = StreamProvider.autoDispose<DaySummary>((ref) {
  final hour = ref.watch(dayRolloverHourProvider).value ?? 4;
  final range = BusinessCalendar(rolloverHour: hour)
      .dayRange(DateTime.now().toUtc());
  return ref
      .watch(transactionQueriesProvider)
      .watchSummary(range.start, range.end);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _revealed = {};

  Future<void> _open(EntryKind kind) async {
    final id = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => EntryScreen(kind: kind)));
    if (id == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.entrySaved),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () async {
              await ref
                  .read(transactionRepositoryProvider)
                  .voidTransaction(id, reason: 'undo', userId: 'owner');
              messenger
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(l10n.entryUndone)));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final balances = ref.watch(balancesProvider).value ?? const {};
    final today = ref.watch(_todayProvider).value ?? const DaySummary();
    final recent = ref.watch(_recentProvider).value ?? const <RecentTxn>[];
    final tokens = context.tokens;

    final loads = [
      for (final a in accounts)
        if (a.kind == AccountKind.load) a,
    ];
    final loadTotal = loads.fold<Money>(
      Money.zero,
      (sum, a) => sum + (balances[a.id] ?? Money.zero),
    );

    final lowLabels = [
      for (final a in accounts)
        if (a.lowAlert != null && (balances[a.id] ?? Money.zero) <= a.lowAlert!)
          a.kind == AccountKind.cash ? l10n.homeCash : a.label,
    ];

    final cards = <BalanceCardData>[
      for (final a in accounts)
        if (a.kind != AccountKind.load && a.kind != AccountKind.bank)
          BalanceCardData(
            id: a.id,
            account: a,
            label: a.kind == AccountKind.cash ? l10n.homeCash : a.label,
            balance: balances[a.id] ?? Money.zero,
            isLow:
                a.lowAlert != null &&
                (balances[a.id] ?? Money.zero) <= a.lowAlert!,
          ),
      if (loads.isNotEmpty)
        BalanceCardData(
          id: 'load-total',
          label: l10n.homeFlexiloadTotal,
          balance: loadTotal,
          isLow: false,
        ),
    ];

    Widget action(EntryKind kind, String label, IconData icon, Color color) =>
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 76),
              child: FilledButton.tonal(
                key: ValueKey('action-${kind.name}'),
                style: FilledButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.16),
                  foregroundColor: theme.colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _open(kind),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 4),
                    Text(label, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (ref.watch(unclosedYesterdayProvider).value case final y?)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: tokens.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.warning),
              ),
              child: ListTile(
                leading: Icon(Icons.fact_check_outlined, color: tokens.warning),
                title: Text(l10n.cdYesterdayOpen),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => CloseDayScreen(businessDate: y),
                  ),
                ),
              ),
            ),
          if (accounts.isNotEmpty && _backupStale(prefs.lastBackupAtMs))
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(l10n.bkStaleBanner),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const BackupScreen()),
                ),
              ),
            ),
          if (lowLabels.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.warning),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: tokens.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.lowBanner(lowLabels.join(', ')))),
                ],
              ),
            ),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = cards[i];
                final hidden = prefs.maskBalances && !_revealed.contains(c.id);
                return BalanceCard(
                  data: c,
                  amountText: hidden ? '৳ ••••' : money.format(c.balance),
                  hidden: hidden,
                  onTap: () {
                    if (hidden) {
                      setState(() => _revealed.add(c.id));
                    } else if (c.account != null) {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              AccountLedgerScreen(account: c.account!),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    action(
                      EntryKind.cashOut,
                      l10n.txnCashOut,
                      Icons.north_east,
                      tokens.cashOut,
                    ),
                    action(
                      EntryKind.cashIn,
                      l10n.txnCashIn,
                      Icons.south_west,
                      tokens.cashIn,
                    ),
                  ],
                ),
                Row(
                  children: [
                    action(
                      EntryKind.flexiload,
                      l10n.txnFlexiload,
                      Icons.phone_android,
                      tokens.cashIn,
                    ),
                    action(
                      EntryKind.floatPurchase,
                      l10n.txnFloatPurchase,
                      Icons.account_balance_wallet_outlined,
                      theme.colorScheme.primary,
                    ),
                  ],
                ),
                Row(
                  children: [
                    action(
                      EntryKind.expense,
                      l10n.txnExpense,
                      Icons.receipt_long_outlined,
                      theme.colorScheme.secondary,
                    ),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(l10n.homeToday, style: theme.textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _Stat(
                  l10n.homeTodayEntries,
                  prefs.digits.localize('${today.count}'),
                ),
                _Stat(l10n.homeTodayCashIn, money.format(today.cashInVolume)),
                _Stat(l10n.homeTodayCashOut, money.format(today.cashOutVolume)),
                _Stat(l10n.homeTodayCommission, money.format(today.commission)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(l10n.homeRecent, style: theme.textTheme.titleMedium),
          ),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.homeNoEntries),
            )
          else
            for (final r in recent)
              ListTile(
                leading: Icon(
                  r.type == TransactionType.cashIn
                      ? Icons.south_west
                      : Icons.north_east,
                  color: r.type == TransactionType.cashIn
                      ? tokens.cashIn
                      : tokens.cashOut,
                ),
                title: Text(
                  '${transactionTypeLabel(l10n, r.type)}'
                  '${r.accountLabel == null ? '' : ' · ${r.accountLabel}'}',
                ),
                subtitle: r.customerNumber == null
                    ? null
                    : Text(r.customerNumber!),
                trailing: Text(
                  money.format(r.amount),
                  style: theme.textTheme.titleMedium,
                ),
              ),
        ],
      ),
    );
  }
}

/// No backup yet, or the last one is more than a week old.
bool _backupStale(int? lastMs) {
  if (lastMs == null) return true;
  final age = DateTime.now().toUtc().millisecondsSinceEpoch - lastMs;
  return age > const Duration(days: 7).inMilliseconds;
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}
