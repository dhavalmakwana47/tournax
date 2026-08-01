import 'package:flutter/material.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/layer_style.dart';
import '../../domain/models/enums.dart';
import 'widgets/render_text_layer.dart';
import 'widgets/render_image_layer.dart';
import 'widgets/render_svg_layer.dart';
import 'widgets/render_shape_layer.dart';
import 'widgets/render_qr_layer.dart';
import 'widgets/render_barcode_layer.dart';
import 'widgets/render_component_layer.dart';

/// Standalone dynamic Flutter renderer engine for TournaX JSON templates.
class TemplateRenderer extends StatelessWidget {
  final TemplateModel template;
  final Map<String, String>? overrideVariables;
  final Size? customSize;

  const TemplateRenderer({
    super.key,
    required this.template,
    this.overrideVariables,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final spec = template.canvasSpec;
    final double targetWidth = customSize?.width ?? spec.width;
    final double targetHeight = customSize?.height ?? spec.height;
    final double scaleX = customSize != null ? targetWidth / spec.width : 1.0;
    final double scaleY = customSize != null ? targetHeight / spec.height : 1.0;

    final Map<String, String> activeVars = {
      ...template.globalVariables,
      ...?overrideVariables,
    };

    // Sort layers by Z-index ascending
    final sortedLayers = List<LayerModel>.from(template.layers)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    // Map sequential generic tags ({{team_name}}, {{team_rank}}, {{slot}}, {{kills}}, {{pts}}) to 1st, 2nd, 3rd... entries
    int teamOccurrence = 0;
    int slotOccurrence = 0;
    int rankOccurrence = 0;
    int killsOccurrence = 0;
    int teamPointsOccurrence = 0;
    int pointsOccurrence = 0;
    int matchesOccurrence = 0;
    int winsOccurrence = 0;
    final Map<String, Map<String, String>> layerSpecificVars = {};

    for (final layer in sortedLayers) {
      if (!layer.isVisible) continue;

      final key = layer.variableKey ?? '';
      final text = layer.text;

      final isGenericTeam = key == '{{team_name}}' ||
          key == 'team_name' ||
          key == '{{team}}' ||
          key == 'team' ||
          text.contains('{{team_name}}') ||
          text.contains('{{team}}');

      final isGenericRank = key == '{{team_rank}}' ||
          key == 'team_rank' ||
          key == '{{rank}}' ||
          key == 'rank' ||
          text.contains('{{team_rank}}') ||
          text.contains('{{rank}}');

      final isGenericSlot = key == '{{slot}}' ||
          key == 'slot' ||
          text.contains('{{slot}}');

      final isGenericMatches = key == '{{team_matches}}' ||
          key == 'team_matches' ||
          key == '{{matches}}' ||
          key == 'matches' ||
          text.contains('{{team_matches}}') ||
          text.contains('{{matches}}');

      final isGenericWins = key == '{{team_wins}}' ||
          key == 'team_wins' ||
          key == '{{team_win}}' ||
          key == 'team_win' ||
          key == '{{wins}}' ||
          key == 'wins' ||
          key == '{{win}}' ||
          key == 'win' ||
          key == '{{wwcd}}' ||
          key == 'wwcd' ||
          text.contains('{{team_wins}}') ||
          text.contains('{{team_win}}') ||
          text.contains('{{wins}}') ||
          text.contains('{{win}}') ||
          text.contains('{{wwcd}}');

      final isGenericKills = key == '{{team_kills}}' ||
          key == 'team_kills' ||
          key == '{{kills}}' ||
          key == 'kills' ||
          key == '{{kill_points}}' ||
          key == 'kill_points' ||
          text.contains('{{team_kills}}') ||
          text.contains('{{kills}}') ||
          text.contains('{{kill_points}}');

      final isGenericTeamPoints = key == '{{team_points}}' ||
          key == 'team_points' ||
          key == '{{placement_points}}' ||
          key == 'placement_points' ||
          text.contains('{{team_points}}') ||
          text.contains('{{placement_points}}');

      final isGenericPoints = key == '{{team_total_points}}' ||
          key == 'team_total_points' ||
          key == '{{total_points}}' ||
          key == 'total_points' ||
          key == '{{points}}' ||
          key == 'points' ||
          key == '{{pts}}' ||
          key == 'pts' ||
          text.contains('{{team_total_points}}') ||
          text.contains('{{total_points}}') ||
          text.contains('{{points}}') ||
          text.contains('{{pts}}');

      if (isGenericTeam || isGenericSlot || isGenericRank || isGenericKills || isGenericTeamPoints || isGenericPoints || isGenericMatches || isGenericWins) {
        final Map<String, String> customVars = Map<String, String>.from(activeVars);

        if (isGenericTeam) {
          teamOccurrence++;
          final teamVal = activeVars['{{team_$teamOccurrence}}'] ??
              activeVars['{{team_name_$teamOccurrence}}'];
          if (teamVal != null) {
            customVars['{{team_name}}'] = teamVal;
            customVars['team_name'] = teamVal;
            customVars['{{team}}'] = teamVal;
            customVars['team'] = teamVal;
          }
        }

        if (isGenericRank) {
          rankOccurrence++;
          final rankVal = activeVars['{{team_rank_$rankOccurrence}}'] ??
              activeVars['{{rank_$rankOccurrence}}'] ??
              '#$rankOccurrence';
          customVars['{{team_rank}}'] = rankVal;
          customVars['team_rank'] = rankVal;
          customVars['{{rank}}'] = rankVal;
          customVars['rank'] = rankVal;
        }

        if (isGenericMatches) {
          matchesOccurrence++;
          final matchesVal = activeVars['{{team_matches_$matchesOccurrence}}'] ??
              activeVars['{{matches_$matchesOccurrence}}'] ??
              '1';
          customVars['{{team_matches}}'] = matchesVal;
          customVars['team_matches'] = matchesVal;
          customVars['{{matches}}'] = matchesVal;
          customVars['matches'] = matchesVal;
        }

        if (isGenericWins) {
          winsOccurrence++;
          final winsVal = activeVars['{{team_wins_$winsOccurrence}}'] ??
              activeVars['{{team_win_$winsOccurrence}}'] ??
              activeVars['{{wins_$winsOccurrence}}'] ??
              activeVars['{{win_$winsOccurrence}}'] ??
              activeVars['{{wwcd_$winsOccurrence}}'] ??
              '0';
          customVars['{{team_wins}}'] = winsVal;
          customVars['team_wins'] = winsVal;
          customVars['{{team_win}}'] = winsVal;
          customVars['team_win'] = winsVal;
          customVars['{{wins}}'] = winsVal;
          customVars['wins'] = winsVal;
          customVars['{{win}}'] = winsVal;
          customVars['win'] = winsVal;
          customVars['{{wwcd}}'] = winsVal;
          customVars['wwcd'] = winsVal;
        }

        if (isGenericKills) {
          killsOccurrence++;
          final killsVal = activeVars['{{team_kills_$killsOccurrence}}'] ??
              activeVars['{{kills_$killsOccurrence}}'] ??
              activeVars['{{kill_points_$killsOccurrence}}'] ??
              '0';
          customVars['{{team_kills}}'] = killsVal;
          customVars['team_kills'] = killsVal;
          customVars['{{kills}}'] = killsVal;
          customVars['kills'] = killsVal;
          customVars['{{kill_points}}'] = killsVal;
          customVars['kill_points'] = killsVal;
        }

        if (isGenericTeamPoints) {
          teamPointsOccurrence++;
          final placeVal = activeVars['{{team_points_$teamPointsOccurrence}}'] ??
              activeVars['{{placement_points_$teamPointsOccurrence}}'] ??
              '0';
          customVars['{{team_points}}'] = placeVal;
          customVars['team_points'] = placeVal;
          customVars['{{placement_points}}'] = placeVal;
          customVars['placement_points'] = placeVal;
        }

        if (isGenericPoints) {
          pointsOccurrence++;
          final ptsVal = activeVars['{{team_total_points_$pointsOccurrence}}'] ??
              activeVars['{{total_points_$pointsOccurrence}}'] ??
              activeVars['{{pts_$pointsOccurrence}}'] ??
              activeVars['{{points_$pointsOccurrence}}'] ??
              '0';
          customVars['{{team_total_points}}'] = ptsVal;
          customVars['team_total_points'] = ptsVal;
          customVars['{{total_points}}'] = ptsVal;
          customVars['total_points'] = ptsVal;
          customVars['{{points}}'] = ptsVal;
          customVars['points'] = ptsVal;
          customVars['{{pts}}'] = ptsVal;
          customVars['pts'] = ptsVal;
        }

        if (isGenericSlot) {
          slotOccurrence++;
          final slotVal = activeVars['{{slot_$slotOccurrence}}'] ?? '$slotOccurrence';
          customVars['{{slot}}'] = slotVal;
          customVars['slot'] = slotVal;
        }

        layerSpecificVars[layer.id] = customVars;
      }
    }

    Widget canvasContent = SizedBox(
      width: spec.width,
      height: spec.height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Canvas Background Image Layer
          if (spec.backgroundImageUrl.isNotEmpty)
            Positioned.fill(
              child: _buildBackgroundImageWidget(spec.backgroundImageUrl),
            ),

          // 2. Template Layers Stack
          ...sortedLayers.map((layer) {
            if (!layer.isVisible) return const SizedBox.shrink();
            final varsForLayer = layerSpecificVars[layer.id] ?? activeVars;
            return Positioned(
              left: layer.x,
              top: layer.y,
              child: _buildLayerTransformWrapper(layer, varsForLayer),
            );
          }),
        ],
      ),
    );

