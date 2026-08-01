import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasource/template_remote_datasource.dart';
import '../../data/repository/template_repository_impl.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/enums.dart';
import '../../../tournament/domain/entities/tournament_entity.dart';
import '../../../tournament/domain/entities/group_entity.dart';
import '../../../tournament/domain/entities/match_entity.dart';

final templateRemoteDatasourceProvider = Provider<TemplateRemoteDatasource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TemplateRemoteDatasourceImpl(apiClient);
});

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  final ds = ref.watch(templateRemoteDatasourceProvider);
  return TemplateRepositoryImpl(ds);
});

class SlotListGeneratorState {
  final bool isLoading;
  final String? errorMessage;
  final List<TemplateModel> templates;
  final TemplateModel? selectedTemplate;
  final int currentPageIndex;
  final int slotsPerPage;
  final int totalPages;
  final String slotPrefix;
  final Map<int, Map<String, String>> pageVariables;
  final TournamentEntity? tournament;
  final GroupEntity? group;
  final MatchEntity? match;

  const SlotListGeneratorState({
    this.isLoading = false,
    this.errorMessage,
    this.templates = const [],
    this.selectedTemplate,
    this.currentPageIndex = 0,
    this.slotsPerPage = 12,
    this.totalPages = 1,
    this.slotPrefix = '',
    this.pageVariables = const {},
    this.tournament,
    this.group,
    this.match,
  });

  Map<String, String> get currentVariables => pageVariables[currentPageIndex] ?? {};

  // Backward compatibility alias for single-page variables
  Map<String, String> get variables => currentVariables;

  SlotListGeneratorState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TemplateModel>? templates,
    TemplateModel? selectedTemplate,
    int? currentPageIndex,
    int? slotsPerPage,
    int? totalPages,
    String? slotPrefix,
    Map<int, Map<String, String>>? pageVariables,
    TournamentEntity? tournament,
    GroupEntity? group,
    MatchEntity? match,
  }) {
    return SlotListGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      slotsPerPage: slotsPerPage ?? this.slotsPerPage,
      totalPages: totalPages ?? this.totalPages,
      slotPrefix: slotPrefix ?? this.slotPrefix,
      pageVariables: pageVariables ?? this.pageVariables,
      tournament: tournament ?? this.tournament,
      group: group ?? this.group,
      match: match ?? this.match,
    );
  }
}

final slotListGeneratorControllerProvider =
    StateNotifierProvider.autoDispose<SlotListGeneratorController, SlotListGeneratorState>((ref) {
  final repo = ref.watch(templateRepositoryProvider);
  return SlotListGeneratorController(repo: repo);
});

class SlotListGeneratorController extends StateNotifier<SlotListGeneratorState> {
  final TemplateRepository repo;

  SlotListGeneratorController({required this.repo}) : super(const SlotListGeneratorState());

  Future<void> init({
    required TournamentEntity tournament,
    required GroupEntity group,
    required MatchEntity match,
  }) async {
    state = state.copyWith(
      isLoading: true,
      tournament: tournament,
      group: group,
      match: match,
    );
    try {
      final fetched = await repo.getTemplates(categoryType: 'slot_list');
      final defaultTemplate = fetched.isNotEmpty ? fetched.first : repo.createDefault12SlotListTemplate();

      _setupTemplatePages(
        template: defaultTemplate,
        templates: fetched.isNotEmpty ? fetched : [defaultTemplate],
        tournament: tournament,
        group: group,
        match: match,
      );
    } catch (e) {
      final fallback = repo.createDefault12SlotListTemplate();
      _setupTemplatePages(
        template: fallback,
        templates: [fallback],
        tournament: tournament,
        group: group,
        match: match,
        error: e.toString(),
      );
    }
  }

  void _setupTemplatePages({
    required TemplateModel template,
    required List<TemplateModel> templates,
    required TournamentEntity tournament,
    required GroupEntity group,
    required MatchEntity match,
    String? error,
  }) {
    final int slotsPerPage = _detectSlotsPerPage(template);

    // Calculate max slot number based on team.slot assignments or total team count
    int maxSlotNum = match.teams.length;
    for (final t in match.teams) {
      if (t.slot != null && t.slot! > maxSlotNum) {
        maxSlotNum = t.slot!;
      }
    }

    final int totalPages = (maxSlotNum > 0 && slotsPerPage > 0)
        ? (maxSlotNum / slotsPerPage).ceil().clamp(1, 99)
        : 1;

    final Map<int, Map<String, String>> pageVars = _buildAllPageVariables(
      template: template,
      tournament: tournament,
      group: group,
      match: match,
      slotsPerPage: slotsPerPage,
      totalPages: totalPages,
    );

    state = state.copyWith(
      isLoading: false,
      errorMessage: error,
      templates: templates,
      selectedTemplate: template,
      currentPageIndex: 0,
      slotsPerPage: slotsPerPage,
      totalPages: totalPages,
      pageVariables: pageVars,
    );
  }

