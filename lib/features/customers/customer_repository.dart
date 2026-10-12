import 'package:drift/drift.dart';

import '../../core/db/app_database.dart';
import '../../core/utils/uuid_v7.dart';

class CustomerSuggestion {
  const CustomerSuggestion({required this.phone, this.name});

  final String phone;
  final String? name;
}

/// Opt-in customer memory. Nothing is imported from the phone's contacts;
/// entries exist only for numbers the agent typed themselves.
class CustomerRepository {
  CustomerRepository(this._db, this._ids, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  /// Returns the id of the customer with [phone], creating it if needed.
  /// A non-empty [name] fills in or replaces the stored name.
  Future<String> upsert({required String phone, String? name}) async {
    final existing = await (_db.select(
      _db.customers,
    )..where((t) => t.phone.equals(phone))).getSingleOrNull();
    final cleanName = (name == null || name.trim().isEmpty)
        ? null
        : name.trim();
    if (existing != null) {
      if (cleanName != null && cleanName != existing.name) {
        await (_db.update(_db.customers)
              ..where((t) => t.id.equals(existing.id)))
            .write(CustomersCompanion(name: Value(cleanName)));
      }
      return existing.id;
    }
    final id = _ids.next();
    await _db
        .into(_db.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            phone: Value(phone),
            name: Value(cleanName),
            createdAt: _clock().toUtc().millisecondsSinceEpoch,
          ),
        );
    return id;
  }

  /// Customers whose phone or name contains [text], most recently used
  /// first.
  Future<List<CustomerSuggestion>> suggest(String text, {int limit = 5}) async {
    final q = text.trim();
    if (q.isEmpty) return const [];
    final like =
        '%${q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows = await _db
        .customSelect(
          r'''
SELECT c.phone, c.name
FROM customer c
LEFT JOIN txn t ON t.customer_id = c.id
WHERE c.phone IS NOT NULL
  AND (c.phone LIKE ? ESCAPE '\' OR c.name LIKE ? ESCAPE '\')
GROUP BY c.id
ORDER BY MAX(COALESCE(t.occurred_at, 0)) DESC, c.created_at DESC
LIMIT ?''',
          variables: [
            Variable.withString(like),
            Variable.withString(like),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.customers, _db.txns},
        )
        .get();
    return [
      for (final r in rows)
        CustomerSuggestion(
          phone: r.read<String>('phone'),
          name: r.readNullable<String>('name'),
        ),
    ];
  }
}
