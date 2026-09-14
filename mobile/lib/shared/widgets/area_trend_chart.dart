import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The employee-detail "Time spent / day" chart. Hand-rolled with
/// `CustomPainter` (no charting package - see `SparklineChart`'s note),
/// mirroring the reference mockups' smoothed-area chart with gridlines and
/// x-axis labels.
class AreaTrendChart extends StatelessWidget {
  const AreaTrendChart({super.key, required this.values, required this.labels, this.height = 180});

  final List<double> values;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No data for this range.', style: TextStyle(color: AppColors.ink300, fontSize: 12)),
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _AreaChartPainter(values: values, labels: labels)),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  _AreaChartPainter({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  static const _padLeft = 30.0;
  static const _padRight = 6.0;
  static const _padTop = 10.0;
  static const _padBottom = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRaw = values.reduce((a, b) => a > b ? a : b);
    final maxY = (((maxRaw / 2).ceil()) * 2 + 2).toDouble();
    final plotW = size.width - _padLeft - _padRight;
    final plotH = size.height - _padTop - _padBottom;

    Offset pointAt(int i) {
      final x = _padLeft + (values.length == 1 ? 0 : (i / (values.length - 1)) * plotW);
      final y = _padTop + plotH - (values[i] / maxY) * plotH;
      return Offset(x, y);
    }

    final points = List.generate(values.length, pointAt);

    // Gridlines + y-axis labels.
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const steps = 4;
    final labelStyle = TextStyle(color: AppColors.ink300, fontSize: 10);
    for (var i = 0; i <= steps; i++) {
      final val = (maxY / steps * i).round();
      final y = _padTop + plotH - (val / maxY) * plotH;
      canvas.drawLine(Offset(_padLeft, y), Offset(size.width - _padRight, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$val', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_padLeft - 6 - tp.width, y - tp.height / 2));
    }

    // Smoothed line + filled area (Catmull-Rom-ish via quadratic midpoints).
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      linePath.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, _padTop + plotH)
      ..lineTo(points.first.dx, _padTop + plotH)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.violet500.withValues(alpha: 0.28), AppColors.violet500.withValues(alpha: 0.02)],
        ).createShader(Rect.fromLTWH(0, _padTop, size.width, plotH)),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.violet500
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // X-axis labels (skip to avoid overlap on dense series).
    final skip = (labels.length / 7).ceil().clamp(1, labels.length);
    for (var i = 0; i < labels.length; i++) {
      if (i % skip != 0 && i != labels.length - 1) continue;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(points[i].dx - tp.width / 2, size.height - _padBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}
