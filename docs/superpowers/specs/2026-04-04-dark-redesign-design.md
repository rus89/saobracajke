# Dark Redesign — Design Spec

**Date:** 2026-04-04  
**Direction:** Deep Emerald (dark theme, DM Sans, emerald green primary)  
**Scope:** Full visual redesign — theme, typography, all three screens. No data layer or logic changes.

---

## 1. Design Goals

- Replace the generic Material 3 light theme with a distinctive, authoritative dark aesthetic
- Make KPI numbers the visual hero of the Dashboard
- Ensure both casual citizens and data-focused users feel at home: clear headline metrics up front, depth available by scrolling
- Consistent design language across all three screens

---

## 2. New Dependency

Add `google_fonts` to `pubspec.yaml`:

```yaml
google_fonts: ^6.2.1
```

No other new dependencies required.

---

## 3. Color Tokens (`app_theme.dart`)

Replace all existing color constants with the Deep Emerald palette:

| Token | Value | Usage |
|---|---|---|
| `scaffoldBg` | `#0A1628` | Scaffold background |
| `surface` | `#0E1E35` | Cards, bottom nav, filter bar |
| `surfaceElevated` | `#162540` | Elevated surfaces (modals, sheets) |
| `primary` | `#10B981` | Accent: active nav, section dots, badges, links |
| `primaryDark` | `#059669` | Gradient end, pressed state |
| `onPrimary` | `#FFFFFF` | Text on primary |
| `textPrimary` | `#E2EDF8` | Body text, titles, values |
| `textSecondary` | `#8AADCC` | Labels, subtitles, nav unselected |
| `textMuted` | `#4A6A8A` | Axis labels, minor metadata |
| `outline` | `#1A3050` | Card borders, dividers |
| `outlineVariant` | `#142A45` | Subtle separators |
| `error` | `#EF4444` | Error states |
| `errorContainer` | `Color(0x1FEF4444)` (~12% opacity) | Error badge backgrounds |

**Semantic colors — unchanged:**

| Token | Value | Meaning |
|---|---|---|
| `semanticFatalities` | `#EF4444` | Accidents with fatalities |
| `semanticInjuries` | `#F97316` | Accidents with injuries |
| `semanticMaterialDamage` | `#3B82F6` | Material damage only |

---

## 4. Typography (`app_theme.dart`)

Single font family: **DM Sans** (via `google_fonts`). Applied globally via `ThemeData.textTheme`.

| Style name | Size | Weight | Letter-spacing | Notes |
|---|---|---|---|---|
| `displayLarge` | 48px | 800 | −2px | KPI hero numbers |
| `displayMedium` | 32px | 800 | −1px | Secondary large numbers |
| `headlineMedium` | 20px | 700 | 0 | Mini stat card numbers (26px override in widget) |
| `titleLarge` | 18px | 700 | 0 | Section titles |
| `titleMedium` | 16px | 600 | 0 | Card titles, AppBar title |
| `titleSmall` | 14px | 600 | 0 | — |
| `bodyLarge` | 16px | 400 | 0 | — |
| `bodyMedium` | 14px | 400 | 0 | Line-height 1.5 |
| `bodySmall` | 12px | 400 | 0 | Secondary body, `textSecondary` color |
| `labelLarge` | 11px | 600 | 1.5px | Caps labels — uppercase in widget |
| `labelMedium` | 11px | 600 | 1.5px | Muted caps — `textSecondary` color |
| `labelSmall` | 10px | 600 | 1.5px | Mini labels in cards |

For number displays, apply `fontFeatures: [FontFeature.tabularFigures()]` to ensure consistent digit widths.

---

## 5. Component Tokens

### AppBar
- Background: `scaffoldBg` (`#0A1628`)
- Bottom border: 1px `outline`
- Elevation: 0, `scrolledUnderElevation`: 0
- Title: `titleMedium` style, `textPrimary` color

### Cards
- Background: `surface` (`#0E1E35`)
- Border: 1px `outline`
- Border-radius: `radiusMd` (12px)
- Box shadow: none (dark theme — shadows less visible, border does the work)

### Hero KPI Card (on Dashboard)
- Same as card + top accent stripe: 3px `LinearGradient(primary → primaryDark)`

### Section Headers (replacing "Sekcija N:")
- Row: 3px×14px emerald dot | 10px caps label (`labelSmall`, `textSecondary`, uppercase, ls 1.8px) | full-width `outline` line
- No "Sekcija" prefix. Labels: "KLJUČNI POKAZATELJI", "TRENDOVI", "VREMENSKA DISTRIBUCIJA"

### Filter Chips (DropdownButton)
- Background: `surface`
- Border: 1px `outline`
- Text: `primary` color, 11px weight 600
- Border-radius: `radiusSm` (8px)
- Arrow indicator: `textMuted` color

### Delta Badges
- Positive delta (worse): `rgba(239,68,68,0.12)` bg, `#EF4444` text, pill shape
- Negative delta (better): `rgba(16,185,129,0.12)` bg, `#10B981` text, pill shape

### Bottom Navigation Bar
- Background: `surface`
- Top border: 1px `outline`
- Selected item: `primary` color + 2px×16px `primary` indicator line above icon
- Unselected item: `textSecondary` color
- Labels: `labelSmall` style

### Floating Action Buttons (Map screen)
- Background: `Color(0xEB0E1E35)` (surface at ~92% opacity)
- Border: 1px `outline`
- Icon color: `primary`
- No colored fill — glass treatment

---

## 6. Dashboard Screen (`home_screen.dart`, `section_one_header.dart`)

