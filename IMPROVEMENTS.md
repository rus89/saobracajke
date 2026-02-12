# App Improvement Opportunities

A comprehensive analysis of the Saobracajke (Serbian Traffic Accidents Dashboard) Flutter application, identifying actionable improvement opportunities organized by priority.

---

## High Priority

### 1. Missing Year-over-Year Deltas for Fatalities, Injuries, and Material Damage

**File:** `lib/presentation/ui/screens/home_screen.dart:114-118`

The dashboard passes hardcoded `0` for fatality, injury, and material damage deltas:

```dart
SectionOneHeader(
  ...
  fatalitiesDelta: 0,       // Always zero
  injuriesDelta: 0,         // Always zero
  materialDamageAccidentsDelta: 0,  // Always zero
)
```

**Improvement:** Fetch previous-year type counts in `TrafficNotifier._loadDashboardData()` (the query `getAccidentTypeCountsForYear(year - 1)` is not called) and compute real deltas. This would make the trend indicators in Section 1 actually functional.

---

### 2. Silent Error Handling — No User Feedback on Failures

**Files:** `lib/presentation/logic/traffic_provider.dart:130-133`, `lib/core/services/database_service.dart:54-57`

All errors are caught and swallowed with `debugPrint`. If the database fails to extract or queries fail, the user sees an empty dashboard with no explanation.

**Improvement:** Add an `errorMessage` field to `TrafficState`. When errors occur, set it. In the UI, display a `SnackBar` or inline error banner so users know something went wrong and can take action (e.g., restart the app).

---

### 3. Legacy Riverpod API Usage

**File:** `lib/presentation/logic/traffic_provider.dart:3`

```dart
import 'package:flutter_riverpod/legacy.dart';
```

The app imports `flutter_riverpod/legacy.dart` for the deprecated `StateNotifier` pattern. With Riverpod v3.2.0, the modern approach uses `Notifier` / `AsyncNotifier` with code generation or manual providers.

**Improvement:** Migrate `TrafficNotifier` from `StateNotifier<TrafficState>` to `AsyncNotifier<TrafficState>`. This removes the legacy import, provides built-in loading/error states (eliminating the manual `isLoading` field), and aligns with the current Riverpod API.

---

### 4. No Tests

**Current state:** Zero test files despite `flutter_test` being listed as a dev dependency.

**Improvement:** Add tests in three tiers:
- **Unit tests** for `TrafficRepository` — mock the database and verify query results are mapped correctly
- **State tests** for `TrafficNotifier` — verify filter changes trigger correct state updates
- **Widget tests** for `HomeScreen` and `MapScreen` — verify UI renders correct data and filters work

---

### 5. Dead Code: Unused `DashboardRepository`

**File:** `lib/data/repositories/dashboard_repository.dart`

This file duplicates functionality that now lives in `TrafficRepository`. It is not imported or used anywhere.

**Improvement:** Delete `dashboard_repository.dart` to reduce confusion and maintenance burden.

---

## Medium Priority

### 6. Map Screen Loads All 1000 Accidents Into Memory at Once

**File:** `lib/presentation/ui/screens/map_screen.dart:29-33`, `lib/data/repositories/traffic_repository.dart:288`

The map loads up to 1000 accident records in a single query with no pagination. For years with dense data, this creates unnecessary memory pressure and slow initial load.

**Improvement:** Implement spatial filtering — only load accidents within the current map viewport bounds. Use `flutter_map`'s `MapEventMove` callbacks to reload data as the user pans/zooms. This also opens the door to removing the arbitrary 1000-row limit.

---

### 7. `copyWith` Uses `_UNSET_` Sentinel String — Fragile Pattern

**File:** `lib/presentation/logic/traffic_provider.dart:56-97`

```dart
TrafficState copyWith({
  String? selectedDept = '_UNSET_',
  Object? selectedYear = '_UNSET_',
  ...
})
```

This uses a magic string `'_UNSET_'` to distinguish "not passed" from "explicitly set to null." It is error-prone (the sentinel could theoretically match real data) and non-idiomatic Dart.

**Improvement:** Use a private sentinel object instead:
```dart
const _sentinel = Object();

TrafficState copyWith({
  Object? selectedDept = _sentinel,
  ...
}) {
  return TrafficState(
    selectedDept: identical(selectedDept, _sentinel)
        ? this.selectedDept
        : selectedDept as String?,
    ...
  );
}
```

Or use the `freezed` package to auto-generate `copyWith` with proper nullable handling.

---

### 8. Debug Prints in Production Code

**Files:** `database_service.dart` (3 occurrences), `traffic_provider.dart` (3 occurrences)

Eight `debugPrint` statements with emoji are scattered through the codebase. While harmless, they clutter logs in release builds.

**Improvement:** Wrap in `kDebugMode` checks or use Dart's `logging` package with configurable log levels. Remove emoji from log messages.

---

### 9. Filter Dialog on Map Screen Is a Dead End

**File:** `lib/presentation/ui/screens/map_screen.dart:430-448`

