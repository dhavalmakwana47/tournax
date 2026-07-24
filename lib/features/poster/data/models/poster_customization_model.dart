import 'package:flutter/material.dart';

class PosterCustomizationModel {
  const PosterCustomizationModel({
    required this.eventName,
    required this.organizerName,
    required this.subTitle,
    required this.week,
    required this.round,
    this.eventLogoPath,
    this.sponsorLogoPaths = const [],
    this.customBgPath,
    this.primaryColorOverride,
    this.secondaryColorOverride,
    required this.fontFamily,
    this.socialLinks = const {},
    required this.watermark,
    this.blurAmountOverride,
    this.opacity = 1.0,
    this.darkOverlayOpacity = 0.5,
    this.showGradientOverlay = true,
  });

  final String eventName;
  final String organizerName;
  final String subTitle;
  final String week;
  final String round;
  final String? eventLogoPath;
  final List<String> sponsorLogoPaths;
  final String? customBgPath;
  final Color? primaryColorOverride;
  final Color? secondaryColorOverride;
  final String fontFamily; // e.g., 'Bebas Neue', 'Anton', 'Oswald', 'Montserrat', 'Poppins'
  final Map<String, String> socialLinks; // e.g., {'instagram': 'tournax', 'youtube': 'tournax'}
  final String watermark;
  final double? blurAmountOverride;
  final double opacity;
  final double darkOverlayOpacity;
  final bool showGradientOverlay;

  PosterCustomizationModel copyWith({
    String? eventName,
    String? organizerName,
    String? subTitle,
    String? week,
    String? round,
    String? eventLogoPath,
    List<String>? sponsorLogoPaths,
    String? customBgPath,
    Color? primaryColorOverride,
    Color? secondaryColorOverride,
    String? fontFamily,
    Map<String, String>? socialLinks,
    String? watermark,
    double? blurAmountOverride,
    double? opacity,
    double? darkOverlayOpacity,
    bool? showGradientOverlay,
    bool clearEventLogo = false,
    bool clearCustomBg = false,
    bool clearPrimaryColorOverride = false,
    bool clearSecondaryColorOverride = false,
    bool clearBlurOverride = false,
  }) =>
      PosterCustomizationModel(
        eventName: eventName ?? this.eventName,
        organizerName: organizerName ?? this.organizerName,
        subTitle: subTitle ?? this.subTitle,
        week: week ?? this.week,
        round: round ?? this.round,
        eventLogoPath: clearEventLogo ? null : eventLogoPath ?? this.eventLogoPath,
        sponsorLogoPaths: sponsorLogoPaths ?? this.sponsorLogoPaths,
        customBgPath: clearCustomBg ? null : customBgPath ?? this.customBgPath,
        primaryColorOverride: clearPrimaryColorOverride ? null : primaryColorOverride ?? this.primaryColorOverride,
        secondaryColorOverride: clearSecondaryColorOverride ? null : secondaryColorOverride ?? this.secondaryColorOverride,
        fontFamily: fontFamily ?? this.fontFamily,
        socialLinks: socialLinks ?? this.socialLinks,
        watermark: watermark ?? this.watermark,
        blurAmountOverride: clearBlurOverride ? null : blurAmountOverride ?? this.blurAmountOverride,
        opacity: opacity ?? this.opacity,
        darkOverlayOpacity: darkOverlayOpacity ?? this.darkOverlayOpacity,
        showGradientOverlay: showGradientOverlay ?? this.showGradientOverlay,
      );
}
