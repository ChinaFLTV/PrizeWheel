import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/wheel_model.dart';
import '../widgets/spinning_wheel.dart';
import 'spin_records_page.dart';

const _multiSpinPresets = [3, 5, 10];
const _multiSpinMin = 2;
const _multiSpinMax = 999;

class WheelSpinPage extends StatefulWidget {
  final WheelModel wheel;
  const WheelSpinPage({super.key, required this.wheel});

  @override
  State<WheelSpinPage> createState() => _WheelSpinPageState();
}

class _WheelSpinPageState extends State<WheelSpinPage> {
  final _wheelKey = GlobalKey<SpinningWheelState>();
  final _db = DatabaseHelper();
  bool _isWheelSpinning = false;

  void _onResult(WheelSegment segment) {
    _saveRecord(segment, batchId: null);
    if (!widget.wheel.showResult || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: segment.iconName != null
            ? Text(segment.iconName!, style: const TextStyle(fontSize: 48))
            : const Icon(Icons.celebration_rounded, size: 48),
        title: Text(l10n.congratulations),
        content: Text(l10n.youWon(segment.label),
          style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.close)),
          FilledButton.icon(
            onPressed: () { Navigator.pop(ctx); _wheelKey.currentState?.spin(); },
            icon: const Icon(Icons.refresh_rounded), label: Text(l10n.spinAgain)),
        ],
      ),
    );
  }

  void _onMultiResult(List<WheelSegment> results) {
    final batchId = const Uuid().v4();
    for (final seg in results) {
      _saveRecord(seg, batchId: batchId);
    }
    if (!mounted) return;
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          _MultiResultRevealPage(results: results, wheel: widget.wheel),
      transitionsBuilder: (context, anim, secondaryAnim, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _saveRecord(WheelSegment segment, {required String? batchId}) {
    _db.insertSpinRecord(SpinRecord(
      id: const Uuid().v4(),
      wheelId: widget.wheel.id,
      wheelTitle: widget.wheel.title,
      prizeName: segment.label,
      prizeColor: segment.color.toARGB32(),
      spinTime: DateTime.now(),
      batchId: batchId,
    )).catchError((e) { debugPrint('Error saving spin record: $e'); });
  }

  void _startMultiSpin(int count, {bool skipAnimation = false}) {
    _wheelKey.currentState?.spinMultiple(count, skipAnimation: skipAnimation);
  }

  void _showMultiSpinPicker() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final customController = TextEditingController();
    bool skipAnim = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.multiSpinTitle, style: theme.textTheme.titleMedium),
                ),
                // Skip animation toggle
                SwitchListTile(
                  title: Text(l10n.skipSpinAnimation),
                  secondary: const Icon(Icons.fast_forward_rounded),
                  value: skipAnim,
                  dense: true,
                  onChanged: (v) => setSheetState(() => skipAnim = v),
                ),
                const Divider(height: 1),
                ..._multiSpinPresets.map((n) => ListTile(
                  leading: CircleAvatar(child: Text('$n')),
                  title: Text(l10n.multiSpinOption(n)),
                  onTap: () { Navigator.pop(ctx); _startMultiSpin(n, skipAnimation: skipAnim); },
                )),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: l10n.customSpinCount,
                            hintText: '$_multiSpinMin - $_multiSpinMax',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          final count = int.tryParse(customController.text) ?? 0;
                          if (count < _multiSpinMin || count > _multiSpinMax) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(l10n.customSpinCountError(_multiSpinMin, _multiSpinMax)),
                            ));
                            return;
                          }
                          Navigator.pop(ctx);
                          _startMultiSpin(count, skipAnimation: skipAnim);
                        },
                        child: Text(l10n.confirm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(String path, WheelModel wheel) {
    Widget bg = Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    if (wheel.bgOpacity < 1.0) bg = Opacity(opacity: wheel.bgOpacity, child: bg);
    if (wheel.bgBlurEnabled && wheel.bgBlurIntensity > 0) {
      bg = Stack(fit: StackFit.expand, children: [
        bg,
        ClipRect(child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: wheel.bgBlurIntensity, sigmaY: wheel.bgBlurIntensity),
          child: const SizedBox.expand(),
        )),
      ]);
    }
    final overlayColor = Color(wheel.bgOverlayColor);
    if (overlayColor.a > 0) {
      bg = Stack(fit: StackFit.expand, children: [bg, ColoredBox(color: overlayColor)]);
    }
    return bg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bgPath = widget.wheel.backgroundImagePath;
    final hasBg = bgPath != null && File(bgPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wheel.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.spinRecords,
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => SpinRecordsPage(wheelId: widget.wheel.id, wheelTitle: widget.wheel.title),
            )),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBg) Positioned.fill(child: _buildBackground(bgPath, widget.wheel)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinningWheel(key: _wheelKey, wheel: widget.wheel, onResult: _onResult, onMultiResult: _onMultiResult, onSpinningChanged: (v) => setState(() => _isWheelSpinning = v)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _isWheelSpinning ? null : () => _wheelKey.currentState?.spin(),
                        icon: const Icon(Icons.casino_rounded),
                        label: Text(l10n.spinTheWheel),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          textStyle: theme.textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isWheelSpinning ? null : _showMultiSpinPicker,
                        icon: const Icon(Icons.repeat_rounded),
                        label: Text(l10n.multiSpin),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                          textStyle: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// CFM-style multi-result reveal page
// ============================================================

const _cardHues = [0.0, 30.0, 60.0, 120.0, 180.0, 210.0, 270.0, 300.0, 330.0, 45.0];

class _MultiResultRevealPage extends StatefulWidget {
  final List<WheelSegment> results;
  final WheelModel wheel;
  const _MultiResultRevealPage({required this.results, required this.wheel});

  @override
  State<_MultiResultRevealPage> createState() => _MultiResultRevealPageState();
}

class _MultiResultRevealPageState extends State<_MultiResultRevealPage>
    with TickerProviderStateMixin {
  late List<AnimationController> _flipControllers;
  late List<Animation<double>> _flipAnimations;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _bgController;
  late AnimationController _shineController;
  late AnimationController _particleController;

  // Per-card tap bounce controllers
  late List<AnimationController> _tapControllers;

  bool _allRevealed = false;
  int _revealedCount = 0;

  @override
  void initState() {
    super.initState();
    final count = widget.results.length;

    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _shineController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();

    _flipControllers = List.generate(count, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 700)));
    _flipAnimations = _flipControllers.map((c) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: c, curve: Curves.easeInOutBack))).toList();

    _scaleControllers = List.generate(count, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 400)));
    _scaleAnimations = _scaleControllers.map((c) => Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.elasticOut))).toList();

    _tapControllers = List.generate(count, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));

    _revealSequentially();
  }

  Future<void> _revealSequentially() async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < widget.results.length; i++) {
      if (!mounted) return;
      _flipControllers[i].forward();
      _scaleControllers[i].forward();
      setState(() => _revealedCount = i + 1);
      final delay = widget.results.length > 20 ? 150 : (widget.results.length > 10 ? 250 : 350);
      await Future.delayed(Duration(milliseconds: delay));
    }
    if (mounted) setState(() => _allRevealed = true);
  }

  void _revealAll() {
    for (int i = 0; i < _flipControllers.length; i++) {
      if (!_flipControllers[i].isCompleted) { _flipControllers[i].forward(); _scaleControllers[i].forward(); }
    }
    setState(() { _revealedCount = widget.results.length; _allRevealed = true; });
  }

  void _onCardTap(int index) {
    _tapControllers[index].reset();
    _tapControllers[index].forward();
  }

  @override
  void dispose() {
    for (final c in _flipControllers) { c.dispose(); }
    for (final c in _scaleControllers) { c.dispose(); }
    for (final c in _tapControllers) { c.dispose(); }
    _bgController.dispose();
    _shineController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  int get _crossAxisCount {
    final n = widget.results.length;
    if (n <= 2) return 1;
    if (n <= 4) return 2;
    return 3;
  }

  double get _childAspectRatio {
    final n = widget.results.length;
    if (n <= 2) return 2.8;
    if (n <= 4) return 1.1;
    return 0.9;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final results = widget.results;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _particleController]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildAnimatedBackground(theme),
              if (_allRevealed) ..._buildParticles(),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(l10n, theme, results.length),
                    _buildProgressBar(theme, results.length),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: _allRevealed
                            ? _buildResultsWithSummary(results, theme, l10n)
                            : GridView.builder(
                                padding: const EdgeInsets.only(bottom: 8),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _crossAxisCount,
                                  childAspectRatio: _childAspectRatio,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: results.length,
                                itemBuilder: (context, index) => _buildRevealCard(index, results[index], theme),
                              ),
                      ),
                    ),
                    _buildBottomBar(l10n),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme) {
    final t = _bgController.value;
    final shimmer = _shineController.value;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.5 + shimmer * 0.3, -1),
          end: Alignment(0.5 - shimmer * 0.3, 1),
          colors: [
            Color.lerp(const Color(0xFF0D0D1A), const Color(0xFF1A1040), t)!,
            Color.lerp(const Color(0xFF0D0D1A), const Color(0xFF0A1628), t)!,
            Color.lerp(const Color(0xFF0D0D1A), const Color(0xFF120E20), t)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    final rng = Random(42);
    final t = _particleController.value;
    return List.generate(18, (i) {
      final baseX = rng.nextDouble();
      final baseY = rng.nextDouble();
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final size = 2.0 + rng.nextDouble() * 4;
      final hue = (i * 37.0) % 360;
      final y = (baseY - t * speed) % 1.0;
      final alpha = (sin(t * pi * 2 + i) * 0.5 + 0.5).clamp(0.2, 0.9);
      return Positioned(
        left: baseX * MediaQuery.of(context).size.width,
        top: y * MediaQuery.of(context).size.height,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HSLColor.fromAHSL(alpha, hue, 0.8, 0.7).toColor(),
            boxShadow: [BoxShadow(color: HSLColor.fromAHSL(alpha * 0.5, hue, 0.9, 0.6).toColor(), blurRadius: size * 2)],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white60), onPressed: () => Navigator.pop(context)),
          const Spacer(),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: [Colors.amber.shade200, Colors.orangeAccent, Colors.amber.shade200]).createShader(bounds),
            child: Text(l10n.multiSpinResult(total), style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const Spacer(),
          if (!_allRevealed) TextButton(onPressed: _revealAll, child: Text(l10n.revealAll, style: const TextStyle(color: Colors.amber)))
          else const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedBuilder(
          animation: _shineController,
          builder: (context, _) {
            final progress = _revealedCount / total;
            return Stack(children: [
              LinearProgressIndicator(value: progress, minHeight: 5, backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation(Color.lerp(Colors.deepPurple, Colors.amber, progress)!)),
              if (progress > 0)
                Positioned.fill(child: FractionallySizedBox(
                  alignment: Alignment.centerLeft, widthFactor: progress,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-1 + _shineController.value * 3, 0),
                      end: Alignment(-0.5 + _shineController.value * 3, 0),
                      colors: [Colors.transparent, Colors.white24, Colors.transparent],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcATop,
                    child: Container(color: Colors.white),
                  ),
                )),
            ]);
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.orange.shade600]),
          boxShadow: [BoxShadow(color: Colors.amber.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(l10n.confirm, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsWithSummary(List<WheelSegment> results, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        _buildSummaryCard(results, theme, l10n),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            childAspectRatio: _childAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) => _buildRevealCard(index, results[index], theme),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(List<WheelSegment> results, ThemeData theme, AppLocalizations l10n) {
    final total = results.length;
    final countMap = <String, _PrizeStat>{};
    for (final seg in results) {
      final stat = countMap.putIfAbsent(seg.label, () => _PrizeStat(seg.label, seg.color, seg.iconName, 0));
      stat.count++;
    }
    final stats = countMap.values.toList()..sort((a, b) => b.count.compareTo(a.count));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(18), Colors.white.withAlpha(8)],
        ),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.bar_chart_rounded, size: 18, color: Colors.amber.shade300),
            const SizedBox(width: 6),
            Text(l10n.prizeSummary, style: TextStyle(color: Colors.amber.shade200, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          ...stats.map((s) {
            final pct = (s.count / total * 100).toStringAsFixed(1);
            final ratio = s.count / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                s.icon != null
                    ? SizedBox(width: 16, child: Text(s.icon!, style: const TextStyle(fontSize: 12)))
                    : Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(s.label, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: ratio, minHeight: 6,
                      backgroundColor: Colors.white.withAlpha(15),
                      valueColor: AlwaysStoppedAnimation(s.color.withAlpha(200)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 56,
                  child: Text('${s.count}次 $pct%', style: const TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.right),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRevealCard(int index, WheelSegment segment, ThemeData theme) {
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimations[index], _scaleAnimations[index], _tapControllers[index]]),
        builder: (context, _) {
          final flipValue = _flipAnimations[index].value;
          final scaleValue = _scaleAnimations[index].value;
          final isFlipped = flipValue >= 0.5;
          final angle = flipValue * pi;

          // Jelly tap bounce
          final tapT = _tapControllers[index].value;
          final jellyScale = 1.0 + 0.1 * sin(tapT * pi * 3) * (1 - tapT);

          return Transform.scale(
            scale: scaleValue * jellyScale,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(3, 2, 0.0015)..rotateY(angle),
              child: isFlipped
                  ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi),
                      child: _buildFrontCard(index, segment, theme))
                  : _buildBackCard(index, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackCard(int index, ThemeData theme) {
    final hue = _cardHues[index % _cardHues.length];
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        final shimmer = _shineController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment(-1 + shimmer * 3, -0.5), end: Alignment(-0.5 + shimmer * 3, 0.5),
              colors: [
                HSLColor.fromAHSL(1, hue, 0.6, 0.25).toColor(),
                HSLColor.fromAHSL(1, hue, 0.5, 0.18).toColor(),
                Colors.white.withAlpha(40),
                HSLColor.fromAHSL(1, hue, 0.5, 0.18).toColor(),
                HSLColor.fromAHSL(1, hue, 0.6, 0.25).toColor(),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ),
            border: Border.all(color: HSLColor.fromAHSL(0.4, hue, 0.7, 0.5).toColor(), width: 1.5),
            boxShadow: [BoxShadow(color: HSLColor.fromAHSL(0.3, hue, 0.8, 0.4).toColor(), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.help_outline_rounded, size: 28, color: Colors.white.withAlpha(160)),
            const SizedBox(height: 4),
            Text('#${index + 1}', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14, fontWeight: FontWeight.bold)),
          ])),
        );
      },
    );
  }

  Widget _buildFrontCard(int index, WheelSegment segment, ThemeData theme) {
    final textColor = segment.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, _) {
        final shimmer = _shineController.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_lighten(segment.color, 0.2), segment.color, _darken(segment.color, 0.15)]),
            border: Border.all(color: Colors.white.withAlpha(100), width: 1.5),
            boxShadow: [
              BoxShadow(color: segment.color.withAlpha(100), blurRadius: 14, spreadRadius: 1),
              BoxShadow(color: segment.color.withAlpha(40), blurRadius: 30, spreadRadius: 4),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(children: [
              Positioned.fill(child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-1.5 + shimmer * 4, -1), end: Alignment(-0.5 + shimmer * 4, 1),
                  colors: [Colors.transparent, Colors.white.withAlpha(45), Colors.transparent],
                ).createShader(bounds),
                blendMode: BlendMode.srcATop,
                child: Container(color: Colors.white.withAlpha(10)),
              )),
              Positioned(top: -10, right: -10, child: Container(width: 50, height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withAlpha(40), Colors.transparent])))),
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  segment.iconName != null
                      ? Text(segment.iconName!, style: const TextStyle(fontSize: 24))
                      : Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withAlpha(35), Colors.transparent], radius: 0.8)),
                          child: Icon(Icons.auto_awesome_rounded, size: 22, color: textColor.withAlpha(220)),
                        ),
                  const SizedBox(height: 4),
                  Text(segment.label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold, height: 1.2,
                    shadows: [Shadow(color: Colors.black.withAlpha(60), blurRadius: 4)]),
                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.black.withAlpha(30)),
                    child: Text('#${index + 1}', style: TextStyle(color: textColor.withAlpha(160), fontSize: 10)),
                  ),
                ]),
              )),
            ]),
          ),
        );
      },
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
}

class _PrizeStat {
  final String label;
  final Color color;
  final String? icon;
  int count;
  _PrizeStat(this.label, this.color, this.icon, this.count);
}
