import 'package:flutter/material.dart';

/// Bars above/below a zero line; positive and negative values get their own
/// colours, and the highest magnitude fills the height.
class SignedBarChart extends StatelessWidget {
  const SignedBarChart({
    super.key,
    required this.values,
    required this.positive,
    required this.negative,
    this.height = 120,
    this.semanticsLabel,
    this.xLabels = const [],
  });

  final List<double> values;
  final Color positive;
  final Color negative;
  final double height;
  final String? semanticsLabel;

  /// One label per bar (same length as [values]); only some are drawn so
  /// they never overlap. Empty = no labels.
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).colorScheme.outline;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarPainter(
            values,
            positive,
            negative,
            line,
            xLabels,
            Theme.of(context).textTheme.bodySmall?.color ?? line,
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(
    this.values,
    this.positive,
    this.negative,
    this.line,
    this.xLabels,
    this.labelColor,
  );

  final List<double> values;
  final Color positive;
  final Color negative;
  final Color line;
  final List<String> xLabels;
  final Color labelColor;

  static const double _labelBand = 18;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final hasLabels = xLabels.length == values.length;
    final plotHeight = hasLabels ? size.height - _labelBand : size.height;
    final maxUp = values.fold<double>(0, (m, v) => v > m ? v : m);
    final maxDown = values.fold<double>(0, (m, v) => -v > m ? -v : m);
    final range = maxUp + maxDown;
    final zeroY = range == 0 ? plotHeight / 2 : plotHeight * (maxUp / range);
    final scale = range == 0 ? 0.0 : plotHeight / range;

    final slot = size.width / values.length;
    final barWidth = (slot * 0.62).clamp(2.0, 28.0);
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v == 0) continue;
      final h = (v.abs() * scale).clamp(2.0, plotHeight);
      final x = slot * i + (slot - barWidth) / 2;
      final rect = v > 0
          ? Rect.fromLTWH(x, zeroY - h, barWidth, h)
          : Rect.fromLTWH(x, zeroY, barWidth, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()..color = v > 0 ? positive : negative,
      );
    }
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      Paint()
        ..color = line
        ..strokeWidth = 1,
    );

    if (hasLabels) {
      // At most ~6 labels, always including the first and the last bar.
      final step = (values.length / 6).ceil().clamp(1, values.length);
      final shown = <int>{
        for (var i = 0; i < values.length; i += step) i,
        values.length - 1,
      };
      // Drop a second-to-last label that would touch the last one.
      if (values.length > 1 && shown.contains(values.length - 2)) {
        final gap = (values.length - 1) % step;
        if (gap != 0 && gap < step / 2 + 0.5) shown.remove(values.length - 2);
      }
      for (final i in shown) {
        final tp = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: TextStyle(fontSize: 11, color: labelColor),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final center = slot * i + slot / 2;
        final x = (center - tp.width / 2).clamp(
          0.0,
          (size.width - tp.width).clamp(0.0, size.width),
        );
        tp.paint(canvas, Offset(x, size.height - _labelBand + 3));
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.values != values ||
      old.positive != positive ||
      old.negative != negative ||
      old.xLabels != xLabels;
}
