import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/wheel_model.dart';
import '../providers/wheel_provider.dart';
import '../widgets/wheel_painter.dart';
import 'wheel_edit_page.dart';
import 'wheel_spin_page.dart';

class WheelListPage extends StatefulWidget {
  const WheelListPage({super.key});

  @override
  State<WheelListPage> createState() => _WheelListPageState();
}

class _WheelListPageState extends State<WheelListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WheelProvider>().loadWheels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<WheelProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wheelTab),
        actions: [
          if (provider.wheels.isNotEmpty && !provider.isSelectionMode)
            IconButton(
              icon: const Icon(Icons.checklist_rounded),
              tooltip: l10n.batchDelete,
              onPressed: () => provider.enterSelectionMode(),
            ),
          if (provider.isSelectionMode) ...[
            TextButton(
              onPressed: provider.selectedIds.length == provider.wheels.length
                  ? () => provider.deselectAll()
                  : () => provider.selectAll(),
              child: Text(
                provider.selectedIds.length == provider.wheels.length
                    ? l10n.deselectAll
                    : l10n.selectAll,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              tooltip: l10n.batchDelete,
              onPressed: provider.selectedIds.isEmpty
                  ? null
                  : () => _confirmBatchDelete(context, provider, l10n),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => provider.exitSelectionMode(),
            ),
          ],
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.wheels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.casino_outlined, size: 80, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(l10n.noWheels, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                )
              : _buildWheelList(provider, l10n, theme),
      floatingActionButton: provider.isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToEdit(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.createWheel),
            ),
    );
  }

  Widget _buildWheelList(WheelProvider provider, AppLocalizations l10n, ThemeData theme) {
    if (provider.isSelectionMode) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.primaryContainer.withAlpha(80),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.selected(provider.selectedIds.length),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          Expanded(child: _buildList(provider, l10n, theme)),
        ],
      );
    }
    return _buildList(provider, l10n, theme);
  }

  Widget _buildList(WheelProvider provider, AppLocalizations l10n, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: provider.wheels.length,
      itemBuilder: (context, index) {
        final wheel = provider.wheels[index];
        final isSelected = provider.selectedIds.contains(wheel.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: provider.isSelectionMode
                ? () => provider.toggleSelection(wheel.id)
                : () => _navigateToSpin(context, wheel),
            onLongPress: !provider.isSelectionMode
                ? () {
                    provider.enterSelectionMode();
                    provider.toggleSelection(wheel.id);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (provider.isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => provider.toggleSelection(wheel.id),
                      ),
                    ),
                  // Mini wheel preview
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CustomPaint(
                      painter: WheelPainter(
                        segments: wheel.segments,
                        style: wheel.style,
                        form: wheel.form,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wheel.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          l10n.totalSegments(wheel.segments.length),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  if (!provider.isSelectionMode)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _navigateToEdit(context, wheel);
                          case 'preview':
                            _navigateToSpin(context, wheel);
                          case 'delete':
                            _confirmDelete(context, wheel, l10n);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'preview', child: ListTile(leading: const Icon(Icons.play_arrow_rounded), title: Text(l10n.preview), dense: true, contentPadding: EdgeInsets.zero)),
                        PopupMenuItem(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_rounded), title: Text(l10n.edit), dense: true, contentPadding: EdgeInsets.zero)),
                        PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_rounded, color: theme.colorScheme.error), title: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)), dense: true, contentPadding: EdgeInsets.zero)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEdit(BuildContext context, WheelModel? wheel) {
    final provider = context.read<WheelProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WheelEditPage(wheel: wheel)),
    ).then((_) => provider.loadWheels());
  }

  void _navigateToSpin(BuildContext context, WheelModel wheel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WheelSpinPage(wheel: wheel)),
    );
  }

  void _confirmDelete(BuildContext context, WheelModel wheel, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.deleteWheelMsg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<WheelProvider>().deleteWheel(wheel.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.deletedSuccess)),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _confirmBatchDelete(BuildContext context, WheelProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirm),
        content: Text(l10n.batchDeleteMsg(provider.selectedIds.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteSelectedWheels();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.deletedSuccess)),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
