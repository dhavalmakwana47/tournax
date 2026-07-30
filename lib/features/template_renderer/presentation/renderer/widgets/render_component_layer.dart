import 'package:flutter/material.dart';
import '../../../domain/models/layer_model.dart';
import '../../../domain/models/layer_style.dart';
import '../../../domain/models/enums.dart';

class RenderComponentLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderComponentLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  String _getVar(String key, String fallback) {
    return variables[key] ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final style = layer.style;

    switch (layer.type) {
      case LayerType.playerAvatar:
        return _buildAvatar(style);
      case LayerType.teamLogo:
        return _buildTeamLogo(style);
      case LayerType.rankBadge:
        return _buildRankBadge(style);
      case LayerType.prizeBadge:
        return _buildPrizeBadge(style);
      case LayerType.slotRow:
        return _buildSlotRow(style);
      case LayerType.playerCard:
        return _buildPlayerCard(style);
      case LayerType.winnerBanner:
        return _buildWinnerBanner(style);
      case LayerType.tournamentHeader:
        return _buildTournamentHeader(style);
      default:
        return Container(
          width: layer.width,
          height: layer.height,
          decoration: BoxDecoration(
            color: parseColor(style.fillColorHex),
            borderRadius: BorderRadius.circular(style.borderRadius),
          ),
          child: Center(
            child: Text(
              layer.name,
              style: TextStyle(color: parseColor(style.textColorHex), fontSize: style.fontSize),
            ),
          ),
        );
    }
  }

  Widget _buildAvatar(LayerStyle style) {
    final name = _getVar('{{player_name}}', 'CYPHER_07');
    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(LayerStyle style) {
    final teamName = _getVar('{{team_name}}', 'ALPHA');
    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              teamName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(LayerStyle style) {
    final rank = _getVar('{{rank}}', '#1');
    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              'RANK $rank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeBadge(LayerStyle style) {
    final prize = _getVar('{{prize}}', '\$5,000 USD');
    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF047857),
          border: Border.all(color: const Color(0xFF34D399), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 6),
            Text(
              prize,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotRow(LayerStyle style) {
    final slot = _getVar('{{slot}}', 'SLOT 04');
    final team = _getVar('{{team_name}}', 'ALPHA ESPORTS');

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF33333F)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(slot, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                team,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(LayerStyle style) {
    final name = _getVar('{{player_name}}', 'CYPHER_07');
    final kills = _getVar('{{kills}}', '18 Kills');

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1F2937), Color(0xFF111827)],
          ),
          border: Border.all(color: const Color(0xFF374151)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF8B5CF6),
              child: Text(name.isNotEmpty ? name[0] : 'P', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                  Text(kills, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(LayerStyle style) {
    final team = _getVar('{{team_name}}', 'ALPHA ESPORTS');

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amberAccent, size: 28),
                  SizedBox(width: 8),
                  Text('CHAMPIONS', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                ],
              ),
              const SizedBox(height: 4),
              Text(team, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentHeader(LayerStyle style) {
    final match = _getVar('{{match}}', 'FINALS - MATCH 03');
    final date = _getVar('{{date}}', '28 JUL 2026');

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          border: Border(bottom: BorderSide(color: Color(0xFF3B82F6), width: 2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOURNAX LEAGUE', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(match, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                Text(date, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
