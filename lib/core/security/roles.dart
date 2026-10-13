/// Who is using the app right now and what they may do.
enum UserRole {
  owner,
  staff;

  static UserRole fromDb(String v) =>
      UserRole.values.firstWhere((r) => r.name == v, orElse: () => staff);
}

/// Id of the built-in owner user (kept for entries that predate staff
/// accounts, which were all recorded as `owner`).
const kOwnerUserId = 'owner';

class Session {
  const Session({
    required this.id,
    required this.name,
    required this.role,
    this.canSeeProfit = false,
    this.canCloseDay = false,
  });

  /// The shop owner. Everything is allowed.
  static const owner = Session(
    id: kOwnerUserId,
    name: 'Owner',
    role: UserRole.owner,
    canSeeProfit: true,
    canCloseDay: true,
  );

  final String id;
  final String name;
  final UserRole role;
  final bool canSeeProfit;
  final bool canCloseDay;

  bool get isOwner => role == UserRole.owner;
}

enum Permission {
  /// Record transactions.
  addEntry,

  /// See commission, margin and profit figures and the Reports tab.
  viewProfit,

  /// Void or edit entries made by other users.
  modifyOthersEntries,

  /// See entries made by other users.
  viewAllHistory,

  /// Close a business day.
  closeDay,

  /// Reopen a closed day.
  reopenDay,

  /// Manual balance adjustments.
  adjustBalance,

  /// Commission rates, accounts, categories, thresholds, reminders.
  manageSettings,

  /// Create and edit staff accounts.
  manageStaff,

  /// Create and restore backups.
  backup,
}

class Permissions {
  const Permissions._();

  static bool can(Session s, Permission p) {
    if (s.isOwner) return true;
    return switch (p) {
      Permission.addEntry => true,
      Permission.viewProfit => s.canSeeProfit,
      Permission.closeDay => s.canCloseDay,
      Permission.modifyOthersEntries ||
      Permission.viewAllHistory ||
      Permission.reopenDay ||
      Permission.adjustBalance ||
      Permission.manageSettings ||
      Permission.manageStaff ||
      Permission.backup => false,
    };
  }
}

/// Thrown by services when the current user lacks a permission.
class PermissionDenied implements Exception {
  const PermissionDenied(this.permission);

  final Permission permission;

  @override
  String toString() => 'PermissionDenied(${permission.name})';
}

/// Supplies the current user to services. Services that are given no reader
/// behave as the owner (single-user mode, scripts and tests).
typedef SessionReader = Session Function();

Session ownerSession() => Session.owner;

/// Throws [PermissionDenied] unless the current user (the owner, when no
/// [reader] is supplied) holds [permission].
void requirePermission(SessionReader? reader, Permission permission) {
  final session = reader == null ? Session.owner : reader();
  if (!Permissions.can(session, permission)) {
    throw PermissionDenied(permission);
  }
}

Session currentSession(SessionReader? reader) =>
    reader == null ? Session.owner : reader();
