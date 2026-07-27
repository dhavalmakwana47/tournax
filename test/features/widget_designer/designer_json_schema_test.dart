import 'package:flutter_test/flutter_test.dart';
import 'package:tournax/features/widget_designer/data/models/designer_json_schema.dart';
import 'package:tournax/features/widget_designer/data/models/designer_placeholder_resolver.dart';

void main() {
  group('Widget Designer Schema & Interpolation Tests', () {
    test('DesignerLayerModel correctly serializes and deserializes JSON', () {
      const layer = DesignerLayerModel(
        id: 'layer_test_1',
        name: 'Header Title',
        type: DesignerLayerType.text,
        x: 50.0,
        y: 100.0,
        width: 400.0,
        height: 60.0,
        rotation: 15.0,
        opacity: 0.9,
        zIndex: 3,
        typography: DesignerTypography(
          text: '{tournament_name}',
          fontSize: 32.0,
          fontFamily: 'Bebas Neue',
          textColor: '#FFD700',
        ),
        boxModel: DesignerBoxModel(
          backgroundColor: '#161922',
          borderColor: '#00E5FF',
          borderWidth: 2.0,
          borderRadius: 8.0,
        ),
      );

      final json = layer.toJson();
      expect(json['id'], equals('layer_test_1'));
      expect(json['type'], equals('text'));
      expect(json['x'], equals(50.0));
      expect(json['z_index'], equals(3));

      final deserialized = DesignerLayerModel.fromJson(json);
      expect(deserialized.id, equals(layer.id));
      expect(deserialized.type, equals(DesignerLayerType.text));
      expect(deserialized.typography.text, equals('{tournament_name}'));
      expect(deserialized.boxModel.borderColor, equals('#00E5FF'));
    });

    test('WidgetDesignerProjectModel serializes full project canvas schema', () {
      final project = WidgetDesignerProjectModel(
        id: 'proj_123',
        name: 'Tournament Banner Widget',
        category: 'slot_list',
        canvas: const DesignerCanvasConfig(
          width: 1080.0,
          height: 420.0,
          backgroundColor: '#1E2330',
        ),
        layers: [
          const DesignerLayerModel(
            id: 'l1',
            name: 'Layer 1',
            type: DesignerLayerType.text,
          ),
        ],
        createdAt: '2026-07-26T00:00:00Z',
        updatedAt: '2026-07-26T00:00:00Z',
      );

      final json = project.toJson();
      expect(json['id'], equals('proj_123'));
      expect(json['canvas']['width'], equals(1080.0));
      expect(json['layers'].length, equals(1));

      final restored = WidgetDesignerProjectModel.fromJson(json);
      expect(restored.name, equals('Tournament Banner Widget'));
      expect(restored.canvas.height, equals(420.0));
      expect(restored.layers.first.id, equals('l1'));
    });

    test('DesignerPlaceholderResolver replaces placeholders with tournament data', () {
      const rawText = '{tournament_name} - {match_name} ({map_name})';
      final resolved = DesignerPlaceholderResolver.resolve(rawText);

      expect(resolved.contains('{tournament_name}'), isFalse);
      expect(resolved.contains('{match_name}'), isFalse);
      expect(resolved.contains('TOURNAX CHAMPIONSHIP'), isTrue);
      expect(resolved.contains('ERANGEL'), isTrue);
    });
  });
}
