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

- **Linting**: `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` only. There is no pre-commit config in the repo; if one is added, never disable hooks (see CLAUDE.md).

- **Read first**: `CLAUDE.md` (mandatory rules), `pubspec.yaml`, `.cursor/plans/project_deep_audit_d8eba396.plan.md` (history and pending items).

---

## 4. Codebase map and architecture

**Layers** (under `lib/`):

- **core/**: Theme (`app_theme.dart`, `app_spacing.dart`), DI (`di/repository_providers.dart`), services (`database_service.dart` — singleton; extracts DB from asset; exposes `database` getter; throws `DatabaseBootstrapException` on failure).
- **domain/**: Contracts and domain types. `repositories/traffic_repository.dart` = abstract interface. `models/accident_model.dart` = accident entity; `AccidentModel.fromSql()` for safe parsing from SQL rows. `accident_types.dart` = canonical type keys and normalization.
- **data/**: `repositories/traffic_repository.dart` = `SqliteTrafficRepository` implements the domain interface; all SQL and DB access lives here. Injected via `repositoryProvider` (optional `databaseProvider` for tests).
- **presentation/**: `logic/dashboard_provider.dart` = `DashboardState` + `DashboardNotifier` (StateNotifier), filters and dashboard aggregates; `logic/accidents_provider.dart` = `FutureProvider` that loads the accident list from the repo using dashboard year/dept. UI: `main_scaffold.dart` (tab shell), `screens/home_screen.dart`, `screens/map_screen.dart`, `widgets/year_department_filter.dart`, `widgets/dashboard/section_*.dart`.

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

## 6. Bite-sized tasks

Each task uses: **Goal**, **Files to touch**, **Tests (TDD: write first, run to see fail, then implement)**, **How to run tests**, **Commit suggestion**.

For any task not listed here, use the same pattern: (1) define goal and files, (2) write failing test, (3) implement, (4) run tests, (5) commit. Prefer adding a small task to this list rather than ad-hoc work.

---

### Task 0 — Onboard

- **Goal**: Run the app, run tests, read CLAUDE.md and this plan. Resolve uncommitted changes with Milan if any.
- **Files**: None (read-only).
- **Tests**: Ensure `flutter test` passes.
- **How to run**: `flutter test`
- **Commit**: Not required (optional: "docs: add implementation plan").

---

### Task 1 — Add loading indicator when filters change (dashboard)

- **Goal**: When the user changes year or department, show a loading state (e.g. spinner) until new data is ready; avoid showing stale data without feedback.
- **Files**: `lib/presentation/logic/dashboard_provider.dart` (set `isLoading: true` at start of `_loadDashboardData`, false at end/error), `lib/presentation/ui/screens/home_screen.dart` (already uses `state.isLoading` for body — verify it covers filter changes).
- **Tests**: In `test/presentation/logic/traffic_provider_test.dart`, add a test that after `setYear` or `setDepartment`, `isLoading` becomes true then false (or assert intermediate loading state). TDD: write test first, then implement.
- **How to run**: `flutter test test/presentation/logic/traffic_provider_test.dart`
- **Commit**: "feat: show loading state when dashboard filters change"

---

### Task 2 — Surface dashboard load errors to the user

- **Goal**: Replace silent `debugPrint` on dashboard load failure with user-visible error state (e.g. banner or inline message and retry).
- **Files**: `lib/presentation/logic/dashboard_provider.dart` (add error message to state; set it in catch of `_initialize` and `_loadDashboardData`), `lib/presentation/ui/screens/home_screen.dart` (show error UI when state has error; retry clears error and reloads).
- **Tests**: Unit test that when repo throws, state contains error message; after retry (or clear), error is cleared. TDD first.
- **How to run**: `flutter test test/presentation/logic/`
- **Commit**: "feat: show dashboard load errors and retry"

---

### Task 3 — YoY deltas for fatalities, injuries, material damage

- **Goal**: Section one header shows real year-over-year deltas (current year vs previous year) for the three type counts, not hardcoded 0.
- **Files**: `lib/presentation/ui/screens/home_screen.dart` (currently uses `fatalitiesDelta: 0` etc.; pass real deltas from state), `lib/presentation/logic/dashboard_provider.dart` (state already has `totalAccidentsPrevYear` and `accidentTypeCounts`; add prev-year type counts — e.g. call `getAccidentTypeCountsForYear(year - 1)` and store in state; compute deltas in state or in header).
- **Tests**: Repository already returns type counts; add or extend test that dashboard state or header receives correct deltas when prev-year counts differ. TDD first.
- **How to run**: `flutter test`
- **Commit**: "feat: real YoY deltas for fatalities, injuries, material damage"

---

### Task 4 — Migrate DashboardNotifier from StateNotifier to AsyncNotifier (optional)

- **Goal**: Use modern Riverpod API: `flutter_riverpod` (no legacy), AsyncNotifier for dashboard.
- **Files**: `lib/presentation/logic/dashboard_provider.dart`, any widget that reads `dashboardProvider.notifier` (home_screen, map_screen, year_department_filter if any).
- **Tests**: Existing tests in traffic_provider_test must still pass; update if API changes (e.g. `ref.read(dashboardProvider.notifier)` usage).
- **How to run**: `flutter test`
- **Commit**: "refactor: dashboard to AsyncNotifier"

---

### Task 5 — Pre-commit hook (analyze + test)

- **Goal**: Add a local git pre-commit hook that runs `flutter analyze` and `flutter test` before every commit, so broken code can't be committed.
- **Files**: `.git/hooks/pre-commit` (not tracked; document in README or CLAUDE.md if needed).
- **Tests**: No new app tests; hook runs existing suite.
- **How to run**: `git commit` (hook fires automatically).
- **Commit**: Not applicable (hook lives in `.git/hooks/`, not tracked by git).

---

### Task 6 — Widget tests for critical UI (optional)

- **Goal**: Add widget tests for filter widget and/or dashboard sections (e.g. YearDepartmentFilter renders and callbacks fire; SectionOneHeader shows numbers).
- **Files**: New tests under `test/presentation/ui/` or `test/.../widgets/`; widgets under `lib/presentation/ui/`.
- **Tests**: Use `testWidgets`, pump with ProviderScope/override repositoryProvider if needed; assert on semantics or text. TDD: write test first.
- **How to run**: `flutter test test/presentation/`
- **Commit**: "test: widget tests for filter and dashboard sections"

---

### Additional tasks (from deep analysis)

These surfaced from a pass over project structure, architecture, code quality, and UI/UX. Add them to your backlog or use the same task format when implementing.

- **Map screen error state**: When `accidentsProvider` fails, the map currently shows an empty map with no message. Add handling for `AsyncValue.hasError` (and optional retry). Files: `lib/presentation/ui/screens/map_screen.dart`. Tests: widget or integration test that when repo throws, map shows error UI. Commit: "feat: map screen error state and retry".

- **ABOUTME headers**: CLAUDE.md requires every code file to start with a 2-line comment, each line starting with "ABOUTME: ". No files in `lib/` currently have it. Add to all Dart files under `lib/`. Commit: "chore: add ABOUTME headers to lib files".

- **~~Localization~~**: Removed — app is Serbian-only, full l10n infrastructure is YAGNI. English strings in `main.dart` were translated to Serbian for consistency.

- **Responsive layout**: Dashboard and map were not audited for small screens. Review and fix layout for narrow/mobile viewports (dashboard sections, map overlay, filter). Files: `lib/presentation/ui/screens/home_screen.dart`, `map_screen.dart`, `year_department_filter.dart`, dashboard section widgets. Commit: "fix: responsive layout for small screens".

- **Lint tightening (optional)**: Add stricter rules in `analysis_options.yaml` beyond default `flutter_lints` (e.g. additional lint rules, document public APIs). Commit: "chore: tighten analysis_options".

- **Play Store prep (optional)**: Prepare for Android Google Play Store update (version, signing, store listing, release config). Commit: "chore: prepare for Play Store update".

---

## 7. Test design guidance

- **Repository**: Test against in-memory SQLite (see `traffic_repository_test.dart`). Create schema in `onCreate`; insert known rows; call repository methods; assert on returned models and counts. Tests validate real SQL and mapping.
- **Notifiers / providers**: Override `repositoryProvider` with a fake that returns deterministic data. Assert on *resulting state* (e.g. `dashboardProvider` state after init or after setYear) and on *observable side effects* (e.g. which year was requested), not on "fake.getTotalAccidentsForYear was called 3 times".
- **Models**: Pure unit tests on `AccidentModel.fromSql` with various maps (valid, nulls, bad date, int coords); see `test/domain/models/accident_model_test.dart`.
- **Avoid**: Tests that only verify a mock was called with X; tests that mock the repository in an E2E scenario; ignoring or not asserting on error output when the test deliberately triggers an error.

---

## 8. Docs and references

- **Must read**: `CLAUDE.md`
- **Reference**: `.cursor/plans/project_deep_audit_d8eba396.plan.md` (pending items: YoY deltas, error handling, loading feedback, Riverpod migration, CI, Play Store prep)
- **Dependencies and assets**: `pubspec.yaml`
- **Run and analyze**: `flutter test`, `flutter analyze`; prefer MCP Dart tools when available (run_tests, analyze_files)
