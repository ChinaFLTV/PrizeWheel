import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    final currentThemeLabel = switch (settings.themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };

    final currentLocaleLabel = SettingsProvider.supportedLocales
        .firstWhere(
          (item) => item.locale.languageCode == settings.locale.languageCode && item.locale.scriptCode == settings.locale.scriptCode,
          orElse: () => SettingsProvider.supportedLocales.first,
        )
        .label;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTab)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Theme
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.palette_rounded, color: theme.colorScheme.primary),
              title: Text(l10n.theme),
              subtitle: Text(currentThemeLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showThemeSheet(context, settings, l10n, theme),
            ),
          ),

          // Language
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.language_rounded, color: theme.colorScheme.primary),
              title: Text(l10n.language),
              subtitle: Text(currentLocaleLabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showLanguageSheet(context, settings, l10n, theme),
            ),
          ),

          // About
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
              title: Text(l10n.aboutApp),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showAboutSheet(context, l10n, theme),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, SettingsProvider settings, AppLocalizations l10n, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Icon(Icons.palette_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(l10n.theme, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(),
            _buildThemeOption(ctx, settings, ThemeMode.system, Icons.brightness_auto_rounded, l10n.themeSystem, theme),
            _buildThemeOption(ctx, settings, ThemeMode.light, Icons.light_mode_rounded, l10n.themeLight, theme),
            _buildThemeOption(ctx, settings, ThemeMode.dark, Icons.dark_mode_rounded, l10n.themeDark, theme),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext ctx, SettingsProvider settings, ThemeMode mode, IconData icon, String label, ThemeData theme) {
    final isSelected = settings.themeMode == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
      onTap: () {
        settings.setThemeMode(mode);
        Navigator.pop(ctx);
      },
    );
  }

  void _showLanguageSheet(BuildContext context, SettingsProvider settings, AppLocalizations l10n, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Icon(Icons.language_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(l10n.language, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Divider(),
            ...SettingsProvider.supportedLocales.map((item) {
              final isSelected = settings.locale.languageCode == item.locale.languageCode &&
                  settings.locale.scriptCode == item.locale.scriptCode;
              return ListTile(
                title: Text(item.label),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
                onTap: () {
                  settings.setLocale(item.locale);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.casino_rounded, size: 40, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(l10n.appTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${l10n.version} 1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 16),
              Text(l10n.appDescription, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Text('${l10n.developer}: FLLife', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
