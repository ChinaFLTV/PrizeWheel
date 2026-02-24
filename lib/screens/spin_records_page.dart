import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../models/wheel_model.dart';

sealed class _RecordItem {}

class _SingleRecord extends _RecordItem {
  final SpinRecord record;
  final int globalIndex;
  final String dateStr;
  _SingleRecord(this.record, this.globalIndex) : dateStr = _dtFmt.format(record.spinTime);
}

class _BatchGroup extends _RecordItem {
  final String batchId;
  final List<SpinRecord> records;
  final int globalIndex;
  final String dateStr;
  late final List<_RecordPrizeStat> stats;
  _BatchGroup(this.batchId, this.records, this.globalIndex)
      : dateStr = _dtFmt.format(records.first.spinTime) {
    _computeStats();
  }
  void _computeStats() {
    final countMap = <String, _RecordPrizeStat>{};
    for (final r in records) {
      final s = countMap.putIfAbsent(r.prizeName, () => _RecordPrizeStat(r.prizeName, r.prizeColor, 0));
      s.count++;
    }
    stats = countMap.values.toList()..sort((a, b) => b.count.compareTo(a.count));
  }
}

final _dtFmt = DateFormat('yyyy-MM-dd HH:mm:ss');
final _timeFmt = DateFormat('HH:mm:ss');

// Isolate-friendly: group raw records into items + compute stats off main thread
class _BuildResult {
  final List<_RecordItem> items;
  final List<_RecordPrizeStat> stats;
  _BuildResult(this.items, this.stats);
}

_BuildResult _buildItemsSync(List<SpinRecord> records) {
  final items = <_RecordItem>[];
  int globalIdx = records.length;
  int i = 0;
  while (i < records.length) {
    final r = records[i];
    if (r.batchId == null) {
      items.add(_SingleRecord(r, globalIdx));
      globalIdx--;
      i++;
    } else {
      final batchId = r.batchId!;
      final batchRecords = <SpinRecord>[];
      while (i < records.length && records[i].batchId == batchId) {
        batchRecords.add(records[i]);
        i++;
      }
      items.add(_BatchGroup(batchId, batchRecords, globalIdx));
      globalIdx -= batchRecords.length;
    }
  }
  // Global stats
  final total = records.length;
  final countMap = <String, _RecordPrizeStat>{};
  if (total > 0) {
    for (final r in records) {
      final s = countMap.putIfAbsent(r.prizeName, () => _RecordPrizeStat(r.prizeName, r.prizeColor, 0));
      s.count++;
    }
  }
  final stats = countMap.values.toList()..sort((a, b) => b.count.compareTo(a.count));
  return _BuildResult(items, stats);
}

class SpinRecordsPage extends StatefulWidget {
  final String wheelId;
  final String wheelTitle;
  const SpinRecordsPage({super.key, required this.wheelId, required this.wheelTitle});

  @override
  State<SpinRecordsPage> createState() => _SpinRecordsPageState();
}

