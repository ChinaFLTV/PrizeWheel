import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/wheel_model.dart';
import '../widgets/spinning_wheel.dart';
import 'spin_records_page.dart';

class WheelSpinPage extends StatefulWidget {
  final WheelModel wheel;
  const WheelSpinPage({super.key, required this.wheel});

  @override
  State<WheelSpinPage> createState() => _WheelSpinPageState();
}

class _WheelSpinPageState extends State<WheelSpinPage> {
  final _wheelKey = GlobalKey<SpinningWheelState>();
  final _db = DatabaseHelper();

  void _onResult(WheelSegment segment) {
    // Save spin record (fire-and-forget with error handling)
    _db.insertSpinRecord(SpinRecord(
      id: const Uuid().v4(),
      wheelId: widget.wheel.id,
      wheelTitle: widget.wheel.title,
      prizeName: segment.label,
      prizeColor: segment.color.toARGB32(),
      spinTime: DateTime.now(),
    )).catchError((e) {
      debugPrint('Error saving spin record: $e');
    });

    if (!widget.wheel.showResult) return;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.celebration_rounded, size: 48),
        title: Text(l10n.congratulations),
        content: Text(
          l10n.youWon(segment.label),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _wheelKey.currentState?.spin();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.spinAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(String path, WheelModel wheel) {
    Widget bg = Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    // Apply opacity
    if (wheel.bgOpacity < 1.0) {
      bg = Opacity(opacity: wheel.bgOpacity, child: bg);
    }

    // Apply gaussian blur
    if (wheel.bgBlurEnabled && wheel.bgBlurIntensity > 0) {
      bg = Stack(
        fit: StackFit.expand,
        children: [
          bg,
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: wheel.bgBlurIntensity,
                sigmaY: wheel.bgBlurIntensity,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      );
    }

    // Apply overlay color
    final overlayColor = Color(wheel.bgOverlayColor);
    if (overlayColor.a > 0) {
      bg = Stack(
        fit: StackFit.expand,
        children: [
          bg,
          ColoredBox(color: overlayColor),
        ],
      );
    }

    return bg;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bgPath = widget.wheel.backgroundImagePath;
    final hasBg = bgPath != null && File(bgPath).existsSync();

    Widget wheelWidget = SpinningWheel(
      key: _wheelKey,
      wheel: widget.wheel,
      onResult: _onResult,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wheel.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.spinRecords,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpinRecordsPage(
                  wheelId: widget.wheel.id,
                  wheelTitle: widget.wheel.title,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (hasBg)
            Positioned.fill(
              child: _buildBackground(bgPath, widget.wheel),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  wheelWidget,
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => _wheelKey.currentState?.spin(),
                    icon: const Icon(Icons.casino_rounded),
                    label: Text(l10n.spinTheWheel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: theme.textTheme.titleMedium,
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
}
