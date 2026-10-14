import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/khata_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../entry/entry_screen.dart';
import '../transactions/history_queries.dart';
import '../transactions/transaction_repository.dart';
import 'history_widgets.dart';

/// Full details of one entry, with void and edit. Pops `true` when the entry
/// was changed so the caller can refresh.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.txnId});

  final String txnId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  TransactionDetail? _detail;
  bool _loaded = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await ref
        .read(transactionDetailLoaderProvider)
        .load(widget.txnId);
    if (mounted) {
      setState(() {
        _detail = d;
        _loaded = true;
      });
    }
  }

  EntryKind? _editKind(TransactionType t) => switch (t) {
    TransactionType.cashOut => EntryKind.cashOut,
    TransactionType.cashIn => EntryKind.cashIn,
    TransactionType.floatPurchase => EntryKind.floatPurchase,
    TransactionType.expense => EntryKind.expense,
    TransactionType.flexiload => EntryKind.flexiload,
    TransactionType.commissionReceived => EntryKind.commissionReceived,
    _ => null,
  };

  Future<void> _void() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(l10n.detailVoid),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.detailVoidReason),
            onChanged: (_) => setLocal(() {}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.detailVoidConfirm),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    try {
      await ref
          .read(transactionRepositoryProvider)
          .voidTransaction(
            widget.txnId,
            reason: reason,
            userId: currentUserId(ref),
          );
      _changed = true;
      await _load();
    } on DayLockedException {
      _toast(l10n.detailLockedHint);
    } on PermissionDenied {
      _toast(l10n.permDenied);
    } on Object {
      _toast(l10n.detailActionFailed);
    }
  }

  Future<void> _edit(TransactionDetail d, EntryKind kind) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EntryScreen(
          kind: kind,
          edit: EditSeed(
            txnId: d.item.id,
            amount: d.item.amount,
            occurredAt: d.item.occurredAt,
            fromAccountId: d.legs.fromAccountId,
            toAccountId: d.legs.toAccountId,
            customerNumber: d.item.customerNumber,
            reference: d.item.reference,
            note: d.item.note,
            paidPaisa: d.legs.fromPaisa,
          ),
        ),
      ),
    );
    if (result != null) {
      _changed = true;
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  void _toast(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider);
    final money = MoneyFormatter(digits: prefs.digits);
    final labels = DateLabels(
      languageCode: prefs.languageCode,
      digits: prefs.digits,
    );
    final d = _detail;
    final session = ref.watch(sessionProvider);
    final showProfit =
        session != null && Permissions.can(session, Permission.viewProfit);
    final canModify =
        session != null &&
        d != null &&
        (d.createdBy == session.id ||
            Permissions.can(session, Permission.modifyOthersEntries));

    final scheme = theme.colorScheme;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    Widget card(List<Widget> children) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        bottomNavigationBar: const AdFooter(),
        appBar: AppBar(title: Text(l10n.detailTitle)),
        body: !_loaded
            ? const Center(child: CircularProgressIndicator())
            : d == null
            ? Center(child: Text(l10n.histEmpty))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Builder(
                    builder: (context) {
                      final out =
                          directionOf(d.item.type) == FlowDirection.moneyOut;
                      final sign = out
                          ? '− '
                          : directionOf(d.item.type) == FlowDirection.moneyIn
                          ? '+ '
                          : '';
                      return Column(
                        children: [
                          DirectionBubble(
                            icon: iconFor(d.item.type),
                            out: out,
                            muted: d.item.isVoid,
                            size: 56,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$sign${money.format(d.item.amount)}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: d.item.isVoid
                                  ? scheme.onSurfaceVariant
                                  : colorFor(context, d.item.type),
                              decoration: d.item.isVoid
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          Text(
                            transactionTypeLabel(l10n, d.item.type),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (d.item.isVoid || d.item.isLocked)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  if (d.item.isVoid)
                                    Chip(label: Text(l10n.labelVoided)),
                                  if (d.item.isLocked)
                                    Chip(label: Text(l10n.labelLocked)),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (d.item.isVoid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.detailVoidedBecause(d.item.voidReason ?? ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.tokens.cashOut),
                      ),
                    ),
                  const SizedBox(height: 16),
                  card([
                    row(l10n.detailWhen, labels.dateTime(d.item.occurredAt)),
                    row(l10n.detailRecorded, labels.dateTime(d.recordedAt)),
                    row(l10n.detailBy, d.createdBy),
                    if (!d.item.charge.isZero)
                      row(l10n.detailCharge, money.format(d.item.charge)),
                    if (showProfit && !d.item.commission.isZero)
                      row(
                        l10n.detailCommission,
                        money.format(d.item.commission),
                      ),
                    if (showProfit && d.ruleSummary != null)
                      row('', l10n.detailRule(d.ruleSummary!)),
                    if (d.item.customerName != null)
                      row(l10n.entryCustomerName, d.item.customerName!),
                    if (d.item.customerNumber != null)
                      row(l10n.entryCustomerNumber, d.item.customerNumber!),
                    if (d.item.reference != null)
                      row(l10n.entryTrxId, d.item.reference!),
                    if (d.item.note != null) row(l10n.entryNote, d.item.note!),
                  ]),
                  card([
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.detailAccounts,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    for (final e in d.entries)
                      row(
                        e.accountLabel,
                        '${e.delta.isNegative ? '' : '+'}${money.format(e.delta)}',
                      ),
                    if (d.item.replacesTxnId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.detailReplaces),
                      ),
                    if (d.replacedByTxnId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(l10n.detailReplacedBy),
                      ),
                  ]),
                  if (d.audit.isNotEmpty)
                    card([
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          l10n.detailAudit,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      for (final a in d.audit)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scheme.secondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.action,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (a.reason != null) Text(a.reason!),
                                    Text(
                                      labels.dateTime(
                                        DateTime.fromMillisecondsSinceEpoch(
                                          a.at,
                                          isUtc: true,
                                        ),
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ]),
                  if (d.item.isLocked)
                    Text(
                      l10n.detailLockedHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else if (!d.item.isVoid && canModify)
                    Row(
                      children: [
                        if (_editKind(d.item.type) case final kind?) ...[
                          Expanded(
                            child: FilledButton.icon(
                              icon: const Icon(LucideIcons.pencil),
                              label: Text(l10n.detailEdit),
                              onPressed: () => _edit(d, kind),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.tokens.cashOut,
                              side: BorderSide(
                                color: context.tokens.cashOut,
                                width: 2,
                              ),
                            ),
                            icon: const Icon(LucideIcons.ban),
                            label: Text(l10n.detailVoid),
                            onPressed: _void,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
