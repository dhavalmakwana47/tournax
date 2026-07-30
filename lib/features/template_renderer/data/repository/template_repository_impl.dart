import 'package:flutter/material.dart';
import '../datasource/template_remote_datasource.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/layer_style.dart';
import '../../domain/models/canvas_spec.dart';
import '../../domain/models/enums.dart';

abstract class TemplateRepository {
  Future<List<TemplateModel>> getTemplates();
  TemplateModel createDefault12SlotListTemplate();
}

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDatasource remoteDatasource;

  TemplateRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<TemplateModel>> getTemplates() async {
    final serverTemplates = await remoteDatasource.fetchTemplates();
    if (serverTemplates.isNotEmpty) {
      return serverTemplates;
    }
    return [createDefault12SlotListTemplate()];
  }

  @override
  TemplateModel createDefault12SlotListTemplate() {
    final now = DateTime.now().toIso8601String();

    final bgLayer = LayerModel(
      id: 'bg_1',
      name: 'Background Fill',
      type: LayerType.shape,
      shapeType: ShapeType.rectangle,
      x: 0,
      y: 0,
      width: 1080,
      height: 1920,
      zIndex: 0,
      style: LayerStyle(
        fillColorHex: 0xFF0F172A,
        isGradientFill: true,
        gradientColorsHex: [0xFF020617, 0xFF0F172A, 0xFF1E1B4B],
        gradientAngle: 135,
      ),
    );

    final titleLayer = LayerModel(
      id: 'title_1',
      name: 'Tournament Header',
      type: LayerType.text,
      text: '{{tournament_name}}',
      x: 40,
      y: 120,
      width: 1000,
      height: 70,
      zIndex: 1,
      style: LayerStyle(
        fontFamily: 'Inter',
        fontSize: 38,
        fontWeightValue: 900,
        textColorHex: 0xFFFFFFFF,
        textAlign: TextAlign.center,
        shadowColorHex: 0x88000000,
        shadowBlurRadius: 8,
        shadowDy: 4,
      ),
    );

    final subTitleLayer = LayerModel(
      id: 'subtitle_1',
      name: 'Match Fixture Header',
      type: LayerType.text,
      text: '{{group_name}} • {{match_name}}',
      x: 40,
      y: 195,
      width: 1000,
      height: 45,
      zIndex: 2,
      style: LayerStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeightValue: 700,
        textColorHex: 0xFF38BDF8,
        textAlign: TextAlign.center,
      ),
    );

    final dateLayer = LayerModel(
      id: 'date_1',
      name: 'Date Header',
      type: LayerType.text,
      text: 'DATE: {{match_date}}',
      x: 40,
      y: 245,
      width: 1000,
      height: 35,
      zIndex: 3,
      style: LayerStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeightValue: 600,
        textColorHex: 0xFF94A3B8,
        textAlign: TextAlign.center,
      ),
    );

    final layers = <LayerModel>[bgLayer, titleLayer, subTitleLayer, dateLayer];

    // Add 12 Slot Rows dynamically
    final double startY = 320;
    final double rowHeight = 105;
    final Map<String, String> defaultVars = {
      '{{tournament_name}}': 'TOURNAMAX CHAMPIONSHIP 2026',
      '{{group_name}}': 'GROUP A',
      '{{match_name}}': 'MATCH 01 (ERANGEL)',
      '{{match_date}}': '30 JUL 2026',
    };

    for (int i = 1; i <= 12; i++) {
      final slotKey = i < 10 ? '0$i' : '$i';
      final varName = '{{team_$i}}';
      defaultVars[varName] = 'TEAM $slotKey';

      layers.add(
        LayerModel(
          id: 'slot_row_$i',
          name: 'Slot $slotKey Row',
          type: LayerType.slotRow,
          x: 60,
          y: startY + (i - 1) * rowHeight,
          width: 960,
          height: 85,
          zIndex: 10 + i,
          metadata: {
            'slot': slotKey,
            'team_name': 'TEAM $slotKey',
            'pts': '0',
          },
        ),
      );
    }

    return TemplateModel(
      id: 'default_slot_list_12',
      name: 'Default 12-Team Slot List Template',
      description: 'Standard 12-Team Tournament Slot List Graphic Layout',
      category: 'Slot List',
      createdAt: now,
      updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080,
        height: 1920,
        backgroundColorHex: 0xFF0F172A,
      ),
      layers: layers,
      globalVariables: defaultVars,
    );
  }
}
