import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme_config.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'selected_theme';
  AppTheme _current = AppThemes.all.first;

  AppTheme get current => _current;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key) ?? AppThemes.all.first.id;
    _current = AppThemes.findById(id);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _current = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.id);
  }
}