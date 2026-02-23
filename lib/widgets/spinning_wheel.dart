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

  // 3D tilt state
  double _tiltX = 0; // rotation around X axis (vertical drag)
  double _tiltY = 0; // rotation around Y axis (horizontal drag)
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
    if (widget.wheel.is3D) {
      _tiltResetController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    }
  }

  @override
  void dispose() {
    _curvedAnimation?.dispose();
    _spinController.dispose();
    _tiltResetController?.dispose();
    super.dispose();
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
    if (_tiltResetController!.isCompleted) {
      _tiltResetController!.removeListener(_animateTiltReset);
    }
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

    _curvedAnimation!.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentRotation = startRotation +
            (targetRotation - startRotation) * _curvedAnimation!.value;
      });
    });

    _spinController.forward().then((_) {
      if (!mounted) return;
      setState(() => _isSpinning = false);
      widget.onResult?.call(winner);
    });
  }

  WheelSegment _selectWinner(Random random) {
    final segments = widget.wheel.segments;

    final candidates = segments.where((s) => s.probability > 0).toList();

    if (candidates.isEmpty) {
      return segments[random.nextInt(segments.length)];
    }

    final guaranteed = candidates.where((s) => s.probability >= 100).toList();
    if (guaranteed.length == 1) return guaranteed.first;

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

    final wheelBase = SizedBox(
      width: wheelSize,
      height: wheelSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(wheelSize, wheelSize),
            painter: WheelPainter(
              segments: widget.wheel.segments,
              rotation: _currentRotation,
              style: widget.wheel.style,
              form: widget.wheel.form,
            ),
          ),
          Positioned(
            top: widget.wheel.pointerPosition == PointerPosition.top ? 0 : wheelSize / 2 - 15,
            right: widget.wheel.pointerPosition == PointerPosition.right ? 0 : null,
            child: _buildPointer(),
          ),
        ],
      ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ground shadow
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(1.2),
            child: Container(
              width: wheelSize * 0.85,
              height: wheelSize * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(wheelSize),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          Transform(
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
                  // Specular highlight overlay
                  ClipOval(
                    child: SizedBox(
                      width: wheelSize,
                      height: wheelSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(
                              (-_tiltY * 2).clamp(-1.0, 1.0),
                              (_tiltX * 2).clamp(-1.0, 1.0),
                            ),
                            end: Alignment(
                              (_tiltY * 2).clamp(-1.0, 1.0),
                              (-_tiltX * 2).clamp(-1.0, 1.0),
                            ),
                            colors: [
                              Colors.white.withAlpha(
                                (30 + (_tiltX.abs() + _tiltY.abs()) * 50).toInt().clamp(0, 80),
                              ),
                              Colors.transparent,
                              Colors.black.withAlpha(
                                ((_tiltX.abs() + _tiltY.abs()) * 25).toInt().clamp(0, 50),
                              ),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointer() {
    final isTop = widget.wheel.pointerPosition == PointerPosition.top;
    return Transform.rotate(
      angle: isTop ? 0 : -pi / 2,
      child: CustomPaint(
        size: const Size(24, 30),
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      color != oldDelegate.color;
}
