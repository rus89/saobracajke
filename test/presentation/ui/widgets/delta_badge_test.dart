// ABOUTME: Widget tests for DeltaBadge — polarity, sign prefix, and color mapping.
// ABOUTME: Guards the shared YoY delta indicator contract.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/delta_badge.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(theme: AppTheme.dark, home: Scaffold(body: child));

  testWidgets('positive delta renders with "+" prefix and error color',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 42)));
    expect(find.text('+42'), findsOneWidget);
    final text = tester.widget<Text>(find.text('+42'));
    expect(text.style?.color, AppTheme.error);
  });

  testWidgets('negative delta renders without "+" and primary color',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: -17)));
    expect(find.text('-17'), findsOneWidget);
    final text = tester.widget<Text>(find.text('-17'));
    expect(text.style?.color, AppTheme.primary);
  });

  testWidgets('zero delta renders neutrally with textSecondary color',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 0)));
    expect(find.text('0'), findsOneWidget);
    final text = tester.widget<Text>(find.text('0'));
    expect(text.style?.color, AppTheme.textSecondary);
  });

  testWidgets('zero delta does not render a directional arrow',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 0)));
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
  });

  testWidgets('positive delta renders upward arrow by default',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 5)));
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
  });

  testWidgets('negative delta renders downward arrow by default',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: -5)));
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
  });

  testWidgets('positive delta has semantic label describing increase',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 7)));
    expect(
      find.bySemanticsLabel('Porast za 7 u odnosu na prošlu godinu'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('negative delta has semantic label describing decrease',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const DeltaBadge(delta: -4)));
    expect(
      find.bySemanticsLabel('Pad za 4 u odnosu na prošlu godinu'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('zero delta has semantic label describing no change',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 0)));
    expect(
      find.bySemanticsLabel('Bez promene u odnosu na prošlu godinu'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('optional trailing label is rendered after the delta',
      (tester) async {
    await tester.pumpWidget(
      wrap(const DeltaBadge(delta: -3, trailing: 'vs prošle godine')),
    );
    expect(find.text('-3'), findsOneWidget);
    expect(find.text('vs prošle godine'), findsOneWidget);
  });
}
