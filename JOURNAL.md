# Project Journal

Running notes for future-Claude. Search before reinvestigating.

---

## 2026-04-22 — Initial project snapshot

Populated because the journal was empty. Baseline facts worth carrying forward:

### What the app is
Flutter read-only viewer for Serbian traffic-accident open data. Bundled SQLite
zip extracted on first launch. Three tabs (Pregled / Mapa / O Aplikaciji).
Current version: `1.0.1+2`. Serbian-only UI (no l10n wired up yet, though
`lib/l10n/` is scaffolded).

### What's already done — do NOT re-propose from IMPROVEMENTS.md
IMPROVEMENTS.md is **partially stale**. Before treating any item there as open,
cross-check against git log. Confirmed done:
- `StateNotifier` → `AsyncNotifier` migration for Dashboard (d2a6401)
- Real YoY deltas for fatalities/injuries/material damage (9369bfa) — was #1
- Dashboard + map error states with retry (f95b33e, 5d58c73) — was #2
- Async `setYear`/`setDepartment` race fix (0fe572d) — was #10/#18
- Widget tests for HomeScreen/dashboard (64c96dd)
- Integration test suite for critical user flows (10e1544)
- Dashboard filter persistence across restarts (4cb7e0b)
- Semantic colors for injuries/fatalities/damage (0d386cb)
- `ABOUTME:` headers on all `lib/` files (d5d9ddd)
- `analysis_options.yaml` tightened (1389a90)
- Pre-commit hook runs `flutter analyze` + `flutter test` (1f116c8)
- About screen with dataset link, disclaimer, contact (e369808, 8f2b21e, cd3fc5a)

Still open from IMPROVEMENTS.md: map viewport spatial filtering (#6), `_UNSET_`
sentinel in `copyWith` (#7), `debugPrint` in prod (#8), dead filter dialog on
map (#9), hardcoded Serbian strings / l10n (#11), CI/CD (#12), dead
`AccidentCard` / `DashboardRepository` (#5, #13), search UI (#14), date range
filtering (#15), export (#16), accessibility semantics (#20).

### Pre-commit hook worktree gotcha
`.git/hooks/pre-commit` unsets `GIT_DIR`, `GIT_WORK_TREE`, and `GIT_COMMON_DIR`
before running Flutter. If any of those env vars leak through (common inside
git worktrees), Flutter misdetects its own SDK version as `0.0.0-unknown` and
pub resolution blows up. Don't strip the `unset` lines. History: 1f116c8 added
the hook, e092ca5 added the `GIT_COMMON_DIR` fix after the worktree setup broke.

### Active parallel work
`feat/dark-redesign` branch has substantial dark-theme redesign work across
Home, Map, About, section headers, and `YearDepartmentFilter` (horizontal
layout + dark chip styling). Don't duplicate that on `main` — rebase or wait.

### Testing notes worth remembering
- Repository tests use `sqflite_common_ffi` + in-memory DB. No mocks.
- `integration_test/app_test.dart` needs a real device/emulator.
- Pre-commit hook catches analyze+test failures — local green is the contract.
