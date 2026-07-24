import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/poster_customization_model.dart';
import '../../data/models/poster_template_model.dart';
import '../../data/models/poster_theme_model.dart';
import '../../../tournament/domain/entities/match_entity.dart';

class PosterPreviewWidget extends StatelessWidget {
  const PosterPreviewWidget({
    super.key,
    required this.repaintKey,
    required this.customization,
    required this.template,
    required this.theme,
    required this.match,
  });

  final GlobalKey repaintKey;
  final PosterCustomizationModel customization;
  final PosterTemplateModel template;
  final PosterThemeModel theme;
  final MatchEntity match;

  Color get _primaryColor => customization.primaryColorOverride ?? theme.primaryColor;
  Color get _secondaryColor => customization.secondaryColorOverride ?? theme.secondaryColor;

  TextStyle _getFontStyle({
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.getFont(
        customization.fontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      // Fallback if google font name isn't fully loaded or fails
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
    // Generate full list of teams from selected match (up to 32)
    final matchTeams = List<MatchTeamMemberEntity>.from(match.teams)
      ..sort((a, b) => (a.slot ?? 99).compareTo(b.slot ?? 99));

    // Pad the list to support 16/20/24/32 slot views if empty or smaller
    final int slotCount;
    if (matchTeams.length <= 16) {
      slotCount = 16;
    } else if (matchTeams.length <= 20) {
      slotCount = 20;
    } else if (matchTeams.length <= 24) {
      slotCount = 24;
    } else {
      slotCount = 32;
    }

    // Prepare teams with mock names if slots are empty
    final displayTeams = List<MatchTeamMemberEntity?>.generate(slotCount, (index) {
      if (index < matchTeams.length) return matchTeams[index];
      return null;
    });

    return Center(
      child: RepaintBoundary(
        key: repaintKey,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            color: Colors.black, // Background fallback
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image (Asset or Picked file)
                _buildBackground(),

                // 2. Blur Filter
                if ((customization.blurAmountOverride ?? 0) > 0)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: customization.blurAmountOverride!,
                        sigmaY: customization.blurAmountOverride!,
                      ),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                // 3. Dark Overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: customization.darkOverlayOpacity),
                  ),
                ),

                // 4. Gradient Overlay
                if (customization.showGradientOverlay)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.9),
                            Colors.transparent,
                            _secondaryColor.withValues(alpha: 0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                // 5. Esports Neon Border (Decorative template asset frame)
                _buildNeonBorder(),

                // 6. Poster Content (Header, Slots grid, Footer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    children: [
                      // Header Section
                      _buildHeader(),
                      const SizedBox(height: 12.0),

                      // Slots Table
                      Expanded(
                        child: _buildSlotsGrid(displayTeams, slotCount),
                      ),
                      const SizedBox(height: 8.0),

                      // Footer & Socials Section
                      _buildFooter(),
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

  Widget _buildBackground() {
    if (customization.customBgPath != null && customization.customBgPath!.isNotEmpty) {
      return Image.file(
        File(customization.customBgPath!),
        fit: BoxFit.cover,
        opacity: AlwaysStoppedAnimation(customization.opacity),
      );
    } else if (template.backgroundImage.isNotEmpty) {
      return Image.asset(
        template.backgroundImage,
        fit: BoxFit.cover,
        opacity: AlwaysStoppedAnimation(customization.opacity),
      );
    } else {
      // solid gradient fallback
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [_secondaryColor.withValues(alpha: 0.5), Colors.black],
            radius: 1.2,
          ),
        ),
      );
    }
  }

  Widget _buildNeonBorder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _primaryColor.withValues(alpha: 0.4),
            width: 3.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Event Logo
        if (customization.eventLogoPath != null && customization.eventLogoPath!.isNotEmpty)
          Container(
            height: 48,
            width: 48,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(File(customization.eventLogoPath!), fit: BoxFit.cover),
            ),
          )
        else
          Container(
            height: 48,
            width: 48,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor, width: 1.5),
            ),
            child: Icon(Icons.emoji_events_rounded, color: _primaryColor, size: 28),
          ),

        // Text details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customization.organizerName.toUpperCase(),
                style: _getFontStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                customization.eventName,
                style: _getFontStyle(
                  fontSize: 22,
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Subtitle / Slotlist Banner
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                customization.subTitle.toUpperCase(),
                style: _getFontStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  customization.week.toUpperCase(),
                  style: _getFontStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  customization.round.toUpperCase(),
                  style: _getFontStyle(
                    fontSize: 9,
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget _buildSlotsGrid(List<MatchTeamMemberEntity?> displayTeams, int slotCount) {
    // Determine layout columns based on slot size
    final int columns = slotCount == 32 ? 3 : 2;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: columns == 3 ? 3.6 : 4.4,
      ),
      itemCount: slotCount,
      itemBuilder: (context, index) {
        final team = displayTeams[index];
        final slotNum = index + 1;
        final slotColor = _primaryColor;

        return Container(
          decoration: BoxDecoration(
            color: theme.tableRowColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _primaryColor.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            children: [
              // Slot Badge
              Container(
                width: 24,
                height: 20,
                decoration: BoxDecoration(
                  color: slotColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.center,
                child: Text(
                  slotNum.toString().padLeft(2, '0'),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Team Name
              Expanded(
                child: Text(
                  team?.name ?? 'EMPTY SLOT',
                  style: _getFontStyle(
                    fontSize: columns == 3 ? 10 : 12,
                    color: team == null ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Status indicator (live or ready)
              if (team != null)
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: team.status == 'ready' ? Colors.green : Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sponsor Logos or Social links
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customization.socialLinks.containsKey('instagram')) ...[
                const Icon(Icons.camera_alt_outlined, size: 10, color: Colors.white70),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    customization.socialLinks['instagram']!,
                    style: _getFontStyle(fontSize: 8, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (customization.socialLinks.containsKey('youtube')) ...[
                const Icon(Icons.play_circle_outline, size: 10, color: Colors.white70),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    customization.socialLinks['youtube']!,
                    style: _getFontStyle(fontSize: 8, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Watermark Label
        Text(
          customization.watermark.toUpperCase(),
          style: _getFontStyle(
            fontSize: 8,
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
