import 'dart:convert';
import 'dart:io';

/// Anonymous, opt-in usage events.
///
/// Only event names and a small allow-list of numeric/boolean parameters are
/// accepted. Amounts, phone numbers, names and notes can never be recorded
/// because they are not in the allow-list. Events stay on the device (a JSON
/// lines file) until the user chooses to share a diagnostics report; a
/// remote sink can be added later behind [AnalyticsSink].
abstract class AnalyticsSink {
  Future<void> log(String event, Map<String, Object> params);
}

class NoopAnalytics implements AnalyticsSink {
  const NoopAnalytics();

  @override
  Future<void> log(String event, Map<String, Object> params) async {}
}

class LocalFileAnalytics implements AnalyticsSink {
  LocalFileAnalytics(this._file, {required this.enabled});

  final File _file;
  final bool Function() enabled;

  static const allowedEvents = {
    'txn_saved',
    'day_closed',
    'variance_nonzero',
    'entry_time_ms',
    'backup_created',
    'restore_done',
  };
  static const allowedParams = {'type', 'count', 'ms', 'ok'};

  @override
  Future<void> log(String event, Map<String, Object> params) async {
    if (!enabled() || !allowedEvents.contains(event)) return;
    final safe = <String, Object>{
      for (final e in params.entries)
        if (allowedParams.contains(e.key) &&
            (e.value is num || e.value is bool || e.value is String))
          e.key: e.value,
    };
    final line = jsonEncode({
      'at': DateTime.now().toUtc().toIso8601String(),
      'event': event,
      if (safe.isNotEmpty) 'params': safe,
    });
    try {
      await _file.writeAsString('$line\n', mode: FileMode.append);
    } on Object {
      // Telemetry must never break the app.
    }
  }

  /// Event name -> count, from the local log.
  Future<Map<String, int>> counts() async {
    final out = <String, int>{};
    try {
      if (!await _file.exists()) return out;
      for (final line in await _file.readAsLines()) {
        final e = (jsonDecode(line) as Map)['event'] as String?;
        if (e != null) out[e] = (out[e] ?? 0) + 1;
      }
    } on Object {
      // ignore
    }
    return out;
  }
}
