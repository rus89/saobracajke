// ABOUTME: Widget tests for the About screen content and layout.
// ABOUTME: Verifies all required text sections render correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saobracajke/presentation/ui/screens/about_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AboutScreen', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'saobracajke',
        packageName: 'com.serbiaOpenData.saobracajke',
        version: '1.1.1',
        buildNumber: '4',
        buildSignature: '',
        installerStore: null,
      );
    });

    Widget buildSubject() {
      return const MaterialApp(home: AboutScreen());
    }

    testWidgets('displays app name', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Saobraćajne Nezgode'), findsOneWidget);
    });

    testWidgets('displays app version', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('v1.1.1+4'), findsOneWidget);
    });

    testWidgets('displays data source information with clickable link', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('otvorenih podataka Republike Srbije'),
        findsOneWidget,
      );
      expect(find.text('Otvori izvor'), findsOneWidget);
    });

    testWidgets('displays disclaimer with educational purpose', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('edukativne svrhe'), findsOneWidget);
      expect(
        find.textContaining('nije povezan ni sa jednim državnim organom'),
        findsOneWidget,
      );
      expect(find.textContaining('nisu za zvaničnu upotrebu'), findsOneWidget);
    });

    testWidgets('displays contact email', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('serbiaopendataapps@gmail.com'), findsOneWidget);
    });

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('O aplikaciji'), findsOneWidget);
    });

    testWidgets('renders both action tiles on non-web', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Oceni aplikaciju'), findsOneWidget);
      expect(find.text('Prijavite grešku ili predlog'), findsOneWidget);
    });

    testWidgets(
      'rate action tile exposes Semantics button with expected label',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final semanticsFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label ==
                  'Oceni aplikaciju u Google Play prodavnici',
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );
  });

  group('shouldShowRateTile', () {
    test('returns false when running on web', () {
      expect(shouldShowRateTile(isWeb: true), isFalse);
    });

    test('returns true when not running on web', () {
      expect(shouldShowRateTile(isWeb: false), isTrue);
    });
  });

  group('buildFeedbackUri', () {
    test(
      'builds mailto URI with recipient, subject, and version-stamped body',
      () {
        final info = PackageInfo(
          appName: 'saobracajke',
          packageName: 'com.serbiaOpenData.saobracajke',
          version: '1.1.1',
          buildNumber: '4',
          buildSignature: '',
          installerStore: null,
        );

        final uri = buildFeedbackUri(info);

        expect(uri.scheme, 'mailto');
        expect(uri.path, 'serbiaopendataapps@gmail.com');
        expect(
          uri.queryParameters['subject'],
          'Saobraćajne Nezgode — povratna informacija',
        );
        expect(
          uri.queryParameters['body'],
          startsWith('Verzija aplikacije: v1.1.1+4'),
        );
      },
    );
  });
}