    return Container(
      width: targetWidth,
      height: targetHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: parseColor(spec.backgroundColorHex),
      ),
      child: customSize != null
          ? FittedBox(
              fit: BoxFit.fill,
              alignment: Alignment.center,
              child: canvasContent,
            )
          : canvasContent,
    );
  }

  Widget _buildLayerTransformWrapper(LayerModel layer, Map<String, String> variables) {
    Widget content = _buildLayerBody(layer, variables);

    if (layer.rotation != 0.0 || layer.flipX || layer.flipY || layer.scaleX != 1.0 || layer.scaleY != 1.0) {
      final double rad = layer.rotation * (3.14159265358979323846 / 180);
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rad)
          ..scale(layer.flipX ? -layer.scaleX : layer.scaleX, layer.flipY ? -layer.scaleY : layer.scaleY),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLayerBody(LayerModel layer, Map<String, String> variables) {
    switch (layer.type) {
      case LayerType.text:
        return RenderTextLayer(layer: layer, variables: variables);
      case LayerType.image:
      case LayerType.playerAvatar:
      case LayerType.teamLogo:
        return RenderImageLayer(layer: layer, variables: variables);
      case LayerType.svg:
        return RenderSvgLayer(layer: layer, variables: variables);
      case LayerType.shape:
      case LayerType.container:
        return RenderShapeLayer(layer: layer);
      case LayerType.qr:
        return RenderQrLayer(layer: layer, variables: variables);
      case LayerType.barcode:
        return RenderBarcodeLayer(layer: layer, variables: variables);
      case LayerType.rankBadge:
      case LayerType.prizeBadge:
      case LayerType.slotRow:
      case LayerType.playerCard:
      case LayerType.winnerBanner:
      case LayerType.tournamentHeader:
      case LayerType.customComponent:
        return RenderComponentLayer(layer: layer, variables: variables);
      default:
        return RenderShapeLayer(layer: layer);
    }
  }

  Widget _buildBackgroundImageWidget(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (url.contains('10.151.118.115:8000')) {
            final fallbackUrl = url.replaceAll('10.151.118.115:8000', '127.0.0.1:8000');
            return Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            );
          } else if (url.contains('127.0.0.1:8000')) {
            final fallbackUrl = url.replaceAll('127.0.0.1:8000', '10.151.118.115:8000');
            return Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
    }
    return const SizedBox.shrink();
  }
}
