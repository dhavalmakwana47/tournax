import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasource/template_remote_datasource.dart';
import '../../data/repository/template_repository_impl.dart';
import '../../domain/models/template_model.dart';
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
  final Map<String, String> variables;

  const SlotListGeneratorState({
    this.isLoading = false,
    this.errorMessage,
    this.templates = const [],
    this.selectedTemplate,
    this.variables = const {},
  });

  SlotListGeneratorState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TemplateModel>? templates,
    TemplateModel? selectedTemplate,
    Map<String, String>? variables,
  }) {
    return SlotListGeneratorState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      templates: templates ?? this.templates,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      variables: variables ?? this.variables,
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
    state = state.copyWith(isLoading: true);
    try {
      final fetched = await repo.getTemplates();
      final defaultTemplate = fetched.isNotEmpty ? fetched.first : repo.createDefault12SlotListTemplate();

      final Map<String, String> initialVars = {
        '{{tournament_name}}': tournament.name,
        '{{group_name}}': group.name,
        '{{match_name}}': match.name ?? 'MATCH ${match.matchNumber}',
        '{{match_date}}': match.scheduledAt != null ? match.scheduledAt!.split('T').first : 'TODAY',
      };

      // Populate teams into variables {{team_1}}, {{team_2}}, ...
      final teams = match.teams;
      for (int i = 0; i < teams.length; i++) {
        final slotNum = i + 1;
        initialVars['{{team_$slotNum}}'] = teams[i].name;
      }
      for (int i = teams.length + 1; i <= 25; i++) {
        initialVars['{{team_$i}}'] = 'SLOT $i';
      }

      final mergedVars = _extractTemplateVariables(defaultTemplate, initialVars);

      state = state.copyWith(
        isLoading: false,
        templates: fetched.isNotEmpty ? fetched : [defaultTemplate],
        selectedTemplate: defaultTemplate,
        variables: mergedVars,
      );
    } catch (e) {
      final fallback = repo.createDefault12SlotListTemplate();
      state = state.copyWith(
        isLoading: false,
        templates: [fallback],
        selectedTemplate: fallback,
        errorMessage: e.toString(),
      );
    }
  }

  void selectTemplate(TemplateModel template) {
    final mergedVars = _extractTemplateVariables(template, state.variables);
    state = state.copyWith(
      selectedTemplate: template,
      variables: mergedVars,
    );
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
    }

    return vars;
  }

  void updateVariable(String key, String value) {
    final updated = Map<String, String>.from(state.variables);
    updated[key] = value;
    state = state.copyWith(variables: updated);
  }
}