class _SpinRecordsPageState extends State<SpinRecordsPage> {
  final _db = DatabaseHelper();
  List<SpinRecord> _records = [];
  List<_RecordItem> _items = [];
  List<_RecordPrizeStat> _cachedStats = [];
  final Set<String> _expandedBatches = {};
  final Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try { _records = await _db.getSpinRecords(widget.wheelId); }
    catch (e) { debugPrint('Error loading spin records: $e'); }
    if (!mounted) return;
    // Build items off-frame to avoid jank on page transition
    final result = _buildItemsSync(_records);
    _items = result.items;
    _cachedStats = result.stats;
    setState(() => _isLoading = false);
  }

  void _rebuildItemsAndStats() {
    final result = _buildItemsSync(_records);
    _items = result.items;
    _cachedStats = result.stats;
  }

  void _enterSelectionMode() => setState(() => _isSelectionMode = true);

  void _exitSelectionMode() => setState(() {
    _isSelectionMode = false;
    _selectedIds.clear();
  });

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) { _selectedIds.remove(id); }
      else { _selectedIds.add(id); }
      if (_selectedIds.isEmpty) _isSelectionMode = false;
    });
  }

  void _selectAll() {
    setState(() {
      for (final r in _records) { _selectedIds.add(r.id); }
    });
  }

  Future<void> _deleteSelected(AppLocalizations l10n) async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.batchDeleteRecordsMsg(_selectedIds.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _db.deleteSpinRecords(_selectedIds.toList());
    _records.removeWhere((r) => _selectedIds.contains(r.id));
    _selectedIds.clear();
    _isSelectionMode = false;
    _rebuildItemsAndStats();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spinRecords),
        leading: _isSelectionMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _exitSelectionMode)
            : null,
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _selectedIds.length == _records.length ? () => setState(() => _selectedIds.clear()) : _selectAll,
              child: Text(_selectedIds.length == _records.length ? l10n.deselectAll : l10n.selectAll),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              tooltip: l10n.batchDeleteRecords,
              onPressed: _selectedIds.isEmpty ? null : () => _deleteSelected(l10n),
            ),
          ] else if (_records.isNotEmpty) ...[
            IconButton(icon: const Icon(Icons.bar_chart_rounded), tooltip: l10n.prizeSummary, onPressed: () => _showSummarySheet(l10n, theme)),
            IconButton(icon: const Icon(Icons.checklist_rounded), tooltip: l10n.batchDeleteRecords, onPressed: _enterSelectionMode),
            IconButton(icon: const Icon(Icons.delete_sweep_rounded), tooltip: l10n.clearAllRecords, onPressed: () => _confirmClearAll(l10n)),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(l10n.noRecords, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
                ]))
              : _buildBody(l10n, theme),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme) {
    return Column(children: [
      if (_isSelectionMode)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.primaryContainer.withAlpha(80),
          child: Row(children: [
            Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.selected(_selectedIds.length), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
          ]),
        ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return switch (item) {
              _SingleRecord() => _buildSingleCard(item, l10n, theme),
              _BatchGroup() => _buildBatchCard(item, l10n, theme),
            };
          },
        ),
      ),
    ]);
  }

  void _showSummarySheet(AppLocalizations l10n, ThemeData theme) {
    final total = _records.length;
    if (total == 0 || _cachedStats.isEmpty) return;
    final stats = _cachedStats;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Icon(Icons.bar_chart_rounded, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.prizeSummary, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('$total ${l10n.spinRecords}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: stats.length,
                itemBuilder: (ctx, i) {
                  final s = stats[i];
                  final pct = (s.count / total * 100).toStringAsFixed(1);
                  final ratio = s.count / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(s.prizeColor), shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: Text(s.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio, minHeight: 8,
                            backgroundColor: theme.colorScheme.outlineVariant.withAlpha(30),
                            valueColor: AlwaysStoppedAnimation(Color(s.prizeColor).withAlpha(200)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 72,
                        child: Text('${s.count}次 $pct%', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.right),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCard(_SingleRecord item, AppLocalizations l10n, ThemeData theme) {
    final record = item.record;
    final isSelected = _selectedIds.contains(record.id);

    final card = Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isSelectionMode ? () => _toggleSelect(record.id) : null,
        onLongPress: !_isSelectionMode ? () { _enterSelectionMode(); _toggleSelect(record.id); } : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Checkbox(value: isSelected, onChanged: (_) => _toggleSelect(record.id)),
              ),
            _buildBadge(record.prizeColor, '#${item.globalIndex}'),
            const SizedBox(width: 12),
            Expanded(child: _buildPrizeInfo(record, item.dateStr, theme)),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(l10n.singleSpin, style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer), overflow: TextOverflow.ellipsis),
              ),
            ),
          ]),
        ),
      ),
    );

    if (_isSelectionMode) return card;

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDeleteRecord(l10n),
      onDismissed: (_) => _deleteRecord(record.id),
      child: card,
    );
  }

  Widget _buildBatchCard(_BatchGroup group, AppLocalizations l10n, ThemeData theme) {
    final isExpanded = _expandedBatches.contains(group.batchId);
    final count = group.records.length;
    final allSelected = group.records.every((r) => _selectedIds.contains(r.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _isSelectionMode && allSelected ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        InkWell(
          onTap: _isSelectionMode
              ? () {
                  setState(() {
                    if (allSelected) { for (final r in group.records) { _selectedIds.remove(r.id); } }
                    else { for (final r in group.records) { _selectedIds.add(r.id); } }
                    if (_selectedIds.isEmpty) _isSelectionMode = false;
                  });
                }
              : () => setState(() {
                  if (isExpanded) { _expandedBatches.remove(group.batchId); }
                  else { _expandedBatches.add(group.batchId); }
                }),
          onLongPress: !_isSelectionMode ? () {
            _enterSelectionMode();
            setState(() { for (final r in group.records) { _selectedIds.add(r.id); } });
          } : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Checkbox(value: allSelected, onChanged: (_) {
                    setState(() {
                      if (allSelected) { for (final r in group.records) { _selectedIds.remove(r.id); } }
                      else { for (final r in group.records) { _selectedIds.add(r.id); } }
                      if (_selectedIds.isEmpty) _isSelectionMode = false;
                    });
                  }),
                ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [theme.colorScheme.tertiary.withAlpha(40), theme.colorScheme.primary.withAlpha(40)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.layers_rounded, size: 22, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Text(l10n.batchSpinCount(count), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onTertiaryContainer)),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.batchSpin, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 13, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Flexible(child: Text(group.dateStr, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), overflow: TextOverflow.ellipsis)),
                ]),
              ])),
              if (!_isSelectionMode)
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more_rounded, color: theme.colorScheme.outline),
                ),
            ]),
          ),
        ),
        // Only build children when actually expanded — no AnimatedCrossFade
        if (!_isSelectionMode && isExpanded)
          _buildBatchChildren(group, l10n, theme),
      ]),
    );
  }

  Widget _buildBatchChildren(_BatchGroup group, AppLocalizations l10n, ThemeData theme) {
    final records = group.records;
    // Cap visible items; show a "load more" hint for very large batches
    const maxVisible = 50;
    final showAll = records.length <= maxVisible || _expandedBatches.contains('${group.batchId}_all');
    final visibleCount = showAll ? records.length : maxVisible;

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withAlpha(40)),
      child: Column(children: [
        const Divider(height: 1),
        _buildBatchSummary(group, theme, l10n),
        const Divider(height: 1),
        for (int idx = 0; idx < visibleCount; idx++)
          _buildBatchChildTile(records[idx], idx, group, l10n, theme),
        if (!showAll)
          InkWell(
            onTap: () => setState(() => _expandedBatches.add('${group.batchId}_all')),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.expand_more_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text('${l10n.showAll} (${records.length - maxVisible}+)', style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _buildBatchChildTile(SpinRecord record, int idx, _BatchGroup group, AppLocalizations l10n, ThemeData theme) {
    final dateStr = _timeFmt.format(record.spinTime);
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16),
        color: theme.colorScheme.error.withAlpha(30),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error, size: 20),
      ),
      confirmDismiss: (_) => _confirmDeleteRecord(l10n),
      onDismissed: (_) => _deleteBatchRecord(record.id, group),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          _buildBadge(record.prizeColor, '#${idx + 1}', small: true),
          const SizedBox(width: 12),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(record.prizeColor), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(record.prizeName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Text(dateStr, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ]),
      ),
    );
  }

  Widget _buildBatchSummary(_BatchGroup group, ThemeData theme, AppLocalizations l10n) {
    final total = group.records.length;
    final stats = group.stats;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.pie_chart_outline_rounded, size: 15, color: theme.colorScheme.tertiary),
          const SizedBox(width: 5),
          Text(l10n.prizeSummary, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.tertiary)),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: stats.map((s) {
            final pct = (s.count / total * 100).toStringAsFixed(1);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(s.prizeColor).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(s.prizeColor).withAlpha(50)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(s.prizeColor), shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(s.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                const SizedBox(width: 4),
                Text('${s.count}次($pct%)', style: TextStyle(fontSize: 10, color: theme.colorScheme.outline)),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _buildBadge(int prizeColor, String text, {bool small = false}) {
    final size = small ? 32.0 : 44.0;
    final fontSize = small ? 11.0 : 14.0;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Color(prizeColor).withAlpha(30), borderRadius: BorderRadius.circular(small ? 8 : 12)),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: Color(prizeColor), fontSize: fontSize)),
    );
  }

  Widget _buildPrizeInfo(SpinRecord record, String dateStr, ThemeData theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(record.prizeColor), shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(record.prizeName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Flexible(child: Text(dateStr, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), overflow: TextOverflow.ellipsis)),
      ]),
    ]);
  }

  Future<bool> _confirmDeleteRecord(AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm), content: Text(l10n.deleteRecordMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: Text(l10n.delete)),
        ],
      ),
    );
    return result ?? false;
  }

  void _deleteRecord(String id) {
    _db.deleteSpinRecord(id);
    if (!mounted) return;
    _records.removeWhere((r) => r.id == id);
    _rebuildItemsAndStats();
    setState(() {});
  }

  void _deleteBatchRecord(String id, _BatchGroup group) {
    _db.deleteSpinRecord(id);
    if (!mounted) return;
    _records.removeWhere((r) => r.id == id);
    group.records.removeWhere((r) => r.id == id);
    if (group.records.isEmpty) { _expandedBatches.remove(group.batchId); }
    _rebuildItemsAndStats();
    setState(() {});
  }

  void _confirmClearAll(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm), content: Text(l10n.clearRecordsMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _db.deleteAllSpinRecords(widget.wheelId).catchError((e) { debugPrint('Error clearing: $e'); });
              if (!mounted) return;
              _records.clear(); _items.clear(); _cachedStats.clear(); _expandedBatches.clear(); _selectedIds.clear();
              _isSelectionMode = false;
              setState(() {});
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _RecordPrizeStat {
  final String label;
  final int prizeColor;
  int count;
  _RecordPrizeStat(this.label, this.prizeColor, this.count);
}
