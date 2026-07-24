import 'package:flutter/material.dart';

class WidgetThemeModel {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardBackground;
  final Color cardBorderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color slotBadgeColor;
  final Color slotBadgeTextColor;

  const WidgetThemeModel({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardBackground,
    required this.cardBorderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.slotBadgeColor,
    required this.slotBadgeTextColor,
  });

  factory WidgetThemeModel.fromJson(Map<String, dynamic> json) {
    Color parseHex(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      try {
        final buffer = StringBuffer();
        if (hex.length == 6 || hex.length == 7) buffer.write('ff');
        buffer.write(hex.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (_) {
        return fallback;
      }
    }

    return WidgetThemeModel(
      primaryColor: parseHex(json['primary_color'], const Color(0xFF00FFCC)),
      secondaryColor: parseHex(json['secondary_color'], const Color(0xFFFF0055)),
      accentColor: parseHex(json['accent_color'], const Color(0xFFFFE600)),
      backgroundColor: parseHex(json['background_color'], const Color(0xFF0D0E15)),
      cardBackground: parseHex(json['card_background'], const Color(0xFF161922)),
      cardBorderColor: parseHex(json['card_border_color'], const Color(0xFF2A2F3D)),
      textPrimary: parseHex(json['text_primary'], Colors.white),
      textSecondary: parseHex(json['text_secondary'], const Color(0xFF8A94A6)),
      slotBadgeColor: parseHex(json['slot_badge_color'], const Color(0xFF00FFCC)),
      slotBadgeTextColor: parseHex(json['slot_badge_text_color'], Colors.black),
    );
  }

  Map<String, dynamic> toJson() => {
        'primary_color': '#${primaryColor.value.toRadixString(16).substring(2)}',
        'secondary_color': '#${secondaryColor.value.toRadixString(16).substring(2)}',
        'accent_color': '#${accentColor.value.toRadixString(16).substring(2)}',
        'background_color': '#${backgroundColor.value.toRadixString(16).substring(2)}',
        'card_background': '#${cardBackground.value.toRadixString(16).substring(2)}',
        'card_border_color': '#${cardBorderColor.value.toRadixString(16).substring(2)}',
        'text_primary': '#${textPrimary.value.toRadixString(16).substring(2)}',
        'text_secondary': '#${textSecondary.value.toRadixString(16).substring(2)}',
        'slot_badge_color': '#${slotBadgeColor.value.toRadixString(16).substring(2)}',
        'slot_badge_text_color': '#${slotBadgeTextColor.value.toRadixString(16).substring(2)}',
      };
}