The filter icon in the map AppBar opens a dialog that simply tells the user to go to the home screen to apply filters — even though the map screen already has its own year/department dropdowns at the top.

**Improvement:** Either remove the filter icon button entirely (since filters are already inline), or replace the dialog with additional filter options (e.g., filter by accident type, date range) that aren't available in the floating card.

---

### 10. `setYear` and `setDepartment` Don't Await Dashboard Reload

**File:** `lib/presentation/logic/traffic_provider.dart:178-187`

```dart
void setYear(int year) {
  state = state.copyWith(selectedYear: year);
  _loadDashboardData();  // Fire-and-forget
}
```

`_loadDashboardData()` is called without `await`, meaning the state isn't set to loading before the async work begins. The UI won't show a loading indicator during the data refresh.

**Improvement:** Make these methods `async`, `await` the dashboard reload, and toggle `isLoading` around it:
```dart
Future<void> setYear(int year) async {
  state = state.copyWith(selectedYear: year, isLoading: true);
  await _loadDashboardData();
  state = state.copyWith(isLoading: false);
}
```

---

### 11. Hardcoded Serbian Strings Throughout UI

**Files:** All screen and widget files

Labels like `'Izaberite godinu'`, `'Sve policijske uprave'`, `'Sa poginulim'` are scattered as string literals throughout the codebase.

**Improvement:** Extract all user-facing strings into a centralized constants file or use Flutter's `intl` localization infrastructure (already a dependency) with `.arb` files. This makes future translation and consistency maintenance easier.

---

### 12. No CI/CD Pipeline

**Current state:** No `.github/workflows` directory, no automated checks.

**Improvement:** Add a GitHub Actions workflow that runs:
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug` (smoke test)

This prevents regressions from being merged and enforces code quality standards.

---

## Low Priority

### 13. Unused `AccidentCard` Widget

**File:** `lib/presentation/ui/widgets/accident_card.dart`

This widget exists but is never referenced from any screen. It contains a `TODO` comment about navigating to a detail screen.

**Improvement:** Either implement the accident detail screen it was designed for, or delete the widget. Dead code adds confusion.

---

### 14. Search Functionality Prepared But Not Exposed in UI

**File:** `lib/data/repositories/traffic_repository.dart:264-268`

The `getAccidents()` method accepts a `keyword` parameter with a `LIKE` query, but no UI ever passes a keyword.

**Improvement:** Add a search bar to the map screen or home screen that allows users to search accidents by participant name or accident ID. The backend support is already in place.

---

### 15. No Date Range Filtering

**Current state:** Users can only filter by full year. There's no way to view a specific month or date range.

**Improvement:** Add a date range picker (Flutter's `showDateRangePicker`) to allow users to narrow down to specific periods. This would be valuable for analyzing seasonal patterns or specific events.

---

### 16. No Data Export Capability

**Current state:** Users can view data but cannot export it.

**Improvement:** Add an export button that generates a CSV or PDF report of the current dashboard view or filtered accident list. The `intl` package already handles formatting; adding `csv` or `pdf` packages would enable this.

---

### 17. `DropdownButtonFormField` Uses `initialValue` Instead of `value`

**Files:** `home_screen.dart:41`, `map_screen.dart:178`

`DropdownButtonFormField` with `initialValue` only sets the value once. When the provider state changes (e.g., from the other screen), the dropdown won't reflect the updated selection.

**Improvement:** Use the `value` parameter instead of `initialValue` so the dropdown stays in sync with the provider state:
```dart
DropdownButtonFormField<int>(
  value: state.selectedYear,  // Instead of initialValue
  ...
)
```

---

### 18. Map Screen Race Condition on Filter Change

**File:** `lib/presentation/ui/screens/map_screen.dart:192-199`

When changing the year filter on the map, `setYear()` fires a dashboard reload (fire-and-forget) and then `loadAccidents()` is awaited separately. These two async operations can race, and the dashboard state may not reflect the new year when accidents load.

**Improvement:** Make `setYear`/`setDepartment` return `Future<void>` and await them before calling `loadAccidents()`, or consolidate into a single method that updates both dashboard and map data atomically.

---

### 19. Inconsistent Department JOIN in Aggregate Queries

**Files:** `traffic_repository.dart:123-128` vs `traffic_repository.dart:30-34`

Some aggregate queries always JOIN `departments` (e.g., `getTotalAccidentsForYear`), while others conditionally JOIN only when a department filter is active (e.g., `getAccidentsBySeasonForYear`). Both approaches work, but the inconsistency makes the code harder to maintain.

**Improvement:** Standardize on one approach. The conditional JOIN is more efficient (avoids unnecessary joins when no department filter is applied), so apply it consistently across all aggregate methods.

---

### 20. Missing Accessibility

**Current state:** No semantic labels on charts, map markers, or interactive elements.

**Improvement:** Add `Semantics` widgets around chart sections and map markers so screen readers can convey the data. For example, wrap the pie chart in a `Semantics` widget that reads out the season counts.
