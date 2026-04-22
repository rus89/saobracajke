# Saobracajke — Implementation Plan

## 1. Title and audience

This document is for engineers who are skilled developers but have **no prior context** on this codebase, toolset, or problem domain, and who want clear guidance on **test design** and task breakdown. Use it by reading sections 2–4 once for orientation, then following section 5 (rules) and section 6 (tasks) for each piece of work.

---

## 2. Project and domain primer

- **What the app is**: A Flutter app for exploring **Serbian traffic accident open data**. It provides a dashboard and a map. "Saobracajke" refers to the traffic (accident) context in Serbian.

- **Data source**: A bundled SQLite database (`assets/db/serbian_traffic.db.zip`) is extracted at runtime. Main tables: `accidents`, `departments`, `stations`, `types`. Accidents have type (fatalities / injuries / material damage), location, date, department, and station.

- **Domain terms**:
  - **Department** = police department (region).
  - **Station** = police station.
  - **Accident types** = canonical keys defined in `lib/domain/accident_types.dart` (e.g. `AccidentTypes.fatalities`, `injuries`, `materialDamage`). Raw DB strings (e.g. "Sa povredjenim" / "Sa povređenim") are normalized to these keys.

- **User flow**: Splash screen → DB init (with retry on failure) → Main scaffold with two tabs: **Pregled** (dashboard) and **Mapa** (map). Filters (year + department) are shared; the same state drives both dashboard and map.

---

## 3. Toolchain and setup

- **Stack**: Flutter (SDK ^3.10.7), flutter_riverpod, sqflite, path_provider, archive, fl_chart, flutter_map, latlong2, flutter_map_marker_cluster. Dev: flutter_test, flutter_lints, sqflite_common_ffi (for in-memory DB in tests).

- **Commands**:
  - Run app: `flutter run` (from project root).
  - Run all tests: `flutter test` (or MCP `mcp_dart_run_tests` with root).
  - Analyze: `dart analyze` or `flutter analyze`.
  - Format: `dart format .` (or MCP `mcp_dart_dart_format`).

- **Tests and SQLite**: Unit tests use `sqflite_common_ffi` and an in-memory DB. Call `sqfliteFfiInit()` in `setUpAll`. The real asset DB is not used in tests. Reference: `test/data/repositories/traffic_repository_test.dart` (schema and pattern).

- **Linting**: `analysis_options.yaml` extends `package:flutter_lints/flutter.yaml` with stricter rules (sort_constructors_first, unawaited_futures, prefer_final_locals, etc.) and promotes `missing_required_param` and `missing_return` to errors. A local git `pre-commit` hook runs `flutter analyze` + `flutter test` — never disable it (see CLAUDE.md).

- **Read first**: `CLAUDE.md` (mandatory rules), `pubspec.yaml`, `docs/superpowers/specs/2026-04-04-dark-redesign-design.md` (open visual-redesign spec — see §6).

---

## 4. Codebase map and architecture

**Layers** (under `lib/`):

