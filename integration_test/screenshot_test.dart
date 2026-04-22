// ABOUTME: Integration test that captures Play Store screenshots by navigating real app state.
// ABOUTME: Must be run via `flutter drive` on a real emulator — not `flutter test`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:saobracajke/main.dart' as app;
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // 5. Screenshot 1: Dashboard
    await settleForScreenshot(tester);
    await binding.takeScreenshot('01_dashboard');

    // 6. Screenshot 2: Map tab. flutter_map setState-loops on tile loads, so
    //    pumpAndSettle never returns. A fixed 15 s delay is sized for the
    //    largest tablet viewport; 5 s leaves pixel_tablet with a gray map.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pump(const Duration(milliseconds: 300));
    await Future.delayed(const Duration(seconds: 15));
    await settleForScreenshot(tester);
    await binding.takeScreenshot('02_map');

    // 7. Screenshot 3: About tab. Static content — pump is sufficient.
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump(const Duration(milliseconds: 300));
    await settleForScreenshot(tester);
    await binding.takeScreenshot('03_about');
  });
}
