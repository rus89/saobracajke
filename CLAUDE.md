Global rules at `~/.claude/CLAUDE.md` apply — project-specific context below.

## Project

Flutter app visualizing Serbian traffic accident open data. Data is read-only — bundled as `assets/db/serbian_traffic.db.zip`, extracted to device storage on first launch.

## Commands

```bash
flutter run              # Run on connected device/emulator
flutter test             # Run all tests
flutter test integration_test/  # Run integration tests (real device/emulator required)
flutter analyze          # Static analysis
flutter build appbundle --release  # Release build (see /release skill for full steps)
```

A pre-commit hook (`.git/hooks/pre-commit`) runs `flutter analyze` and `flutter test` automatically — fix locally before committing; don't skip with `--no-verify`.

## Architecture

Clean Architecture with three layers:

```
lib/
  core/          # Shared infrastructure (DatabaseService, theme, DI providers)
  data/          # Repository implementations (SqliteTrafficRepository)
  domain/        # Interfaces, models, AccidentTypes enum/normalization
  presentation/
    logic/       # Riverpod providers (accidents_provider, dashboard_provider)
    ui/
      screens/   # home_screen (dashboard stats), map_screen (accident map), about_screen
      widgets/   # Reusable UI components; dashboard/ subdirectory for chart widgets
```

State management: flutter_riverpod. Entry point: `lib/main.dart` (SplashScreen bootstraps DB, then pushes `presentation/ui/main_scaffold.dart` — a BottomNavigationBar + IndexedStack shell with three tabs: Pregled / Mapa / O Aplikaciji).

Key dependencies: `flutter_map` (map rendering), `fl_chart` (dashboard charts), `sqflite` (local DB).

Test layout: `test/` mirrors `lib/` (unit/widget tests); `integration_test/app_test.dart` holds full-app flows. `lib/l10n/` is scaffolded but empty — Serbian-only UI for now.

## Gotchas

- **DB bootstrap**: `DatabaseService` is a singleton. If the bundled zip changes, the old extracted `.db` must be deleted (or the app re-installed) — `_initDatabase()` skips extraction if the file already exists. On failure it throws `DatabaseBootstrapException`, which SplashScreen catches and renders with a retry button.
- **Testing**: Repository tests use `sqflite_common_ffi` with in-memory SQLite (`databaseFactoryFfi`). Do not mock the database — use in-memory.
- **`getAccidents()` cap**: The list query hard-limits to 1000 rows. This is intentional for map performance.
- **`AccidentTypes.normalize()`**: Raw DB type names must be passed through this before display or counting — the DB contains inconsistent strings.
- **Planning docs**: `IMPROVEMENTS.md` (repo root) tracks known improvement opportunities (year-over-year deltas, error UX, Riverpod migration). `docs/plans/` holds implementation plans. Check both before starting a larger feature.
