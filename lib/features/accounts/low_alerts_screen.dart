import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/ledger/account.dart';
import '../../core/ledger/account_kind.dart';
import '../../core/money/money.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';

/// Per-account low-balance thresholds. Empty means no alert.
class LowAlertsScreen extends ConsumerStatefulWidget {
  const LowAlertsScreen({super.key});

  @override
  ConsumerState<LowAlertsScreen> createState() => _LowAlertsScreenState();
}

class _LowAlertsScreenState extends ConsumerState<LowAlertsScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(Account a) =>
      _controllers.putIfAbsent(a.id, () {
        final v = a.lowAlert;
        return TextEditingController(text: v == null ? '' : '${v.wholeTaka}');
      });

  Future<void> _save(Account a, String text) async {
    final t = DigitFormatter.toLatin(text).trim();
    final repo = ref.read(accountRepositoryProvider);
    if (t.isEmpty) {
      await repo.setLowAlert(a.id, null);
      return;
    }
    final m = Money.tryParse(t);
    if (m != null) await repo.setLowAlert(a.id, m);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accounts = [
      for (final a in ref.watch(accountsProvider).value ?? const <Account>[])
        if (a.kind != AccountKind.external) a,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lowTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.lowSubtitle),
          const SizedBox(height: 12),
          for (final a in accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _controllerFor(a),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: a.label,
                  prefixText: '৳ ',
                ),
                onChanged: (v) => _save(a, v),
              ),
            ),
        ],
      ),
    );
  }
}
