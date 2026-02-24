import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_model.dart';
import 'wheel_painter.dart';

class SpinningWheel extends StatefulWidget {
  final WheelModel wheel;
  final bool interactive;
  final ValueChanged<WheelSegment>? onResult;
  final ValueChanged<List<WheelSegment>>? onMultiResult;
  final ValueChanged<bool>? onSpinningChanged;

  const SpinningWheel({
    super.key,
    required this.wheel,
    this.interactive = true,
    this.onResult,
    this.onMultiResult,
    this.onSpinningChanged,
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

  void _setSpinning(bool value) {
    if (_isSpinning == value) return;
    _isSpinning = value;
    widget.onSpinningChanged?.call(value);
  }

  late AnimationController _glowController;
  late AnimationController _bounceController;
  double _bounceScale = 1.0;

  // Tap jelly bounce
  late AnimationController _tapBounceController;
  double _tapBounceScale = 1.0;

  double _tiltX = 0;
  double _tiltY = 0;
  AnimationController? _tiltResetController;
  double _tiltXStart = 0;
  double _tiltYStart = 0;

  // Multi-spin state
  List<WheelSegment> _multiResults = [];
  int _multiTotal = 0;
  int _multiCurrent = 0;
  bool get isSpinning => _isSpinning;

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

    _tapBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tapBounceController.addListener(_onTapBounce);

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
    _tapBounceController.removeListener(_onTapBounce);
    _tapBounceController.dispose();
    _tiltResetController?.dispose();
    super.dispose();
  }

  void _onBounce() {
    if (!mounted) return;
    final t = _bounceController.value;
    final bounce = 1.0 + 0.06 * sin(t * pi) * (1 - t);
    setState(() => _bounceScale = bounce);
  }

  void _onTapBounce() {
    if (!mounted) return;
    final t = _tapBounceController.value;
    // Elastic jelly: squish down then overshoot up then settle
    final scale = 1.0 + 0.08 * sin(t * pi * 3) * (1 - t);
    setState(() => _tapBounceScale = scale);
  }

  void _handleTap() {
    if (_isSpinning) return;
    _tapBounceController.reset();
    _tapBounceController.forward();
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

  double get _pointerAngleOffset => switch (widget.wheel.pointerPosition) {
    PointerPosition.top => 0.0,
    PointerPosition.right => pi / 2,
    PointerPosition.bottom => pi,
    PointerPosition.left => 3 * pi / 2,
  };

  void spin() {
    if (_isSpinning || widget.wheel.segments.length < 2) return;
    setState(() => _setSpinning(true));
    final random = Random();
    final winner = _selectWinner(random);
    _animateToSegment(winner, random, () {
      widget.onResult?.call(winner);
    });
  }

  /// Spin N times. If [skipAnimation] is true, skip the wheel animation
  /// and directly compute all results.
  void spinMultiple(int count, {bool skipAnimation = false}) {
    if (_isSpinning || widget.wheel.segments.length < 2 || count <= 0) return;

    if (skipAnimation) {
      // Instant results — no animation
      final random = Random();
      final results = List.generate(count, (_) => _selectWinner(random));
      widget.onMultiResult?.call(results);
      return;
    }

    setState(() {
      _setSpinning(true);
      _multiResults = [];
      _multiTotal = count;
      _multiCurrent = 0;
    });
    _spinNext();
  }

  void _spinNext() {
    if (_multiCurrent >= _multiTotal) {
      setState(() => _setSpinning(false));
      widget.onMultiResult?.call(List.unmodifiable(_multiResults));
      return;
    }

    final random = Random();
    final winner = _selectWinner(random);
    final durationMs = _multiTotal > 1
        ? (widget.wheel.spinDuration * 600).toInt().clamp(1200, 5000)
        : (widget.wheel.spinDuration * 1000).toInt();

    _animateToSegment(winner, random, () {
      _multiResults.add(winner);
      _multiCurrent++;
      if (_multiCurrent < _multiTotal) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _spinNext();
        });
      } else {
        setState(() => _setSpinning(false));
        widget.onMultiResult?.call(List.unmodifiable(_multiResults));
      }
    }, overrideDurationMs: durationMs);
  }

  void _animateToSegment(WheelSegment winner, Random random, VoidCallback onComplete, {int? overrideDurationMs}) {
    final winnerIndex = widget.wheel.segments.indexOf(winner);
    final totalRatio = widget.wheel.segments.fold<double>(0, (s, seg) => s + seg.ratio);
    if (totalRatio <= 0) { setState(() => _setSpinning(false)); return; }

    double winnerCenterAngle = 0;
    for (int i = 0; i < winnerIndex; i++) {
      winnerCenterAngle += (widget.wheel.segments[i].ratio / totalRatio) * 2 * pi;
    }
    winnerCenterAngle += (winner.ratio / totalRatio) * pi;
    winnerCenterAngle -= _pointerAngleOffset;

    final halfSweep = (winner.ratio / totalRatio) * pi;
    final jitter = (random.nextDouble() - 0.5) * halfSweep * 0.8;
    winnerCenterAngle += jitter;

    final speedMultiplier = switch (widget.wheel.spinSpeed) {
      SpinSpeed.slow => 4, SpinSpeed.normal => 6, SpinSpeed.fast => 10,
    };

    final fullRotations = speedMultiplier * 2 * pi;
    final targetRotation = _currentRotation + fullRotations + (2 * pi - ((_currentRotation + winnerCenterAngle) % (2 * pi)));
    final startRotation = _currentRotation;

    final durationMs = overrideDurationMs ?? (widget.wheel.spinDuration * 1000).toInt();
    _spinController.duration = Duration(milliseconds: durationMs);
    _spinController.reset();

    _curvedAnimation?.dispose();
    _curvedAnimation = CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic);

    void onSpinTick() {
      if (!mounted) return;
      setState(() {
        _currentRotation = startRotation + (targetRotation - startRotation) * _curvedAnimation!.value;
      });
    }

    _curvedAnimation!.addListener(onSpinTick);
    _spinController.forward().then((_) {
      _curvedAnimation?.removeListener(onSpinTick);
      if (!mounted) return;
      _bounceController.reset();
      _bounceController.forward();
      onComplete();
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
          scale: _bounceScale * _tapBounceScale,
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
                _buildPositionedPointer(wheelSize),
              ],
            ),
          ),
        );
      },
    );

    // Wrap with tap detector for jelly bounce
    final tappableWheel = GestureDetector(
      onTap: _handleTap,
      child: wheelBase,
    );

    if (!is3D) {
      return Column(mainAxisSize: MainAxisSize.min, children: [tappableWheel]);
    }

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_tiltX)
      ..rotateY(_tiltY);

    return GestureDetector(
      onTap: _handleTap,
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
                    colors: [Colors.black.withAlpha(35), Colors.black.withAlpha(10), Colors.transparent],
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
                        color: Colors.black.withAlpha(50 + ((_tiltX.abs() + _tiltY.abs()) * 40).toInt().clamp(0, 80)),
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
                                center: Alignment((-_tiltY * 1.5).clamp(-0.8, 0.8), (_tiltX * 1.5).clamp(-0.8, 0.8)),
                                radius: 0.9,
                                colors: [
                                  Colors.white.withAlpha((20 + (_tiltX.abs() + _tiltY.abs()) * 60).toInt().clamp(0, 90)),
                                  Colors.white.withAlpha((5 + (_tiltX.abs() + _tiltY.abs()) * 15).toInt().clamp(0, 30)),
                                  Colors.transparent,
                                  Colors.black.withAlpha(((_tiltX.abs() + _tiltY.abs()) * 20).toInt().clamp(0, 40)),
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

  Widget _buildPositionedPointer(double wheelSize) {
    final totalSize = wheelSize + 16;
    final pointerWidget = _buildPointer();
    switch (widget.wheel.pointerPosition) {
      case PointerPosition.top:
        return Positioned(top: 0, child: pointerWidget);
      case PointerPosition.bottom:
        return Positioned(bottom: 0, child: Transform.rotate(angle: pi, child: pointerWidget));
      case PointerPosition.right:
        return Positioned(right: 0, top: totalSize / 2 - 15, child: Transform.rotate(angle: -pi / 2, child: pointerWidget));
      case PointerPosition.left:
        return Positioned(left: 0, top: totalSize / 2 - 15, child: Transform.rotate(angle: pi / 2, child: pointerWidget));
    }
  }

  Widget _buildPointer() {
    final color = Theme.of(context).colorScheme.primary;
    final style = widget.wheel.pointerStyle;
    return CustomPaint(size: const Size(28, 34), painter: _PointerPainter(color: color, style: style));
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  final PointerStyle style;
  _PointerPainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case PointerStyle.classic: _paintClassic(canvas, size);
      case PointerStyle.arrow: _paintArrow(canvas, size);
      case PointerStyle.diamond: _paintDiamond(canvas, size);
      case PointerStyle.dot: _paintDot(canvas, size);
      case PointerStyle.flag: _paintFlag(canvas, size);
    }
  }

  void _paintClassic(Canvas canvas, Size size) {
    final path = Path()..moveTo(size.width / 2, size.height)..lineTo(0, 0)..lineTo(size.width, 0)..close();
    _drawPointerPath(canvas, size, path);
  }

  void _paintArrow(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()..moveTo(w / 2, h)..lineTo(0, h * 0.35)..lineTo(w * 0.25, h * 0.35)
      ..lineTo(w * 0.25, 0)..lineTo(w * 0.75, 0)..lineTo(w * 0.75, h * 0.35)..lineTo(w, h * 0.35)..close();
    _drawPointerPath(canvas, size, path);
  }

  void _paintDiamond(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()..moveTo(w / 2, h)..lineTo(0, h / 2)..lineTo(w / 2, 0)..lineTo(w, h / 2)..close();
    _drawPointerPath(canvas, size, path);
  }

  void _paintDot(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    canvas.drawCircle(center + const Offset(1, 2), radius, Paint()..color = Colors.black.withAlpha(60)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(center: const Alignment(-0.3, -0.4), colors: [_lighten(color, 0.3), color, _darken(color, 0.15)]).createShader(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withAlpha(200)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(center + Offset(-radius * 0.25, -radius * 0.25), radius * 0.3, Paint()..color = Colors.white.withAlpha(150));
    final tipPath = Path()..moveTo(size.width / 2, size.height)..lineTo(size.width / 2 - 5, size.height - 10)..lineTo(size.width / 2 + 5, size.height - 10)..close();
    canvas.drawPath(tipPath, Paint()..color = color);
  }

  void _paintFlag(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Rect.fromLTWH(w / 2 - 1.5, 0, 3, h), Paint()..color = _darken(color, 0.1));
    final flagPath = Path()..moveTo(w / 2 + 1.5, 0)..lineTo(w, h * 0.1)..lineTo(w * 0.7, h * 0.25)..lineTo(w, h * 0.4)..lineTo(w / 2 + 1.5, h * 0.3)..close();
    canvas.drawPath(flagPath, Paint()..shader = LinearGradient(colors: [_lighten(color, 0.2), color]).createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawPath(flagPath, Paint()..color = Colors.white.withAlpha(150)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawCircle(Offset(w / 2, h), 3, Paint()..color = color);
  }

  void _drawPointerPath(Canvas canvas, Size size, Path path) {
    canvas.drawPath(path.shift(const Offset(1, 2)), Paint()..color = Colors.black.withAlpha(60)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_lighten(color, 0.2), color, _darken(color, 0.15)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    canvas.drawPath(path, Paint()..color = Colors.white.withAlpha(200)..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.2), 2.5, Paint()..color = Colors.white.withAlpha(150));
  }

  static Color _lighten(Color c, double amount) => HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness + amount).clamp(0.0, 1.0)).toColor();
  static Color _darken(Color c, double amount) => HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness - amount).clamp(0.0, 1.0)).toColor();

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => color != oldDelegate.color || style != oldDelegate.style;
}
