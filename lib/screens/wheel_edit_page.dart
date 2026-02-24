import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/wheel_model.dart';
import '../providers/wheel_provider.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/wheel_painter.dart';

const _defaultColors = [
  Color(0xFFE53935), Color(0xFF1E88E5), Color(0xFF43A047),
  Color(0xFFFDD835), Color(0xFFFF8F00), Color(0xFF8E24AA),
  Color(0xFF00ACC1), Color(0xFFF4511E), Color(0xFF5E35B1),
  Color(0xFF00897B), Color(0xFFD81B60), Color(0xFF7CB342),
];

const _overlayPresets = [
  Color(0x00000000), // none (transparent)
  Color(0x30000000), // dark
  Color(0x20FFFFFF), // light
  Color(0x251A237E), // deep blue
  Color(0x254E342E), // warm brown
  Color(0x25880E4F), // magenta
];

class WheelEditPage extends StatefulWidget {
  final WheelModel? wheel;
  const WheelEditPage({super.key, this.wheel});

  @override
  State<WheelEditPage> createState() => _WheelEditPageState();
}

class _WheelEditPageState extends State<WheelEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late WheelStyle _style;
  late WheelSize _size;
  late WheelForm _form;
  late double _spinDuration;
  late SpinSpeed _spinSpeed;
  late PointerPosition _pointerPosition;
  late PointerStyle _pointerStyle;
  late bool _showResult;
  late bool _enableSound;
  late bool _is3D;
  late String? _backgroundImagePath;
  late bool _bgBlurEnabled;
  late double _bgBlurIntensity;
  late double _bgOpacity;
  late int _bgOverlayColor;
  late List<WheelSegment> _segments;

  // Controllers for probability and ratio fields, keyed by segment id
  final Map<String, TextEditingController> _probControllers = {};
  final Map<String, TextEditingController> _ratioControllers = {};

  bool get _isEditing => widget.wheel != null;

  @override
  void initState() {
    super.initState();
    final w = widget.wheel;
    _titleController.text = w?.title ?? '';
    _style = w?.style ?? WheelStyle.classic;
    _size = w?.size ?? WheelSize.medium;
    _form = w?.form ?? WheelForm.standard;
    _spinDuration = w?.spinDuration ?? 5.0;
    _spinSpeed = w?.spinSpeed ?? SpinSpeed.normal;
    _pointerPosition = w?.pointerPosition ?? PointerPosition.top;
    _pointerStyle = w?.pointerStyle ?? PointerStyle.classic;
    _showResult = w?.showResult ?? true;
    _enableSound = w?.enableSound ?? true;
    _is3D = w?.is3D ?? false;
    _backgroundImagePath = w?.backgroundImagePath;
    _bgBlurEnabled = w?.bgBlurEnabled ?? false;
    _bgBlurIntensity = w?.bgBlurIntensity ?? 10.0;
    _bgOpacity = w?.bgOpacity ?? 1.0;
    _bgOverlayColor = w?.bgOverlayColor ?? 0x00000000;
    _segments = w?.segments.map((s) => WheelSegment(
      id: s.id, label: s.label, probability: s.probability,
      color: s.color, ratio: s.ratio, iconName: s.iconName,
      iconSize: s.iconSize, iconRotation: s.iconRotation,
    )).toList() ?? [];

    if (_segments.isEmpty) {
      _addDefaultSegments();
    }
    _initSegmentControllers();
  }

  void _initSegmentControllers() {
    _probControllers.clear();
    _ratioControllers.clear();
    for (final s in _segments) {
      _probControllers[s.id] = TextEditingController(text: s.probability.toStringAsFixed(1));
      _ratioControllers[s.id] = TextEditingController(text: s.ratio.toStringAsFixed(1));
    }
  }

  void _addDefaultSegments() {
    for (int i = 0; i < 4; i++) {
      _segments.add(WheelSegment(
        id: const Uuid().v4(),
        label: '',
        probability: 25,
        color: _defaultColors[i % _defaultColors.length],
        ratio: 1.0,
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _probControllers.values) {
      c.dispose();
    }
    for (final c in _ratioControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editWheel : l10n.createWheel,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_rounded),
            tooltip: l10n.preview,
            onPressed: _segments.length >= 2 ? _showPreview : null,
          ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.save),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.wheelTitle,
                hintText: l10n.wheelTitleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 20),

            // Style & Size row
            Row(
              children: [
                Expanded(child: _buildDropdown<WheelStyle>(
                  label: l10n.wheelStyle,
                  value: _style,
                  items: WheelStyle.values,
                  labelFn: (v) => _styleLabel(l10n, v),
                  onChanged: (v) => setState(() => _style = v!),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown<WheelSize>(
                  label: l10n.wheelSize,
                  value: _size,
                  items: WheelSize.values,
                  labelFn: (v) => _sizeLabel(l10n, v),
                  onChanged: (v) => setState(() => _size = v!),
                )),
              ],
            ),
            const SizedBox(height: 12),

            // Form & Speed row
            Row(
              children: [
                Expanded(child: _buildDropdown<WheelForm>(
                  label: l10n.wheelForm,
                  value: _form,
                  items: WheelForm.values,
                  labelFn: (v) => _formLabel(l10n, v),
                  onChanged: (v) => setState(() => _form = v!),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown<SpinSpeed>(
                  label: l10n.spinSpeed,
                  value: _spinSpeed,
                  items: SpinSpeed.values,
                  labelFn: (v) => _speedLabel(l10n, v),
                  onChanged: (v) => setState(() => _spinSpeed = v!),
                )),
              ],
            ),
            const SizedBox(height: 12),

            // Pointer position & style row
            Row(
              children: [
                Expanded(child: _buildDropdown<PointerPosition>(
                  label: l10n.pointerPosition,
                  value: _pointerPosition,
                  items: PointerPosition.values,
                  labelFn: (v) => _pointerLabel(l10n, v),
                  onChanged: (v) => setState(() => _pointerPosition = v!),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown<PointerStyle>(
                  label: l10n.pointerStyle,
                  value: _pointerStyle,
                  items: PointerStyle.values,
                  labelFn: (v) => _pointerStyleLabel(l10n, v),
                  onChanged: (v) => setState(() => _pointerStyle = v!),
                )),
              ],
            ),
            const SizedBox(height: 12),

            // Duration slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.spinDuration}: ${_spinDuration.toStringAsFixed(1)}s',
                    style: theme.textTheme.bodySmall),
                Slider(
                  value: _spinDuration,
                  min: 2,
                  max: 15,
                  divisions: 26,
                  onChanged: (v) => setState(() => _spinDuration = v),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Switches
            SwitchListTile(
              title: Text(l10n.showResult),
              value: _showResult,
              onChanged: (v) => setState(() => _showResult = v),
            ),
            SwitchListTile(
              title: Text(l10n.enableSound),
              value: _enableSound,
              onChanged: (v) => setState(() => _enableSound = v),
            ),
            SwitchListTile(
              title: Text(l10n.mode3D),
              secondary: Icon(_is3D ? Icons.view_in_ar_rounded : Icons.crop_square_rounded),
              value: _is3D,
              onChanged: (v) => setState(() => _is3D = v),
            ),
            ListTile(
              leading: const Icon(Icons.image_rounded),
              title: Text(l10n.backgroundImage),
              subtitle: _backgroundImagePath != null
                  ? Text(_backgroundImagePath!, overflow: TextOverflow.ellipsis, maxLines: 1)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_backgroundImagePath != null)
                    IconButton(
                      icon: Icon(Icons.clear_rounded, color: theme.colorScheme.error),
                      tooltip: l10n.clearImage,
                      onPressed: () => setState(() => _backgroundImagePath = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.photo_library_rounded),
                    tooltip: l10n.pickImage,
                    onPressed: _pickBackgroundImage,
                  ),
                ],
              ),
            ),

            // Background texture settings (only visible when image is set)
            if (_backgroundImagePath != null) ...[
              const SizedBox(height: 4),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gaussian blur toggle + intensity
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.bgBlur),
                        secondary: const Icon(Icons.blur_on_rounded),
                        value: _bgBlurEnabled,
                        onChanged: (v) => setState(() => _bgBlurEnabled = v),
                      ),
                      if (_bgBlurEnabled) ...[
                        Text('${l10n.bgBlurIntensity}: ${_bgBlurIntensity.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall),
                        Slider(
                          value: _bgBlurIntensity,
                          min: 1,
                          max: 30,
                          divisions: 29,
                          onChanged: (v) => setState(() => _bgBlurIntensity = v),
                        ),
                      ],
                      const Divider(height: 8),
                      // Opacity
                      Text('${l10n.bgOpacity}: ${(_bgOpacity * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall),
                      Slider(
                        value: _bgOpacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 18,
                        onChanged: (v) => setState(() => _bgOpacity = v),
                      ),
                      const Divider(height: 8),
                      // Overlay color
                      Row(
                        children: [
                          Text(l10n.bgOverlayColor, style: theme.textTheme.bodySmall),
                          const Spacer(),
                          ..._overlayPresets.map((preset) => Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _bgOverlayColor = preset.toARGB32()),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: preset,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _bgOverlayColor == preset.toARGB32()
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withAlpha(60),
                                    width: _bgOverlayColor == preset.toARGB32() ? 2.5 : 1,
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],

            const Divider(height: 32),

            // Segments header
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.segments, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: _autoBalanceProbability,
                  icon: const Icon(Icons.balance_rounded, size: 16),
                  label: Text(l10n.probabilityAutoBalance, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                TextButton.icon(
                  onPressed: _autoBalanceRatio,
                  icon: const Icon(Icons.equalizer_rounded, size: 16),
                  label: Text(l10n.ratioAutoBalance, style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Segment list
            ..._segments.asMap().entries.map((entry) => _buildSegmentCard(entry.key, entry.value, l10n, theme)),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addSegment,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addSegment),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelFn,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(labelFn(e), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSegmentCard(int index, WheelSegment segment, AppLocalizations l10n, ThemeData theme) {
    return Card(
      key: ValueKey(segment.id),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onPrimaryContainer)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: segment.label,
                    decoration: InputDecoration(
                      labelText: l10n.segmentLabel,
                      hintText: l10n.segmentLabelHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => segment.label = v,
                    validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  tooltip: l10n.deleteSegment,
                  onPressed: _segments.length > 2
                      ? () => setState(() {
                          final removed = _segments.removeAt(index);
                          _probControllers.remove(removed.id)?.dispose();
                          _ratioControllers.remove(removed.id)?.dispose();
                        })
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Color picker
                GestureDetector(
                  onTap: () async {
                    final color = await showDialog<Color>(
                      context: context,
                      builder: (_) => ColorPickerDialog(initialColor: segment.color),
                    );
                    if (color != null) setState(() => segment.color = color);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline.withAlpha(80)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Probability
                Expanded(
                  child: TextFormField(
                    controller: _probControllers[segment.id],
                    decoration: InputDecoration(
                      labelText: l10n.segmentProbability,
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: '%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) segment.probability = val;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Ratio
                Expanded(
                  child: TextFormField(
                    controller: _ratioControllers[segment.id],
                    decoration: InputDecoration(
                      labelText: l10n.segmentRatio,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null && val > 0) segment.ratio = val;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Emoji icon row
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showEmojiPicker(segment),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.outline.withAlpha(80)),
                    ),
                    alignment: Alignment.center,
                    child: segment.iconName != null
                        ? Text(segment.iconName!, style: const TextStyle(fontSize: 20))
                        : Icon(Icons.emoji_emotions_outlined, size: 18, color: theme.colorScheme.outline),
                  ),
                ),
                const SizedBox(width: 8),
                Text(l10n.segmentIcon, style: theme.textTheme.bodySmall),
                if (segment.iconName != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() {
                      segment.iconName = null;
                      segment.iconSize = 1.0;
                      segment.iconRotation = 0.0;
                    }),
                    child: Icon(Icons.clear_rounded, size: 16, color: theme.colorScheme.error),
                  ),
                ],
              ],
            ),
            // Emoji size & rotation sliders (only when icon is set)
            if (segment.iconName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.format_size_rounded, size: 16, color: theme.colorScheme.outline),
                  Expanded(
                    child: Slider(
                      value: segment.iconSize,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (v) => setState(() => segment.iconSize = v),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text('${(segment.iconSize * 100).toInt()}%',
                        style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.rotate_right_rounded, size: 16, color: theme.colorScheme.outline),
                  Expanded(
                    child: Slider(
                      value: segment.iconRotation,
                      min: -3.14159,
                      max: 3.14159,
                      divisions: 24,
                      onChanged: (v) => setState(() => segment.iconRotation = v),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text('${(segment.iconRotation * 180 / 3.14159).toInt()}°',
                        style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _emojiCategories = <String, List<String>>{
    '😀': ['😀','😂','🤣','😊','😍','🥰','😎','🤩','😇','🥳','😋','🤗','🤔','😏','😴','🤯','🥺','😱','😈','🤡'],
    '🎉': ['🎉','🎊','🎁','🎈','🏆','🥇','🥈','🥉','🎯','🎲','🎰','🎳','🎮','🕹️','🎵','🎶','🎸','🎺','🎭','🎬'],
    '🍕': ['🍕','🍔','🍟','🌭','🍿','🧁','🍰','🎂','🍩','🍪','🍫','🍬','🍭','🍮','🍯','🍎','🍉','🍇','🍓','🥝'],
    '🐶': ['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🐔','🐧','🐦','🦄','🐝'],
    '⚽': ['⚽','🏀','🏈','⚾','🎾','🏐','🏉','🎱','🏓','🏸','🥊','🏋️','🚴','🏊','🤸','⛷️','🏂','🏄','🧗','🤺'],
    '❤️': ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟','♥️','🫶'],
    '🌟': ['🌟','⭐','✨','💫','🔥','💥','🌈','☀️','🌙','⚡','❄️','🌊','🍀','🌸','🌺','🌻','🌹','💎','👑','🔮'],
    '🚗': ['🚗','🚕','🚌','🏎️','🚓','🚑','🚒','✈️','🚀','🛸','🚁','⛵','🚢','🚂','🏠','🏰','🗼','🎡','🎢','🗽'],
  };

  void _showEmojiPicker(WheelSegment segment) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String selectedCategory = _emojiCategories.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(l10n.segmentIcon, style: theme.textTheme.titleMedium),
                    const Spacer(),
                    if (segment.iconName != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            segment.iconName = null;
                            segment.iconSize = 1.0;
                            segment.iconRotation = 0.0;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(l10n.clearImage),
                      ),
                  ],
                ),
              ),
              // Category tabs
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: _emojiCategories.keys.map((cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 18)),
                      selected: selectedCategory == cat,
                      onSelected: (_) => setSheetState(() => selectedCategory = cat),
                      visualDensity: VisualDensity.compact,
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _emojiCategories[selectedCategory]!.length,
                  itemBuilder: (_, i) {
                    final emoji = _emojiCategories[selectedCategory]![i];
                    final isSelected = segment.iconName == emoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() => segment.iconName = emoji);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primaryContainer : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSegment() {
    setState(() {
      final segment = WheelSegment(
        id: const Uuid().v4(),
        label: '',
        probability: 0,
        color: _defaultColors[_segments.length % _defaultColors.length],
        ratio: 1.0,
      );
      _segments.add(segment);
      _probControllers[segment.id] = TextEditingController(text: segment.probability.toStringAsFixed(1));
      _ratioControllers[segment.id] = TextEditingController(text: segment.ratio.toStringAsFixed(1));
    });
  }

  void _autoBalanceProbability() {
    if (_segments.isEmpty) return;
    final each = double.parse((100.0 / _segments.length).toStringAsFixed(1));
    setState(() {
      for (final s in _segments) {
        s.probability = each;
        _probControllers[s.id]?.text = each.toStringAsFixed(1);
      }
    });
  }

  void _autoBalanceRatio() {
    setState(() {
      for (final s in _segments) {
        s.ratio = 1.0;
        _ratioControllers[s.id]?.text = '1.0';
      }
    });
  }

  void _showPreview() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_titleController.text.isEmpty ? l10n.preview : _titleController.text,
                  style: Theme.of(dialogCtx).textTheme.titleLarge),
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: WheelPainter(segments: _segments, style: _style, form: _form),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Proportionally scale all segment probabilities so they sum to exactly 100%.
  void _normalizeProbabilities() {
    final total = _segments.fold<double>(0, (sum, s) => sum + s.probability);
    if (total <= 0 || total == 100.0) return;
    final scale = 100.0 / total;
    for (final s in _segments) {
      s.probability = double.parse((s.probability * scale).toStringAsFixed(1));
      _probControllers[s.id]?.text = s.probability.toStringAsFixed(1);
    }
    // Fix rounding residual: adjust the largest segment
    final residual = 100.0 - _segments.fold<double>(0, (sum, s) => sum + s.probability);
    if (residual.abs() > 0.001) {
      final largest = _segments.reduce((a, b) => a.probability >= b.probability ? a : b);
      largest.probability = double.parse((largest.probability + residual).toStringAsFixed(1));
      _probControllers[largest.id]?.text = largest.probability.toStringAsFixed(1);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_segments.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.validationMinSegments)),
      );
      return;
    }

    // Normalize probabilities so they sum to exactly 100%
    _normalizeProbabilities();

    final now = DateTime.now();
    final wheel = WheelModel(
      id: widget.wheel?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      style: _style,
      size: _size,
      form: _form,
      spinDuration: _spinDuration,
      spinSpeed: _spinSpeed,
      pointerPosition: _pointerPosition,
      pointerStyle: _pointerStyle,
      showResult: _showResult,
      enableSound: _enableSound,
      is3D: _is3D,
      backgroundImagePath: _backgroundImagePath,
      bgBlurEnabled: _bgBlurEnabled,
      bgBlurIntensity: _bgBlurIntensity,
      bgOpacity: _bgOpacity,
      bgOverlayColor: _bgOverlayColor,
      segments: _segments,
      createdAt: widget.wheel?.createdAt ?? now,
      updatedAt: now,
    );

    final provider = context.read<WheelProvider>();
    if (_isEditing) {
      await provider.updateWheel(wheel);
    } else {
      await provider.addWheel(wheel);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.savedSuccess)),
    );
    Navigator.pop(context);
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${const Uuid().v4()}${p.extension(picked.path)}';
    final savedFile = await File(picked.path).copy(p.join(appDir.path, fileName));
    if (!mounted) return;
    setState(() => _backgroundImagePath = savedFile.path);
  }

  String _styleLabel(AppLocalizations l10n, WheelStyle s) => switch (s) {
    WheelStyle.classic => l10n.styleClassic,
    WheelStyle.neon => l10n.styleNeon,
    WheelStyle.candy => l10n.styleCandy,
    WheelStyle.elegant => l10n.styleElegant,
    WheelStyle.gradient => l10n.styleGradient,
    WheelStyle.retro => l10n.styleRetro,
    WheelStyle.ocean => l10n.styleOcean,
    WheelStyle.sunset => l10n.styleSunset,
    WheelStyle.metallic => l10n.styleMetallic,
    WheelStyle.pastel => l10n.stylePastel,
    WheelStyle.dark => l10n.styleDark,
    WheelStyle.rainbow => l10n.styleRainbow,
  };

  String _sizeLabel(AppLocalizations l10n, WheelSize s) => switch (s) {
    WheelSize.small => l10n.sizeSmall,
    WheelSize.medium => l10n.sizeMedium,
    WheelSize.large => l10n.sizeLarge,
  };

  String _formLabel(AppLocalizations l10n, WheelForm f) => switch (f) {
    WheelForm.standard => l10n.formStandard,
    WheelForm.petal => l10n.formPetal,
    WheelForm.star => l10n.formStar,
    WheelForm.polygon => l10n.formPolygon,
  };

  String _speedLabel(AppLocalizations l10n, SpinSpeed s) => switch (s) {
    SpinSpeed.slow => l10n.speedSlow,
    SpinSpeed.normal => l10n.speedNormal,
    SpinSpeed.fast => l10n.speedFast,
  };

  String _pointerLabel(AppLocalizations l10n, PointerPosition p) => switch (p) {
    PointerPosition.top => l10n.pointerTop,
    PointerPosition.right => l10n.pointerRight,
    PointerPosition.bottom => l10n.pointerBottom,
    PointerPosition.left => l10n.pointerLeft,
  };

  String _pointerStyleLabel(AppLocalizations l10n, PointerStyle s) => switch (s) {
    PointerStyle.classic => l10n.pointerStyleClassic,
    PointerStyle.arrow => l10n.pointerStyleArrow,
    PointerStyle.diamond => l10n.pointerStyleDiamond,
    PointerStyle.dot => l10n.pointerStyleDot,
    PointerStyle.flag => l10n.pointerStyleFlag,
  };
}
