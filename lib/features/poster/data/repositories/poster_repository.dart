import '../models/poster_template_model.dart';
import '../models/poster_theme_model.dart';

class PosterRepository {
  List<PosterTemplateModel> getTemplates() {
    return [
      const PosterTemplateModel(
        id: 'tpl_green_classic',
        title: 'Cyber Green',
        thumbnail: 'assets/App Logo/logo.png',
        premium: false,
        backgroundImage: 'assets/App Logo/logo.png',
        layoutType: 'compact',
      ),
      const PosterTemplateModel(
        id: 'tpl_gold_championship',
        title: 'Golden Cup',
        thumbnail: 'assets/App Logo/tournax.png',
        premium: false,
        backgroundImage: 'assets/App Logo/tournax.png',
        layoutType: 'split',
      ),
      const PosterTemplateModel(
        id: 'tpl_red_aggro',
        title: 'Aggressive Red',
        thumbnail: 'assets/design/login/6b9eacdc-4371-431d-9d3f-5243df9b5735.png',
        premium: true,
        backgroundImage: 'assets/design/login/6b9eacdc-4371-431d-9d3f-5243df9b5735.png',
        layoutType: 'split',
      ),
      const PosterTemplateModel(
        id: 'tpl_solid_minimal',
        title: 'Solid Minimalist',
        thumbnail: '',
        premium: false,
        backgroundImage: '',
        layoutType: 'compact',
      ),
    ];
  }

  List<PosterThemeModel> getThemes() {
    return PosterThemeModel.defaultThemes;
  }
}
