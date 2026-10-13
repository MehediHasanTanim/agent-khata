import 'package:agentkhata/core/security/roles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const staff = Session(id: 's1', name: 'Rahim', role: UserRole.staff);
  const staffProfit = Session(
    id: 's2',
    name: 'Karim',
    role: UserRole.staff,
    canSeeProfit: true,
  );
  const staffCloser = Session(
    id: 's3',
    name: 'Salma',
    role: UserRole.staff,
    canCloseDay: true,
  );

  test('the owner may do everything', () {
    for (final p in Permission.values) {
      expect(Permissions.can(Session.owner, p), isTrue, reason: p.name);
    }
  });

  test('a plain staff member can only add entries', () {
    for (final p in Permission.values) {
      expect(
        Permissions.can(staff, p),
        p == Permission.addEntry,
        reason: p.name,
      );
    }
  });

  test('profit and day close are separate switches', () {
    expect(Permissions.can(staffProfit, Permission.viewProfit), isTrue);
    expect(Permissions.can(staffProfit, Permission.closeDay), isFalse);
    expect(Permissions.can(staffCloser, Permission.closeDay), isTrue);
    expect(Permissions.can(staffCloser, Permission.viewProfit), isFalse);
  });

  test('staff can never reopen, adjust or manage', () {
    for (final s in [staff, staffProfit, staffCloser]) {
      expect(Permissions.can(s, Permission.reopenDay), isFalse);
      expect(Permissions.can(s, Permission.adjustBalance), isFalse);
      expect(Permissions.can(s, Permission.manageStaff), isFalse);
      expect(Permissions.can(s, Permission.backup), isFalse);
    }
  });

  test('unknown role strings fall back to the least privileged', () {
    expect(UserRole.fromDb('owner'), UserRole.owner);
    expect(UserRole.fromDb('admin'), UserRole.staff);
  });
}
