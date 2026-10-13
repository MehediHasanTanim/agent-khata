import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'daily_sheet_model.dart';

/// Draws [SheetPage]s as A4 images (150 dpi) with the engine's own text
/// layout, so Bangla and the taka sign print correctly using the phone's
/// fonts. Black and white, laid out like a hand-ruled cash book.
class DailySheetRenderer {
  const DailySheetRenderer();

  static const double pageWidth = 1240;
  static const double pageHeight = 1754;
  static const double _margin = 70;
  static const double _slot = 46;
  static const double _contentWidth = pageWidth - 2 * _margin;

  static const _fonts = ['Noto Sans Bengali', 'Hind Siliguri'];

  // Ledger columns (sum = 1100): time, particulars, in, out, balance.
  static const _ledgerCols = [120.0, 440.0, 170.0, 170.0, 200.0];
  // Wallet columns: name, opening, in, out, expected, actual.
  static const _walletCols = [300.0, 160.0, 160.0, 160.0, 160.0, 160.0];

  Future<List<Uint8List>> render(List<SheetPage> pages) async {
    final out = <Uint8List>[];
    for (final page in pages) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        const Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      );
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, pageWidth, pageHeight),
        Paint()..color = Colors.white,
      );
      _draw(canvas, page);
      final image = await recorder.endRecording().toImage(
        pageWidth.toInt(),
        pageHeight.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      out.add(bytes!.buffer.asUint8List());
    }
    return out;
  }

  void _draw(Canvas canvas, SheetPage page) {
    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    var y = _margin;

    _text(canvas, page.title, _margin, y, _contentWidth, size: 40, bold: true);
    y += 58;
    _text(canvas, page.status, _margin, y, _contentWidth, size: 24);
    y += 52;

    // --- cash ledger ------------------------------------------------------
    y = _table(
      canvas,
      y,
      cols: _ledgerCols,
      header: page.ledgerHeader,
      rows: page.ledgerRows,
      rightFrom: 2,
      line: line,
    );

    // --- final section ----------------------------------------------------
    if (page.hasFinalSection) {
      y += _slot * 0.6;
      _text(
        canvas,
        page.walletsHeading!,
        _margin,
        y,
        _contentWidth,
        size: 28,
        bold: true,
      );
      y += _slot;
      y = _table(
        canvas,
        y,
        cols: _walletCols,
        header: page.walletHeader,
        rows: page.walletRows,
        rightFrom: 1,
        line: line,
      );

      y += _slot * 0.6;
      _text(
        canvas,
        page.summaryHeading!,
        _margin,
        y,
        _contentWidth,
        size: 28,
        bold: true,
      );
      y += _slot;
      for (final (label, value) in page.summary) {
        _text(canvas, label, _margin + 10, y, 560, size: 26);
        _text(
          canvas,
          value,
          _margin + 600,
          y,
          300,
          size: 26,
          align: TextAlign.right,
        );
        canvas.drawLine(
          Offset(_margin, y + _slot - 6),
          Offset(_margin + 900, y + _slot - 6),
          Paint()
            ..color = const Color(0xFFBBBBBB)
            ..strokeWidth = 1,
        );
        y += _slot;
      }

      // Signature lines.
      y += _slot * 1.6;
      var x = _margin;
      for (final label in page.signatures) {
        canvas.drawLine(Offset(x, y), Offset(x + 400, y), line);
        _text(canvas, label, x, y + 8, 400, size: 24);
        x += 560;
      }
    }

    _text(
      canvas,
      page.footer,
      _margin,
      pageHeight - _margin - 28,
      _contentWidth,
      size: 22,
      align: TextAlign.center,
      color: const Color(0xFF444444),
    );
  }

  /// Draws a ruled table; returns the y below it.
  double _table(
    Canvas canvas,
    double top, {
    required List<double> cols,
    required List<String> header,
    required List<SheetRow> rows,
    required int rightFrom,
    required Paint line,
  }) {
    var y = top;
    var x = _margin;

    // Header: a double rule above and below, like a ruled ledger.
    canvas.drawLine(
      Offset(_margin, y),
      Offset(_margin + _contentWidth, y),
      line,
    );
    for (var c = 0; c < cols.length; c++) {
      _text(
        canvas,
        header[c],
        x + 8,
        y + 8,
        cols[c] - 16,
        size: 24,
        bold: true,
        align: c >= rightFrom ? TextAlign.right : TextAlign.left,
      );
      x += cols[c];
    }
    y += _slot;
    canvas.drawLine(
      Offset(_margin, y),
      Offset(_margin + _contentWidth, y),
      line,
    );

    final thin = Paint()
      ..color = const Color(0xFF999999)
      ..strokeWidth = 1;
    for (final row in rows) {
      x = _margin;
      for (var c = 0; c < cols.length; c++) {
        _text(
          canvas,
          row.cells[c],
          x + 8,
          y + 9,
          cols[c] - 16,
          size: 24,
          bold: row.isBold,
          strike: row.isVoid,
          color: row.isVoid ? const Color(0xFF666666) : Colors.black,
          align: c >= rightFrom ? TextAlign.right : TextAlign.left,
        );
        x += cols[c];
      }
      y += _slot;
      canvas.drawLine(
        Offset(_margin, y),
        Offset(_margin + _contentWidth, y),
        row.isBold ? line : thin,
      );
    }

    // Vertical rules.
    x = _margin;
    for (var c = 0; c <= cols.length; c++) {
      canvas.drawLine(Offset(x, top), Offset(x, y), thin);
      if (c < cols.length) x += cols[c];
    }
    return y;
  }

  void _text(
    Canvas canvas,
    String text,
    double x,
    double y,
    double width, {
    double size = 24,
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
