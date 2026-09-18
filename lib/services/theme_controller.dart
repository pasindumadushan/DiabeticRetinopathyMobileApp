import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide light/dark theme state, persisted to disk so the choice survives
/// app restarts. Listen to it with a [ListenableBuilder]/[AnimatedBuilder]
/// (see `main.dart`) and flip it from the Settings screen.
class ThemeController extends ChangeNotifier {
  ThemeController._internal();

  static final ThemeController instance = ThemeController._internal();

  static const String _prefsKey = 'dark_mode_enabled';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Loads the saved preference. Call once at app startup, before [runApp].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefsKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}
