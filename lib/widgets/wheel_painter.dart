import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_model.dart';

class WheelPainter extends CustomPainter {
  final List<WheelSegment> segments;
  final double rotation;
  final WheelStyle style;
  final WheelForm form;
  final double glowPhase; // 0..1 animated phase for outer glow pulsing

  WheelPainter({
    required this.segments,
    this.rotation = 0,
    this.style = WheelStyle.classic,
    this.form = WheelForm.standard,
    this.glowPhase = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final totalRatio = segments.fold<double>(0, (sum, s) => sum + s.ratio);
    if (totalRatio <= 0) return;

    // Outer glow halo behind the wheel
    _drawOuterGlow(canvas, center, radius);

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
      _drawSegmentInnerHighlight(canvas, center, radius, startAngle, sweepAngle, i);
      _drawSegmentText(canvas, center, radius, startAngle, sweepAngle, segment);

      startAngle += sweepAngle;
    }

    // Radial shine overlay on top of segments
    _drawRadialShine(canvas, center, radius);

    canvas.restore();

    // Outer decorative ring with light bulbs
    _drawOuterRing(canvas, center, radius);
    _drawLightBulbs(canvas, center, radius);

    // Center hub with metallic gradient
    _drawCenterHub(canvas, center, radius);
  }

  void _drawOuterGlow(Canvas canvas, Offset center, double radius) {
    final glowColor = _glowAccentColor;
    final pulseAlpha = (40 + 30 * sin(glowPhase * 2 * pi)).toInt().clamp(0, 255);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withAlpha(pulseAlpha),
          glowColor.withAlpha((pulseAlpha * 0.3).toInt()),
          Colors.transparent,
        ],
        stops: const [0.7, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20));
    canvas.drawCircle(center, radius + 20, glowPaint);
  }

  void _drawSegment(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, WheelSegment segment, int index) {
    final paint = Paint()..style = PaintingStyle.fill;

    switch (style) {
      case WheelStyle.neon:
        paint.shader = RadialGradient(
          colors: [
            _lighten(segment.color, 0.15).withAlpha(220),
            segment.color,
            _darken(segment.color, 0.1),
          ],
          stops: const [0.0, 0.6, 1.0],
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
          colors: [_lighten(segment.color, 0.25), segment.color, _darken(segment.color, 0.2)],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.ocean:
        paint.shader = RadialGradient(
          center: Alignment.topCenter,
          colors: [_lighten(segment.color, 0.4), segment.color, _darken(segment.color, 0.15)],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.metallic:
        paint.shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _lighten(segment.color, 0.4),
            segment.color,
            _darken(segment.color, 0.15),
            _lighten(segment.color, 0.25),
            _darken(segment.color, 0.3),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.pastel:
        paint.color = _lighten(segment.color, 0.3).withAlpha(220);
      case WheelStyle.dark:
        paint.shader = RadialGradient(
          colors: [_darken(segment.color, 0.25), _darken(segment.color, 0.45)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.rainbow:
        final hue = (index / segments.length) * 360;
        paint.shader = RadialGradient(
          colors: [
            HSLColor.fromAHSL(1, hue, 0.85, 0.65).toColor(),
            HSLColor.fromAHSL(1, hue, 0.9, 0.45).toColor(),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.candy:
        // Candy stripe effect
        final c1 = segment.color;
        final c2 = _lighten(segment.color, 0.25);
        paint.shader = SweepGradient(
          startAngle: startAngle + pi / 2,
          endAngle: startAngle + sweepAngle + pi / 2,
          colors: [c1, c2, c1, c2, c1],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          tileMode: TileMode.clamp,
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.elegant:
        paint.shader = RadialGradient(
          colors: [_lighten(segment.color, 0.1), segment.color, _darken(segment.color, 0.1)],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      case WheelStyle.retro:
        paint.color = _darken(segment.color, 0.1);
      default:
        paint.color = segment.color;
    }

    if (form == WheelForm.standard || form == WheelForm.polygon) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
    } else if (form == WheelForm.petal) {
      final petalRadius = radius * 0.95;
      canvas.drawArc(Rect.fromCircle(center: center, radius: petalRadius), startAngle, sweepAngle, true, paint);
      final innerPaint = Paint()..color = segment.color.withAlpha(50)..style = PaintingStyle.fill;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.4), startAngle, sweepAngle, true, innerPaint);
    } else if (form == WheelForm.star) {
      _drawStarSegment(canvas, center, radius, startAngle, sweepAngle, paint);
    }
  }

  /// Subtle inner highlight along the top edge of each segment for depth
  void _drawSegmentInnerHighlight(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, int index) {
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        startAngle: startAngle + pi / 2,
        endAngle: startAngle + sweepAngle + pi / 2,
        colors: [
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(60),
          Colors.white.withAlpha(0),
        ],
        stops: const [0.0, 0.5, 1.0],
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.85));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.85), startAngle, sweepAngle, false, highlightPaint);
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
        WheelStyle.neon => Colors.white.withAlpha(200),
        WheelStyle.dark => Colors.grey.shade600.withAlpha(120),
        WheelStyle.pastel => Colors.white.withAlpha(150),
        WheelStyle.metallic => Colors.white.withAlpha(100),
        _ => Colors.white.withAlpha(180),
      }
      ..style = PaintingStyle.stroke
      ..strokeWidth = style == WheelStyle.neon ? 1.5 : 2.0;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, borderPaint);
  }

  void _drawSegmentText(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, WheelSegment segment) {
    final textAngle = startAngle + sweepAngle / 2;
    final hasIcon = segment.iconName != null && segment.iconName!.isNotEmpty;
    final textRadius = hasIcon ? radius * 0.55 : radius * 0.62;
    final textX = center.dx + textRadius * cos(textAngle);
    final textY = center.dy + textRadius * sin(textAngle);

    canvas.save();
    canvas.translate(textX, textY);

    double labelAngle = textAngle + pi / 2;
    final normalized = (textAngle % (2 * pi) + 2 * pi) % (2 * pi);
    if (normalized > pi / 2 && normalized < 3 * pi / 2) {
      labelAngle += pi;
    }
    canvas.rotate(labelAngle);

    final shadows = <Shadow>[
      Shadow(color: Colors.black.withAlpha(120), blurRadius: 3, offset: const Offset(1, 1)),
    ];
    if (style == WheelStyle.neon) {
      shadows.add(Shadow(color: Colors.cyanAccent.withAlpha(100), blurRadius: 8));
    }

    // Draw emoji icon above text
    if (hasIcon) {
      final iconFontSize = _calculateFontSize(radius, segments.length) * 2.0 * segment.iconSize;
      canvas.save();
      canvas.rotate(segment.iconRotation);
      final iconPainter = TextPainter(
        text: TextSpan(
          text: segment.iconName,
          style: TextStyle(fontSize: iconFontSize),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      iconPainter.layout();
      iconPainter.paint(canvas, Offset(-iconPainter.width / 2, -iconPainter.height - 2));
      canvas.restore();
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: segment.label,
        style: TextStyle(
          color: _getTextColor(segment.color),
          fontSize: _calculateFontSize(radius, segments.length),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          shadows: shadows,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    );
    textPainter.layout(maxWidth: radius * 0.45);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, hasIcon ? 0 : -textPainter.height / 2));

    canvas.restore();
  }

  /// Radial shine overlay for a glossy look
  void _drawRadialShine(Canvas canvas, Offset center, double radius) {
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.9,
        colors: [
          Colors.white.withAlpha(45),
          Colors.white.withAlpha(15),
          Colors.transparent,
          Colors.black.withAlpha(15),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, shinePaint);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    // Thick outer ring with gradient
    final ringWidth = 5.0;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..shader = SweepGradient(
        colors: [
          _outerRingColor,
          _lighten(_outerRingColor, 0.2),
          _outerRingColor,
          _darken(_outerRingColor, 0.15),
          _outerRingColor,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, ringPaint);

    // Thin inner highlight ring
    canvas.drawCircle(center, radius - ringWidth / 2 - 1, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withAlpha(60));
  }

  void _drawLightBulbs(Canvas canvas, Offset center, double radius) {
    final bulbCount = max(segments.length * 3, 12);
    final bulbRadius = radius * 0.022;
    final bulbDistance = radius + 3;

    for (int i = 0; i < bulbCount; i++) {
      final angle = (i / bulbCount) * 2 * pi - pi / 2;
      final x = center.dx + bulbDistance * cos(angle);
      final y = center.dy + bulbDistance * sin(angle);
      final bulbCenter = Offset(x, y);

      // Alternate lit/dim based on glowPhase
      final isLit = ((i + (glowPhase * bulbCount).toInt()) % 2 == 0);
      final baseColor = i % 3 == 0 ? Colors.amber : (i % 3 == 1 ? Colors.white : Colors.redAccent);
      final alpha = isLit ? 255 : 80;

      // Glow behind bulb
      if (isLit) {
        canvas.drawCircle(bulbCenter, bulbRadius * 2.5, Paint()
          ..color = baseColor.withAlpha(50)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }

      // Bulb body
      canvas.drawCircle(bulbCenter, bulbRadius, Paint()
        ..color = baseColor.withAlpha(alpha)
        ..style = PaintingStyle.fill);

      // Tiny specular dot
      if (isLit) {
        canvas.drawCircle(
          bulbCenter + Offset(-bulbRadius * 0.3, -bulbRadius * 0.3),
          bulbRadius * 0.35,
          Paint()..color = Colors.white.withAlpha(180),
        );
      }
    }
  }

  void _drawCenterHub(Canvas canvas, Offset center, double radius) {
    final hubRadius = radius * 0.13;

    // Shadow under hub
    canvas.drawCircle(center + const Offset(1, 2), hubRadius + 2, Paint()
      ..color = Colors.black.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Metallic gradient fill
    final hubPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          _lighten(_centerFillColor, 0.35),
          _centerFillColor,
          _darken(_centerFillColor, 0.2),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: hubRadius));
    canvas.drawCircle(center, hubRadius, hubPaint);

    // Border ring
    canvas.drawCircle(center, hubRadius, Paint()
      ..color = _centerBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);

    // Specular highlight
    canvas.drawCircle(
      center + Offset(-hubRadius * 0.25, -hubRadius * 0.25),
      hubRadius * 0.35,
      Paint()..color = Colors.white.withAlpha(90),
    );
  }

  Color get _glowAccentColor => switch (style) {
    WheelStyle.neon => Colors.cyanAccent,
    WheelStyle.ocean => Colors.lightBlueAccent,
    WheelStyle.sunset => Colors.deepOrange,
    WheelStyle.rainbow => Colors.purpleAccent,
    WheelStyle.candy => Colors.pinkAccent,
    WheelStyle.dark => Colors.blueGrey,
    WheelStyle.metallic => Colors.blueGrey.shade200,
    _ => Colors.amber.shade200,
  };

  Color get _centerFillColor => switch (style) {
    WheelStyle.neon => const Color(0xFF1A1A2E),
    WheelStyle.ocean => const Color(0xFF1A237E),
    WheelStyle.sunset => const Color(0xFF4E342E),
    WheelStyle.metallic => const Color(0xFF37474F),
    WheelStyle.dark => const Color(0xFF1A1A1A),
    WheelStyle.rainbow => Colors.white,
    _ => Colors.white,
  };

  Color get _centerBorderColor => switch (style) {
    WheelStyle.neon => Colors.cyanAccent,
    WheelStyle.ocean => Colors.lightBlueAccent,
    WheelStyle.sunset => Colors.orangeAccent,
    WheelStyle.metallic => Colors.grey.shade300,
    WheelStyle.dark => Colors.grey.shade500,
    WheelStyle.rainbow => Colors.deepPurple,
    _ => Colors.grey.shade400,
  };

  Color get _outerRingColor => switch (style) {
    WheelStyle.neon => Colors.cyanAccent.withAlpha(180),
    WheelStyle.ocean => Colors.blue.shade400,
    WheelStyle.sunset => Colors.deepOrange.shade300,
    WheelStyle.retro => Colors.brown.shade400,
    WheelStyle.metallic => Colors.blueGrey.shade300,
    WheelStyle.dark => Colors.grey.shade600,
    WheelStyle.rainbow => Colors.deepPurple.shade300,
    WheelStyle.pastel => Colors.pink.shade200,
    WheelStyle.candy => Colors.pink.shade300,
    _ => Colors.grey.shade400,
  };

  Color _getTextColor(Color bgColor) {
    if (style == WheelStyle.dark) return Colors.white;
    if (style == WheelStyle.pastel) return Colors.black87;
    if (style == WheelStyle.neon) return Colors.white;
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
      form != oldDelegate.form ||
      glowPhase != oldDelegate.glowPhase;
}
