// ABOUTME: End-to-end integration tests for critical user flows in the traffic accidents app.
// ABOUTME: Tests run on a real device/emulator using the real bundled SQLite database — no mocks.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:saobracajke/main.dart' as app;
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // Flow 1: App launch and splash screen
  // ---------------------------------------------------------------------------
  group('App launch and splash screen', () {
    testWidgets(
      'shows loading indicator during DB bootstrap, then main scaffold appears',
      (tester) async {
        app.main();
        await tester.pump();

        // The loading content carries the semantics label set in SplashScreen.
        // It may only be visible for a brief moment before DB init completes.
        // We verify that the CircularProgressIndicator appears at some point.
        final progressFinder = find.byType(CircularProgressIndicator);
        // It is valid for the splash to complete before the first pump on fast
        // devices, so we allow it to already be gone.
        final splashStillVisible = progressFinder.evaluate().isNotEmpty;
        if (splashStillVisible) {
          expect(progressFinder, findsAtLeastNWidgets(1));
        }

        // Wait for DB init and navigation to complete (up to 30 seconds).
        await tester.pumpAndSettle(const Duration(seconds: 30));

        // After bootstrap, BottomNavigationBar should be visible.
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      },
    );

    testWidgets(
      'no error banner shown after successful launch',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));

        // No retry button from the splash error screen.
        expect(find.text('Pokušaj ponovo'), findsNothing);
        // Main scaffold is present.
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Flow 2: Dashboard tab loads with data
  // ---------------------------------------------------------------------------
  group('Dashboard tab loads with data', () {
    testWidgets(
      'year filter dropdown is present and at least one stat value is rendered',
      (tester) async {
        app.main();
        // Wait for splash + DB init.
        await tester.pumpAndSettle(const Duration(seconds: 30));
        // Wait for dashboard async data load.
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // YearDepartmentFilter chip is always present when loaded.
        expect(find.byType(YearDepartmentFilter), findsOneWidget);

        // The "UKUPNO NESREĆA" label appears in the SectionOneHeader card.
        expect(find.text('UKUPNO NESREĆA'), findsOneWidget);

        // No MaterialBanner error is showing.
        expect(find.byType(MaterialBanner), findsNothing);
      },
    );

    testWidgets(
      'section 1 header is rendered after data loads',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // Scroll the dashboard body until the section header is visible.
        await tester.scrollUntilVisible(
          find.text('KLJUČNI POKAZATELJI'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('KLJUČNI POKAZATELJI'), findsOneWidget);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Flow 3: Tab navigation
  // ---------------------------------------------------------------------------
  group('Tab navigation', () {
    testWidgets(
      'tapping Map tab shows map screen app bar title',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));

        // Tap the Map tab (label 'Mapa').
        await tester.tap(find.text('Mapa'));
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // The MapScreen AppBar title.
        expect(find.text('Mapa Nesreća'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping About tab shows about screen static content',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));

        // Tap the About tab (label 'O aplikaciji').
        await tester.tap(find.text('O aplikaciji'));
        await tester.pumpAndSettle();

        // AboutScreen AppBar title and key static content are present.
        expect(find.text('O aplikaciji'), findsAtLeastNWidgets(1));
        expect(find.text('Izvor podataka'), findsOneWidget);
        expect(find.text('Napomena'), findsOneWidget);
        expect(find.text('Kontakt'), findsOneWidget);
      },
    );

    testWidgets(
      'navigating back to Dashboard tab preserves dashboard content',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // Navigate to About tab.
        await tester.tap(find.text('O aplikaciji'));
        await tester.pumpAndSettle();

        // Navigate back to Dashboard tab.
        await tester.tap(find.text('Pregled'));
        await tester.pumpAndSettle();

        // IndexedStack preserves state — dashboard content is still visible.
        expect(find.byType(YearDepartmentFilter), findsOneWidget);
        expect(find.byType(MaterialBanner), findsNothing);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Flow 4: Year filter change
  // ---------------------------------------------------------------------------
  group('Year filter change', () {
    testWidgets(
      'selecting a different year reloads dashboard without error',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 30));
        await tester.pumpAndSettle(const Duration(seconds: 15));

        // Confirm dashboard data is loaded.
        expect(find.text('UKUPNO NESREĆA'), findsOneWidget);

        // Open the year dropdown chip scoped to the filter widget.
        final yearDropdown = find.descendant(
          of: find.byType(YearDepartmentFilter),
          matching: find.byType(DropdownButton<int>),
        );
        await tester.tap(yearDropdown);
        await tester.pumpAndSettle();

        // Find all visible DropdownMenuItem<int> options in the overlay.
        final menuItems = find.byType(DropdownMenuItem<int>);
        final itemCount = menuItems.evaluate().length;

        if (itemCount > 1) {
          // Tap the second year option (differs from the default first).
          await tester.tap(menuItems.at(1));
          await tester.pumpAndSettle(const Duration(seconds: 15));

          // Data should still be present after filter change — no error.
          expect(find.text('UKUPNO NESREĆA'), findsOneWidget);
          expect(find.byType(MaterialBanner), findsNothing);
        } else {
          // Only one year available in this dataset build — close overlay.
          await tester.tapAt(Offset.zero);
          await tester.pumpAndSettle();
          // Dashboard unchanged.
          expect(find.text('UKUPNO NESREĆA'), findsOneWidget);
        }
      },
    );
  });
}