### AppBar
- Title: "Pregled"
- Subtitle: dynamic — e.g. "Saobraćajne nezgode · 2023" (current selected year)
- No trailing action (keep existing AppBar structure — no new icons)

### Filter Row
- Slim bar directly below AppBar, same `scaffoldBg` background
- Two `DropdownButton` chips side by side: year | department
- Styled as filter chips (see §5)
- Remove the heavy bordered container currently wrapping `YearDepartmentFilter`

### Section 1 — KPI
- Section header: "KLJUČNI POKAZATELJI"
- Hero card: full-width, `displayLarge` total accidents number, delta badge below
- Mini stats: `GridView` 3-column (Povređeni / Poginuli / Mat. šteta)
  - Each card: icon in colour-tinted rounded square, `headlineMedium` count (26px override), `labelSmall` label, delta badge

### Section 2 — Trendovi
- Section header: "TRENDOVI"
- Charts unchanged in data/type — re-skin only: dark backgrounds, `outline` grid lines, `textMuted` axis labels, semantic colors for data series

### Section 3 — Vremenska distribucija  
- Section header: "VREMENSKA DISTRIBUCIJA"
- Same re-skin approach

---

## 7. Map Screen (`map_screen.dart`)

### Map Tiles
Switch tile URL from OSM standard to Stadia Alidade Smooth Dark:
```
https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png
```
Attribution: `© Stadia Maps © OpenMapTiles © OpenStreetMap contributors` — add as overlay text or in `TileLayer.additionalOptions`.

### Filter Overlay
- Replace `Card` wrapper with a frosted glass `Container`:
  - Wrap in `ClipRRect(borderRadius: radiusMd)` → `BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8))`
  - Inner `Container` color: `Color(0xEB0E1E35)` (surface at ~92% opacity)
  - Border: `Border.all(color: outline)`
  - BorderRadius: `radiusMd` (12px)

### Markers
- Replace `Icons.location_on` (pin) with a filled circle: `Container` 10×10px, `BoxShape.circle`, semantic color fill, 2px dark border
- Keeps `GestureDetector` tap behavior unchanged

### Cluster Widget
- Background: `primary` (`#10B981`)
- Border: 2px `scaffoldBg`
- Box-shadow: `0 0 0 4px rgba(16,185,129,0.2)` (glow ring)
- Text: white, `labelMedium` weight 700

### FABs (zoom in / out / recenter)
- Replace `backgroundColor: AppTheme.primaryGreenDark` with glass treatment (see §5 FABs)
- Icon color: `primary`

### Legend
- Background: `Color(0xEB0E1E35)` + blur (same frosted glass treatment as filter overlay)
- Title: `labelSmall` uppercase, `textSecondary`
- Replace `Icons.location_on` per row with 7px filled circle dot

### Accident Detail Bottom Sheet
- Background: `surfaceElevated`
- Top border: 1px `outline`
- Drag handle: 32px × 3px, `outline` color
- Header: icon in colour-tinted rounded square, type title + department subtitle
- Metadata: 2-column `GridView` (Date/Time/Station/Participants)
  - Label: `labelSmall`, `textSecondary`
  - Value: `bodySmall` weight 600, `textPrimary`

---

## 8. About Screen (`about_screen.dart`)

### Hero Card
- Full-width card with top accent stripe (same as hero KPI card)
- Car icon in a `primary`-tinted rounded square (48×48, radius 12)
- App title: `titleLarge` weight 800
- Subtitle: "Otvoreni podaci Srbije", `bodySmall`, `textSecondary`
- Version: pill badge, `primary` tinted bg+border, `primary` text

### Info Cards
Three cards (Data Source / Disclaimer / Contact), each:
- Icon in a colour-tinted rounded square (26×26):
  - Data source: `semanticMaterialDamage` tint (blue)
  - Disclaimer: `semanticInjuries` tint (orange)
  - Contact: `primary` tint (emerald)
- Title: `titleSmall`
- Body: `bodySmall`, `textSecondary`, `padding-left: 34px` (aligns under title)

---

## 9. Splash Screen

No structural change — apply dark theme colors (`scaffoldBg` background, `primary` progress indicator). The splash is brief and functional; no redesign needed.

---

## 10. Files to Change

| File | Change type |
|---|---|
| `pubspec.yaml` | Add `google_fonts` dependency |
| `lib/core/theme/app_theme.dart` | Full replacement — new color tokens, DM Sans text theme, all component themes |
| `lib/presentation/ui/screens/home_screen.dart` | AppBar title/subtitle, filter row styling, section header widget |
| `lib/presentation/ui/widgets/dashboard/section_one_header.dart` | Hero card accent stripe, mini stats 3-col grid |
| `lib/presentation/ui/widgets/dashboard/section_two_charts.dart` | Chart theme: bg, grid lines, label colors |
| `lib/presentation/ui/widgets/dashboard/section_three_charts.dart` | Chart theme: bg, grid lines, label colors |
| `lib/presentation/ui/widgets/year_department_filter.dart` | Filter chip styling |
| `lib/presentation/ui/screens/map_screen.dart` | Tile URL, filter overlay, markers, clusters, FABs, legend, bottom sheet |
| `lib/presentation/ui/screens/about_screen.dart` | Hero card, info cards |

**Files with no changes:** All domain, data, and logic files. `app_spacing.dart` needs no changes.

---

## 11. Out of Scope

- Navigation structure (3 tabs stay as-is)
- Data model, repository, providers
- Accessibility semantics (already good — preserve all existing `Semantics` wrappers)
- App icon / splash image
- Any new features or screens
