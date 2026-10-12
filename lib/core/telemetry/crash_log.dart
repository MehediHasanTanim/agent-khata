import 'dart:io';

import 'package:flutter/foundation.dart';

/// Keeps a small on-device crash log so the user can send it to support.
/// Nothing leaves the phone unless the user shares the diagnostics report.
class CrashLog {
  CrashLog(this._file);

  final File _file;

  static const _maxBytes = 64 * 1024;

  /// Routes Flutter and uncaught async errors into the log (and still prints
  /// them in debug).
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      record(details.exception, details.stack);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      record(error, stack);
      return false;
    };
  }

  void record(Object error, StackTrace? stack) {
    try {
      final text =
          '--- ${DateTime.now().toUtc().toIso8601String()}\n'
          '$error\n${stack ?? ''}\n';
      final existing = _file.existsSync() ? _file.readAsStringSync() : '';
      var all = existing + text;
      if (all.length > _maxBytes) all = all.substring(all.length - _maxBytes);
      _file.writeAsStringSync(all);
    } on Object {
      // Never throw from the error handler.
    }
  }

  String read() {
    try {
      return _file.existsSync() ? _file.readAsStringSync() : '';
    } on Object {
      return '';
    }
  }

  void clear() {
    try {
      if (_file.existsSync()) _file.deleteSync();
    } on Object {
      // ignore
    }
  }
}
