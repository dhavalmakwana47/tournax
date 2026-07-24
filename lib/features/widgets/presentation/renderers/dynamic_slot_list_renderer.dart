import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../poster/data/models/poster_customization_model.dart';
import '../../../tournament/domain/entities/match_entity.dart';
import '../../data/models/widget_template_model.dart';

class DynamicSlotListRenderer extends StatelessWidget {
  final GlobalKey repaintKey;
  final WidgetTemplateModel template;
  final PosterCustomizationModel customization;
  final MatchEntity match;

  const DynamicSlotListRenderer({
    super.key,
    required this.repaintKey,
    required this.template,
    required this.customization,
    required this.match,
  });

  TextStyle _getFontStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
  }) {
    final titleFontFamily = template.typography['title_font']?['family'] ?? 'Bebas Neue';
    try {
      return GoogleFonts.getFont(
        titleFontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = template.theme;
    final layout = template.layout;

    final primaryColor = customization.primaryColorOverride ?? theme.primaryColor;
    final secondaryColor = customization.secondaryColorOverride ?? theme.secondaryColor;
    final activeBlurSigma = customization.blurAmountOverride ??
        (layout.blurEnabled ? layout.blurSigmaX : 0.0);
    final activeDarkOpacity = customization.darkOverlayOpacity;

    final matchTeams = List<MatchTeamMemberEntity>.from(match.teams)
      ..sort((a, b) => (a.slot ?? 99).compareTo(b.slot ?? 99));

    final int slotCount = matchTeams.length <= 16
        ? 16
        : (matchTeams.length <= 20
            ? 20
            : (matchTeams.length <= 24 ? 24 : 32));

    final displayTeams = List<MatchTeamMemberEntity?>.generate(slotCount, (index) {
      if (index < matchTeams.length) return matchTeams[index];
      return null;
    });

    final int columns = slotCount == 32
        ? layout.upTo32SlotsColumns
        : (slotCount <= 20 ? layout.upTo16SlotsColumns : layout.upTo24SlotsColumns);

    return Center(
      child: RepaintBoundary(
        key: repaintKey,
        child: AspectRatio(
          aspectRatio: layout.aspectRatio,
          child: Container(
            color: theme.backgroundColor,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Layer (Custom Image, Network Asset, or Solid Gradient)
                _buildBackground(secondaryColor),

                // 2. Dynamic Blur Effect
                if (activeBlurSigma > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: activeBlurSigma,
                        sigmaY: activeBlurSigma,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                // 3. Dark Overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: activeDarkOpacity),
                  ),
                ),

                // 4. Gradient Overlay
                if (layout.gradientEnabled)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.9),
                            Colors.transparent,
                            secondaryColor.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                // 5. Dynamic Neon Frame
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                        width: 3.0,
                      ),
                    ),
                  ),
                ),

                // 6. Slots Grid & Poster Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor, width: 1.5),
                            ),
                            child: Icon(Icons.emoji_events_rounded, color: primaryColor, size: 28),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customization.organizerName.toUpperCase(),
                                  style: _getFontStyle(
                                    fontSize: 10,
                                    color: theme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  customization.eventName,
                                  style: _getFontStyle(
                                    fontSize: 22,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                template.name.toUpperCase(),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Slots Grid
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 6.0,
                            childAspectRatio: columns == 3 ? 4.2 : 5.2,
                          ),
                          itemCount: slotCount,
                          itemBuilder: (context, index) {
                            final team = displayTeams[index];
                            final slotNum = index + 1;

                            return Container(
                              decoration: BoxDecoration(
                                color: theme.cardBackground,
                                borderRadius: BorderRadius.circular(layout.cardBorderRadius),
                                border: Border.all(
                                  color: theme.cardBorderColor,
                                  width: layout.cardBorderWidth,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: theme.slotBadgeColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      slotNum.toString().padLeft(2, '0'),
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 12,
                                        color: theme.slotBadgeTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      team?.name ?? 'EMPTY SLOT',
                                      style: _getFontStyle(
                                        fontSize: columns == 3 ? 10 : 12,
                                        color: team == null ? theme.textSecondary : theme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              template.slug.toUpperCase(),
                              style: TextStyle(fontSize: 8, color: theme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              customization.watermark.toUpperCase(),
                              style: _getFontStyle(
                                fontSize: 9,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Color secondaryColor) {
    if (customization.customBgPath != null && customization.customBgPath!.isNotEmpty) {
      return Image.file(
        File(customization.customBgPath!),
        fit: BoxFit.cover,
        opacity: AlwaysStoppedAnimation(customization.opacity),
      );
    } else if (template.assets.containsKey('background')) {
      return Image.network(
        template.assets['background']!.url,
        fit: BoxFit.cover,
        opacity: AlwaysStoppedAnimation(customization.opacity),
        errorBuilder: (_, __, ___) => _buildFallbackGradient(secondaryColor),
      );
    } else {
      return _buildFallbackGradient(secondaryColor);
    }
  }

  Widget _buildFallbackGradient(Color secondaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [secondaryColor.withValues(alpha: 0.5), Colors.black],
          radius: 1.2,
        ),
      ),
    );
  }
}
