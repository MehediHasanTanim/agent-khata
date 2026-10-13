import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/digit_formatter.dart';
import '../../core/providers.dart';
import '../../core/security/roles.dart';
import '../../l10n/gen/app_localizations.dart';
import 'staff_service.dart';

/// Owner-only: add staff, set their PIN and what they may see or do.
class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ref.watch(staffListProvider).value ?? const [];
    final staff = [
      for (final m in all)
        if (m.role == UserRole.staff) m,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.staffTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-staff'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.staffAdd),
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute(builder: (_) => const StaffFormScreen()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.staffInfo, style: theme.textTheme.bodyLarge),
          ),
          if (staff.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.staffEmpty)),
            ),
          for (final m in staff)
            ListTile(
              key: ValueKey('staff-${m.id}'),
              leading: Icon(
                m.isActive ? Icons.person_outline : Icons.person_off_outlined,
              ),
              title: Text(m.name),
              subtitle: Text(
                [
                  if (!m.isActive) l10n.staffInactive,
                  if (m.canSeeProfit) l10n.staffCanSeeProfit,
                  if (m.canCloseDay) l10n.staffCanCloseDay,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(builder: (_) => StaffFormScreen(member: m)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Create (no [member]) or edit a staff account.
class StaffFormScreen extends ConsumerStatefulWidget {
  const StaffFormScreen({super.key, this.member});

  final StaffMember? member;

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.member?.name ?? '',
  );
  final TextEditingController _pin = TextEditingController();
  late bool _canSeeProfit = widget.member?.canSeeProfit ?? false;
  late bool _canCloseDay = widget.member?.canCloseDay ?? false;
  late bool _active = widget.member?.isActive ?? true;
  String? _error;
  bool _busy = false;

  bool get _isNew => widget.member == null;

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  String _message(AppLocalizations l10n, StaffException e) => switch (e.code) {
    'bad_pin' => l10n.staffBadPin,
    'pin_in_use' => l10n.staffPinInUse,
    'name_required' => l10n.staffNameRequired,
    _ => l10n.duesFailed,
  };

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(staffServiceProvider);
    final pin = DigitFormatter.toLatin(_pin.text).trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_isNew) {
        await service.create(
          name: _name.text,
          pin: pin,
          canSeeProfit: _canSeeProfit,
          canCloseDay: _canCloseDay,
        );
      } else {
        await service.update(
          widget.member!.id,
          name: _name.text,
          canSeeProfit: _canSeeProfit,
          canCloseDay: _canCloseDay,
          isActive: _active,
        );
        if (pin.isNotEmpty) await service.resetPin(widget.member!.id, pin);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.staffSaved)));
      Navigator.of(context).pop();
    } on StaffException catch (e) {
      setState(() {
        _busy = false;
        _error = _message(l10n, e);
      });
    } on PermissionDenied {
      setState(() {
        _busy = false;
        _error = l10n.permDenied;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canSave =
        !_busy &&
        _name.text.trim().isNotEmpty &&
        (!_isNew || _pin.text.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l10n.staffAdd : widget.member!.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('staff-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.staffName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('staff-pin'),
            controller: _pin,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: _isNew ? l10n.staffPin : l10n.staffResetPin,
              helperText: _isNew ? null : l10n.staffPin,
            ),
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            value: _canSeeProfit,
            title: Text(l10n.staffCanSeeProfit),
            onChanged: (v) => setState(() => _canSeeProfit = v),
          ),
          SwitchListTile(
            value: _canCloseDay,
            title: Text(l10n.staffCanCloseDay),
            onChanged: (v) => setState(() => _canCloseDay = v),
          ),
          if (!_isNew)
            SwitchListTile(
              value: _active,
              title: Text(l10n.staffActivate),
              onChanged: (v) => setState(() => _active = v),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('staff-save'),
            onPressed: canSave ? _save : null,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
