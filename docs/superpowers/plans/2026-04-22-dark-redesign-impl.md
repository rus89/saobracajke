# Dark Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Spec:** [docs/superpowers/specs/2026-04-04-dark-redesign-design.md](../specs/2026-04-04-dark-redesign-design.md)

**Goal:** Replace the current light Material 3 theme with the Deep Emerald dark aesthetic across all three screens (Pregled / Mapa / O Aplikaciji), while keeping data, logic, and navigation unchanged.

**Architecture:** Single-theme app (dark only). Theme tokens centralized in `app_theme.dart`. Two new reusable widgets (`SectionHeader`, `DeltaBadge`) absorb patterns that appear on the dashboard. Existing widgets are restyled in place. No changes to repositories, providers, or navigation.

**Tech Stack:** Flutter / Dart. DM Sans TTF bundled as an asset (no `google_fonts` dependency — offline-first, smaller footprint). Map tiles switch from OpenStreetMap standard to CartoDB `dark_all`. `fl_chart`, `flutter_map`, `flutter_map_marker_cluster` unchanged.

**Spec deviations (explicit):**
- Spec §2 calls for the `google_fonts` package. **Deviation:** we bundle DM Sans as a Flutter asset font and reference it via `TextStyle(fontFamily: 'DMSans')`. Rationale: Milan requested offline bundling; a direct asset font satisfies that without the network-fetch code path of `google_fonts`, and drops a dependency.
- Spec §7 calls for Stadia Maps tiles. **Deviation:** we use CartoDB `dark_all` tiles instead. Rationale: Stadia requires an API key for production; CartoDB's `dark_all` is free-tier with attribution only, zero signup.
- Spec §5 calls for a 1px `outline` top border on the bottom navigation bar and a 2×16 `primary` indicator line above the selected icon. **Deviation:** neither is implemented. Rationale: the classic `BottomNavigationBar` used in `main_scaffold.dart` has no border or indicator slots, and the plan intentionally does not restructure navigation (spec §11 "Out of scope: Navigation structure"). Migrating to M3 `NavigationBar` to gain an indicator would exceed the scope of a visual re-skin. `selectedItemColor: primary` + `unselectedItemColor: textSecondary` on the existing widget conveys the active-state distinction without new structure.

**Approved rewrites:** Milan has explicitly approved full-file rewrites for `lib/presentation/ui/widgets/dashboard/section_one_header.dart` (Task 11), `lib/presentation/ui/screens/about_screen.dart` (Task 21), and `lib/presentation/ui/widgets/year_department_filter.dart` (Task 8). The redesign changes structure (hero card + grid, hero + info cards, chip-style dropdowns) enough that in-place edits would be noisier than a clean replacement.

**Out of scope** (unchanged from spec §11): data layer, navigation structure, `AccidentTypes` normalization, `AppSpacing` tokens, app icon / launcher splash.

---

## File Structure

**New files:**
- `assets/fonts/DMSans-VariableFont_opsz,wght.ttf` — DM Sans variable font asset
- `lib/presentation/ui/widgets/section_header.dart` — emerald dot + caps label + outline line header
- `lib/presentation/ui/widgets/delta_badge.dart` — polarity-aware pill badge
- `test/presentation/ui/widgets/section_header_test.dart`
- `test/presentation/ui/widgets/delta_badge_test.dart`
- `test/core/theme/app_theme_test.dart` — asserts key color token values + typography family

**Modified files:**
- `pubspec.yaml` — adds `fonts:` section and `assets/fonts/` declaration
- `lib/core/theme/app_theme.dart` — full replacement (Deep Emerald palette, DM Sans text theme, component themes). Rename `AppTheme.light` → `AppTheme.dark`.
- `lib/main.dart` — `AppTheme.light` → `AppTheme.dark`
- `lib/presentation/ui/screens/home_screen.dart` — AppBar title+subtitle, filter row, section headers via new widget
- `lib/presentation/ui/widgets/dashboard/section_one_header.dart` — accent stripe, DeltaBadge, 3-col grid
- `lib/presentation/ui/widgets/dashboard/section_two_charts.dart` — axis/grid/border color tokens
- `lib/presentation/ui/widgets/dashboard/section_three_charts.dart` — same
- `lib/presentation/ui/widgets/year_department_filter.dart` — chip-style dropdowns
- `lib/presentation/ui/screens/map_screen.dart` — tile URL + attribution, marker, cluster, FABs, legend, filter overlay, bottom sheet
- `lib/presentation/ui/screens/about_screen.dart` — hero card + info cards
- `lib/main.dart` — splash screen dark styling (already inherits theme; minor tweaks only)
- Existing tests under `test/` — update where token references change

---

## Conventions

- **Commits per task:** one commit per completed task. Pre-commit hook runs `flutter analyze` + `flutter test` — do not bypass with `--no-verify`.
- **TDD order:** write/update the failing test first, confirm failure, implement, confirm green, commit.
- **File header:** every new Dart file starts with two `// ABOUTME:` lines per the project rule.
- **No emojis** in code or commits.

---

## Task 1: Bundle DM Sans font asset

**Files:**
- Create: `assets/fonts/DMSans.ttf`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Create fonts directory and download DM Sans variable font**

```bash
mkdir -p assets/fonts
curl -fL \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/dmsans/DMSans%5Bopsz%2Cwght%5D.ttf" \
  -o "assets/fonts/DMSans.ttf"
ls -lh "assets/fonts/DMSans.ttf"
```

Expected: file exists, ~350-450 KB. (The source file on GitHub uses `DMSans[opsz,wght].ttf`; we rename to `DMSans.ttf` to avoid YAML-hostile characters in `pubspec.yaml`.)

- [ ] **Step 2: Declare font family in pubspec.yaml**

Add a `fonts:` section under `flutter:` (after the existing `assets:` block):

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/db/serbian_traffic.db.zip
  fonts:
    - family: DMSans
      fonts:
        - asset: assets/fonts/DMSans.ttf
```

- [ ] **Step 3: Pub get to pick up the new asset**

Run: `flutter pub get`
Expected: exit 0, no errors.

- [ ] **Step 4: Verify the font is visible to Flutter**

Run: `flutter analyze`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add assets/fonts/ pubspec.yaml
git commit -m "chore: bundle DM Sans font asset for dark redesign"
```

