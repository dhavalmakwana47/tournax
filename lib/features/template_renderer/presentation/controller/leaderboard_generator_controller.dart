import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_args.dart';
import '../../../tournament/domain/entities/tournament_entity.dart';
import '../../../tournament/domain/entities/leaderboard_item_entity.dart';
import '../../../tournament/domain/usecases/get_group_leaderboard_usecase.dart';
import '../../../tournament/domain/usecases/get_round_leaderboard_usecase.dart';
import '../../../tournament/domain/usecases/get_stage_leaderboard_usecase.dart';
import '../../../tournament/domain/usecases/get_tournament_leaderboard_usecase.dart';
import '../../../tournament/domain/usecases/get_match_leaderboard_usecase.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/enums.dart';
import '../../data/repository/template_repository_impl.dart';
import 'slot_list_generator_controller.dart';

class LeaderboardGeneratorState {
  final bool isLoading;
  final String? errorMessage;
  final List<TemplateModel> templates;
  final TemplateModel? selectedTemplate;
  final int currentPageIndex;
  final int itemsPerPage;
  final int totalPages;
  final Map<int, Map<String, String>> pageVariables;
  final TournamentEntity? tournament;
  final LeaderboardArgs? args;
  final List<LeaderboardItemEntity> items;

  final int templatePage;
  final bool hasMoreTemplates;
  final bool isLoadingMoreTemplates;

  const LeaderboardGeneratorState({
    this.isLoading = false,
    this.errorMessage,
    this.templates = const [],
    this.selectedTemplate,
    this.currentPageIndex = 0,
    this.itemsPerPage = 16,
    this.totalPages = 1,
    this.pageVariables = const {},
    this.tournament,
    this.args,
    this.items = const [],
    this.templatePage = 1,
    this.hasMoreTemplates = false,
    this.isLoadingMoreTemplates = false,
  });

  Map<String, String> get currentVariables => pageVariables[currentPageIndex] ?? {};

  LeaderboardGeneratorState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TemplateModel>? templates,
    TemplateModel? selectedTemplate,
    int? currentPageIndex,
    int? itemsPerPage,
    int? totalPages,
    Map<int, Map<String, String>>? pageVariables,
    TournamentEntity? tournament,
    LeaderboardArgs? args,
    List<LeaderboardItemEntity>? items,
    int? templatePage,
    bool? hasMoreTemplates,
    bool? isLoadingMoreTemplates,
  }) {
    return LeaderboardGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalPages: totalPages ?? this.totalPages,
      pageVariables: pageVariables ?? this.pageVariables,
      tournament: tournament ?? this.tournament,
      args: args ?? this.args,
      items: items ?? this.items,
      templatePage: templatePage ?? this.templatePage,
      hasMoreTemplates: hasMoreTemplates ?? this.hasMoreTemplates,
      isLoadingMoreTemplates: isLoadingMoreTemplates ?? this.isLoadingMoreTemplates,
    );
  }
}

final leaderboardGeneratorControllerProvider =
    StateNotifierProvider.autoDispose<LeaderboardGeneratorController, LeaderboardGeneratorState>((ref) {
  final repo = ref.watch(templateRepositoryProvider);
  return LeaderboardGeneratorController(ref: ref, repo: repo);
});

class LeaderboardGeneratorController extends StateNotifier<LeaderboardGeneratorState> {
  final Ref ref;
  final TemplateRepository repo;

  LeaderboardGeneratorController({required this.ref, required this.repo})
      : super(const LeaderboardGeneratorState());

