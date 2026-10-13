import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/security/pin_service.dart';
import '../../core/security/roles.dart';
import '../../core/utils/uuid_v7.dart';

class StaffException implements Exception {
  const StaffException(this.code);

  /// `name_required`, `bad_pin`, `pin_in_use`, `not_found`.
  final String code;

  @override
  String toString() => 'StaffException($code)';
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.canSeeProfit,
    required this.canCloseDay,
    required this.isActive,
    required this.hasPin,
  });

  final String id;
  final String name;
  final UserRole role;
  final bool canSeeProfit;
  final bool canCloseDay;
  final bool isActive;
  final bool hasPin;

  Session toSession() => Session(
    id: id,
    name: name,
    role: role,
    canSeeProfit: canSeeProfit,
    canCloseDay: canCloseDay,
  );
}

/// Staff accounts. The owner's PIN stays in secure storage (PinService);
/// staff PINs are salted hashes in `app_user`.
class StaffService {
  StaffService({
    required this._db,
    required this._pins,
    required this._ids,
    DateTime Function()? clock,
    this._session,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final PinService _pins;
  final IdGenerator _ids;
  final DateTime Function() _clock;
  final SessionReader? _session;

  static StaffMember _member(AppUserRow r) => StaffMember(
    id: r.id,
    name: r.name,
    role: UserRole.fromDb(r.role),
    canSeeProfit: r.canSeeProfit,
    canCloseDay: r.canCloseDay,
    isActive: r.isActive,
    hasPin: r.pinHash != null,
  );

  /// Makes sure the built-in owner row exists. Idempotent.
  Future<void> ensureOwner({String name = 'Owner'}) async {
    await _db
        .into(_db.appUsers)
        .insert(
          AppUsersCompanion.insert(
            id: kOwnerUserId,
            name: name,
            role: UserRole.owner.name,
            canSeeProfit: const Value(true),
            canCloseDay: const Value(true),
            createdAt: Value(_clock().toUtc().millisecondsSinceEpoch),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<String> create({
    required String name,
    required String pin,
    bool canSeeProfit = false,
    bool canCloseDay = false,
  }) async {
    requirePermission(_session, Permission.manageStaff);
    final clean = name.trim();
    if (clean.isEmpty) throw const StaffException('name_required');
    await _checkPin(pin);
    final id = _ids.next();
    await _db
        .into(_db.appUsers)
        .insert(
          AppUsersCompanion.insert(
            id: id,
            name: clean,
            role: UserRole.staff.name,
            pinHash: Value(await _pins.hashPin(pin)),
            canSeeProfit: Value(canSeeProfit),
            canCloseDay: Value(canCloseDay),
            createdAt: Value(_clock().toUtc().millisecondsSinceEpoch),
          ),
        );
    return id;
  }

  Future<void> update(
    String id, {
    String? name,
    bool? canSeeProfit,
    bool? canCloseDay,
    bool? isActive,
  }) async {
    requirePermission(_session, Permission.manageStaff);
    if (id == kOwnerUserId) throw const StaffException('not_found');
    if (name != null && name.trim().isEmpty) {
      throw const StaffException('name_required');
    }
    final n = await (_db.update(_db.appUsers)..where((t) => t.id.equals(id)))
        .write(
          AppUsersCompanion(
            name: name == null ? const Value.absent() : Value(name.trim()),
            canSeeProfit: canSeeProfit == null
                ? const Value.absent()
                : Value(canSeeProfit),
            canCloseDay: canCloseDay == null
                ? const Value.absent()
                : Value(canCloseDay),
            isActive: isActive == null ? const Value.absent() : Value(isActive),
          ),
        );
    if (n == 0) throw const StaffException('not_found');
  }

  Future<void> resetPin(String id, String pin) async {
    requirePermission(_session, Permission.manageStaff);
    if (id == kOwnerUserId) throw const StaffException('not_found');
    await _checkPin(pin, exceptUserId: id);
    final n = await (_db.update(_db.appUsers)..where((t) => t.id.equals(id)))
        .write(AppUsersCompanion(pinHash: Value(await _pins.hashPin(pin))));
    if (n == 0) throw const StaffException('not_found');
  }

  /// A staff PIN must be valid and unlike the owner's and everyone else's.
  Future<void> _checkPin(String pin, {String? exceptUserId}) async {
    if (!PinService.isValidFormat(pin)) throw const StaffException('bad_pin');
    if (await _pins.matchesOwnerPin(pin)) {
      throw const StaffException('pin_in_use');
    }
    final others = await (_db.select(
      _db.appUsers,
    )..where((t) => t.pinHash.isNotNull())).get();
    for (final u in others) {
      if (u.id == exceptUserId) continue;
      if (await _pins.verifyHash(pin, u.pinHash!)) {
        throw const StaffException('pin_in_use');
      }
    }
  }

  /// Everyone, owner first.
  Stream<List<StaffMember>> watchAll() =>
      (_db.select(_db.appUsers)..orderBy([
            (t) => OrderingTerm.asc(t.role), // 'owner' < 'staff'
            (t) => OrderingTerm.asc(t.createdAt),
            (t) => OrderingTerm.asc(t.name),
          ]))
          .watch()
          .map((rows) => rows.map(_member).toList());

  Future<List<StaffMember>> activeStaff() async =>
      (await (_db.select(
                _db.appUsers,
              )..where((t) => t.role.equals('staff') & t.isActive.equals(true)))
              .get())
          .map(_member)
          .toList();

  Future<StaffMember?> byId(String id) async {
    final row = await (_db.select(
      _db.appUsers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _member(row);
  }

  /// Stored PIN hash for login (staff only).
  Future<String?> pinHashOf(String id) async {
    final row =
        await (_db.select(_db.appUsers)
              ..where((t) => t.id.equals(id) & t.isActive.equals(true)))
            .getSingleOrNull();
    return row?.pinHash;
  }
}