- **core/**: Theme (`app_theme.dart`, `app_spacing.dart`), DI (`di/repository_providers.dart`), services (`database_service.dart` — singleton; extracts DB from asset; exposes `database` getter; throws `DatabaseBootstrapException` on failure).
- **domain/**: Contracts and domain types. `repositories/traffic_repository.dart` = abstract interface. `models/accident_model.dart` = accident entity; `AccidentModel.fromSql()` for safe parsing from SQL rows. `accident_types.dart` = canonical type keys and normalization.
- **data/**: `repositories/traffic_repository.dart` = `SqliteTrafficRepository` implements the domain interface; all SQL and DB access lives here. Injected via `repositoryProvider` (optional `databaseProvider` for tests).
- **presentation/**: `logic/dashboard_provider.dart` = `DashboardState` + `DashboardNotifier` (`AsyncNotifier<DashboardState>`), filters and dashboard aggregates; exposes `retry()` and emits `AsyncValue.loading` on each filter change via `_runGuarded`. Dashboard state holds both current-year and previous-year type counts, so `fatalitiesDelta` / `injuriesDelta` / `materialDamageDelta` are real year-over-year deltas. Filters are persisted across restarts via `SharedPreferences`. `logic/accidents_provider.dart` = `FutureProvider` that loads the accident list from the repo using dashboard year/dept. UI: `main_scaffold.dart` (tab shell), `screens/home_screen.dart` (handles loading/error/data via `asyncState.when`; error banner has retry), `screens/map_screen.dart` (handles `accidentsAsync.hasError` with retry via `ref.invalidate(accidentsProvider)`), `screens/about_screen.dart`, `widgets/year_department_filter.dart`, `widgets/dashboard/section_*.dart`.

**Entry and flow**: `lib/main.dart` → `ProviderScope` → `MyApp` → `SplashScreen`. Splash awaits `DatabaseService().database`, then replaces with `MainScaffold`. Home and Map both watch `dashboardProvider` and `accidentsProvider` (map uses accidents for markers).

**Key files by concern**:

| Concern | Files |
|--------|--------|
| DB bootstrap / errors | `lib/main.dart`, `lib/core/services/database_service.dart` |
| Repository API / SQL | `lib/domain/repositories/traffic_repository.dart`, `lib/data/repositories/traffic_repository.dart` |
| Dashboard state / filters | `lib/presentation/logic/dashboard_provider.dart` |
| Accident list for map | `lib/presentation/logic/accidents_provider.dart` |
| Dashboard UI | `lib/presentation/ui/screens/home_screen.dart`, section_one_header, section_two_charts, section_three_charts |
| Map UI | `lib/presentation/ui/screens/map_screen.dart` |
| Shared filter | `lib/presentation/ui/widgets/year_department_filter.dart` |

---

## 5. Mandatory rules (summary)

See **CLAUDE.md** for the full rule set. Summary:

- **TDD**: For every feature or bugfix: (1) write a failing test that validates the desired behavior, (2) run the test and see it fail, (3) write minimal code to pass, (4) run to confirm, (5) refactor if needed. Do not skip steps.
- **DRY / YAGNI**: Reduce duplication; do not add code or features that are not required right now.
- **Naming**: Names describe what code does (domain story), not implementation or history. No "New", "Legacy", "Wrapper", "Improved", etc. No implementation details in names.
- **Comments**: WHAT/WHY, not "improved" or "refactored". Every file starts with a 2-line ABOUTME comment (each line starts with "ABOUTME: "). Do not remove comments unless they are proven false.
- **Version control**: Work on a WIP branch when there is no clear task branch. Commit frequently; never skip or disable pre-commit hooks. Do not use `git add -A` without a prior `git status`.
- **Testing**: All test failures are your responsibility. Do not delete failing tests — raise with Milan. Tests must cover all functionality. Do not write tests that only assert on mocks/fakes (e.g. "fake was called with X"); test observable behavior or real logic. **E2E tests**: real data and real APIs; no mocks. **Unit tests**: repository tests use real in-memory SQLite; notifier tests may override `repositoryProvider` with a fake to isolate notifier logic — assert on state and behavior, not "fake received call X". Test output must be pristine to pass; if a test intentionally triggers an error, capture and assert on that output.
- **Smallest change**: Smallest reasonable change to achieve the goal. Match existing style. Fix bugs when found.

---

## 6. Active work

There is one substantial open task. For anything not listed here, follow the same pattern: (1) define goal and files, (2) write failing test, (3) implement, (4) run tests, (5) commit. Prefer adding a small task to this section rather than ad-hoc work.

---

### Task 0 — Onboard

- **Goal**: Run the app, run tests, read CLAUDE.md and this plan. Resolve uncommitted changes with Milan if any.
- **Files**: None (read-only).
- **Tests**: Ensure `flutter test` passes.
- **How to run**: `flutter test`
- **Commit**: Not required.

---

### Task 1 — Dark redesign (Deep Emerald)

- **Goal**: Apply the visual redesign specified in `docs/superpowers/specs/2026-04-04-dark-redesign-design.md`: new color tokens, DM Sans typography via `google_fonts`, hero KPI card, frosted-glass map overlays, filled-circle markers, dark map tiles. No data-layer or logic changes — theme and widget styling only.
- **Scope**: See the spec for the authoritative file-by-file change list. High level:
  - `pubspec.yaml` — add `google_fonts`.
  - `lib/core/theme/app_theme.dart` — replace palette, add DM Sans text theme, component themes.
  - `lib/presentation/ui/screens/home_screen.dart` — AppBar title+subtitle, slim filter row, replace "Sekcija N:" section headers with caps-label headers ("KLJUČNI POKAZATELJI", "TRENDOVI", "VREMENSKA DISTRIBUCIJA").
  - `lib/presentation/ui/widgets/dashboard/section_one_header.dart` — accent-stripe hero card, 3-col mini stats grid.
  - `section_two_charts.dart`, `section_three_charts.dart` — dark chart re-skin (backgrounds, grid, axis labels).
  - `lib/presentation/ui/widgets/year_department_filter.dart` — filter chip styling.
  - `lib/presentation/ui/screens/map_screen.dart` — Stadia Alidade Smooth Dark tiles, frosted-glass filter overlay + legend, filled-circle markers, cluster glow ring, glass FABs, `surfaceElevated` bottom sheet.
  - `lib/presentation/ui/screens/about_screen.dart` — hero card + three info cards.
- **Tests**: Existing widget tests must stay green. Consider golden tests for the three dashboard sections and the about screen — the spec calls for specific visual treatments and goldens are the cheapest way to lock them down. Do not mock the repository inside goldens — use `FakeRepository` with fixed data via `repositoryProvider.overrideWithValue`.
- **How to run**: `flutter test`; visual check with `flutter run`.
- **Commit**: Multiple commits preferred — split by surface (theme tokens; dashboard; map; about). Example: "feat(theme): Deep Emerald dark theme and DM Sans", "feat(dashboard): hero KPI card and caps section headers", "feat(map): frosted-glass overlays and filled-circle markers", "feat(about): hero card and info cards".

---

## 7. Test design guidance

- **Repository**: Test against in-memory SQLite (see `traffic_repository_test.dart`). Create schema in `onCreate`; insert known rows; call repository methods; assert on returned models and counts. Tests validate real SQL and mapping.
- **Notifiers / providers**: Override `repositoryProvider` with a fake that returns deterministic data. Assert on *resulting state* (e.g. `dashboardProvider` state after init or after setYear) and on *observable side effects* (e.g. which year was requested), not on "fake.getTotalAccidentsForYear was called 3 times".
- **Models**: Pure unit tests on `AccidentModel.fromSql` with various maps (valid, nulls, bad date, int coords); see `test/domain/models/accident_model_test.dart`.
- **Avoid**: Tests that only verify a mock was called with X; tests that mock the repository in an E2E scenario; ignoring or not asserting on error output when the test deliberately triggers an error.

---

## 8. Docs and references

- **Must read**: `CLAUDE.md`
- **Active spec**: `docs/superpowers/specs/2026-04-04-dark-redesign-design.md` (visual redesign — see §6 Task 1)
- **Play Store release checklist**: `docs/play_store.md`
- **Dependencies and assets**: `pubspec.yaml`
- **Run and analyze**: `flutter test`, `flutter analyze`; prefer MCP Dart tools when available (run_tests, analyze_files)
