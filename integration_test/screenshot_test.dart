// ABOUTME: Integration test that captures Play Store screenshots by navigating real app state.
// ABOUTME: Must be run via `flutter drive` on a real emulator — not `flutter test`.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:saobracajke/main.dart' as app;
import 'package:saobracajke/presentation/ui/screens/map_screen.dart';
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _datePattern = RegExp(r'\d+\.\d+\.\d+');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Ensure a frame is rasterized into FlutterImageView before each takeScreenshot.
  // Without this, takeScreenshot blocks its RPC reply waiting for a frame that
  // never arrives. Do NOT inline — every screenshot call needs it.
  Future<void> settleForScreenshot(WidgetTester tester) async {
    await tester.pump();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pump();
  }

  testWidgets('capture Play Store screenshots', (tester) async {
    // 1. Clear SharedPreferences so the dashboard starts with default filter state.
    //    The app has no onboarding — DB is bundled and bootstrapped on first launch.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 2. Launch the real app. Do NOT await — app.main() calls runApp() which
    //    never returns; awaiting hangs the test forever.
    app.main();

    // 3. Wait until the dashboard filter widget is in the tree. It only renders
    //    after DB bootstrap + dashboard provider finishes loading.
    //    Do NOT use bare pumpAndSettle() here — the async data load keeps the
    //    tree busy and pumpAndSettle will throw a timeout error.
    var found = false;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(seconds: 2));
      if (find.byType(YearDepartmentFilter).evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }
    if (!found) {
      fail('YearDepartmentFilter not found after 60 seconds — DB bootstrap or dashboard load failed.');
    }

    // 4. Switch the Flutter surface to image-capture mode. Must be called once,
    //    after the UI is stable, before any takeScreenshot.
    await binding.convertFlutterSurfaceToImage();

    // 5. Screenshot 1: Dashboard — default view (key indicators at top).
    await settleForScreenshot(tester);
    await binding.takeScreenshot('01_dashboard');

    // 6. Screenshot 2: Dashboard with the Uprava (municipality) dropdown
    //    expanded. With prefs.clear() the selected value is null, so the
    //    chip renders the "Sve uprave" DropdownMenuItem — tapping that text
    //    opens the dropdown. Municipality list is richer than the year one,
    //    so this single shot conveys both filter dimensions.
    await tester.tap(find.text('Sve uprave'));
    await tester.pumpAndSettle();
    await settleForScreenshot(tester);
    await binding.takeScreenshot('02_dashboard_filter');

    // Dismiss the dropdown by tapping the currently-selected menu entry
    // (value == null re-applied is a no-op). After opening, 'Sve uprave'
    // appears both on the chip and in the overlay menu — .last targets the
    // overlay entry which is rendered after the main tree.
    await tester.tap(find.text('Sve uprave').last);
    await tester.pumpAndSettle();

    // 7. Screenshot 3: Dashboard scrolled so the VREMENSKA DISTRIBUCIJA
    //    section header sits at the top of the viewport with the first pie
    //    chart directly below. scrollUntilVisible leaves the header near the
    //    bottom edge; we then measure the delta to the viewport top and drag
    //    by exactly that offset (a fixed drag overshoots into the middle of
    //    the pie charts).
    final scrollable = find.byType(Scrollable).first;
    final headerFinder = find.text('VREMENSKA DISTRIBUCIJA');
    await tester.scrollUntilVisible(
      headerFinder,
      200,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 200));
    final headerTop = tester.getRect(headerFinder).top;
    final viewportTop = tester.getRect(scrollable).top;
    final excessTop = headerTop - viewportTop - 8;
    if (excessTop > 0) {
      await tester.drag(scrollable, Offset(0, -excessTop));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await settleForScreenshot(tester);
    await binding.takeScreenshot('03_dashboard_charts');

    // 8. Screenshot 4: Map tab overview. flutter_map setState-loops on tile
    //    loads, so pumpAndSettle never returns. A fixed 15 s delay is sized
    //    for the largest tablet viewport; 5 s leaves pixel_tablet gray.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pump(const Duration(milliseconds: 300));
    await Future.delayed(const Duration(seconds: 15));
    await settleForScreenshot(tester);
    await binding.takeScreenshot('04_map');

    // 9. Screenshot 5: Map with the accident-detail bottom sheet open.
    //    Camera is driven directly via MapScreen.testMapController (exposed
    //    behind @visibleForTesting) rather than tapping clusters — at
    //    zoom ≥ 16 clustering is disabled so markers are individually
    //    tappable, and centring on Belgrade's Trg Republike at zoom 16
    //    keeps streets visible on the Carto dark basemap.
    final controller = MapScreen.testMapController;
    if (controller == null) {
      fail('MapScreen.testMapController was not registered.');
    }
    controller.move(const LatLng(44.8176, 20.4633), 16);
    await tester.pump(const Duration(milliseconds: 500));
    await Future.delayed(const Duration(seconds: 12));
    await tester.pump();

    final markers = find.descendant(
      of: find.byType(FlutterMap),
      matching: find.bySemanticsLabel(_datePattern),
    );
    if (markers.evaluate().isEmpty) {
      fail('No individual markers in viewport at Belgrade zoom 16.');
    }
    await tester.tap(markers.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await settleForScreenshot(tester);
    await binding.takeScreenshot('05_map_detail');
  });
}
