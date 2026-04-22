// ABOUTME: Widget tests for MapLegend, GlassyFab, and AccidentDetailSheet.
// ABOUTME: Verifies rendering of map overlay widgets independent of map tiles.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/presentation/ui/widgets/map/accident_detail_sheet.dart';
import 'package:saobracajke/presentation/ui/widgets/map/glassy_fab.dart';
import 'package:saobracajke/presentation/ui/widgets/map/map_legend.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

void main() {
  group('MapLegend', () {
    testWidgets('renders each accident-type label', (tester) async {
      await tester.pumpWidget(_wrap(const MapLegend()));
      expect(
        find.text(AccidentTypes.displayLabel(AccidentTypes.fatalities)),
        findsOneWidget,
      );
      expect(
        find.text(AccidentTypes.displayLabel(AccidentTypes.injuries)),
        findsOneWidget,
      );
      expect(
        find.text(AccidentTypes.displayLabel(AccidentTypes.materialDamage)),
        findsOneWidget,
      );
    });
  });

  group('GlassyFab', () {
    testWidgets('zoom in variant exposes Zoom in semantics as a button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          GlassyFab(
            heroTag: 'zoom_in',
            semanticLabel: 'Zoom in',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Zoom in'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      handle.dispose();
    });
  });

  group('AccidentDetailSheet', () {
    testWidgets('renders all four meta fields for a given accident',
        (tester) async {
      final accident = AccidentModel(
        id: '1',
        department: 'PU Beograd',
        station: 'PS Vračar',
        type: AccidentTypes.injuries,
        date: DateTime(2024, 5, 17, 9, 5),
        lat: 44.8,
        lng: 20.4,
        participants: 'Automobil',
      );
      await tester.pumpWidget(_wrap(AccidentDetailSheet(accident: accident)));
      expect(find.text('DATUM'), findsOneWidget);
      expect(find.text('VREME'), findsOneWidget);
      expect(find.text('STANICA'), findsOneWidget);
      expect(find.text('UČESNICI'), findsOneWidget);
      expect(find.text('17.5.2024'), findsOneWidget);
      expect(find.text('9:05'), findsOneWidget);
      expect(find.text('PS Vračar'), findsOneWidget);
      expect(find.text('Automobil'), findsOneWidget);
    });
  });
}
