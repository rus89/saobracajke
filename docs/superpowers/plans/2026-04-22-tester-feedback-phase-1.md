# Plan: Tester Feedback — Phase 1 (Rate, ASO, Feedback) — Saobracajke

## Context

This plan ports three tester-feedback features from a sister Flutter app (`rpg_claude`) to **saobracajke** (Serbian traffic-accident open-data app). The original plan referenced files, package IDs, copy, and design tokens that don't exist in this repo — every concrete path, class, and string below has been re-grounded against the current codebase.

The three features:

1. **Rate Your App** action in "O aplikaciji" — opens the Play Store listing for `com.serbiaOpenData.saobracajke`.
2. **ASO polish** — update in-repo `pubspec.yaml` description (keyword-rich Serbian copy) + draft Play Store listing text. **Web is out of scope** for this app (not published).
3. **User feedback** action in "O aplikaciji" — opens a pre-filled `mailto:` to `serbiaopendataapps@gmail.com`, with app version auto-stamped in the body so support can triage stale builds.

All UI is Serbian-only (this app has no localization). Target: Android. Web build exists in the repo tree but is not published.

## Scope

**In:** the three features above, plus their tests, AndroidManifest update, `pubspec.yaml` ASO copy, and the Kontakt-card email correction.

**Out:** `in_app_review` native prompt (manual-button is what testers asked for), English localisation, onboarding flow, dark-mode toggle (already dark), performance/marketing items, web manifest/index.html/OpenGraph (web not published), Play Store screenshots (handled separately).

## Pre-flight: existing-state facts (verified)

