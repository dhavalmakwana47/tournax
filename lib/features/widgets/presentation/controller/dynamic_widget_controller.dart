import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_constants.dart';
import '../../data/datasources/widget_remote_datasource.dart';
import '../../data/models/widget_category_model.dart';
import '../../data/models/widget_template_model.dart';

class DynamicWidgetState extends Equatable {
  final List<WidgetTemplateModel> templates;
  final List<WidgetCategoryModel> categories;
  final WidgetTemplateModel? selectedTemplate;
  final String selectedCategorySlug; // 'all' or category slug
  final bool isLoading;
  final String? errorMessage;

  const DynamicWidgetState({
    this.templates = const [],
    this.categories = const [],
    this.selectedTemplate,
    this.selectedCategorySlug = 'all',
    this.isLoading = false,
    this.errorMessage,
  });

  DynamicWidgetState copyWith({
    List<WidgetTemplateModel>? templates,
    List<WidgetCategoryModel>? categories,
    WidgetTemplateModel? selectedTemplate,
    String? selectedCategorySlug,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DynamicWidgetState(
      templates: templates ?? this.templates,
      categories: categories ?? this.categories,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      selectedCategorySlug: selectedCategorySlug ?? this.selectedCategorySlug,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        templates,
        categories,
        selectedTemplate,
        selectedCategorySlug,
        isLoading,
        errorMessage,
      ];
}

class DynamicWidgetController extends StateNotifier<DynamicWidgetState> {
  final WidgetRemoteDataSource _dataSource;

  DynamicWidgetController(this._dataSource) : super(const DynamicWidgetState()) {
    fetchTemplates();
  }

  Future<void> fetchTemplates({String type = 'slot_list'}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final templates = await _dataSource.getTemplates(type: type);
      final categories = await _dataSource.getCategories();

      final initial = templates.isNotEmpty ? templates.first : null;

      state = state.copyWith(
        templates: templates,
        categories: categories,
        selectedTemplate: initial,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load templates from server',
      );
    }
  }

  void selectTemplate(WidgetTemplateModel template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void selectCategory(String categorySlug) {
    final filtered = state.templates.where((t) {
      if (categorySlug == 'all') return true;
      return t.category.toLowerCase() == categorySlug.toLowerCase();
    }).toList();

    final nextSelected = filtered.isNotEmpty ? filtered.first : state.selectedTemplate;

    state = state.copyWith(
      selectedCategorySlug: categorySlug,
      selectedTemplate: nextSelected,
    );
  }
}

final widgetDioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
  ));
});

final widgetRemoteDataSourceProvider = Provider<WidgetRemoteDataSource>((ref) {
  return WidgetRemoteDataSource(ref.watch(widgetDioProvider));
});

final dynamicWidgetControllerProvider =
    StateNotifierProvider<DynamicWidgetController, DynamicWidgetState>((ref) {
  return DynamicWidgetController(ref.watch(widgetRemoteDataSourceProvider));
});
