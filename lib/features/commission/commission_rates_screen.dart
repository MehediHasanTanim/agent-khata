import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ledger/transaction_type.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../onboarding/provider_catalog.dart';
import 'commission_engine.dart';
import 'commission_rule.dart';
import 'rate_row.dart';

String transactionTypeLabel(AppLocalizations l10n, TransactionType t) =>
    switch (t) {
      TransactionType.cashOut => l10n.txnCashOut,
      TransactionType.cashIn => l10n.txnCashIn,
      TransactionType.flexiload => l10n.txnFlexiload,
      TransactionType.floatPurchase => l10n.txnFloatPurchase,
      TransactionType.expense => l10n.txnExpense,
      _ => l10n.txnOther,
    };

/// Edit current commission rates. Saving creates new effective-dated rules;
/// entries saved earlier keep the commission they were saved with.
class CommissionRatesScreen extends ConsumerStatefulWidget {
  const CommissionRatesScreen({super.key});

  @override
  ConsumerState<CommissionRatesScreen> createState() =>
      _CommissionRatesScreenState();
}

class _CommissionRatesScreenState extends ConsumerState<CommissionRatesScreen> {
  final Map<(String, TransactionType), RateInput> _inputs = {};
  bool _saving = false;

  bool get _valid => _inputs.values.every((i) => i.problem == null);

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(commissionRuleRepositoryProvider);
    final now = DateTime.now().toUtc();
    setState(() => _saving = true);
    for (final e in _inputs.entries) {
      await repo.setRate(
        provider: e.key.$1,
        type: e.key.$2,
        mode: e.value.mode,
        value: e.value.value!,
        at: now,
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.rateSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(preferencesProvider).languageCode;
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final rules = ref.watch(commissionRulesProvider).value ?? const [];
    const engine = CommissionEngine();
    final now = DateTime.now().toUtc();

    final providerIds = <String>{
      for (final a in accounts)
        if (a.provider != null) a.provider!,
    };

    final rows = <Widget>[];
    for (final id in providerIds) {
      final info = ProviderCatalog.byId(id);
      if (info == null) continue;
      for (final type in info.rateTypes) {
        final key = (id, type);
        final current = engine.selectRule(
          rules,
          provider: id,
          type: type,
          at: now,
        );
        final input = _inputs.putIfAbsent(
          key,
          () => RateInput(
            mode: current?.mode ?? CommissionMode.perThousand,
            value: current?.value ?? 0,
          ),
        );
        rows.add(
          RateRow(
            key: ValueKey('rate-$id-${type.dbName}'),
            title: '${info.name(lang)} · ${transactionTypeLabel(l10n, type)}',
            input: input,
            onChanged: () => setState(() {}),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commissionRates)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.onbRatesNotice),
          const SizedBox(height: 4),
          Text(
            l10n.rateEffectiveNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ...rows,
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _valid && !_saving ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
