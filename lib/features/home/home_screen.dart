import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/interstitial_policy.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/business_calendar.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../accounts/account_ledger_screen.dart';
import '../backup/backup_screen.dart';
import '../closeday/close_day_screen.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../dues/dues_screen.dart';
import '../entry/entry_providers.dart';
import '../entry/entry_screen.dart';
import '../expenses/recurring_screens.dart';
import '../history/history_widgets.dart';
import '../lock/lock_controller.dart';
import '../shifts/shift_handover_screen.dart';
import '../transactions/transaction_queries.dart';
import 'balance_cards.dart';

/// Staff only see (and total) their own entries.
String? _scopeToUser(Ref ref) {
  final s = ref.watch(sessionProvider);
  if (s == null || Permissions.can(s, Permission.viewAllHistory)) return null;
  return s.id;
}

final _recentProvider = StreamProvider.autoDispose<List<RecentTxn>>(
  (ref) => ref
      .watch(transactionQueriesProvider)
      .watchRecent(createdBy: _scopeToUser(ref)),
);

final _todayProvider = StreamProvider.autoDispose<DaySummary>((ref) {
  final hour = ref.watch(dayRolloverHourProvider).value ?? 4;
  final range = BusinessCalendar(rolloverHour: hour)
      .dayRange(DateTime.now().toUtc());
  return ref
      .watch(transactionQueriesProvider)
      .watchSummary(range.start, range.end, createdBy: _scopeToUser(ref));
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<String> _revealed = {};

  Future<void> _open(EntryKind kind, {EntryPrefill? prefill}) async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntryScreen(kind: kind, prefill: prefill),
      ),
    );
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
                  .voidTransaction(
                    id,
                    reason: 'undo',
                    userId: currentUserId(ref),
                  );
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
    final session = ref.watch(sessionProvider);
    final showProfit =
        session != null && Permissions.can(session, Permission.viewProfit);
    final names = ref.watch(userNamesProvider);
    final shift = ref.watch(openShiftProvider).value;
    final regulars = ref.watch(regularsProvider(null)).value ?? const [];
    final recurringDue = ref.watch(recurringDueProvider).value ?? const [];

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

    Widget tile({
      required Key key,
      required String label,
      required IconData icon,
      required Color bg,
      required Color fg,
      required VoidCallback onPressed,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            key: key,
            borderRadius: BorderRadius.circular(28),
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      child: Icon(icon, color: fg, size: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final scheme = theme.colorScheme;
    Widget action(EntryKind kind, String label, IconData icon, Color color) {
      // Direction decides the tint: terracotta out, sage in, sand neutral.
      final out =
          kind == EntryKind.cashOut ||
          kind == EntryKind.expense ||
          kind == EntryKind.floatPurchase;
      final inn = kind == EntryKind.cashIn || kind == EntryKind.flexiload;
      return tile(
        key: ValueKey('action-${kind.name}'),
        label: label,
        icon: icon,
        bg: out
            ? scheme.primaryContainer
            : (inn ? scheme.secondaryContainer : scheme.tertiaryContainer),
        fg: out
            ? scheme.onPrimaryContainer
            : (inn ? scheme.onSecondaryContainer : scheme.onSurface),
        onPressed: () => _open(kind),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          if (session != null)
            TextButton.icon(
              key: const ValueKey('switch-user'),
              icon: const Icon(Icons.person_outline),
              label: Text(
                session.isOwner ? l10n.roleOwner : session.name,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => ref.read(lockControllerProvider.notifier).lock(),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (recurringDue.isNotEmpty)
            NoticeBanner(
              key: const ValueKey('recurring-banner'),
              icon: Icons.event_repeat,
              text: l10n.recDueBanner(
                prefs.digits.localize('${recurringDue.length}'),
              ),
              onTap: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(builder: (_) => const RecurringDueScreen()),
                );
                ref.invalidate(recurringDueProvider);
              },
            ),
          if (shift != null)
            Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: ListTile(
                key: const ValueKey('shift-card'),
                leading: const Icon(Icons.badge_outlined),
                title: Text(
                  l10n.shiftCurrent(
                    shift.userId == kOwnerUserId
                        ? l10n.roleOwner
                        : (names[shift.userId] ?? shift.userName ?? ''),
                  ),
                ),
                subtitle: Text(
                  l10n.shiftSince(
                    DateLabels(
                      languageCode: prefs.languageCode,
                      digits: prefs.digits,
                    ).time(shift.startedAt),
                  ),
                ),
                trailing: FilledButton.tonal(
                  key: const ValueKey('handover'),
                  onPressed: () async {
                    final handedOver = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => const ShiftHandoverScreen(),
                      ),
                    );
                    if (handedOver == true) {
                      // A natural break: the shift just ended.
                      await ref
                          .read(adsServiceProvider)
                          .maybeShowInterstitial(AdTrigger.shiftHandover);
                    }
                  },
                  child: Text(l10n.shiftHandover),
                ),
              ),
            ),
          if (ref.watch(unclosedYesterdayProvider).value case final y?)
            NoticeBanner(
              icon: Icons.fact_check_outlined,
              text: l10n.cdYesterdayOpen,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => CloseDayScreen(businessDate: y),
                ),
              ),
            ),
          if (accounts.isNotEmpty && _backupStale(prefs.lastBackupAtMs))
            NoticeBanner(
              icon: Icons.backup_outlined,
              tone: BannerTone.info,
              text: l10n.bkStaleBanner,
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => const BackupScreen()),
              ),
            ),
          if (lowLabels.isNotEmpty)
            NoticeBanner(
              icon: Icons.warning_amber,
              text: l10n.lowBanner(lowLabels.join(', ')),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Builder(
                      builder: (context) {
                        final c = cards[i];
                        final hidden =
                            prefs.maskBalances && !_revealed.contains(c.id);
                        return BalanceCard(
                          data: c,
                          amountText: hidden
                              ? '৳ ••••'
                              : money.format(c.balance),
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
                  ],
                ],
              ),
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
                    tile(
                      key: const ValueKey('action-dues'),
                      label: l10n.duesTitle,
                      icon: Icons.menu_book_outlined,
                      bg: scheme.tertiaryContainer,
                      fg: scheme.onSurface,
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(builder: (_) => const DuesScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (regulars.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.regularsTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final r in regulars)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        key: ValueKey(
                          'home-regular-${r.number}-${r.type.name}',
                        ),
                        avatar: Icon(
                          r.type == TransactionType.cashIn
                              ? Icons.south_west
                              : r.type == TransactionType.flexiload
                              ? Icons.phone_android
                              : Icons.north_east,
                          size: 18,
                        ),
                        label: Text(
                          '${r.displayName} · ${money.format(r.lastAmount)}',
                        ),
                        onPressed: () => _open(
                          switch (r.type) {
                            TransactionType.cashIn => EntryKind.cashIn,
                            TransactionType.flexiload => EntryKind.flexiload,
                            _ => EntryKind.cashOut,
                          },
                          prefill: EntryPrefill(
                            amount: r.lastAmount,
                            walletId: r.accountId,
                            customerNumber: r.number,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
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
                if (showProfit)
                  _Stat(
                    l10n.homeTodayCommission,
                    money.format(today.commission),
                  ),
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
              KhataTile(
                leading: DirectionBubble(
                  icon: iconFor(r.type),
                  out: directionOf(r.type) == FlowDirection.moneyOut,
                ),
                title: Text(
                  '${transactionTypeLabel(l10n, r.type)}'
                  '${r.accountLabel == null ? '' : ' · ${r.accountLabel}'}',
                ),
                subtitle: r.customerNumber == null
                    ? null
                    : Text(r.customerNumber!),
                trailing: Text(
                  '${directionOf(r.type) == FlowDirection.moneyOut ? '− ' : '+ '}'
                  '${money.format(r.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorFor(context, r.type),
                  ),
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
