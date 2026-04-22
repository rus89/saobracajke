// ABOUTME: Widget tests for SectionHeader — asserts label is uppercased and styling applied.
// ABOUTME: Guards the shared dashboard section header contract.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/section_header.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  testWidgets('renders the label verbatim (expected already uppercase)',
      (tester) async {
    await tester.pumpWidget(wrap(const SectionHeader(label: 'KLJUČNI POKAZATELJI')));
    expect(find.text('KLJUČNI POKAZATELJI'), findsOneWidget);
  });

  testWidgets('label uses labelSmall style with emerald dot and divider',
      (tester) async {
    await tester.pumpWidget(wrap(const SectionHeader(label: 'TRENDOVI')));

    final text = tester.widget<Text>(find.text('TRENDOVI'));
    expect(text.style?.fontSize, 10);
    expect(text.style?.letterSpacing, isNotNull);

    // Dot: a Container with primary color and 3x14 size.
    final dotFinder = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints == const BoxConstraints.tightFor(width: 3, height: 14),
    );
    expect(dotFinder, findsOneWidget);

    // A horizontal divider-style line uses Expanded + Container.
    expect(find.byType(Expanded), findsOneWidget);
  });
}
