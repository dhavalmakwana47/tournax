import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/poster_customization_model.dart';
import '../../data/models/poster_template_model.dart';
import '../../data/models/poster_theme_model.dart';
import '../../data/repositories/poster_repository.dart';
import '../../../tournament/domain/entities/match_entity.dart';

class PosterState extends Equatable {
  const PosterState({
    required this.customization,
    required this.selectedTemplate,
    required this.selectedTheme,
    this.templates = const [],
    this.themes = const [],
    required this.match,
    this.exporting = false,
  });

  final PosterCustomizationModel customization;
  final PosterTemplateModel selectedTemplate;
  final PosterThemeModel selectedTheme;
  final List<PosterTemplateModel> templates;
  final List<PosterThemeModel> themes;
  final MatchEntity match;
  final bool exporting;

  PosterState copyWith({
    PosterCustomizationModel? customization,
    PosterTemplateModel? selectedTemplate,
    PosterThemeModel? selectedTheme,
    List<PosterTemplateModel>? templates,
    List<PosterThemeModel>? themes,
    MatchEntity? match,
    bool? exporting,
  }) =>
      PosterState(
        customization: customization ?? this.customization,
        selectedTemplate: selectedTemplate ?? this.selectedTemplate,
        selectedTheme: selectedTheme ?? this.selectedTheme,
        templates: templates ?? this.templates,
        themes: themes ?? this.themes,
        match: match ?? this.match,
        exporting: exporting ?? this.exporting,
      );

  @override
  List<Object?> get props => [
        customization,
        selectedTemplate,
        selectedTheme,
        templates,
        themes,
        match,
        exporting,
      ];
}

class PosterController extends FamilyNotifier<PosterState, MatchEntity> {
  final _repository = PosterRepository();

  @override
  PosterState build(MatchEntity arg) {
    final templates = _repository.getTemplates();
    final themes = _repository.getThemes();
    final initialTemplate = templates.first;
    final initialTheme = themes.first;

    final initialCustomization = PosterCustomizationModel(
      eventName: arg.name ?? 'BGMI Showdown',
      organizerName: 'TournaX Esports',
      subTitle: 'SLOT LIST',
      week: 'Week 01',
      round: 'Round 01',
      fontFamily: 'Bebas Neue',
      watermark: 'POWERED BY TOURNAX',
      socialLinks: const {
        'instagram': '@tournax_app',
        'youtube': 'TournaX Gaming',
      },
    );

    return PosterState(
      customization: initialCustomization,
      selectedTemplate: initialTemplate,
      selectedTheme: initialTheme,
      templates: templates,
      themes: themes,
      match: arg,
    );
  }

  void updateEventName(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(eventName: val),
    );
  }

  void updateOrganizerName(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(organizerName: val),
    );
  }

  void updateSubTitle(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(subTitle: val),
    );
  }

  void updateWeek(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(week: val),
    );
  }

  void updateRound(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(round: val),
    );
  }

  void updateEventLogo(String? path) {
    if (path == null) {
      state = state.copyWith(
        customization: state.customization.copyWith(clearEventLogo: true),
      );
    } else {
      state = state.copyWith(
        customization: state.customization.copyWith(eventLogoPath: path),
      );
    }
  }

  void addSponsorLogo(String path) {
    final updated = List<String>.from(state.customization.sponsorLogoPaths)..add(path);
    state = state.copyWith(
      customization: state.customization.copyWith(sponsorLogoPaths: updated),
    );
  }

  void removeSponsorLogo(int index) {
    final updated = List<String>.from(state.customization.sponsorLogoPaths)..removeAt(index);
    state = state.copyWith(
      customization: state.customization.copyWith(sponsorLogoPaths: updated),
    );
  }

  void updateCustomBg(String? path) {
    if (path == null) {
      state = state.copyWith(
        customization: state.customization.copyWith(clearCustomBg: true),
      );
    } else {
      state = state.copyWith(
        customization: state.customization.copyWith(customBgPath: path),
      );
    }
  }

  void updateColors(Color? primary, Color? secondary) {
    state = state.copyWith(
      customization: state.customization.copyWith(
        primaryColorOverride: primary,
        secondaryColorOverride: secondary,
      ),
    );
  }

  void resetColorOverrides() {
    state = state.copyWith(
      customization: state.customization.copyWith(
        clearPrimaryColorOverride: true,
        clearSecondaryColorOverride: true,
        clearBlurOverride: true,
      ),
    );
  }

  void updateFontFamily(String font) {
    state = state.copyWith(
      customization: state.customization.copyWith(fontFamily: font),
    );
  }

  void updateWatermark(String val) {
    state = state.copyWith(
      customization: state.customization.copyWith(watermark: val),
    );
  }

  void updateBlurAmount(double val) {
    state = state.copyWith(
      customization: state.customization.copyWith(blurAmountOverride: val),
    );
  }

  void updateOpacity(double val) {
    state = state.copyWith(
      customization: state.customization.copyWith(opacity: val),
    );
  }

  void updateDarkOverlayOpacity(double val) {
    state = state.copyWith(
      customization: state.customization.copyWith(darkOverlayOpacity: val),
    );
  }

  void updateShowGradientOverlay(bool val) {
    state = state.copyWith(
      customization: state.customization.copyWith(showGradientOverlay: val),
    );
  }

  void selectTemplate(PosterTemplateModel template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void selectTheme(PosterThemeModel theme) {
    state = state.copyWith(
      selectedTheme: theme,
      customization: state.customization.copyWith(
        primaryColorOverride: theme.primaryColor,
        secondaryColorOverride: theme.secondaryColor,
      ),
    );
  }

  void updateSocialLink(String platform, String value) {
    final updated = Map<String, String>.from(state.customization.socialLinks);
    updated[platform] = value;
    state = state.copyWith(
      customization: state.customization.copyWith(socialLinks: updated),
    );
  }

  void removeSocialLink(String platform) {
    final updated = Map<String, String>.from(state.customization.socialLinks);
    updated.remove(platform);
    state = state.copyWith(
      customization: state.customization.copyWith(socialLinks: updated),
    );
  }

  void setExporting(bool val) {
    state = state.copyWith(exporting: val);
  }
}

final posterControllerProvider =
    NotifierProviderFamily<PosterController, PosterState, MatchEntity>(
  PosterController.new,
);
