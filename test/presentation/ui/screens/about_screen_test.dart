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
  });
}
