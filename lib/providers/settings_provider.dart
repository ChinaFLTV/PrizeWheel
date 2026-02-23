import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('zh');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = (themeIndex >= 0 && themeIndex < ThemeMode.values.length)
        ? ThemeMode.values[themeIndex]
        : ThemeMode.system;

    final localeStr = prefs.getString(_localeKey) ?? 'zh';
    _locale = _parseLocale(localeStr);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, _localeToString(locale));
    notifyListeners();
  }

  String _localeToString(Locale locale) {
    if (locale.scriptCode != null) {
      return '${locale.languageCode}_${locale.scriptCode}';
    }
    return locale.languageCode;
  }

  Locale _parseLocale(String str) {
    if (str.contains('_')) {
      final parts = str.split('_');
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(str);
  }

  static const supportedLocales = [
    (locale: Locale('zh'), label: '简体中文'),
    (locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), label: '繁體中文'),
    (locale: Locale('en'), label: 'English'),
    (locale: Locale('fr'), label: 'Français'),
    (locale: Locale('de'), label: 'Deutsch'),
    (locale: Locale('ja'), label: '日本語'),
  ];
}
