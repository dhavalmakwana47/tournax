class PosterTemplateModel {
  const PosterTemplateModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.premium,
    required this.backgroundImage,
    required this.layoutType,
  });

  final String id;
  final String title;
  final String thumbnail;
  final bool premium;
  final String backgroundImage;
  final String layoutType; // e.g., 'compact', 'grid_split', 'row_flow'
}
