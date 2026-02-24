import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_model.dart';
import 'wheel_painter.dart';

class SpinningWheel extends StatefulWidget {
  final WheelModel wheel;
  final bool interactive;
  final ValueChanged<WheelSegment>? onResult;

  const SpinningWheel({
    super.key,
    required this.wheel,
    this.interactive = true,
    this.onResult,
  });

  @override
  State<SpinningWheel> createState() => SpinningWheelState();
}

class SpinningWheelState extends State<SpinningWheel>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  CurvedAnimation? _curvedAnimation;
  double _currentRotation = 0;
  bool _isSpinning = false;

  // Idle breathing / glow animation
  late AnimationController _glowController;

  // Bounce on stop
  late AnimationController _bounceController;
  double _bounceScale = 1.0;

  // 3D tilt state
  double _tiltX = 0;
  double _tiltY = 0;
  AnimationController? _tiltResetController;
  double _tiltXStart = 0;
  double _tiltYStart = 0;

  static const double _maxTilt = 0.6;
  static const double _tiltSensitivity = 0.005;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.wheel.spinDuration * 1000).toInt()),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceController.addListener(_onBounce);

    if (widget.wheel.is3D) {
      _tiltResetController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    }
  }

  @override
  void dispose() {
    _tiltResetController?.removeListener(_animateTiltReset);
    _curvedAnimation?.dispose();
    _spinController.dispose();
    _glowController.dispose();
    _bounceController.removeListener(_onBounce);
    _bounceController.dispose();
    _tiltResetController?.dispose();
    super.dispose();
  }

  void _onBounce() {
    if (!mounted) return;
    final t = _bounceController.value;
    final bounce = 1.0 + 0.06 * sin(t * pi) * (1 - t);
    setState(() => _bounceScale = bounce);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.wheel.is3D) return;
    setState(() {
      _tiltY = (_tiltY + details.delta.dx * _tiltSensitivity).clamp(-_maxTilt, _maxTilt);
      _tiltX = (_tiltX - details.delta.dy * _tiltSensitivity).clamp(-_maxTilt, _maxTilt);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.wheel.is3D) return;
    _tiltXStart = _tiltX;
    _tiltYStart = _tiltY;
    _tiltResetController!.removeListener(_animateTiltReset);
    _tiltResetController!.reset();
    _tiltResetController!.addListener(_animateTiltReset);
    _tiltResetController!.forward();
  }

  void _animateTiltReset() {
    if (!mounted) return;
    final t = Curves.elasticOut.transform(_tiltResetController!.value);
    setState(() {
      _tiltX = _tiltXStart * (1 - t);
      _tiltY = _tiltYStart * (1 - t);
    });
  }

  void spin() {
    if (_isSpinning || widget.wheel.segments.length < 2) return;
    setState(() => _isSpinning = true);

    final random = Random();
    final winner = _selectWinner(random);
    final winnerIndex = widget.wheel.segments.indexOf(winner);

    final totalRatio = widget.wheel.segments.fold<double>(0, (s, seg) => s + seg.ratio);
    if (totalRatio <= 0) {
      setState(() => _isSpinning = false);
      return;
    }

    double winnerCenterAngle = 0;
    for (int i = 0; i < winnerIndex; i++) {
      winnerCenterAngle += (widget.wheel.segments[i].ratio / totalRatio) * 2 * pi;
    }
    winnerCenterAngle += (winner.ratio / totalRatio) * pi;

    if (widget.wheel.pointerPosition == PointerPosition.right) {
      winnerCenterAngle -= pi / 2;
    }

    final halfSweep = (winner.ratio / totalRatio) * pi;
    final jitter = (random.nextDouble() - 0.5) * halfSweep * 0.8;
    winnerCenterAngle += jitter;

    final speedMultiplier = switch (widget.wheel.spinSpeed) {
      SpinSpeed.slow => 4,
      SpinSpeed.normal => 6,
      SpinSpeed.fast => 10,
    };

    final fullRotations = speedMultiplier * 2 * pi;
    final targetRotation = _currentRotation + fullRotations + (2 * pi - ((_currentRotation + winnerCenterAngle) % (2 * pi)));
    final startRotation = _currentRotation;

    _spinController.duration = Duration(
      milliseconds: (widget.wheel.spinDuration * 1000).toInt(),
    );
    _spinController.reset();

    _curvedAnimation?.dispose();
    _curvedAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    void onSpinTick() {
      if (!mounted) return;
      setState(() {
        _currentRotation = startRotation +
            (targetRotation - startRotation) * _curvedAnimation!.value;
      });
    }

    _curvedAnimation!.addListener(onSpinTick);

    _spinController.forward().then((_) {
      _curvedAnimation?.removeListener(onSpinTick);
      if (!mounted) return;
      setState(() => _isSpinning = false);
      _bounceController.reset();
      _bounceController.forward();
      widget.onResult?.call(winner);
    });
  }

  WheelSegment _selectWinner(Random random) {
    final segments = widget.wheel.segments;
    if (segments.isEmpty) return segments.first;
    final candidates = segments.where((s) => s.probability > 0).toList();
    if (candidates.isEmpty) return segments[random.nextInt(segments.length)];
    final totalProb = candidates.fold<double>(0, (s, seg) => s + seg.probability);
    if (totalProb <= 0) return segments[random.nextInt(segments.length)];
    double roll = random.nextDouble() * totalProb;
    for (final segment in candidates) {
      roll -= segment.probability;
      if (roll <= 0) return segment;
    }
    return candidates.last;
  }

  @override
  Widget build(BuildContext context) {
    final wheelSize = switch (widget.wheel.size) {
      WheelSize.small => 240.0,
      WheelSize.medium => 300.0,
      WheelSize.large => 360.0,
    };
    final is3D = widget.wheel.is3D;

    final wheelBase = AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceScale,
          child: SizedBox(
            width: wheelSize + 16,
            height: wheelSize + 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(wheelSize + 16, wheelSize + 16),
                  painter: WheelPainter(
                    segments: widget.wheel.segments,
                    rotation: _currentRotation,
                    style: widget.wheel.style,
                    form: widget.wheel.form,
                    glowPhase: _glowController.value,
                  ),
                ),
                Positioned(
                  top: widget.wheel.pointerPosition == PointerPosition.top ? 0 : (wheelSize + 16) / 2 - 15,
                  right: widget.wheel.pointerPosition == PointerPosition.right ? 0 : null,
                  child: _buildPointer(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!is3D) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [wheelBase],
      );
    }

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_tiltX)
      ..rotateY(_tiltY);

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: SizedBox(
        width: wheelSize + 56,
        height: wheelSize + 76,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: wheelSize * 0.75,
                height: wheelSize * 0.10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(wheelSize),
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withAlpha(35),
                      Colors.black.withAlpha(10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(
                          50 + ((_tiltX.abs() + _tiltY.abs()) * 40).toInt().clamp(0, 80),
                        ),
                        blurRadius: 20 + (_tiltX.abs() + _tiltY.abs()) * 15,
                        offset: Offset(_tiltY * 20, -_tiltX * 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      wheelBase,
                      ClipOval(
                        child: SizedBox(
                          width: wheelSize,
                          height: wheelSize,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(
                                  (-_tiltY * 1.5).clamp(-0.8, 0.8),
                                  (_tiltX * 1.5).clamp(-0.8, 0.8),
                                ),
                                radius: 0.9,
                                colors: [
                                  Colors.white.withAlpha(
                                    (20 + (_tiltX.abs() + _tiltY.abs()) * 60).toInt().clamp(0, 90),
                                  ),
                                  Colors.white.withAlpha(
                                    (5 + (_tiltX.abs() + _tiltY.abs()) * 15).toInt().clamp(0, 30),
                                  ),
                                  Colors.transparent,
                                  Colors.black.withAlpha(
                                    ((_tiltX.abs() + _tiltY.abs()) * 20).toInt().clamp(0, 40),
                                  ),
                                ],
                                stops: const [0.0, 0.25, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointer() {
    final isTop = widget.wheel.pointerPosition == PointerPosition.top;
    return Transform.rotate(
      angle: isTop ? 0 : -pi / 2,
      child: CustomPaint(
        size: const Size(28, 34),
        painter: _PointerPainter(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    // Drop shadow
    canvas.drawPath(
      path.shift(const Offset(1, 2)),
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_lighten(color, 0.2), color, _darken(color, 0.15)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, gradientPaint);

    // White border
    canvas.drawPath(path, Paint()
      ..color = Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Specular highlight
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.2),
      2.5,
      Paint()..color = Colors.white.withAlpha(150),
    );
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
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      color != oldDelegate.color;
}
