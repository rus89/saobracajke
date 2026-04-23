// ABOUTME: Widget tests for the About screen content and layout.
// ABOUTME: Verifies all required text sections render correctly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saobracajke/presentation/ui/screens/about_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declared before the mocked-PackageInfo group so PackageInfo.fromPlatform
  // hasn't been populated yet — this exercises the genuine cold-start path
  // where _packageInfo is still null when the user taps the feedback tile.
  group('AboutScreen cold start', () {
    testWidgets(
      'feedback tile shows copyable email SnackBar when PackageInfo is null',
      (WidgetTester tester) async {
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(1200, 2400);

        await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
        // Deliberately skip pumpAndSettle so _loadVersion has not yet resolved
        // and _packageInfo is still null — the cold-start race the fix targets.

        final feedbackTile = find.text('Prijavite grešku ili predlog');
        await tester.tap(feedbackTile);
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('serbiaopendataapps@gmail.com'),
          ),
          findsOneWidget,
        );
      },
    );
  });

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

    testWidgets('displays app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('O aplikaciji'), findsOneWidget);
    });

    testWidgets('renders all three action tiles on non-web', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Oceni aplikaciju'), findsOneWidget);
      expect(find.text('Prijavite grešku ili predlog'), findsOneWidget);
      expect(find.text('Politika Privatnosti'), findsOneWidget);
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

    testWidgets(
      'feedback action tile exposes Semantics button with expected label',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final semanticsFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == 'Prijavite grešku ili predlog autoru',
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );

    testWidgets(
      'privacy policy action tile exposes Semantics button with expected label',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final semanticsFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label ==
                  'Otvori politiku privatnosti u pretraživaču',
        );
        expect(semanticsFinder, findsOneWidget);
      },
    );
  });

  group('buildCopyableSnackBar', () {
    test('builds SnackBar with Kopiraj action and 8 second duration', () {
      const target = 'https://example.com/path';
      final snackBar = buildCopyableSnackBar(target);

      expect(snackBar.duration, const Duration(seconds: 8));
      expect(snackBar.action, isNotNull);
      expect(snackBar.action!.label, 'Kopiraj');
      expect(snackBar.content, isA<Text>());
      expect((snackBar.content as Text).data, target);
    });
  });

  group('shouldShowRateTile', () {
    test('returns false when running on web', () {
      expect(shouldShowRateTile(isWeb: true), isFalse);
    });

    test('returns true when not running on web', () {
      expect(shouldShowRateTile(isWeb: false), isTrue);
    });
  });

  group('playStoreUrl', () {
    test('points at Google Play with the app package id', () {
      final uri = Uri.parse(playStoreUrl);

      expect(uri.host, 'play.google.com');
      expect(uri.queryParameters['id'], 'com.serbiaOpenData.saobracajke');
    });
  });

  group('privacyPolicyUrl', () {
    test('points at the public Serbia Open Data site over HTTPS', () {
      final uri = Uri.parse(privacyPolicyUrl);

      expect(uri.scheme, 'https');
      expect(uri.host, 'sites.google.com');
      expect(uri.path, '/view/serbiaopendata/home');
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

    test('encodes spaces as %20 (mailto RFC 6068), not + (form-style)', () {
      final info = PackageInfo(
        appName: 'saobracajke',
        packageName: 'com.serbiaOpenData.saobracajke',
        version: '1.1.1',
        buildNumber: '4',
        buildSignature: '',
        installerStore: null,
      );

      final raw = buildFeedbackUri(info).toString();

      expect(raw, contains('Nezgode%20'));
      expect(raw, isNot(contains('Nezgode+')));
    });
  });
}