  int _detectSlotsPerPage(TemplateModel template) {
    int maxSlot = 0;
    int genericTeamCount = 0;
    final RegExp teamRegex = RegExp(r'\{\{team_?name_?(\d+)\}\}|\{\{team_(\d+)\}\}');

    for (final layer in template.layers) {
      final key = layer.variableKey ?? '';
      final text = layer.text;

      if (key == '{{team_name}}' ||
          key == 'team_name' ||
          key == '{{team}}' ||
          key == 'team' ||
          text.contains('{{team_name}}') ||
          text.contains('{{team}}')) {
        genericTeamCount++;
      }

      if (key.isNotEmpty) {
        final match = teamRegex.firstMatch(key);
        if (match != null) {
          final strNum = match.group(1) ?? match.group(2) ?? '';
          final num = int.tryParse(strNum);
          if (num != null && num > maxSlot) maxSlot = num;
        }
      }
      final matches = teamRegex.allMatches(text);
      for (final m in matches) {
        final strNum = m.group(1) ?? m.group(2) ?? '';
        final num = int.tryParse(strNum);
        if (num != null && num > maxSlot) maxSlot = num;
      }
      if (layer.type == LayerType.slotRow) {
        maxSlot++;
      }
    }

    final detected = maxSlot > genericTeamCount ? maxSlot : genericTeamCount;
    return detected > 0 ? detected : 12;
  }

  Map<int, Map<String, String>> _buildAllPageVariables({
    required TemplateModel template,
    required TournamentEntity tournament,
    required GroupEntity group,
    required MatchEntity match,
    required int slotsPerPage,
    required int totalPages,
  }) {
    final teams = match.teams;
    final Map<int, Map<String, String>> allPages = {};

    // Build a map of explicitly assigned slots (slotNumber -> team)
    final Map<int, MatchTeamMemberEntity> slotToTeamMap = {};
    final List<MatchTeamMemberEntity> unassignedTeams = [];

    for (final team in teams) {
      if (team.slot != null && team.slot! > 0) {
        slotToTeamMap[team.slot!] = team;
      } else {
        unassignedTeams.add(team);
      }
    }

    int unassignedPointer = 0;

    for (int p = 0; p < totalPages; p++) {
      final dateStr = match.scheduledAt != null && match.scheduledAt!.isNotEmpty
          ? match.scheduledAt!.split('T').first
          : (tournament.startDate != null && tournament.startDate!.isNotEmpty
              ? tournament.startDate!.split('T').first
              : 'TODAY');

      final Map<String, String> baseVars = {
        '{{tournament_name}}': tournament.name,
        '{{group_name}}': group.name,
        '{{match_name}}': match.name ?? 'MATCH ${match.matchNumber}',
        '{{date}}': dateStr,
        '{{match_date}}': dateStr,
        '{{organizer_name}}': 'TournaX Esports',
        '{{organizer_logo}}': '',
        '{{sponsor_logo}}': '',
        '{{page}}': 'PAGE ${p + 1}',
        '{{page_number}}': '${p + 1} / $totalPages',
      };

      final int startSlotNum = (p * slotsPerPage) + 1;
      for (int s = 1; s <= slotsPerPage; s++) {
        final overallSlotNum = startSlotNum + (s - 1);

        String teamName;
        if (slotToTeamMap.containsKey(overallSlotNum)) {
          teamName = slotToTeamMap[overallSlotNum]!.name;
        } else if (unassignedPointer < unassignedTeams.length) {
          teamName = unassignedTeams[unassignedPointer++].name;
        } else {
          teamName = 'SLOT $overallSlotNum';
        }

        final slotNumDisplay = '$overallSlotNum';

        baseVars['{{team_$s}}'] = teamName;
        baseVars['{{team_name_$s}}'] = teamName;
        baseVars['{{slot_$s}}'] = '${state.slotPrefix}$slotNumDisplay';
      }

      allPages[p] = _extractTemplateVariables(template, baseVars);
    }

    return allPages;
  }

