import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_widgets.dart';
import '../../core/i18n/date_labels.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../l10n/gen/app_localizations.dart';
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

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
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
                  TypeLabel(d.item.type),
                  const SizedBox(height: 8),
                  Text(
                    money.format(d.item.amount),
                    style: theme.textTheme.displayMedium?.copyWith(
                      decoration: d.item.isVoid
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (d.item.isVoid)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.detailVoidedBecause(d.item.voidReason ?? ''),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  row(l10n.detailWhen, labels.dateTime(d.item.occurredAt)),
                  row(l10n.detailRecorded, labels.dateTime(d.recordedAt)),
                  row(l10n.detailBy, d.createdBy),
                  if (!d.item.charge.isZero)
                    row(l10n.detailCharge, money.format(d.item.charge)),
                  if (showProfit && !d.item.commission.isZero)
                    row(l10n.detailCommission, money.format(d.item.commission)),
                  if (showProfit && d.ruleSummary != null)
                    row('', l10n.detailRule(d.ruleSummary!)),
                  if (d.item.customerName != null)
                    row(l10n.entryCustomerName, d.item.customerName!),
                  if (d.item.customerNumber != null)
                    row(l10n.entryCustomerNumber, d.item.customerNumber!),
                  if (d.item.reference != null)
                    row(l10n.entryTrxId, d.item.reference!),
                  if (d.item.note != null) row(l10n.entryNote, d.item.note!),
                  const Divider(height: 32),
                  Text(l10n.detailAccounts, style: theme.textTheme.titleMedium),
                  for (final e in d.entries)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.accountLabel),
                      trailing: Text(
                        '${e.delta.isNegative ? '' : '+'}${money.format(e.delta)}',
                      ),
                    ),
                  if (d.item.replacesTxnId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(l10n.detailReplaces),
                    ),
                  if (d.replacedByTxnId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(l10n.detailReplacedBy),
                    ),
                  const Divider(height: 32),
                  Text(l10n.detailAudit, style: theme.textTheme.titleMedium),
                  for (final a in d.audit)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(a.action),
                      subtitle: a.reason == null ? null : Text(a.reason!),
                      trailing: Text(
                        labels.dateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                            a.at,
                            isUtc: true,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (d.item.isLocked)
                    Text(l10n.detailLockedHint)
                  else if (!d.item.isVoid && canModify) ...[
                    if (_editKind(d.item.type) case final kind?)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.detailEdit),
                        onPressed: () => _edit(d, kind),
                      ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      icon: const Icon(Icons.block),
                      label: Text(l10n.detailVoid),
                      onPressed: _void,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
