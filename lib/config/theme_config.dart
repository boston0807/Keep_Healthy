import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color bg;
  final Color bgSecondary;
  final Color card;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  const AppTheme({
    required this.id,
    required this.name,
    required this.bg,
    required this.bgSecondary,
    required this.card,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class AppThemes {
  static const List<AppTheme> all = [
    AppTheme(
      id: 'dark_blue',
      name: 'Dark Blue',
      bg: Color(0xFF0F1117),
      bgSecondary: Color(0xFF2E2E2E),
      card: Color(0xFF1A1F35),
      accent: Color(0xFF4F8EF7),
      textPrimary: Color(0xFFEEF0F8),
      textSecondary: Color(0xFF7B82A3),
    ),
    AppTheme(
      id: 'light',
      name: 'Light',
      bg: Color(0xFFF5F7FA),
      bgSecondary: Color.fromARGB(255, 192, 192, 192),
      card: Color.fromARGB(255, 255, 250, 250),
      accent: Color(0xFF4F8EF7),
      textPrimary: Color.fromARGB(255, 0, 0, 0),
      textSecondary: Color.fromARGB(255, 57, 58, 63),
    ),
  ];

  static AppTheme findById(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}