---

## Task 2: Theme color tokens (Deep Emerald palette)

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Create: `test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Write failing test for the new palette**

Create `test/core/theme/app_theme_test.dart`:

```dart
// ABOUTME: Tests that AppTheme exposes the Deep Emerald dark palette tokens.
// ABOUTME: Guards against accidental color regressions.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

void main() {
  group('AppTheme color tokens', () {
    test('scaffoldBg is Deep Emerald navy', () {
      expect(AppTheme.scaffoldBg, const Color(0xFF0A1628));
    });

    test('surface is elevated emerald navy', () {
      expect(AppTheme.surface, const Color(0xFF0E1E35));
    });

    test('surfaceElevated is brighter navy', () {
      expect(AppTheme.surfaceElevated, const Color(0xFF162540));
    });

    test('primary is emerald 500', () {
      expect(AppTheme.primary, const Color(0xFF10B981));
    });

    test('primaryDark is emerald 600', () {
      expect(AppTheme.primaryDark, const Color(0xFF059669));
    });

    test('textPrimary is near-white navy tint', () {
      expect(AppTheme.textPrimary, const Color(0xFFE2EDF8));
    });

    test('textSecondary is mid-contrast navy tint', () {
      expect(AppTheme.textSecondary, const Color(0xFF8AADCC));
    });

    test('textMuted is low-contrast navy tint', () {
      expect(AppTheme.textMuted, const Color(0xFF4A6A8A));
    });

    test('outline is navy border', () {
      expect(AppTheme.outline, const Color(0xFF1A3050));
    });

    test('outlineVariant is subtler navy border', () {
      expect(AppTheme.outlineVariant, const Color(0xFF142A45));
    });

    test('semantic colors preserved', () {
      expect(AppTheme.semanticFatalities, const Color(0xFFEF4444));
      expect(AppTheme.semanticInjuries, const Color(0xFFF97316));
      expect(AppTheme.semanticMaterialDamage, const Color(0xFF3B82F6));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `AppTheme.scaffoldBg` etc. undefined.

- [ ] **Step 3: Replace color tokens in app_theme.dart**

Overwrite the color tokens section (the top of the class body, before `static ThemeData get light`). Replace lines 11-30 of [lib/core/theme/app_theme.dart](../../../lib/core/theme/app_theme.dart) with:

```dart
  // ---------- Deep Emerald palette ----------
  static const Color scaffoldBg = Color(0xFF0A1628);
  static const Color surface = Color(0xFF0E1E35);
  static const Color surfaceElevated = Color(0xFF162540);
  static const Color primary = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF059669);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFE2EDF8);
  static const Color textSecondary = Color(0xFF8AADCC);
  static const Color textMuted = Color(0xFF4A6A8A);
  static const Color outline = Color(0xFF1A3050);
  static const Color outlineVariant = Color(0xFF142A45);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0x1FEF4444);

  // ---------- Semantic (accident type) colors ----------
  static const Color semanticFatalities = Color(0xFFEF4444);
  static const Color semanticInjuries = Color(0xFFF97316);
  static const Color semanticMaterialDamage = Color(0xFF3B82F6);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS.

- [ ] **Step 5: Run analyze to catch downstream breakage**

Run: `flutter analyze`
Expected: there WILL be errors — the old `primaryGreen`, `primaryGreenDark`, `onSurface`, etc. tokens are referenced from other files. Those get fixed in later tasks. Do NOT fix them now; just note the errors exist. If the errors are confined to references to `AppTheme.primaryGreen`, `AppTheme.primaryGreenDark`, `AppTheme.onSurface`, `AppTheme.onSurfaceVariant`, `AppTheme.surfaceContainer`, `AppTheme.surfaceContainerLow`, `AppTheme.outlineLight`, `AppTheme.onError` — that's expected. Do NOT commit yet.

Actually, to keep the tree compilable commit-by-commit, **keep backwards-compatible aliases** as getters in this same step. Add these inside the class body (below the new tokens):

```dart
  // Transitional aliases — removed as call sites migrate in later tasks.
  static const Color primaryGreen = primary;
  static const Color primaryGreenDark = primaryDark;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
  static const Color surfaceContainer = surface;
  static const Color surfaceContainerLow = surfaceElevated;
  static const Color outlineLight = outlineVariant;
  static const Color onError = onPrimary;
```

Re-run `flutter analyze`. Expected: clean. (`primaryGreenLight` is defined in the current `app_theme.dart:14` but is unused outside the file — verified via `grep -rn 'primaryGreenLight' lib test integration_test`; the wholesale rewrite in Step 3 drops it, no alias needed.)

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "feat: introduce Deep Emerald color tokens in AppTheme"
```

---

## Task 3: Theme typography (DM Sans text theme)

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Extend the app_theme_test with typography assertions**

Append to `test/core/theme/app_theme_test.dart` inside `void main()`:

```dart
  group('AppTheme typography', () {
    test('uses DMSans font family on displayLarge', () {
      final style = AppTheme.dark.textTheme.displayLarge;
      expect(style?.fontFamily, 'DMSans');
    });

    test('displayLarge is 48px weight 800', () {
      final style = AppTheme.dark.textTheme.displayLarge;
      expect(style?.fontSize, 48);
      expect(style?.fontWeight, FontWeight.w800);
    });

    test('labelSmall is 10px weight 600 with 1.5px tracking', () {
      final style = AppTheme.dark.textTheme.labelSmall;
      expect(style?.fontSize, 10);
      expect(style?.fontWeight, FontWeight.w600);
      expect(style?.letterSpacing, 1.5);
    });

    test('bodyMedium uses textPrimary color', () {
      final style = AppTheme.dark.textTheme.bodyMedium;
      expect(style?.color, AppTheme.textPrimary);
    });
  });
```

Note: this references `AppTheme.dark`, which Task 5 renames from the existing `light` getter. To keep Tasks 3 and 4 compilable before that rename, Step 3 below adds a temporary `static ThemeData get dark => light;` forwarding getter that Task 5 removes.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `AppTheme.dark` undefined or typography mismatches.

- [ ] **Step 3: Replace `_buildTextTheme()` body and add a `dark` getter forwarding to `light`**

Replace the body of `_buildTextTheme()` (currently lines 123-194 of [lib/core/theme/app_theme.dart](../../../lib/core/theme/app_theme.dart)):

```dart
  static TextTheme _buildTextTheme() {
    const family = 'DMSans';
    const features = [FontFeature.tabularFigures()];
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: family,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.0,
        letterSpacing: -2.0,
        fontFeatures: features,
      ),
      displayMedium: TextStyle(
        fontFamily: family,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.05,
        letterSpacing: -1.0,
        fontFeatures: features,
      ),
      headlineMedium: TextStyle(
        fontFamily: family,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFeatures: features,
      ),
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: family,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.5,
      ),
      labelMedium: TextStyle(
        fontFamily: family,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.5,
      ),
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
```

Also add `import 'dart:ui' show FontFeature;` at the top of the file (only if `FontFeature` isn't already accessible via `package:flutter/material.dart`). The Flutter `material` library re-exports `FontFeature`, so most likely you don't need the extra import — check with `flutter analyze` after edit.

Finally, add a `dark` getter alongside `light` (at the end of the class body, before the `sectionTitleStyle`):

```dart
  /// Dark theme for the app (Deep Emerald).
  static ThemeData get dark => light;
```

This is a temporary alias so the test in Step 1 passes; Task 5 renames the real getter.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: clean (legacy aliases from Task 2 still absorb any dangling references).

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "feat: switch AppTheme typography to DM Sans"
```

---

## Task 4: Theme component themes

**Files:**
- Modify: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Replace the body of `static ThemeData get light`**

Replace the entire `light` getter body (currently lines 33-121) with the dark-theme `ThemeData`. The full replacement — `ColorScheme.dark(...)`, `AppBarTheme`, `CardThemeData`, `BottomNavigationBarThemeData`, `FloatingActionButtonThemeData`, `InputDecorationTheme`, `DropdownMenuThemeData`, button themes:

```dart
  /// Dark theme (Deep Emerald) applied to the entire app.
  static ThemeData get light {
    const colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryDark,
      onPrimaryContainer: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      onSurfaceVariant: textSecondary,
      outline: outline,
      outlineVariant: outlineVariant,
      error: error,
      onError: onPrimary,
      errorContainer: errorContainer,
      onErrorContainer: error,
      shadow: Color(0xFF000000),
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: scaffoldBg,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: const IconThemeData(color: textPrimary),
        shape: const Border(
          bottom: BorderSide(color: outline, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(
            AppSpacing.minTouchTarget,
            AppSpacing.minTouchTarget,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: textTheme.bodySmall?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodySmall?.copyWith(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        isDense: false,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(surfaceElevated),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              side: const BorderSide(color: outline),
            ),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: const BorderSide(color: outline),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 0,
        extendedSizeConstraints: BoxConstraints(minHeight: 56, minWidth: 56),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceElevated,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }
```

Also update `sectionTitleStyle` at the bottom of the class (currently lines 197-203) since the old value is no longer used:

```dart
  /// Deprecated — use the SectionHeader widget instead.
  @Deprecated('Use SectionHeader widget.')
  static const TextStyle sectionTitleStyle = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 1.5,
  );
```

Milan approved: do NOT create backward-compat preservation for the sectionTitleStyle name itself beyond the `@Deprecated` annotation; it will be removed when no references remain.

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: clean. Legacy-alias getters from Task 2 absorb remaining references; `@Deprecated` on `sectionTitleStyle` will surface as an info-level hint ONLY at call sites (acceptable).

- [ ] **Step 3: Run all tests**

Run: `flutter test`
Expected: PASS for theme tests. Widget tests may still pass because the legacy aliases keep colour references compiling; if any widget test asserts a specific old color (e.g. `primaryGreen == 0xFF2E7D32`), it will fail — that's addressed in later tasks. If any unexpected test fails, stop and diagnose rather than pushing through.

- [ ] **Step 4: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat: apply Deep Emerald dark theme to Material components"
```

---

## Task 5: Rename `AppTheme.light` → `AppTheme.dark`

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/main.dart`
- Modify: any test files referencing `AppTheme.light`

- [ ] **Step 1: Find all references to `AppTheme.light`**

Run: `grep -rn 'AppTheme.light' lib/ test/ integration_test/`

Expected: handful of call sites in `lib/main.dart` and possibly test files.

- [ ] **Step 2: Rename the getter and the forwarding alias in app_theme.dart**

In [lib/core/theme/app_theme.dart](../../../lib/core/theme/app_theme.dart):
- Change `static ThemeData get light {` to `static ThemeData get dark {`
- Delete the temporary `static ThemeData get dark => light;` forwarding alias from Task 3.

- [ ] **Step 3: Update all call sites**

Replace `AppTheme.light` with `AppTheme.dark` in every file grepped in Step 1. In the current tree that's `lib/main.dart:29`.

- [ ] **Step 4: Run analyze**

Run: `flutter analyze`
Expected: clean.

- [ ] **Step 5: Run tests**

Run: `flutter test`
Expected: PASS (theme tests already assert `AppTheme.dark`).

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_theme.dart lib/main.dart test/
git commit -m "refactor: rename AppTheme.light to AppTheme.dark"
```

---

## Task 6: `SectionHeader` widget

Reusable header: 3×14px emerald dot, 10px caps label, full-width outline line.

**Files:**
- Create: `lib/presentation/ui/widgets/section_header.dart`
- Create: `test/presentation/ui/widgets/section_header_test.dart`

- [ ] **Step 1: Write failing widget test**

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/ui/widgets/section_header_test.dart`
Expected: FAIL — `SectionHeader` undefined.

- [ ] **Step 3: Implement SectionHeader**

Create `lib/presentation/ui/widgets/section_header.dart`:

```dart
// ABOUTME: Dashboard section header — emerald dot + caps label + outline line.
// ABOUTME: Used above each dashboard section instead of "Sekcija N:" text.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints.tightFor(width: 3, height: 14),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(height: 1, color: AppTheme.outline),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/ui/widgets/section_header_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/ui/widgets/section_header.dart test/presentation/ui/widgets/section_header_test.dart
git commit -m "feat: add SectionHeader widget for dashboard sections"
```

---

## Task 7: `DeltaBadge` widget

Pill badge: red (error) bg+text when delta > 0 (worse), emerald bg+text when delta ≤ 0 (better/equal).

**Files:**
- Create: `lib/presentation/ui/widgets/delta_badge.dart`
- Create: `test/presentation/ui/widgets/delta_badge_test.dart`

- [ ] **Step 1: Write failing widget test**

```dart
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

  testWidgets('zero delta renders with "0" and primary color (treated as no-regression)',
      (tester) async {
    await tester.pumpWidget(wrap(const DeltaBadge(delta: 0)));
    expect(find.text('0'), findsOneWidget);
    final text = tester.widget<Text>(find.text('0'));
    expect(text.style?.color, AppTheme.primary);
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/ui/widgets/delta_badge_test.dart`
Expected: FAIL — `DeltaBadge` undefined.

- [ ] **Step 3: Implement DeltaBadge**

Create `lib/presentation/ui/widgets/delta_badge.dart`:

```dart
// ABOUTME: Polarity-aware pill badge for year-over-year deltas.
// ABOUTME: Red when worse (delta > 0), emerald when equal or better.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({
    super.key,
    required this.delta,
    this.trailing,
    this.showArrow = false,
  });

  final int delta;
  final String? trailing;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWorse = delta > 0;
    final color = isWorse ? AppTheme.error : AppTheme.primary;
    final bg = color.withValues(alpha: 0.12);
    final sign = delta > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow) ...[
            Icon(
              isWorse ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            '$sign$delta',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              trailing!,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/ui/widgets/delta_badge_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/ui/widgets/delta_badge.dart test/presentation/ui/widgets/delta_badge_test.dart
git commit -m "feat: add DeltaBadge widget for YoY indicators"
```

---

## Task 8: Restyle `YearDepartmentFilter` as chip-style

Per spec §5 & §6: `surface` background, 1px `outline`, `primary` text color for value, 11px weight 600, 8px radius. Remove heavy border treatment — slim inline chips.

**Files:**
- Modify: `lib/presentation/ui/widgets/year_department_filter.dart`

- [ ] **Step 1: Replace the widget body**

Overwrite [lib/presentation/ui/widgets/year_department_filter.dart](../../../lib/presentation/ui/widgets/year_department_filter.dart):

```dart
// ABOUTME: Reusable filter widget with year and police department dropdown selectors.
// ABOUTME: Chip-style presentation on both home screen and map overlay.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

class YearDepartmentFilter extends StatelessWidget {
  const YearDepartmentFilter({
    super.key,
    required this.selectedYear,
    required this.availableYears,
    required this.selectedDept,
    required this.departments,
    required this.onYearChanged,
    required this.onDepartmentChanged,
    this.compact = false,
  });

  final int? selectedYear;
  final List<int> availableYears;
  final String? selectedDept;
  final List<String> departments;
  final ValueChanged<int?>? onYearChanged;
  final ValueChanged<String?>? onDepartmentChanged;

  /// When true, uses denser layout (e.g. map overlay).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter by year and police department',
      child: Row(
        children: [
          Expanded(
            child: _Chip<int>(
              value: selectedYear,
              items: availableYears
                  .map(
                    (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
                  )
                  .toList(),
              hint: 'Godina',
              onChanged: onYearChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Chip<String?>(
              value: selectedDept,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sve uprave'),
                ),
                ...departments.map(
                  (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
                ),
              ],
              hint: 'Uprava',
              onChanged: onDepartmentChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip<T> extends StatelessWidget {
  const _Chip({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hint;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          isDense: true,
          value: value,
          hint: Text(
            hint,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          dropdownColor: AppTheme.surfaceElevated,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.textMuted,
          ),
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppTheme.primary,
            letterSpacing: 0.5,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
```

Note: this drops the `compact` parameter from influencing layout (there is effectively one chip layout now). Keep the parameter on the class signature to preserve call sites — mark its use as intentionally ignored with a single leading underscore in the field declaration. Actually keep the public API unchanged but note `compact` is reserved for future tweaks; no behavior difference today.

- [ ] **Step 2: Update tests**

Existing tests that reference `DropdownButtonFormField` or `labelText: 'Izaberite godinu'` need updating. Run the grep across BOTH `test/` and `integration_test/`:

```bash
grep -rn 'Izaberite godinu\|Izaberite policijsku\|DropdownButtonFormField' test/ integration_test/
```

Expected hits today: `test/presentation/ui/screens/home_screen_test.dart:140-141` and `integration_test/app_test.dart:68,150,173-174`. For each matching assertion, update to the new UI: `find.text('Godina')`, `find.text('Uprava')`, `find.byType(DropdownButton)`. Where an assertion was purely presentation-checking (labelText), remove it; where it was behavioral (tapping a dropdown and selecting a value), update the finder. Pay particular attention to `integration_test/app_test.dart:173-174` — the `find.descendant(of: find.text('Izaberite godinu'), matching: find.byType(DropdownButtonFormField<int>))` will break on both counts and must be rewritten against the new chip widget.

- [ ] **Step 3: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + all unit/widget tests pass. (Integration tests are not run here — they require an emulator; they are exercised in Task 24.)

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/ui/widgets/year_department_filter.dart test/ integration_test/
git commit -m "feat: restyle YearDepartmentFilter as chip-style"
```

---

## Task 9: Home screen — AppBar title+subtitle + new filter row

**Files:**
- Modify: `lib/presentation/ui/screens/home_screen.dart`

- [ ] **Step 1: Replace AppBar and filter row**

In [lib/presentation/ui/screens/home_screen.dart](../../../lib/presentation/ui/screens/home_screen.dart), replace the `AppBar` (lines 24-29) and the filter-row block (lines 75-107) with:

```dart
      appBar: AppBar(
        title: asyncState.maybeWhen(
          data: (state) {
            final theme = Theme.of(context);
            final year = state.selectedYear;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pregled', style: theme.textTheme.titleMedium),
                if (year != null)
                  Text(
                    'Saobraćajne nezgode · $year',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            );
          },
          orElse: () => const Text('Pregled'),
        ),
      ),
```

And the filter row (replacing the `Semantics`/`Container`/`Padding` wrapping `YearDepartmentFilter`):

```dart
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        child: YearDepartmentFilter(
                          selectedYear: state.selectedYear,
                          availableYears: state.availableYears,
                          selectedDept: state.selectedDept,
                          departments: state.departments,
                          onYearChanged: (year) {
                            if (year != null) {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setYear(year);
                            }
                          },
                          onDepartmentChanged: (dept) {
                            ref
                                .read(dashboardProvider.notifier)
                                .setDepartment(dept);
                          },
                        ),
                      ),
```

Keep the rest of the build method (sections, loading, error) unchanged in this task.

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean. `home_screen_test.dart:119` asserts `'Saobraćajne Nezgode - Pregled'` and will fail — update it to find `'Pregled'` + `'Saobraćajne nezgode · <year>'`. Also update `integration_test/app_test.dart` if it asserts the same string (`grep -n 'Saobraćajne Nezgode - Pregled' integration_test/` — if any match, update likewise).

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/home_screen.dart test/ integration_test/
git commit -m "feat: home screen AppBar title+subtitle and slim filter row"
```

---

## Task 10: Home screen — replace `_SectionHeader` with new widget

**Files:**
- Modify: `lib/presentation/ui/screens/home_screen.dart`

- [ ] **Step 1: Remove the private `_SectionHeader` class and update call sites**

In [lib/presentation/ui/screens/home_screen.dart](../../../lib/presentation/ui/screens/home_screen.dart):

- Delete the `_SectionHeader` class (lines 157-195 or thereabouts).
- Replace the three call sites with the new widget:

```dart
const SectionHeader(label: 'KLJUČNI POKAZATELJI'),
// ...
const SectionHeader(label: 'TRENDOVI'),
// ...
const SectionHeader(label: 'VREMENSKA DISTRIBUCIJA'),
```

- Add the import: `import 'package:saobracajke/presentation/ui/widgets/section_header.dart';`

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean. Grep across BOTH directories to find all affected assertions:

```bash
grep -rn 'Sekcija 1:\|Sekcija 2:\|Sekcija 3:' test/ integration_test/
```

Expected hits: `test/presentation/ui/screens/home_screen_test.dart:99-101` and `integration_test/app_test.dart:88,92`. Replace each with `'KLJUČNI POKAZATELJI'` / `'TRENDOVI'` / `'VREMENSKA DISTRIBUCIJA'` to match the new widget output.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/home_screen.dart test/ integration_test/
git commit -m "feat: use SectionHeader widget on home screen"
```

---

## Task 11: Refactor `SectionOneHeader` — hero accent + DeltaBadge + 3-col grid

Spec §6: hero KPI card with top accent gradient stripe, `displayLarge` total, DeltaBadge below; mini stats 3-column `GridView` with 26px override for the count.

**Files:**
- Modify: `lib/presentation/ui/widgets/dashboard/section_one_header.dart`

- [ ] **Step 1: Overwrite the widget**

Replace the entire file contents of [lib/presentation/ui/widgets/dashboard/section_one_header.dart](../../../lib/presentation/ui/widgets/dashboard/section_one_header.dart) with:

```dart
// ABOUTME: Dashboard section 1 body: hero KPI card plus mini stats for injuries/fatalities/material damage.
// ABOUTME: Consumes DeltaBadge for year-over-year indicators and shows three-column grid of metrics.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/presentation/ui/widgets/delta_badge.dart';

class SectionOneHeader extends StatelessWidget {
  const SectionOneHeader({
    super.key,
    required this.totalAccidents,
    required this.delta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.injuries,
    required this.injuriesDelta,
    required this.materialDamageAccidents,
    required this.materialDamageAccidentsDelta,
  });

  final int totalAccidents;
  final int delta;
  final int fatalities;
  final int fatalitiesDelta;
  final int injuries;
  final int injuriesDelta;
  final int materialDamageAccidents;
  final int materialDamageAccidentsDelta;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Key metrics: $totalAccidents total accidents, trend $delta vs last year. Injuries: $injuries, Fatalities: $fatalities, Material damage: $materialDamageAccidents',
      child: Column(
        children: [
          _HeroCard(total: totalAccidents, delta: delta),
          const SizedBox(height: AppSpacing.lg),
          _MiniGrid(
            injuries: injuries,
            injuriesDelta: injuriesDelta,
            fatalities: fatalities,
            fatalitiesDelta: fatalitiesDelta,
            materialDamage: materialDamageAccidents,
            materialDamageDelta: materialDamageAccidentsDelta,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.total, required this.delta});

  final int total;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UKUPNO NESREĆA',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  NumberFormat('#,###').format(total),
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                DeltaBadge(
                  delta: delta,
                  trailing: 'vs prošle godine',
                  showArrow: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGrid extends StatelessWidget {
  const _MiniGrid({
    required this.injuries,
    required this.injuriesDelta,
    required this.fatalities,
    required this.fatalitiesDelta,
    required this.materialDamage,
    required this.materialDamageDelta,
  });

  final int injuries;
  final int injuriesDelta;
  final int fatalities;
  final int fatalitiesDelta;
  final int materialDamage;
  final int materialDamageDelta;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final cards = [
          _MiniStat(
            label: 'POVREĐENI',
            count: injuries,
            delta: injuriesDelta,
            color: AppTheme.semanticInjuries,
            icon: Icons.personal_injury,
          ),
          _MiniStat(
            label: 'POGINULI',
            count: fatalities,
            delta: fatalitiesDelta,
            color: AppTheme.semanticFatalities,
            icon: Icons.heart_broken,
          ),
          _MiniStat(
            label: 'MAT. ŠTETA',
            count: materialDamage,
            delta: materialDamageDelta,
            color: AppTheme.semanticMaterialDamage,
            icon: Icons.build,
          ),
        ];
        if (narrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.count,
    required this.delta,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final int delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            NumberFormat('#,###').format(count),
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          DeltaBadge(delta: delta),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean. If an existing widget test on home_screen asserted specific private class names (`_MiniStatArgs`), they will need updating — but the new file does not export internals, so tests should rely on rendered labels only.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/widgets/dashboard/section_one_header.dart test/
git commit -m "feat: redesign SectionOneHeader with accent hero and mini grid"
```

---

## Task 12: Restyle Section 2 charts for dark tokens

**Files:**
- Modify: `lib/presentation/ui/widgets/dashboard/section_two_charts.dart`

- [ ] **Step 1: Replace hardcoded chart styling with new tokens**

Three changes throughout [lib/presentation/ui/widgets/dashboard/section_two_charts.dart](../../../lib/presentation/ui/widgets/dashboard/section_two_charts.dart):

1. Each chart card's `BoxDecoration`: replace `color: theme.colorScheme.surface` with `color: AppTheme.surface` and `border: Border.all(color: theme.colorScheme.outlineVariant)` with `border: Border.all(color: AppTheme.outline)`. (`radiusMd` stays.)

2. `FlGridData` instances — replace bare `FlGridData(show: true)` with:

```dart
FlGridData(
  show: true,
  drawVerticalLine: false,
  getDrawingHorizontalLine: (_) =>
      const FlLine(color: AppTheme.outlineVariant, strokeWidth: 1),
),
```

3. `FlBorderData`: replace `border: Border.all(color: theme.colorScheme.outline)` with `border: Border.all(color: AppTheme.outlineVariant)` — avoids competing with the grid.

4. Axis title text: every `Text(…, style: theme.textTheme.bodySmall)` inside `getTitlesWidget` becomes:

```dart
Text(
  '...',
  style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textMuted),
),
```

5. The purple bar-chart color `Colors.purple.shade600` on line 386 becomes `AppTheme.primary`.

6. The monthly-line dot `strokeColor: theme.colorScheme.surface` becomes `strokeColor: AppTheme.surface` (token matches value post-theme-swap; kept explicit for clarity).

Add the import if missing: `import 'package:saobracajke/core/theme/app_theme.dart';`

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/widgets/dashboard/section_two_charts.dart
git commit -m "feat: dark-theme chart tokens for SectionTwoCharts"
```

---

## Task 13: Restyle Section 3 charts for dark tokens

**Files:**
- Modify: `lib/presentation/ui/widgets/dashboard/section_three_charts.dart`

- [ ] **Step 1: Apply the same substitutions as Task 12**

In [lib/presentation/ui/widgets/dashboard/section_three_charts.dart](../../../lib/presentation/ui/widgets/dashboard/section_three_charts.dart):

1. Each chart card's `BoxDecoration`: `color: theme.colorScheme.surface` → `color: AppTheme.surface`; `border: Border.all(color: theme.colorScheme.outlineVariant)` → `border: Border.all(color: AppTheme.outline)`.

2. Pie slice title text color: `color: theme.colorScheme.surface` → `color: AppTheme.scaffoldBg` (the slice text is rendered ON a slice, so it needs contrast against the slice color — dark navy is correct against the vivid semantic palette).

3. Legend text `bodyMedium` → `bodyMedium?.copyWith(color: AppTheme.textPrimary)` (explicit, for safety); label color `theme.colorScheme.onSurfaceVariant` → `AppTheme.textSecondary`.

4. Legend swatch color Container: unchanged (uses the `colors[]` list already).

Add the import if missing.

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/widgets/dashboard/section_three_charts.dart
git commit -m "feat: dark-theme chart tokens for SectionThreeTemporal"
```

---

## Task 14: Map — switch tiles to CartoDB dark_all + attribution

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Update the TileLayer**

In [lib/presentation/ui/screens/map_screen.dart](../../../lib/presentation/ui/screens/map_screen.dart), replace the `TileLayer` (lines 179-184) with:

```dart
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.serbiaOpenData.saobracajke',
                      retinaMode: RetinaMode.isHighDensity(context),
                      maxZoom: 20,
                    ),
```

Add the attribution. Immediately after `MarkerClusterLayerWidget(...)` inside the `FlutterMap.children:` list, append a `RichAttributionWidget`:

```dart
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                        TextSourceAttribution(
                          'CARTO',
                          onTap: () {},
                        ),
                      ],
                    ),
```

`RichAttributionWidget` is provided by `flutter_map` out of the box — no import changes required beyond the existing `package:flutter_map/flutter_map.dart`. `TextSourceAttribution` prepends `© ` automatically via its default `prependCopyright: true`, so the text strings above intentionally omit the leading copyright symbol.

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: switch map tiles to CartoDB dark_all with attribution"
```

---

## Task 15: Map — markers become filled circle dots

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace `_buildMarker` and the per-marker size**

In [lib/presentation/ui/screens/map_screen.dart](../../../lib/presentation/ui/screens/map_screen.dart):

Replace `_buildMarker` (lines 32-59) with:

```dart
  //----------------------------------------------------------------------------
  Widget _buildMarker(String type) {
    final color = _getMarkerColor(type);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.scaffoldBg, width: 2),
      ),
    );
  }
```

Update the marker creation inside `build` (lines 123-136) to use the new signature and reduce the marker bounding box:

```dart
      markers.add(
        Marker(
          point: LatLng(accident.lat, accident.lng),
          width: 14,
          height: 14,
          child: GestureDetector(
            onTap: () => _showAccidentDetails(accident),
            child: _buildMarker(accident.type),
          ),
        ),
      );
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: map markers become filled circle dots"
```

---

## Task 16: Map — cluster widget styling

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace the cluster `builder`**

Replace the `builder:` closure (lines 190-210) with:

```dart
                        builder: (context, markers) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                              border: Border.all(
                                color: AppTheme.scaffoldBg,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  spreadRadius: 4,
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              markers.length.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          );
                        },
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: map cluster styled with primary bg and glow"
```

---

## Task 17: Map — FABs become glass treatment

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace the three `FloatingActionButton` widgets**

In the `floatingActionButton` column (lines 256-303), the three FABs currently pass `backgroundColor: AppTheme.primaryGreenDark`. Replace each `FloatingActionButton` with:

```dart
          Semantics(
            label: 'Zoom in',
            button: true,
            child: FloatingActionButton(
              heroTag: 'zoom_in',
              backgroundColor: AppTheme.surface.withValues(alpha: 0.92),
              foregroundColor: AppTheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: const BorderSide(color: AppTheme.outline),
              ),
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
```

Apply the same pattern for `zoom_out` and `recenter` (preserving their respective `Semantics` labels, icons, and onPressed).

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: map FABs become glass with primary icon"
```

---

## Task 18: Map — legend with frosted glass + circle dots

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace `_buildLegend` and `_buildLegendItem`**

In [lib/presentation/ui/screens/map_screen.dart](../../../lib/presentation/ui/screens/map_screen.dart) add `import 'dart:ui' show ImageFilter;` at the top.

Replace `_buildLegend` and `_buildLegendItem` with:

```dart
  //----------------------------------------------------------------------------
  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Map legend: accident types by color',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.92),
              border: Border.all(color: AppTheme.outline),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEGENDA',
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildLegendItem(
                  context,
                  AccidentTypes.markerColor(AccidentTypes.fatalities),
                  AccidentTypes.displayLabel(AccidentTypes.fatalities),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildLegendItem(
                  context,
                  AccidentTypes.markerColor(AccidentTypes.injuries),
                  AccidentTypes.displayLabel(AccidentTypes.injuries),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildLegendItem(
                  context,
                  AccidentTypes.markerColor(AccidentTypes.materialDamage),
                  AccidentTypes.displayLabel(AccidentTypes.materialDamage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: map legend as frosted glass card with dot markers"
```

---

## Task 19: Map — filter overlay as frosted glass

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace the filter overlay**

Replace the `Card` wrapper around `YearDepartmentFilter` (lines 220-253) with a frosted-glass container:

```dart
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withValues(alpha: 0.92),
                              border: Border.all(color: AppTheme.outline),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: YearDepartmentFilter(
                              selectedYear: dashboardState?.selectedYear,
                              availableYears:
                                  dashboardState?.availableYears ?? const [],
                              selectedDept: dashboardState?.selectedDept,
                              departments:
                                  dashboardState?.departments ?? const [],
                              compact: true,
                              onYearChanged: (year) {
                                if (year == null) return;
                                ref
                                    .read(dashboardProvider.notifier)
                                    .setYear(year);
                              },
                              onDepartmentChanged: (dept) {
                                ref
                                    .read(dashboardProvider.notifier)
                                    .setDepartment(dept);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass. Update `map_screen_test.dart` if it asserted `Card` as the overlay container — drop that assertion or switch to `BackdropFilter`.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart test/
git commit -m "feat: map filter overlay becomes frosted glass"
```

---

## Task 20: Map — accident detail bottom sheet

**Files:**
- Modify: `lib/presentation/ui/screens/map_screen.dart`

- [ ] **Step 1: Replace `_showAccidentDetails`**

Replace `_showAccidentDetails` (lines 369-459) with:

```dart
  //----------------------------------------------------------------------------
  void _showAccidentDetails(AccidentModel accident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final color = _getMarkerColor(accident.type);
        return Semantics(
          label: 'Accident details: ${accident.type}, ${accident.department}',
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              border: const Border(
                top: BorderSide(color: AppTheme.outline),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(Icons.directions_car, size: 20, color: color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(accident.type, style: theme.textTheme.titleMedium),
                          Text(
                            accident.department,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3.5,
                  children: [
                    _metaField(
                      theme,
                      'DATUM',
                      '${accident.date.day}.${accident.date.month}.${accident.date.year}',
                    ),
                    _metaField(
                      theme,
                      'VREME',
                      '${accident.date.hour}:${accident.date.minute.toString().padLeft(2, '0')}',
                    ),
                    _metaField(theme, 'STANICA', accident.station),
                    _metaField(theme, 'UČESNICI', accident.participants),
                  ],
                ),
                if (accident.officialDesc != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('OPIS', style: theme.textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    accident.officialDesc!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metaField(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
```

You can now delete the old `_buildDetailRow` method — it has no callers.

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean + tests pass.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/map_screen.dart
git commit -m "feat: redesign accident detail bottom sheet"
```

---

## Task 21: About screen — hero card + info cards

**Files:**
- Modify: `lib/presentation/ui/screens/about_screen.dart`

- [ ] **Step 1: Overwrite the file**

Replace [lib/presentation/ui/screens/about_screen.dart](../../../lib/presentation/ui/screens/about_screen.dart) with:

```dart
// ABOUTME: Static informational screen: app title, data source, disclaimer, contact.
// ABOUTME: Hero card with accent stripe and three info cards, all dark-theme styled.
import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _appVersion = '1.0.1';
  static const String _datasetUrl =
      'https://data.gov.rs/sr/datasets/podatsi-o-saobratshajnim-nezgodama-po-politsijskim-upravama-i-opshtinama/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('O aplikaciji')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Hero(theme: theme, version: _appVersion),
              const SizedBox(height: AppSpacing.lg),
              _InfoCard(
                theme: theme,
                icon: Icons.storage_outlined,
                iconColor: AppTheme.semanticMaterialDamage,
                title: 'Izvor podataka',
                body:
                    'Podaci u ovoj aplikaciji potiču sa portala otvorenih podataka Republike Srbije.',
                actionLabel: 'Otvori izvor',
                onAction: () => launchUrl(
                  Uri.parse(_datasetUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                theme: theme,
                icon: Icons.warning_amber_outlined,
                iconColor: AppTheme.semanticInjuries,
                title: 'Napomena',
                body:
                    'Ova aplikacija je razvijena u edukativne svrhe. Autor nije povezan ni sa jednim državnim organom niti institucijom. Podaci se prikazuju u viđenom stanju, nisu za zvaničnu upotrebu i mogu biti nepotpuni ili zastareli.',
              ),
              const SizedBox(height: AppSpacing.md),
              _InfoCard(
                theme: theme,
                icon: Icons.email_outlined,
                iconColor: AppTheme.primary,
                title: 'Kontakt',
                body: 'serbiaopendata@gmail.com',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.theme, required this.version});

  final ThemeData theme;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saobraćajne Nezgode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Otvoreni podaci Srbije',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    border: Border.all(color: AppTheme.primary),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    'v$version',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final ThemeData theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 34,
              top: AppSpacing.sm,
            ),
            child: Text(body, style: theme.textTheme.bodySmall),
          ),
          if (actionLabel != null && onAction != null)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: TextButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean. Existing `about_screen_test.dart` may assert specific legacy texts — update to find:
- `'Saobraćajne Nezgode'`
- `'Otvoreni podaci Srbije'`
- `'v1.0.1'`
- `'Izvor podataka'`, `'Napomena'`, `'Kontakt'`

Drop any assertions for `'Verzija 1.0.1'` (removed) or `Icons.directions_car` at headline size 64 (now in hero).

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/ui/screens/about_screen.dart test/
git commit -m "feat: redesign About screen with hero and info cards"
```

---

## Task 22: Splash screen — verified no-op

**Files:** none.

Verified pre-plan: the splash in `lib/main.dart` (lines 77-177) already sources every color from `theme.colorScheme.*` / `theme.textTheme.*` — no hard-coded `Colors.white` or similar. After Task 4 swaps `ThemeData` to the dark palette, the splash picks up the new tokens automatically.

- [ ] **Step 1: Re-verify and skip**

Run: `grep -n 'Colors\.\|Color(0x' lib/main.dart`
Expected: zero matches inside the splash build methods (only the license/file header, if anything). If any match appears, stop and replace with a `theme.colorScheme.*` token in the same commit pattern used by the rest of the plan.

No commit for this task if the grep is clean.

---

## Task 23: Clean up transitional aliases

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: any call sites still using old names

- [ ] **Step 1: Find remaining references to transitional aliases**

Run:

```bash
grep -rn 'AppTheme\.primaryGreen\|AppTheme\.primaryGreenDark\|AppTheme\.onSurface\b\|AppTheme\.onSurfaceVariant\|AppTheme\.surfaceContainer\|AppTheme\.surfaceContainerLow\|AppTheme\.outlineLight\|AppTheme\.onError\|AppTheme\.sectionTitleStyle' lib/ test/ integration_test/
```

- [ ] **Step 2: Rewrite each call site to the new token**

For each match:
- `AppTheme.primaryGreen` → `AppTheme.primary`
- `AppTheme.primaryGreenDark` → `AppTheme.primaryDark`
- `AppTheme.onSurface` → `AppTheme.textPrimary`
- `AppTheme.onSurfaceVariant` → `AppTheme.textSecondary`
- `AppTheme.surfaceContainer` → `AppTheme.surface`
- `AppTheme.surfaceContainerLow` → `AppTheme.surfaceElevated`
- `AppTheme.outlineLight` → `AppTheme.outlineVariant`
- `AppTheme.onError` → `AppTheme.onPrimary`
- `AppTheme.sectionTitleStyle` → delete call site (use `SectionHeader` widget instead; if the call site is an inline label where `SectionHeader` does not fit, use `Theme.of(context).textTheme.labelSmall`)

- [ ] **Step 3: Delete the transitional aliases from app_theme.dart**

Remove the entire `// Transitional aliases` block added in Task 2 Step 5. Also remove the `@Deprecated sectionTitleStyle` getter if no references remain.

- [ ] **Step 4: Run analyze + tests**

Run: `flutter analyze && flutter test`
Expected: clean. If any reference missed, `flutter analyze` will fail — go back to Step 1 with the new failure and iterate.

- [ ] **Step 5: Commit**

```bash
git add lib/ test/
git commit -m "refactor: remove transitional AppTheme aliases"
```

---

## Task 24: Final verification — manual + automated

**Files:**
- No code changes.

- [ ] **Step 1: Full test suite**

Run: `flutter test`
Expected: all tests pass. Integration tests are not run here (they require a device).

- [ ] **Step 2: Full analyze**

Run: `flutter analyze`
Expected: exit 0, no errors or warnings introduced.

- [ ] **Step 3: Launch app on a device/emulator**

Run: `flutter run` (pick a device).
Verify by eye:
- Splash → black emerald background, green progress.
- Dashboard → AppBar shows `Pregled` + `Saobraćajne nezgode · 2023` (or current year), chip filter row, hero KPI card with thin green accent stripe, 3-column mini stats grid, dark charts with muted axis labels.
- Tap the Mapa tab → dark CartoDB tiles, small green/orange/red circle markers, green emerald cluster with glow, glass FABs (zoom/recenter), glass legend bottom-left, glass filter overlay top.
- Tap a marker → bottom sheet slides up with drag handle, icon+title+department, 2-column grid with date/time/station/participants.
- Tap O Aplikaciji tab → hero card with car icon, green version pill, three info cards with colored icon tiles.
- Bottom nav: surface background, green active-state text + indicator.

If any screen looks off, iterate on the specific task that owns that surface.

- [ ] **Step 4: Integration test sanity**

Run: `flutter test integration_test/` (emulator required).
Expected: the existing integration test passes — Tasks 8, 9, and 10 already updated its finders against the new UI (`'Godina'`, `'Pregled'`, `'KLJUČNI POKAZATELJI'`, etc.). If anything still fails here, it means a finder was missed upstream — fix it in place rather than re-opening the owning task.

- [ ] **Step 5: Final commit for any integration-test or misc tweaks**

If Step 4 required fixes:

```bash
git add integration_test/
git commit -m "test: update integration finders for dark redesign"
```

Otherwise, skip this step. Redesign is complete.

---

## Self-Review

**Spec coverage (against the Design Spec sections):**

| Spec § | Coverage |
|---|---|
| §2 Dependency | Tasks 1 + 3 (asset font, no `google_fonts` dep — deviation noted) |
| §3 Color tokens | Task 2 |
| §4 Typography | Task 3 |
| §5 Component tokens (AppBar / Cards / Hero / SectionHeader / Filter / Delta / BottomNav / FAB) | Tasks 4 (themes), 6 (SectionHeader), 7 (DeltaBadge), 8 (Filter), 17 (FAB) |
| §6 Dashboard screen | Tasks 9, 10, 11 |
| §6 Section 2 & 3 charts | Tasks 12, 13 |
| §7 Map tiles | Task 14 |
| §7 Filter overlay | Task 19 |
| §7 Markers | Task 15 |
| §7 Cluster | Task 16 |
| §7 FABs | Task 17 |
| §7 Legend | Task 18 |
| §7 Accident detail bottom sheet | Task 20 |
| §8 About screen (hero + info cards) | Task 21 |
| §9 Splash | Task 22 |
| §10 Files to change | Every file listed has a task |
| §11 Out of scope | Respected (no domain/data/logic/nav/a11y changes) |

**Gaps:** none identified. Goldens deliberately out of plan (Milan accepted widget tests + manual verification as sufficient).

**Placeholder scan:** no TBD / TODO placeholders. Each code-changing step shows complete code blocks.

**Type consistency:** `SectionHeader({required String label})`, `DeltaBadge({required int delta, String? trailing, bool showArrow})`, both referenced consistently across Tasks 6, 7, 9, 10, 11.
