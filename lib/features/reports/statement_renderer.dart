import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One printed row: date, description, in, out, balance.
class StatementRow {
  const StatementRow({
    required this.date,
    required this.description,
    required this.moneyIn,
    required this.moneyOut,
    required this.balance,
    this.isVoid = false,
  });

  final String date;
  final String description;
  final String moneyIn;
  final String moneyOut;
  final String balance;
  final bool isVoid;
}

/// Draws statement pages straight onto a canvas with the engine's text
/// layout. That keeps Bangla (and the taka sign) correct using the phone's
/// own fonts, which a PDF library without an embedded Bangla font cannot do.
class StatementRenderer {
  const StatementRenderer();

  static const double pageWidth = 1240;
  static const double pageHeight = 1754;
  static const double _margin = 70;
  static const double _rowHeight = 46;
  static const int rowsPerPage = 30;

  static const _fonts = ['Noto Sans Bengali', 'Hind Siliguri'];

  /// Returns one PNG per page.
  Future<List<Uint8List>> render({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<StatementRow> rows,
    required String Function(int page, int total) footer,
  }) async {
    final pages = <List<StatementRow>>[];
    for (var i = 0; i < rows.length; i += rowsPerPage) {
      pages.add(
        rows.sublist(
          i,
          i + rowsPerPage > rows.length ? rows.length : i + rowsPerPage,
        ),
      );
    }
    if (pages.isEmpty) pages.add(const []);

    final out = <Uint8List>[];
    for (var p = 0; p < pages.length; p++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        const Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      );
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, pageWidth, pageHeight),
        Paint()..color = Colors.white,
      );
      _page(
        canvas,
        title: title,
        subtitle: subtitle,
        headers: headers,
        rows: pages[p],
        footerText: footer(p + 1, pages.length),
      );
      final image = await recorder.endRecording().toImage(
        pageWidth.toInt(),
        pageHeight.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      out.add(bytes!.buffer.asUint8List());
    }
    return out;
  }

  void _page(
    Canvas canvas, {
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<StatementRow> rows,
    required String footerText,
  }) {
    const contentWidth = pageWidth - 2 * _margin;
    // Column x offsets and widths: date, description, in, out, balance.
    const widths = [190.0, 440.0, 170.0, 170.0, 190.0];
    var y = _margin;

    _text(canvas, title, _margin, y, contentWidth, size: 44, bold: true);
    y += 64;
    _text(canvas, subtitle, _margin, y, contentWidth, size: 28);
    y += 60;

    // Header band.
    canvas.drawRect(
      Rect.fromLTWH(_margin, y, contentWidth, _rowHeight),
      Paint()..color = const Color(0xFFE6EBE8),
    );
    var x = _margin;
    for (var c = 0; c < 5; c++) {
      _text(
        canvas,
        headers[c],
        x + 10,
        y + 6,
        widths[c] - 20,
        size: 26,
        bold: true,
        align: c >= 2 ? TextAlign.right : TextAlign.left,
      );
      x += widths[c];
    }
    y += _rowHeight;

    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      if (r.isOdd) {
        canvas.drawRect(
          Rect.fromLTWH(_margin, y, contentWidth, _rowHeight),
          Paint()..color = const Color(0xFFF6F8F7),
        );
      }
      final cells = [
        row.date,
        row.description,
        row.moneyIn,
        row.moneyOut,
        row.balance,
      ];
      x = _margin;
      for (var c = 0; c < 5; c++) {
        _text(
          canvas,
          cells[c],
          x + 10,
          y + 7,
          widths[c] - 20,
          size: 25,
          strike: row.isVoid,
          color: row.isVoid ? const Color(0xFF777777) : Colors.black,
          align: c >= 2 ? TextAlign.right : TextAlign.left,
        );
        x += widths[c];
      }
      y += _rowHeight;
    }

    canvas.drawLine(
      Offset(_margin, y),
      Offset(pageWidth - _margin, y),
      Paint()
        ..color = const Color(0xFF999999)
        ..strokeWidth = 1.5,
    );
    _text(
      canvas,
      footerText,
      _margin,
      pageHeight - _margin - 30,
      contentWidth,
      size: 24,
      align: TextAlign.center,
      color: const Color(0xFF555555),
    );
  }

  void _text(
    Canvas canvas,
    String text,
    double x,
    double y,
    double width, {
    double size = 26,
    bool bold = false,
    bool strike = false,
    Color color = Colors.black,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
          decoration: strike ? TextDecoration.lineThrough : null,
          fontFamilyFallback: _fonts,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, Offset(x, y));
  }
}
