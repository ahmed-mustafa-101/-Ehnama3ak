import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier {
  static const String _themeKey = 'is_dark_mode';
  static SharedPreferences? _prefs;

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    final isDark = _prefs?.getBool(_themeKey) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggleTheme() {
    final isDark = themeMode.value == ThemeMode.light;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs?.setBool(_themeKey, isDark);
  }
}
