class WidgetCategoryModel {
  final int id;
  final String slug;
  final String name;

  const WidgetCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
  });

  factory WidgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return WidgetCategoryModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
