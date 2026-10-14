import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/transaction_type.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../../core/widgets/khata_widgets.dart';
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
  bool _lastQuick = false;
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
    _lastQuick = quick;
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

    const stepOrder = [
      _Step.providers,
      _Step.balances,
      _Step.rates,
      _Step.shop,
    ];
    final scheme = theme.colorScheme;

    Widget statusView() {
      final failed = _error != null && !_busy;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!failed)
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        color: scheme.secondary,
                        backgroundColor: scheme.secondaryContainer,
                      ),
                    )
                  else
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryContainer,
                      ),
                      child: Text(
                        '!',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    failed ? _error! : l10n.onbSaving,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: failed ? null : 'Caprasimo',
                      fontWeight: failed ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  if (failed) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('onb-retry'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 60),
                      ),
                      onPressed: () => _finish(quick: _lastQuick),
                      child: Text(l10n.onbFinish),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _error = null),
                      child: Text(l10n.back),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_busy || _error != null) return statusView();

    Widget scaffold({
      required String title,
      String? subtitle,
      required List<Widget> children,
      required Widget bottom,
    }) {
      final idx = stepOrder.indexOf(_step);
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  children: [
                    if (idx >= 0)
                      Row(
                        children: [
                          for (var i = 0; i < stepOrder.length; i++)
                            Expanded(
                              child: Container(
                                height: 8,
                                margin: EdgeInsets.only(
                                  right: i == stepOrder.length - 1 ? 0 : 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: i <= idx
                                      ? scheme.primary
                                      : scheme.tertiaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Caprasimo',
                        fontWeight: FontWeight.w400,
                        fontSize: 30,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ...children,
                  ],
                ),
              ),
              Padding(padding: const EdgeInsets.all(16), child: bottom),
            ],
          ),
        ),
      );
    }

    Widget navRow({
      required VoidCallback? onNext,
      required _Step back,
      String? nextLabel,
    }) => Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 60),
              backgroundColor: scheme.tertiaryContainer,
              foregroundColor: scheme.onSurface,
            ),
            onPressed: _busy ? null : () => _go(back),
            child: Text('‹ ${l10n.back}'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 60)),
            onPressed: _busy ? null : onNext,
            child: Text(nextLabel ?? l10n.next),
          ),
        ),
      ],
    );

    switch (_step) {
      case _Step.welcome:
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      child: PillSegmented<String>(
                        value: lang,
                        options: const [('bn', 'বাংলা'), ('en', 'English')],
                        onChanged: _setLanguage,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, bottom: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.secondaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.secondary.withValues(alpha: 0.2),
                              spreadRadius: 18,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.bookOpen,
                          size: 72,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    l10n.onbWelcomeTitle,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontFamily: 'Caprasimo',
                      fontWeight: FontWeight.w400,
                      fontSize: 40,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.onbWelcomeBody,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const ValueKey('onb-quick'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 64),
                    ),
                    onPressed: _busy ? null : () => _finish(quick: true),
                    child: Text(l10n.onbQuickStart),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    key: const ValueKey('onb-step'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 60),
                      backgroundColor: scheme.tertiaryContainer,
                      foregroundColor: scheme.onSurface,
                    ),
                    onPressed: _busy ? null : () => _go(_Step.providers),
                    child: Text(l10n.onbStepByStep),
                  ),
                  TextButton(
                    key: const ValueKey('onb-restore'),
                    onPressed: _busy
                        ? null
                        : () => runRestoreFlow(context, ref),
                    child: Text(l10n.onbRestore),
                  ),
                ],
              ),
            ),
          ),
        );

      case _Step.providers:
        Widget group(String title, List<ProviderInfo> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in items)
                  ChoiceChip(
                    key: ValueKey('provider-${p.id}'),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    selected: _selected.contains(p.id),
                    label: Text(p.name(lang)),
                    onSelected: (v) => setState(
                      () => v ? _selected.add(p.id) : _selected.remove(p.id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
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
