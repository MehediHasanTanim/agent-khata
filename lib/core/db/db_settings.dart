import 'app_database.dart';

/// Typed access to the key-value `setting` table.
class DbSettings {
  DbSettings(this._db);

  final AppDatabase _db;

  static const dayRolloverHourKey = 'day_rollover_hour';
  static const defaultRolloverHour = 4;

  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<int> dayRolloverHour() async {
    final raw = await get(dayRolloverHourKey);
    final hour = int.tryParse(raw ?? '');
    return (hour != null && hour >= 0 && hour < 24)
        ? hour
        : defaultRolloverHour;
  }
}