- About screen: [lib/presentation/ui/screens/about_screen.dart](lib/presentation/ui/screens/about_screen.dart). Class is `AboutScreen` (`StatelessWidget`). Layout: `_Hero` + 3 `_InfoCard`s (Izvor podataka, Napomena, Kontakt). **No** "Vodič kroz aplikaciju" section.
- About-screen tests: [test/presentation/ui/screens/about_screen_test.dart](test/presentation/ui/screens/about_screen_test.dart) — 6 tests, all wrap subject in `MaterialApp(home: AboutScreen())`. No `ProviderScope` needed (screen has no Riverpod deps).
- `_InfoCard` already supports an optional tap action via `actionLabel` + `onAction` rendering a `TextButton` ([about_screen.dart:155-222](lib/presentation/ui/screens/about_screen.dart#L155-L222)). The existing "Otvori izvor" button uses this.
- Theme tokens live in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) (`AppTheme.surface`, `AppTheme.outline`, `AppTheme.primary`, `AppTheme.primaryDark`) and [lib/core/theme/app_spacing.dart](lib/core/theme/app_spacing.dart) (`AppSpacing.lg`, `AppSpacing.md`, `AppSpacing.radiusMd`, `AppSpacing.minTouchTarget`).
- Package ID: `com.serbiaOpenData.saobracajke` ([android/app/build.gradle.kts:21,40](android/app/build.gradle.kts#L21)). Android label: `Saobracajke` ([AndroidManifest.xml:4](android/app/src/main/AndroidManifest.xml#L4)).
- AndroidManifest `<queries>` block currently declares **only** `PROCESS_TEXT` ([AndroidManifest.xml:40-45](android/app/src/main/AndroidManifest.xml#L40-L45)) — `mailto:` will throw on Android 11+ without an additional intent.
- `url_launcher: ^6.3.2` already in [pubspec.yaml:21](pubspec.yaml#L21).
- Current pubspec version: `1.1.0+3` ([pubspec.yaml:5](pubspec.yaml#L5)). Hardcoded `_appVersion = '1.0.1'` in [about_screen.dart:11](lib/presentation/ui/screens/about_screen.dart#L11) is **already stale** — `package_info_plus` work in Feature 3 will fix this as a bonus.
- Existing `launchUrl` at [about_screen.dart:37-40](lib/presentation/ui/screens/about_screen.dart#L37-L40) ("Otvori izvor" → data.gov.rs) is **un-guarded** — no try/catch. There is no precedent in this app for the try/catch+SnackBar fallback; this plan establishes it.
- Kontakt card currently shows `serbiaopendata@gmail.com` ([about_screen.dart:57](lib/presentation/ui/screens/about_screen.dart#L57)) — the canonical address for this project is `serbiaopendataapps@gmail.com`. This plan corrects the Kontakt card too so addresses don't diverge.
- All Dart files in this repo start with `// ABOUTME:` two-line headers (project rule, [CLAUDE.md](CLAUDE.md)). New helpers/files MUST follow this.

## Feature 1: Rate Your App action

### Behaviour
- New full-card-tap action rendered in `AboutScreen` **after the Kontakt `_InfoCard`** (no Vodič section exists; tiles append at the bottom).
- Label: "Oceni aplikaciju", icon `Icons.star_rate`, subtitle "Otvori Google Play prodavnicu".
- Tapping calls `launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.serbiaOpenData.saobracajke'), mode: LaunchMode.externalApplication)` inside a `try`. On `PlatformException` (or non-`true` return), show a `SnackBar` with the URL as plaintext so the user can copy it.
- Hidden entirely when `kIsWeb == true` (no rating flow for web users) — gated via a pure helper (see **Web visibility seam** below) so the branch is unit-testable.

### Accessibility
- Wrap tap target in `Semantics(button: true, label: 'Oceni aplikaciju u Google Play prodavnici')`.
- Tap target minimum height `AppSpacing.minTouchTarget` (already defined as 48 in [app_spacing.dart](lib/core/theme/app_spacing.dart)) — use `InkWell` inside a `Padding(all: AppSpacing.lg)` so tap region covers the card.

### Implementation: introduce `_ActionCard`
The existing `_InfoCard` shows tap actions as a separate `TextButton`, which is fine for "Otvori izvor" (informational card with optional secondary action) but doesn't give us the full-card tap target the a11y requirement asks for. Add a sibling `_ActionCard` widget (new, file-private, ~30 LOC) that takes `icon`, `title`, `subtitle`, `onTap`. Mirror the `_InfoCard` decoration so visual language stays consistent:

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surface,
    border: Border.all(color: AppTheme.outline),
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  ),
  child: InkWell(onTap: onTap, child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: …)),
)
```

Use `Material(color: Colors.transparent)` wrapper so `InkWell`'s ripple renders against the surface color. Apply `BorderRadius` to the InkWell's `borderRadius` parameter so the ripple respects the card's rounded corners.

### Web visibility seam
Extract the web check into a file-private helper so tests don't have to fake `kIsWeb`:

```dart
@visibleForTesting
bool shouldShowRateTile({bool isWeb = kIsWeb}) => !isWeb;
```

The tile's `if (shouldShowRateTile())` call reads `kIsWeb` by default; tests call `shouldShowRateTile(isWeb: true)` and `shouldShowRateTile(isWeb: false)` as a pure unit test.

## Feature 2: ASO polish

### In-repo changes (Android-only — web is not shipped)
Update **only** [pubspec.yaml:2](pubspec.yaml#L2) `description`. Web manifest/index.html stay untouched (the app is not published to the web).

Suggested description (Milan to approve final wording):

> "Pregledaj otvorene podatke o saobraćajnim nezgodama u Srbiji — mapa nezgoda, statistika po opštinama, trendovi kroz vreme. Podaci sa data.gov.rs."

### Play Store listing (out-of-repo deliverable)
Drafted copy Milan will paste into Play Console — stored in this plan for reference, not in the repo.

**Short description (≤80 chars), candidate:**
> "Otvoreni podaci o saobraćajnim nezgodama u Srbiji — mapa, opštine, trendovi"

**Full description (≤4000 chars) outline — to be fleshed out by Milan:**
- Opening hook (1 sentence, what the app does)
- Three-to-four feature bullets (Pregled, Opštine, Trendovi, Mapa)
- Data source attribution + link to data.gov.rs
- Independence disclaimer (mirror the "Napomena" card text from About screen)
- Keyword-natural closing paragraph (saobraćaj, nezgode, otvoreni podaci, Srbija, statistika, opštine)

## Feature 3: User feedback action

### Behaviour
- Second `_ActionCard` rendered after the Rate card.
- Icon `Icons.mail_outline`, label "Prijavite grešku ili predlog", subtitle "Pošaljite poruku autoru".
- Tap opens a mailto URI built with `Uri(scheme: 'mailto', path: 'serbiaopendataapps@gmail.com', queryParameters: {'subject': 'Saobraćajne Nezgode — povratna informacija', 'body': 'Verzija aplikacije: v$version+$buildNumber\n\n'})`. Do **NOT** hand-concatenate the query string — Cyrillic characters in the body/subject break without proper percent-encoding, which `Uri(...)` handles.
- Same `try`/`SnackBar`-fallback pattern as the rate button (user without a mail client gets the address in a copyable snackbar).
- Visible on both Android and web (mailto works in web browsers — even though we don't ship web, the helper stays unconditional so the gate logic only lives in `shouldShowRateTile`).

### Kontakt-card email correction
Update the existing Kontakt info card body at [about_screen.dart:57](lib/presentation/ui/screens/about_screen.dart#L57) from `serbiaopendata@gmail.com` to `serbiaopendataapps@gmail.com` so the displayed address matches the mailto target. Also update the test expectation at [about_screen_test.dart:55](test/presentation/ui/screens/about_screen_test.dart#L55).

### Android package visibility (REQUIRED for mailto)
Android 11+ (API 30+) requires declaring intent queries for external schemes. Current [AndroidManifest.xml:40-45](android/app/src/main/AndroidManifest.xml#L40-L45) only declares `PROCESS_TEXT`, so `launchUrl('mailto:…')` throws `PlatformException` on real devices. Add a `SENDTO` query **before** coding the feature:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <intent>
        <action android:name="android.intent.action.SENDTO" />
        <data android:scheme="mailto" />
    </intent>
</queries>
```

`https` (Play Store) generally resolves on Android 11+ without an explicit query under `url_launcher` ≥ 6.1.12, so the existing `data.gov.rs` link works without further manifest changes. Only `mailto:` needs the query above.

### Version stamping
- Add `package_info_plus` to `pubspec.yaml` via `flutter pub add package_info_plus` (let pub resolve to latest stable; do **not** pin a specific minor version without checking pub.dev first).
- Fetch `PackageInfo.fromPlatform()` once at screen init via `FutureBuilder` or pre-load in a `StatefulWidget` and cache. Cache in a local `String` field so the mailto handler reads synchronously when tapped.
- Format: `v${info.version}+${info.buildNumber}` → produces "v1.1.1+4" after the bump in this plan.
- **Bonus:** Replace the hardcoded `_appVersion = '1.0.1'` constant at [about_screen.dart:11](lib/presentation/ui/screens/about_screen.dart#L11) with the same `PackageInfo` value, so the `_Hero` badge stays in sync with the real version. Convert `AboutScreen` from `StatelessWidget` to `StatefulWidget` (or use a `FutureBuilder<PackageInfo>` at the top of `build`) to load this once.

### Why we need a `StatefulWidget` (and what to watch for in tests)
`PackageInfo.fromPlatform()` is async. Two viable shapes:

1. **`FutureBuilder<PackageInfo>`** at the top of `build()` — simpler, but the screen renders a loading placeholder briefly. The hero version badge would flicker.
2. **Convert `AboutScreen` to `StatefulWidget`** — load `PackageInfo` in `initState`, store in a `String? _versionLabel` field, render the badge & build the mailto URI from it. Cleaner UX, but requires test updates because tests now need to pump until the future resolves.

Recommendation: option **2** (StatefulWidget). For tests, mock `PackageInfo.setMockInitialValues({...})` (provided by `package_info_plus`) before pumping, then `tester.pumpAndSettle()`. Existing test wrapper `MaterialApp(home: AboutScreen())` keeps working — just add the `setMockInitialValues` call in `setUp`.

## Dependencies (pubspec.yaml delta)

```yaml
dependencies:
  # existing entries…
  package_info_plus: <latest stable from pub.dev>
```

No other additions. `url_launcher` is already present at [pubspec.yaml:21](pubspec.yaml#L21).

## Files to modify

| File | Change |
|---|---|
| [lib/presentation/ui/screens/about_screen.dart](lib/presentation/ui/screens/about_screen.dart) | Add `_ActionCard` widget + `shouldShowRateTile` helper + `_buildFeedbackUri` helper; convert to `StatefulWidget` and load `PackageInfo` in `initState`; insert two action cards after the Kontakt info card; wire up try/catch + SnackBar fallback for both new tiles **and** wrap the existing `_DataSourceLink`/"Otvori izvor" `onAction` with the same try/catch (consistency); update Kontakt card body to `serbiaopendataapps@gmail.com`; remove the hardcoded `_appVersion = '1.0.1'` constant — feed `_Hero.version` from `PackageInfo`. Keep the `// ABOUTME:` header. |
| [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) | Add `SENDTO`/`mailto` intent to existing `<queries>` block. Label `Saobracajke` stays. |
| [pubspec.yaml](pubspec.yaml) | Update `description` to Serbian, traffic-domain copy; add `package_info_plus` dep; bump `version` (see step 12 below). |
| [test/presentation/ui/screens/about_screen_test.dart](test/presentation/ui/screens/about_screen_test.dart) | **Modify existing** file — append new tests to the existing 6 tests; do not replace. Add `PackageInfo.setMockInitialValues({...})` in `setUp` so the StatefulWidget's `initState` resolves. Update the existing email assertion from `serbiaopendata@gmail.com` to `serbiaopendataapps@gmail.com`. Update the existing `'displays app version'` test to expect the value driven by `setMockInitialValues` (e.g., `'v1.1.1+4'`). See Tests section below. |

**Out (web not shipped):** `web/manifest.json`, `web/index.html`. Do not touch.

## Tests (TDD, per [CLAUDE.md](CLAUDE.md) rule)

Per [CLAUDE.md](CLAUDE.md) TDD rule, write tests first. The file [test/presentation/ui/screens/about_screen_test.dart](test/presentation/ui/screens/about_screen_test.dart) already exists with 6 tests — **append** to it, don't replace. The screen is a plain (post-refactor: `Stateful`) widget with no Riverpod deps, so wrapping in `MaterialApp(home: AboutScreen())` stays valid; do **not** introduce `ProviderScope`.

Mandatory `setUp` addition once `PackageInfo` lands:
```dart
setUp(() {
  PackageInfo.setMockInitialValues(
    appName: 'saobracajke', packageName: 'com.serbiaOpenData.saobracajke',
    version: '1.1.1', buildNumber: '4', buildSignature: '', installerStore: null,
  );
});
```

Update existing test #2 (`'displays app version'`) to expect `'v1.1.1+4'` (was `'v1.0.1'`).
Update existing test #5 (`'displays contact email'`) to expect `'serbiaopendataapps@gmail.com'` (was `'serbiaopendata@gmail.com'`).

New tests to add:

1. **Both action tiles render on non-web.** Pump `MaterialApp(home: AboutScreen())`, `pumpAndSettle()`, assert `find.text('Oceni aplikaciju')` and `find.text('Prijavite grešku ili predlog')` each `findsOneWidget`.
2. **Web gating (unit test on the helper).** Call `shouldShowRateTile(isWeb: true)` → expect `false`; `shouldShowRateTile(isWeb: false)` → expect `true`. Pure Dart, no widget pump. The widget-level `kIsWeb` branch stays untested (acceptable — `kIsWeb` is compile-time in the VM and can't be toggled per-test).
3. **Accessibility: action tiles expose `Semantics(button: true)` with the expected label.** Use `tester.getSemantics(find.byType(_ActionCard).first)` and assert `hasAction(SemanticsAction.tap)` + `isButton`. (`_ActionCard` is private — test it via key or via `find.byWidgetPredicate` on `Semantics` with the expected label.)
4. **Unit test for `_buildFeedbackUri(PackageInfo info)`** (extract as file-private function annotated `@visibleForTesting`). Pass a fake `PackageInfo` (`version: '1.1.1', buildNumber: '4', …`); assert `result.scheme == 'mailto'`, `result.path == 'serbiaopendataapps@gmail.com'`, decoded `subject == 'Saobraćajne Nezgode — povratna informacija'`, and decoded `body` starts with `'Verzija aplikacije: v1.1.1+4'`.

Do **not** mock `url_launcher_platform_interface`. Presence + semantics + pure-function unit tests catch the high-value regressions (tile removed, wrong label, wrong URL, wrong body, wrong recipient).

Run `flutter test` — target: all existing tests still pass (with the two updated expectations), plus four new tests green.

## Implementation order

1. Add `SENDTO`/`mailto` intent to [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) `<queries>` (Feature 3 blocker — do this first so manual Android smoke test later doesn't throw).
2. Run `flutter pub add package_info_plus` (let pub resolve latest stable, then `flutter pub get`).
3. Update existing test expectations (email → `serbiaopendataapps@gmail.com`, version → `v1.1.1+4`) and add `PackageInfo.setMockInitialValues` to `setUp`. Run `flutter test test/presentation/ui/screens/about_screen_test.dart` — both updated tests should fail until the screen is updated.
4. Write the 4 new failing tests (helper unit test, semantics, both-tiles-render, mailto URI).
5. Convert `AboutScreen` to `StatefulWidget`; load `PackageInfo` in `initState`; remove hardcoded `_appVersion`; feed `_Hero.version` from state.
6. Implement `_ActionCard` (full-card `InkWell`, semantics wrapper, mirrors `_InfoCard` decoration).
7. Implement `shouldShowRateTile` (file-private, `@visibleForTesting`).
8. Implement `_buildFeedbackUri(PackageInfo)` (file-private, `@visibleForTesting`).
9. Insert the two action cards after the Kontakt `_InfoCard`. Hide rate card behind `if (shouldShowRateTile())`.
10. Update Kontakt card email to `serbiaopendataapps@gmail.com`.
11. Wrap the existing "Otvori izvor" `onAction` (currently un-guarded `launchUrl` at [about_screen.dart:37-40](lib/presentation/ui/screens/about_screen.dart#L37-L40)) with the same try/catch + SnackBar pattern (this is the first time the pattern lands in the app — establish, don't mirror).
12. Run `flutter test`, `flutter analyze`, `dart format --set-exit-if-changed .` — all clean.
13. Update [pubspec.yaml:2](pubspec.yaml#L2) `description` to Serbian, traffic-domain copy.
14. Manual smoke test on Android device:
    - Open "O aplikaciji" → see two action cards after Kontakt.
    - Tap "Oceni aplikaciju" → Play Store opens to `com.serbiaOpenData.saobracajke` (not in-app webview, thanks to `LaunchMode.externalApplication`).
    - Tap "Prijavite grešku ili predlog" → mail app opens with recipient `serbiaopendataapps@gmail.com`, subject `Saobraćajne Nezgode — povratna informacija`, body starts with `Verzija aplikacije: v1.1.1+4`.
    - Cyrillic characters in the subject render correctly (no `%` escapes visible).
    - Tap existing "Otvori izvor" → still works; if no browser installed, shows the SnackBar fallback instead of silently throwing.
15. Commit as logical units (per [CLAUDE.md](CLAUDE.md) — small, atomic, conventional):
    - `chore: add mailto intent query for Android 11+ package visibility`
    - `feat: add Rate app and feedback action cards to About screen`
    - `refactor: wrap data.gov.rs launchUrl with error fallback`
    - `chore: polish ASO description in pubspec`
    - `fix: correct contact email to serbiaopendataapps@gmail.com`
16. Bump version in [pubspec.yaml](pubspec.yaml) from `1.1.0+3` → `1.1.1+4` (patch bump — user-visible additions but no behavioural change to existing flows). Tag per [CLAUDE.md](CLAUDE.md) Build Tagging rule: `git tag v1.1.1+4 <commit>`. Update Play Console listing copy from the drafts above.

## Verification

- **Unit + widget tests**: `flutter test` exits 0 with all updated + new assertions passing.
- **Static analysis**: `flutter analyze` reports no issues; `dart format --set-exit-if-changed .` exits 0.
- **Pre-commit hook**: `.git/hooks/pre-commit` runs `flutter analyze` + `flutter test` automatically — must pass without `--no-verify`.
- **Manual — Android device** (must be API 30+ to validate package-visibility work):
  - Navigate to "O aplikaciji" tab. See two action cards after the Kontakt card.
  - Tap "Oceni aplikaciju" → Play Store app opens at `com.serbiaOpenData.saobracajke`.
  - Tap "Prijavite grešku ili predlog" → default mail app opens with recipient `serbiaopendataapps@gmail.com`, subject pre-filled, body starts with `Verzija aplikacije: v1.1.1+4`. If no email client installed, the SnackBar fallback appears.
  - Serbian/Cyrillic characters render correctly in the compose window.
  - Existing "Otvori izvor" link still opens data.gov.rs; on a device with no browser, now shows the SnackBar fallback.
  - Hero badge in About screen shows `v1.1.1+4` (proves `package_info_plus` wiring + bonus fix for the stale hardcoded version).
- **Build verification**: `flutter build appbundle --release` completes (per `/release` skill).