  void selectTemplate(TemplateModel template) {
    if (state.tournament != null && state.group != null && state.match != null) {
      _setupTemplatePages(
        template: template,
        templates: state.templates,
        tournament: state.tournament!,
        group: state.group!,
        match: state.match!,
      );
    } else {
      final mergedVars = _extractTemplateVariables(template, state.currentVariables);
      final updatedPages = Map<int, Map<String, String>>.from(state.pageVariables);
      updatedPages[state.currentPageIndex] = mergedVars;
      state = state.copyWith(
        selectedTemplate: template,
        pageVariables: updatedPages,
      );
    }
  }

  void selectPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < state.totalPages) {
      state = state.copyWith(currentPageIndex: pageIndex);
    }
  }

  Map<String, String> _extractTemplateVariables(TemplateModel template, Map<String, String> existingVars) {
    final Map<String, String> vars = Map<String, String>.from(template.globalVariables);
    vars.addAll(existingVars);

    final RegExp exp = RegExp(r'\{\{([^}]+)\}\}');

    for (final layer in template.layers) {
      if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
        final key = layer.variableKey!.startsWith('{{') ? layer.variableKey! : '{{${layer.variableKey}}}';
        if (!vars.containsKey(key)) {
          vars[key] = layer.text.isNotEmpty ? layer.text : 'Sample Value';
        }
      }
      final matches = exp.allMatches(layer.text);
      for (final match in matches) {
        final rawMatch = match.group(0);
        if (rawMatch != null && !vars.containsKey(rawMatch)) {
          vars[rawMatch] = rawMatch.replaceAll('{{', '').replaceAll('}}', '').replaceAll('_', ' ').toUpperCase();
        }
      }

      // Extract static text layers as editable ONLY IF layer.isEditable is true
      if (layer.type == LayerType.text &&
          layer.isEditable &&
          layer.text.isNotEmpty &&
          (layer.variableKey == null || layer.variableKey!.isEmpty) &&
          !exp.hasMatch(layer.text)) {
        final cleanName = layer.name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
        final layerKey = '{{$cleanName}}';
        if (!vars.containsKey(layerKey)) {
          vars[layerKey] = layer.text;
        }
      }
    }

    return vars;
  }

  void updateSlotPrefix(String prefix) {
    final Map<int, Map<String, String>> updatedAllPages = {};

    state.pageVariables.forEach((pIdx, pVars) {
      final vars = Map<String, String>.from(pVars);
      vars['{{slot_prefix}}'] = prefix;
      vars['slot_prefix'] = prefix;

      final int startTeamIdx = pIdx * state.slotsPerPage;
      for (int s = 1; s <= state.slotsPerPage; s++) {
        final slotNum = '${startTeamIdx + s}';
        vars['{{slot_$s}}'] = '$prefix$slotNum';
      }

      updatedAllPages[pIdx] = vars;
    });

    state = state.copyWith(
      slotPrefix: prefix,
      pageVariables: updatedAllPages,
    );
  }

  void updateVariable(String key, String value) {
    if (key == '{{slot_prefix}}' || key == 'slot_prefix') {
      updateSlotPrefix(value);
      return;
    }

    final isSlotSpecificKey = key.toLowerCase().contains('team_') ||
        key.toLowerCase().contains('team1') ||
        key.toLowerCase().contains('team2');

    final updatedAllPages = Map<int, Map<String, String>>.from(state.pageVariables);

    if (isSlotSpecificKey) {
      // Slot team name updates apply to current page
      final pageVars = Map<String, String>.from(state.currentVariables);
      pageVars[key] = value;

      // Sync alias keys (e.g. {{team_1}} <-> {{team_name_1}})
      final RegExp teamRegex = RegExp(r'^\{\{team_(?:name_)?(\d+)\}\}$', caseSensitive: false);
      final match = teamRegex.firstMatch(key);
      if (match != null) {
        final slotNum = match.group(1);
        if (slotNum != null) {
          pageVars['{{team_$slotNum}}'] = value;
          pageVars['{{team_name_$slotNum}}'] = value;
        }
      }
      updatedAllPages[state.currentPageIndex] = pageVars;
    } else {
      // Global graphic details (tournament_name, group_name, match_name, date, organizer, logos, etc.)
      // Propagate across ALL pages!
      updatedAllPages.forEach((pIdx, pVars) {
        final vars = Map<String, String>.from(pVars);
        vars[key] = value;
        updatedAllPages[pIdx] = vars;
      });
    }

    state = state.copyWith(pageVariables: updatedAllPages);
  }

  void resetVariablesToDefaults() {
    if (state.selectedTemplate != null &&
        state.tournament != null &&
        state.group != null &&
        state.match != null) {
      _setupTemplatePages(
        template: state.selectedTemplate!,
        templates: state.templates,
        tournament: state.tournament!,
        group: state.group!,
        match: state.match!,
      );
    }
  }
}
