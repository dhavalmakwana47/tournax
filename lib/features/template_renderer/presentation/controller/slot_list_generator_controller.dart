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
      final fetched = await repo.getTemplates();
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
    final int totalTeams = match.teams.length;
    final int totalPages = (totalTeams > 0 && slotsPerPage > 0)
        ? (totalTeams / slotsPerPage).ceil().clamp(1, 99)
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
    final RegExp teamRegex = RegExp(r'\{\{team_?name_?(\d+)\}\}|\{\{team_(\d+)\}\}');

    for (final layer in template.layers) {
      if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
        final match = teamRegex.firstMatch(layer.variableKey!);
        if (match != null) {
          final strNum = match.group(1) ?? match.group(2) ?? '';
          final num = int.tryParse(strNum);
          if (num != null && num > maxSlot) maxSlot = num;
        }
      }
      final matches = teamRegex.allMatches(layer.text);
      for (final m in matches) {
        final strNum = m.group(1) ?? m.group(2) ?? '';
        final num = int.tryParse(strNum);
        if (num != null && num > maxSlot) maxSlot = num;
      }
      if (layer.type == LayerType.slotRow) {
        maxSlot++;
      }
    }
    return maxSlot > 0 ? maxSlot : 12;
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
    final int totalTeams = teams.length;
    final Map<int, Map<String, String>> allPages = {};

    for (int p = 0; p < totalPages; p++) {
      final Map<String, String> baseVars = {
        '{{tournament_name}}': tournament.name,
        '{{group_name}}': group.name,
        '{{match_name}}': match.name ?? 'MATCH ${match.matchNumber}',
        '{{match_date}}': match.scheduledAt != null ? match.scheduledAt!.split('T').first : 'TODAY',
        '{{page}}': 'PAGE ${p + 1}',
        '{{page_number}}': '${p + 1} / $totalPages',
      };

      final int startTeamIdx = p * slotsPerPage;
      for (int s = 1; s <= slotsPerPage; s++) {
        final teamIdx = startTeamIdx + (s - 1);
        final teamName = teamIdx < totalTeams ? teams[teamIdx].name : 'SLOT ${teamIdx + 1}';
        baseVars['{{team_$s}}'] = teamName;
        baseVars['{{team_name_$s}}'] = teamName;
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

  void updateVariable(String key, String value) {
    final pageVars = Map<String, String>.from(state.currentVariables);
    pageVars[key] = value;

    final updatedAllPages = Map<int, Map<String, String>>.from(state.pageVariables);
    updatedAllPages[state.currentPageIndex] = pageVars;

    state = state.copyWith(pageVariables: updatedAllPages);
  }
}
