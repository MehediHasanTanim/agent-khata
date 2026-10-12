import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../utils/uuid_v7.dart';

/// Appends rows to `audit_log`. Call inside the same DB transaction as the
/// change it records so the two commit or roll back together.
class AuditLogger {
  AuditLogger(this._db, this._ids, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final IdGenerator _ids;
  final DateTime Function() _clock;

  Future<void> log({
    required String userId,
    required String action,
    required String entity,
    String? entityId,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
    String? reason,
  }) async {
    await _db
        .into(_db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            id: _ids.next(),
            at: _clock().toUtc().millisecondsSinceEpoch,
            userId: userId,
            action: action,
            entity: entity,
            entityId: Value(entityId),
            beforeJson: Value(before == null ? null : jsonEncode(before)),
            afterJson: Value(after == null ? null : jsonEncode(after)),
            reason: Value(reason),
          ),
        );
  }
}
