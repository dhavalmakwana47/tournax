import 'package:flutter/material.dart';

class PosterThemeModel {
  const PosterThemeModel({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.tableRowColor,
    required this.textColor,
    required this.textSecondaryColor,
  });

  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color tableRowColor;
  final Color textColor;
  final Color textSecondaryColor;

  static List<PosterThemeModel> get defaultThemes => [
        const PosterThemeModel(
          name: 'Green',
          primaryColor: Color(0xFF00E676),
          secondaryColor: Color(0xFF1B5E20),
          accentColor: Color(0xFFAEEA00),
          tableRowColor: Color(0x3300E676),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFB0BEC5),
        ),
        const PosterThemeModel(
          name: 'Red',
          primaryColor: Color(0xFFFF1744),
          secondaryColor: Color(0xFFB71C1C),
          accentColor: Color(0xFFFF5252),
          tableRowColor: Color(0x33FF1744),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFE0E0E0),
        ),
        const PosterThemeModel(
          name: 'Blue',
          primaryColor: Color(0xFF2979FF),
          secondaryColor: Color(0xFF0D47A1),
          accentColor: Color(0xFF82B1FF),
          tableRowColor: Color(0x332979FF),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFCFD8DC),
        ),
        const PosterThemeModel(
          name: 'Purple',
          primaryColor: Color(0xFFD500F9),
          secondaryColor: Color(0xFF4A148C),
          accentColor: Color(0xFFE040FB),
          tableRowColor: Color(0x33D500F9),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFE1BEE7),
        ),
        const PosterThemeModel(
          name: 'Gold',
          primaryColor: Color(0xFFFFD600),
          secondaryColor: Color(0xFFF57F17),
          accentColor: Color(0xFFFFEA00),
          tableRowColor: Color(0x33FFD600),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFFFF9C4),
        ),
        const PosterThemeModel(
          name: 'White',
          primaryColor: Color(0xFFFFFFFF),
          secondaryColor: Color(0xFF757575),
          accentColor: Color(0xFFBDBDBD),
          tableRowColor: Color(0x33FFFFFF),
          textColor: Colors.black,
          textSecondaryColor: Color(0xFF424242),
        ),
        const PosterThemeModel(
          name: 'Black',
          primaryColor: Color(0xFF212121),
          secondaryColor: Color(0xFF000000),
          accentColor: Color(0xFF424242),
          tableRowColor: Color(0x33424242),
          textColor: Colors.white,
          textSecondaryColor: Color(0xFFBDBDBD),
        ),
      ];
}
