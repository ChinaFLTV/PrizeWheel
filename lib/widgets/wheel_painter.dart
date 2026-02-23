import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_model.dart';

class WheelPainter extends CustomPainter {
  final List<WheelSegment> segments;
  final double rotation;
  final WheelStyle style;
  final WheelForm form;

  WheelPainter({
    required this.segments,
    this.rotation = 0,
    this.style = WheelStyle.classic,
    this.form = WheelForm.standard,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    final totalRatio = segments.fold<double>(0, (sum, s) => sum + s.ratio);
    if (totalRatio <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    double startAngle = -pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = (segment.ratio / totalRatio) * 2 * pi;

      _drawSegment(canvas, center, radius, startAngle, sweepAngle, segment, i);
      _drawSegmentBorder(canvas, center, radius, startAngle, sweepAngle);
      _drawSegmentText(canvas, center, radius, startAngle, sweepAngle, segment);

      startAngle += sweepAngle;
    }

    canvas.restore();

    // Center circle
    final centerRadius = radius * 0.12;
    canvas.drawCircle(center, centerRadius, Paint()
      ..color = _centerFillColor
      ..style = PaintingStyle.fill);
    canvas.drawCircle(center, centerRadius, Paint()
      ..color = _centerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Outer ring
    canvas.drawCircle(center, radius, Paint()
      ..color = _outerRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);

    // Decorative dots for candy/retro/rainbow styles
    if (style == WheelStyle.candy || style == WheelStyle.retro || style == WheelStyle.rainbow) {
      _drawOuterDots(canvas, center, radius);
    }
  }

  void _drawSegment(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, WheelSegment segment, int index) {
    final paint = Paint()..style = PaintingStyle.fill;

    switch (style) {
      case WheelStyle.neon:
        paint.shader = RadialGradient(
          colors: [segment.color.withAlpha(200), segment.color],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.gradient:
        paint.shader = SweepGradient(
          startAngle: startAngle + pi / 2,
          endAngle: startAngle + sweepAngle + pi / 2,
          colors: [segment.color, _lighten(segment.color, 0.3)],
          tileMode: TileMode.clamp,
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.sunset:
        paint.shader = RadialGradient(
          colors: [_lighten(segment.color, 0.2), segment.color, _darken(segment.color, 0.2)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.ocean:
        paint.shader = RadialGradient(
          center: Alignment.topCenter,
          colors: [_lighten(segment.color, 0.4), segment.color],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.metallic:
        paint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _lighten(segment.color, 0.35),
            segment.color,
            _darken(segment.color, 0.15),
            _lighten(segment.color, 0.2),
            _darken(segment.color, 0.25),
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.pastel:
        paint.color = _lighten(segment.color, 0.3).withAlpha(220);
      case WheelStyle.dark:
        paint.color = _darken(segment.color, 0.35);
      case WheelStyle.rainbow:
        final hue = (index / segments.length) * 360;
        paint.shader = RadialGradient(
          colors: [
            HSLColor.fromAHSL(1, hue, 0.8, 0.65).toColor(),
            HSLColor.fromAHSL(1, hue, 0.9, 0.45).toColor(),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      default:
        paint.color = segment.color;
    }

    if (form == WheelForm.standard || form == WheelForm.polygon) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
    } else if (form == WheelForm.petal) {
      final petalRadius = radius * 0.95;
      canvas.drawArc(Rect.fromCircle(center: center, radius: petalRadius), startAngle, sweepAngle, true, paint);
      // Inner petal curve
      final innerPaint = Paint()..color = segment.color.withAlpha(60)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.4), startAngle, sweepAngle, true, innerPaint);
    } else if (form == WheelForm.star) {
      _drawStarSegment(canvas, center, radius, startAngle, sweepAngle, paint);
    }
  }

  void _drawStarSegment(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    final outerR = radius;
    final innerR = radius * 0.7;

    final path = Path()..moveTo(center.dx, center.dy);
    const steps = 20;
    for (int j = 0; j <= steps; j++) {
      final t = j / steps;
      final angle = startAngle + sweepAngle * t;
      final distFromMid = (t - 0.5).abs() * 2;
      final r = innerR + (outerR - innerR) * (1 - distFromMid * 0.3);
      path.lineTo(center.dx + r * cos(angle), center.dy + r * sin(angle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSegmentBorder(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle) {
    final borderPaint = Paint()
      ..color = switch (style) {
        WheelStyle.neon => Colors.white.withAlpha(180),
        WheelStyle.dark => Colors.grey.shade700.withAlpha(150),
        WheelStyle.pastel => Colors.white.withAlpha(120),
        _ => Colors.white.withAlpha(200),
      }
      ..style = PaintingStyle.stroke
      ..strokeWidth = style == WheelStyle.neon ? 1.5 : 2.0;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, borderPaint);
  }

  void _drawSegmentText(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, WheelSegment segment) {
    final textAngle = startAngle + sweepAngle / 2;
    final textRadius = radius * 0.62;
    final textX = center.dx + textRadius * cos(textAngle);
    final textY = center.dy + textRadius * sin(textAngle);

    canvas.save();
    canvas.translate(textX, textY);

    // Rotate text to be readable: flip if on bottom half of wheel
    double labelAngle = textAngle + pi / 2;
    // Normalize to [0, 2pi)
    final normalized = (textAngle % (2 * pi) + 2 * pi) % (2 * pi);
    if (normalized > pi / 2 && normalized < 3 * pi / 2) {
      labelAngle += pi;
    }
    canvas.rotate(labelAngle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: segment.label,
        style: TextStyle(
          color: _getTextColor(segment.color),
          fontSize: _calculateFontSize(radius, segments.length),
          fontWeight: FontWeight.w600,
          shadows: style == WheelStyle.neon
              ? [const Shadow(color: Colors.black54, blurRadius: 4)]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    );
    textPainter.layout(maxWidth: radius * 0.45);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    canvas.restore();
  }

  void _drawOuterDots(Canvas canvas, Offset center, double radius) {
    final dotRadius = radius * 0.025;
    final dotDistance = radius + dotRadius * 2;
    final dotCount = segments.length * 4;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi - pi / 2;
      final x = center.dx + dotDistance * cos(angle);
      final y = center.dy + dotDistance * sin(angle);
      canvas.drawCircle(Offset(x, y), dotRadius, Paint()
        ..color = i % 2 == 0 ? Colors.white : Colors.amber
        ..style = PaintingStyle.fill);
    }
  }

  Color get _centerFillColor => switch (style) {
    WheelStyle.neon => Colors.black87,
    WheelStyle.ocean => const Color(0xFF1A237E),
    WheelStyle.sunset => const Color(0xFF4E342E),
    WheelStyle.metallic => const Color(0xFF37474F),
    WheelStyle.dark => const Color(0xFF212121),
    WheelStyle.rainbow => Colors.white,
    _ => Colors.white,
  };

  Color get _centerBorderColor => switch (style) {
    WheelStyle.neon => Colors.cyanAccent,
    WheelStyle.ocean => Colors.lightBlueAccent,
    WheelStyle.sunset => Colors.orangeAccent,
    WheelStyle.metallic => Colors.grey.shade300,
    WheelStyle.dark => Colors.grey.shade600,
    WheelStyle.rainbow => Colors.deepPurple,
    _ => Colors.grey.shade400,
  };

  Color get _outerRingColor => switch (style) {
    WheelStyle.neon => Colors.cyanAccent.withAlpha(100),
    WheelStyle.ocean => Colors.blue.shade300.withAlpha(150),
    WheelStyle.sunset => Colors.deepOrange.withAlpha(120),
    WheelStyle.retro => Colors.brown.shade300,
    WheelStyle.metallic => Colors.blueGrey.shade200,
    WheelStyle.dark => Colors.grey.shade700,
    WheelStyle.rainbow => Colors.deepPurple.withAlpha(120),
    WheelStyle.pastel => Colors.pink.shade100,
    _ => Colors.grey.shade300,
  };

  Color _getTextColor(Color bgColor) {
    if (style == WheelStyle.dark) return Colors.white;
    if (style == WheelStyle.pastel) return Colors.black87;
    return bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  double _calculateFontSize(double radius, int count) {
    if (count <= 4) return radius * 0.1;
    if (count <= 8) return radius * 0.08;
    return radius * 0.06;
  }

  static Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      rotation != oldDelegate.rotation ||
      segments != oldDelegate.segments ||
      style != oldDelegate.style ||
      form != oldDelegate.form;
}