  Future<void> init({
    required TournamentEntity tournament,
    required LeaderboardArgs args,
    List<LeaderboardItemEntity> initialItems = const [],
  }) async {
    state = state.copyWith(
      isLoading: true,
      tournament: tournament,
      args: args,
      items: initialItems,
    );

    List<LeaderboardItemEntity> items = initialItems;
    if (items.isEmpty) {
      try {
        items = await _fetchStandingsForArgs(args);
      } catch (e) {
        print('Fetch standings error in LeaderboardGeneratorController: $e');
      }
    }

    try {
      final paginated = await repo.getTemplates(categoryType: 'leaderboard', page: 1, perPage: 10);
      final templates = paginated.items.isNotEmpty ? paginated.items : [repo.createDefaultLeaderboardTemplate()];
      final defaultTemplate = templates.first;

      _setupTemplatePages(
        template: defaultTemplate,
        templates: templates,
        tournament: tournament,
        args: args,
        items: items,
        templatePage: paginated.currentPage,
        hasMoreTemplates: paginated.hasMore,
      );
    } catch (e) {
      final fallback = repo.createDefaultLeaderboardTemplate();
      _setupTemplatePages(
        template: fallback,
        templates: [fallback],
        tournament: tournament,
        args: args,
        items: items,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreTemplates() async {
    if (state.isLoadingMoreTemplates || !state.hasMoreTemplates) return;
    state = state.copyWith(isLoadingMoreTemplates: true);

    try {
      final nextPage = state.templatePage + 1;
      final paginated = await repo.getTemplates(
        categoryType: 'leaderboard',
        page: nextPage,
        perPage: 10,
      );

      if (paginated.items.isNotEmpty) {
        final existingIds = state.templates.map((t) => t.id).toSet();
        final newItems = paginated.items.where((t) => !existingIds.contains(t.id)).toList();
        final updatedList = [...state.templates, ...newItems];

        state = state.copyWith(
          templates: updatedList,
          templatePage: paginated.currentPage,
          hasMoreTemplates: paginated.hasMore,
          isLoadingMoreTemplates: false,
        );
      } else {
        state = state.copyWith(
          hasMoreTemplates: false,
          isLoadingMoreTemplates: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoadingMoreTemplates: false);
    }
  }

  Future<List<LeaderboardItemEntity>> _fetchStandingsForArgs(LeaderboardArgs args, {int perPage = 100}) async {
    switch (args.type) {
      case LeaderboardType.group:
        return await ref.read(getGroupLeaderboardUseCaseProvider)(args.id, perPage: perPage);
      case LeaderboardType.round:
        return await ref.read(getRoundLeaderboardUseCaseProvider)(args.id, perPage: perPage);
      case LeaderboardType.stage:
        return await ref.read(getStageLeaderboardUseCaseProvider)(args.id, perPage: perPage);
      case LeaderboardType.tournament:
        return await ref.read(getTournamentLeaderboardUseCaseProvider)(args.id, perPage: perPage);
      case LeaderboardType.match:
        return await ref.read(getMatchLeaderboardUseCaseProvider)(args.id, perPage: perPage);
    }
  }

  void _setupTemplatePages({
    required TemplateModel template,
    required List<TemplateModel> templates,
    required TournamentEntity tournament,
    required LeaderboardArgs args,
    required List<LeaderboardItemEntity> items,
    int templatePage = 1,
    bool hasMoreTemplates = false,
    String? error,
  }) {
    final int itemsPerPage = _detectItemsPerPage(template);
    final int itemCount = items.length;
    final int totalPages = (itemCount > 0 && itemsPerPage > 0)
        ? (itemCount / itemsPerPage).ceil().clamp(1, 99)
        : 1;

    final Map<int, Map<String, String>> pageVars = _buildAllPageVariables(
      template: template,
      tournament: tournament,
      args: args,
      items: items,
      itemsPerPage: itemsPerPage,
      totalPages: totalPages,
    );

    state = state.copyWith(
      isLoading: false,
      errorMessage: error,
      templates: templates,
      selectedTemplate: template,
      currentPageIndex: 0,
      itemsPerPage: itemsPerPage,
      totalPages: totalPages,
      pageVariables: pageVars,
      items: items,
      templatePage: templatePage,
      hasMoreTemplates: hasMoreTemplates,
    );
  }

  int _detectItemsPerPage(TemplateModel template) {
    int maxIndex = 0;
    int genericCount = 0;
    final RegExp numRegex = RegExp(r'\{\{(?:team|rank|pts|kills|wins|matches)_?(\d+)\}\}');

    for (final layer in template.layers) {
      final key = layer.variableKey ?? '';
      final text = layer.text;

      if (key == '{{team_name}}' || key == '{{team}}' || text.contains('{{team_name}}')) {
        genericCount++;
      }

      if (key.isNotEmpty) {
        final match = numRegex.firstMatch(key);
        if (match != null) {
          final strNum = match.group(1) ?? '';
          final num = int.tryParse(strNum);
          if (num != null && num > maxIndex) maxIndex = num;
        }
      }

      final matches = numRegex.allMatches(text);
      for (final m in matches) {
        final strNum = m.group(1) ?? '';
        final num = int.tryParse(strNum);
        if (num != null && num > maxIndex) maxIndex = num;
      }

      if (layer.type == LayerType.slotRow) {
        maxIndex++;
      }
    }

    final detected = maxIndex > genericCount ? maxIndex : genericCount;
    return detected > 0 ? detected : 16;
  }

  Map<int, Map<String, String>> _buildAllPageVariables({
    required TemplateModel template,
    required TournamentEntity tournament,
    required LeaderboardArgs args,
    required List<LeaderboardItemEntity> items,
    required int itemsPerPage,
    required int totalPages,
  }) {
    final Map<int, Map<String, String>> allPages = {};
    final String dateStr = DateTime.now().toString().split(' ').first;

    for (int p = 0; p < totalPages; p++) {
      final Map<String, String> baseVars = {
        '{{tournament_name}}': tournament.name,
        '{{title}}': args.name.toUpperCase(),
        '{{group_name}}': args.name,
        '{{date}}': dateStr,
        '{{organizer_name}}': 'TournaX Esports',
        '{{page}}': 'PAGE ${p + 1}',
        '{{page_number}}': '${p + 1} / $totalPages',
      };

      final int startIndex = p * itemsPerPage;
      for (int i = 1; i <= itemsPerPage; i++) {
        final int itemIdx = startIndex + (i - 1);
        final LeaderboardItemEntity? item = (itemIdx < items.length) ? items[itemIdx] : null;

        final rankDisplay = item?.rank != null ? '#${item!.rank}' : '#${itemIdx + 1}';
        final teamName = item?.teamName ?? (itemIdx < items.length ? 'TEAM ${itemIdx + 1}' : '-');
        final matchesVal = item != null ? '${item.matches}' : '0';
        final winsVal = item != null ? '${item.wins}' : '0';
        final killsVal = item != null ? '${item.killPoints > 0 ? item.killPoints : item.kills}' : '0';
        final placementPtsVal = item != null ? '${item.placementPoints}' : '0';
        final totalPtsVal = item != null ? '${item.points}' : '0';

        baseVars['{{rank_$i}}'] = rankDisplay;
        baseVars['{{team_rank_$i}}'] = rankDisplay;
        baseVars['{{raw_rank_$i}}'] = item?.rank != null ? '${item!.rank}' : '${itemIdx + 1}';
        baseVars['{{team_$i}}'] = teamName;
        baseVars['{{team_name_$i}}'] = teamName;
        baseVars['{{matches_$i}}'] = matchesVal;
        baseVars['{{team_matches_$i}}'] = matchesVal;
        baseVars['{{wins_$i}}'] = winsVal;
        baseVars['{{team_wins_$i}}'] = winsVal;
        baseVars['{{win_$i}}'] = winsVal;
        baseVars['{{team_win_$i}}'] = winsVal;
        baseVars['{{wwcd_$i}}'] = winsVal;
        baseVars['{{kills_$i}}'] = killsVal;
        baseVars['{{team_kills_$i}}'] = killsVal;
        baseVars['{{kill_points_$i}}'] = killsVal;
        baseVars['{{team_points_$i}}'] = placementPtsVal;
        baseVars['{{placement_points_$i}}'] = placementPtsVal;
        baseVars['{{team_total_points_$i}}'] = totalPtsVal;
        baseVars['{{total_points_$i}}'] = totalPtsVal;
        baseVars['{{pts_$i}}'] = totalPtsVal;
        baseVars['{{points_$i}}'] = totalPtsVal;

        if (i == 1) {
          baseVars['{{team_rank}}'] = rankDisplay;
          baseVars['{{rank}}'] = rankDisplay;
          baseVars['{{team_name}}'] = teamName;
          baseVars['{{team}}'] = teamName;
          baseVars['{{matches}}'] = matchesVal;
          baseVars['{{team_matches}}'] = matchesVal;
          baseVars['{{wins}}'] = winsVal;
          baseVars['{{team_wins}}'] = winsVal;
          baseVars['{{win}}'] = winsVal;
          baseVars['{{team_win}}'] = winsVal;
          baseVars['{{wwcd}}'] = winsVal;
          baseVars['{{kills}}'] = killsVal;
          baseVars['{{team_kills}}'] = killsVal;
          baseVars['{{kill_points}}'] = killsVal;
          baseVars['{{team_points}}'] = placementPtsVal;
          baseVars['{{placement_points}}'] = placementPtsVal;
          baseVars['{{team_total_points}}'] = totalPtsVal;
          baseVars['{{total_points}}'] = totalPtsVal;
          baseVars['{{pts}}'] = totalPtsVal;
          baseVars['{{points}}'] = totalPtsVal;
        }
      }

      allPages[p] = _extractTemplateVariables(template, baseVars);
    }

    return allPages;
  }

  void selectTemplate(TemplateModel template) {
    if (state.tournament != null && state.args != null) {
      _setupTemplatePages(
        template: template,
        templates: state.templates,
        tournament: state.tournament!,
        args: state.args!,
        items: state.items,
        templatePage: state.templatePage,
        hasMoreTemplates: state.hasMoreTemplates,
      );
    }
  }

  void selectNextTemplate() {
    if (state.templates.isEmpty || state.selectedTemplate == null) return;
    final currentIndex = state.templates.indexWhere((t) => t.id == state.selectedTemplate!.id);
    if (currentIndex != -1 && currentIndex < state.templates.length - 1) {
      selectTemplate(state.templates[currentIndex + 1]);
      if (currentIndex >= state.templates.length - 3) {
        loadMoreTemplates();
      }
    }
  }

  void selectPreviousTemplate() {
    if (state.templates.isEmpty || state.selectedTemplate == null) return;
    final currentIndex = state.templates.indexWhere((t) => t.id == state.selectedTemplate!.id);
    if (currentIndex > 0) {
      selectTemplate(state.templates[currentIndex - 1]);
    }
  }

  void setPage(int index) {
    if (index >= 0 && index < state.totalPages) {
      state = state.copyWith(currentPageIndex: index);
    }
  }

  void updateVariable(String key, String value) {
    final curVars = Map<String, String>.from(state.currentVariables);
    curVars[key] = value;
    final updatedPages = Map<int, Map<String, String>>.from(state.pageVariables);
    updatedPages[state.currentPageIndex] = curVars;
    state = state.copyWith(pageVariables: updatedPages);
  }

  void resetVariablesToDefaults() {
    if (state.selectedTemplate != null && state.tournament != null && state.args != null) {
      _setupTemplatePages(
        template: state.selectedTemplate!,
        templates: state.templates,
        tournament: state.tournament!,
        args: state.args!,
        items: state.items,
      );
    }
  }

  Map<String, String> _extractTemplateVariables(TemplateModel template, Map<String, String> base) {
    final Map<String, String> result = Map<String, String>.from(base);
    template.globalVariables.forEach((k, v) {
      if (!result.containsKey(k)) {
        result[k] = v;
      }
    });

    final RegExp varRegExp = RegExp(r'\{\{([a-zA-Z0-9_\-\.]+)\}\}');
    for (final layer in template.layers) {
      if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
        final key = layer.variableKey!;
        if (!result.containsKey(key)) {
          result[key] = layer.text.isNotEmpty ? layer.text : key;
        }
      }
      for (final match in varRegExp.allMatches(layer.text)) {
        final fullVar = match.group(0)!;
        if (!result.containsKey(fullVar)) {
          result[fullVar] = fullVar;
        }
      }
    }
    return result;
  }
}
