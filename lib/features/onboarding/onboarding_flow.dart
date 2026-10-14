import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../backup/restore_flow.dart';
import '../commission/commission_rates_screen.dart' show transactionTypeLabel;
import '../commission/commission_rule.dart';
import '../commission/rate_row.dart';
import 'onboarding_service.dart';
import 'provider_catalog.dart';

enum _Step { welcome, providers, balances, rates, shop }

/// First-run setup: language, wallets and operators, opening balances,
/// commission rates, shop name. The PIN comes right after (lock gate).
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  _Step _step = _Step.welcome;
  final Set<String> _selected = {...ProviderCatalog.quickStartIds};
  final TextEditingController _cash = TextEditingController();
  final Map<String, TextEditingController> _openings = {};
  final TextEditingController _shop = TextEditingController();
  final Map<(String, TransactionType), RateInput> _rates = {};
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _cash.dispose();
    _shop.dispose();
    for (final c in _openings.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<ProviderInfo> get _chosen => [
    for (final p in ProviderCatalog.all)
      if (_selected.contains(p.id)) p,
  ];

  Money? _parse(String text) {
    final t = DigitFormatter.toLatin(text).replaceAll(',', '').trim();
    if (t.isEmpty) return Money.zero;
    return Money.tryParse(t);
  }

  bool get _balancesValid =>
      _parse(_cash.text) != null &&
      _chosen.every((p) => _parse(_openings[p.id]?.text ?? '') != null);

  bool get _ratesValid => _rates.values.every((r) => r.problem == null);

  void _setLanguage(String code) {
    ref
        .read(preferencesProvider.notifier)
        .update(
          (p) => p.copyWith(
            languageCode: code,
            digitStyle: code == 'bn' ? DigitStyle.bangla : DigitStyle.latin,
          ),
        );
  }

  void _ensureRateInputs() {
    for (final p in _chosen) {
      for (final type in p.rateTypes) {
        final sample = p.sampleRates.where((s) => s.type == type).firstOrNull;
        _rates.putIfAbsent(
          (p.id, type),
          () => RateInput(
            mode: sample?.mode ?? CommissionMode.perThousand,
            value: sample?.value ?? 0,
          ),
        );
      }
    }
    _rates.removeWhere((k, _) => !_selected.contains(k.$1));
  }

  Future<void> _finish({required bool quick}) async {
    final l10n = AppLocalizations.of(context);
    final lang = ref.read(preferencesProvider).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final providers = quick
          ? [
              for (final id in ProviderCatalog.quickStartIds)
                ProviderCatalog.byId(id)!,
            ]
          : _chosen;
      final plan = OnboardingPlan(
        cashLabel: l10n.homeCash,
        openingCash: quick ? Money.zero : _parse(_cash.text) ?? Money.zero,
        shopName: quick ? '' : _shop.text,
        accounts: [
          for (final p in providers)
            AccountSetup(
              providerId: p.id,
              label: p.name(lang),
              opening: quick
                  ? Money.zero
                  : _parse(_openings[p.id]?.text ?? '') ?? Money.zero,
            ),
        ],
        rates: [
          for (final p in providers)
            for (final type in p.rateTypes)
              if (quick)
                for (final s in p.sampleRates.where((s) => s.type == type))
                  RateSetup(p.id, type, s.mode, s.value)
              else if (_rates[(p.id, type)] case final input?)
                if (input.mode == CommissionMode.tiered)
                  RateSetup(
                    p.id,
                    type,
                    input.mode,
                    0,
                    tiers: input.tiersParsed ?? const [],
                  )
                else if ((input.value ?? 0) > 0)
                  RateSetup(p.id, type, input.mode, input.value!),
        ],
        expenseCategories: [
          l10n.catRent,
          l10n.catElectricity,
          l10n.catTransport,
          l10n.catStaffPay,
          l10n.catTea,
          l10n.catOther,
        ],
      );
      await ref.read(onboardingServiceProvider).apply(plan);
      await ref.read(onboardingDoneProvider.notifier).complete();
    } on Object catch (e, st) {
      // Keep the cause: it goes to the local crash log and the debug console.
      debugPrint('Onboarding failed: $e\n$st');
      ref.read(crashLogProvider)?.record(e, st);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.onbError;
        });
      }
    }
  }

  void _go(_Step step) {
    if (step == _Step.rates) _ensureRateInputs();
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider);
    final lang = prefs.languageCode;
    final theme = Theme.of(context);

    Widget scaffold({
      required String title,
      String? subtitle,
      required List<Widget> children,
      required Widget bottom,
    }) => Scaffold(
      appBar: AppBar(title: Text(l10n.appName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(title, style: theme.textTheme.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle, style: theme.textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 16),
                  ...children,
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: bottom),
          ],
        ),
      ),
    );

    Widget navRow({
      required VoidCallback? onNext,
      required _Step back,
      String? nextLabel,
    }) => Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _busy ? null : () => _go(back),
            child: Text(l10n.back),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: _busy ? null : onNext,
            child: Text(nextLabel ?? l10n.next),
          ),
        ),
      ],
    );

    switch (_step) {
      case _Step.welcome:
        return scaffold(
          title: l10n.onbWelcomeTitle,
          subtitle: l10n.onbWelcomeBody,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'bn', label: Text('বাংলা')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {lang},
              onSelectionChanged: (s) => _setLanguage(s.first),
            ),
          ],
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('onb-quick'),
                  onPressed: _busy ? null : () => _finish(quick: true),
                  child: Text(_busy ? l10n.onbSaving : l10n.onbQuickStart),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const ValueKey('onb-restore'),
                  onPressed: _busy ? null : () => runRestoreFlow(context, ref),
                  child: Text(l10n.onbRestore),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const ValueKey('onb-step'),
                  onPressed: _busy ? null : () => _go(_Step.providers),
                  child: Text(l10n.onbStepByStep),
                ),
              ),
            ],
          ),
        );

      case _Step.providers:
        Widget group(String title, List<ProviderInfo> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            for (final p in items)
              CheckboxListTile(
                value: _selected.contains(p.id),
                title: Text(p.name(lang)),
                onChanged: (v) => setState(
                  () =>
                      v == true ? _selected.add(p.id) : _selected.remove(p.id),
                ),
              ),
            const SizedBox(height: 12),
          ],
        );
        return scaffold(
          title: l10n.onbProvidersTitle,
          subtitle: l10n.onbProvidersSubtitle,
          children: [
            group(l10n.onbProvidersTitle, ProviderCatalog.wallets),
            group(l10n.onbOperatorsTitle, ProviderCatalog.operators),
          ],
          bottom: navRow(
            back: _Step.welcome,
            onNext: () => _go(_Step.balances),
          ),
        );

      case _Step.balances:
        Widget field(String label, TextEditingController c, {Key? key}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                key: key,
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  prefixText: '৳ ',
                  errorText: _parse(c.text) == null ? l10n.amountInvalid : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            );
        return scaffold(
          title: l10n.onbBalancesTitle,
          subtitle: l10n.onbBalancesSubtitle,
          children: [
            field(l10n.onbCashLabel, _cash, key: const ValueKey('open-cash')),
            for (final p in _chosen)
              field(
                p.name(lang),
                _openings.putIfAbsent(p.id, TextEditingController.new),
                key: ValueKey('open-${p.id}'),
              ),
          ],
          bottom: navRow(
            back: _Step.providers,
            onNext: _balancesValid ? () => _go(_Step.rates) : null,
          ),
        );

      case _Step.rates:
        return scaffold(
          title: l10n.onbRatesTitle,
          subtitle: l10n.onbRatesNotice,
          children: [
            for (final e in _rates.entries)
              RateRow(
                key: ValueKey('rate-${e.key.$1}-${e.key.$2.dbName}'),
                title:
                    '${ProviderCatalog.byId(e.key.$1)!.name(lang)} · '
                    '${transactionTypeLabel(l10n, e.key.$2)}',
                input: e.value,
                onChanged: () => setState(() {}),
              ),
          ],
          bottom: navRow(
            back: _Step.balances,
            onNext: _ratesValid ? () => _go(_Step.shop) : null,
          ),
        );

      case _Step.shop:
        return scaffold(
          title: l10n.onbShopTitle,
          children: [
            TextField(
              controller: _shop,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: l10n.onbShopHint),
            ),
          ],
          bottom: navRow(
            back: _Step.rates,
            nextLabel: _busy ? l10n.onbSaving : l10n.onbFinish,
            onNext: () => _finish(quick: false),
          ),
        );
    }
  }
}
