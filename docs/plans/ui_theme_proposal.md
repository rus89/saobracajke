# Saobracajke — UI and App Theme Proposal

## Audience and use

This document analyzes the current UI and theme and proposes concrete improvements for a nicer, more cohesive look. It is for anyone implementing theme or UI changes: read the analysis, then apply the proposals in the order that fits your backlog (or implement the "Quick wins" first).

---

## 1. Current state summary

### Theme ([lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart))

- **Material 3** light theme only. Primary green `#2E7D32` with light/dark variants; surfaces white/gray (`#F5F5F5` / `#FFFFFF`); outline and onSurfaceVariant for borders and secondary text; error/errorContainer for errors.
- **Typography**: Single `TextTheme` (displayLarge through labelSmall), default font family (system/Roboto). Sizes and weights are defined; no custom font.
- **Components**: AppBar (elevation 0, no explicit background), 48dp icon buttons, Filled/Text buttons with spacing, outlined inputs (8px radius), cards (12px radius, elevation 2), bottom nav (fixed, primary green selected).

### Spacing ([lib/core/theme/app_spacing.dart](lib/core/theme/app_spacing.dart))

- Tokens `xs` (4) through `xxxl` (32) and `minTouchTarget` (48). Used in many places; some widgets still use magic numbers (e.g. `vertical: 10`, `borderRadius: 30`).

### Screens and widgets

- **Splash**: Centered `CircularProgressIndicator` and "Setting up database..."; error block with icon, title, message, retry. No logo or branding.
- **Main scaffold**: `IndexedStack` for Pregled/Mapa; bottom nav with dashboard/map icons and labels.
- **Home**: AppBar "Saobraćajne Nezgode - Pregled"; filter strip (surfaceContainerHighest, bottom border); section titles "Sekcija 1/2/3: ..." with `titleLarge`; SectionOneHeader (large total-accidents card with pill delta); three metric cards (injuries/fatalities/material) with **raw `Colors.orange`, `Colors.red`, `Colors.blue`**; SectionTwoCharts and SectionThreeTemporal in bordered containers; charts use theme primary but section three pie also uses **raw `Colors.orange`, `Colors.brown`, `Colors.blue`**.
- **Map**: AppBar "Mapa Nesreća" with filter action; full-screen map; overlay filter card; error state with retry.
- **Filter**: Two dropdowns (year, department) with outline decoration and icons; used in home strip and map overlay.

---

## 2. Strengths

- Material 3 and spacing tokens give a consistent base. Touch targets and accessibility are considered.
- Clear information hierarchy: filter → key metrics → trends → temporal.
- Charts and cards use theme for primary and surfaces; structure is readable.

---

## 3. Weaknesses and improvement areas

| Area | Issue | Impact |
|------|--------|--------|
| **Semantic colors** | Mini stats and some charts use raw `Colors.orange`/`red`/`blue`/`brown` instead of theme or app-defined semantic colors. | Inconsistent with primary green; no single source of truth; harder to add dark theme or rebrand. |
| **Section titles** | Plain "Sekcija 1: Ključni pokazatelji" with `titleLarge` only. | Looks generic; sections don’t feel clearly grouped. |
| **Radius and elevation** | Mix of 8, 12, 16, 20, 30 across cards and pills. | Slightly inconsistent visual language. |
| **Typography** | Default font only; no distinct identity. | Functional but not distinctive. |
| **App bar and nav** | Default styling; no selected indicator on bottom nav. | Could better match a more refined look. |
| **Splash** | Minimal (spinner + text). | Missed chance for light branding and trust. |
| **Magic numbers** | e.g. `vertical: 10`, `borderRadius: 30`, `blurRadius: 20`. | Small inconsistency with design tokens. |

---

## 4. Proposals

### 4.1 Semantic colors (high impact)

**Goal:** One place for "injuries / fatalities / material damage" (and chart) colors so they align with the app and support future dark theme.

**Approach:**

- In [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) (or a small `app_semantic_colors.dart` if you prefer), define semantic tokens, for example:
  - `semanticInjuries` — amber/orange tone (e.g. `Color(0xFFE65100)` or a softer amber).
  - `semanticFatalities` — red tone (e.g. keep `Color(0xFFC62828)` or use a red that fits the palette).
  - `semanticMaterialDamage` — blue/slate (e.g. `Color(0xFF1565C0)` or `0xFF455A64`).
- Use these in:
  - [lib/presentation/ui/widgets/dashboard/section_one_header.dart](lib/presentation/ui/widgets/dashboard/section_one_header.dart) for the three mini stat cards (replace `Colors.orange`, `Colors.red`, `Colors.blue`).
  - [lib/presentation/ui/widgets/dashboard/section_three_charts.dart](lib/presentation/ui/widgets/dashboard/section_three_charts.dart) for pie/bar segments (replace `Colors.orange`, `Colors.brown`, `Colors.blue` and ad-hoc shades).
- Keep chart segment variants as `.withValues(alpha: …)` or light/dark shades derived from these tokens.

**Result:** Consistent, theme-aligned colors; easier to add dark theme later.

---

### 4.2 Section title style (medium impact)

**Goal:** Section headers that look intentional and separate content blocks clearly.

**Approach:**

- Add a dedicated section title style in the theme, e.g.:
  - `labelLarge` or a custom style: uppercase or small-caps, letter-spacing ~1–1.2, color `onSurfaceVariant`, optional slightly larger than current label.
- In [lib/presentation/ui/screens/home_screen.dart](lib/presentation/ui/screens/home_screen.dart), use this style for "Sekcija 1: Ključni pokazatelji", "Sekcija 2: Trendovi i Analize", "Sekcija 3: Vremenska Distribucija".
- Optionally add a thin horizontal divider or a small left accent (e.g. 4dp vertical bar in primary) below the section title for separation.

**Result:** Clearer hierarchy and a less generic dashboard look.

---

### 4.3 Radius and elevation consistency (low–medium impact)

**Goal:** Fewer ad-hoc values; predictable card and pill look.

**Approach:**

- In [lib/core/theme/app_spacing.dart](lib/core/theme/app_spacing.dart) (or theme), add a small set of radius tokens, e.g.:
  - `radiusSm = 8`, `radiusMd = 12`, `radiusLg = 16`, `radiusPill = 24` (or 999 for full pill).
- Replace magic numbers:
  - Cards: use one radius (e.g. `radiusMd` or `radiusLg`) for SectionOneHeader total card and mini stats, and for chart containers in section two/three.
  - Delta pill in SectionOneHeader: use `radiusPill` (or 999) instead of 30.
- Keep card elevation low (1–2) and consistent; prefer subtle shadow or outline so it doesn’t feel heavy.

**Result:** Coherent depth and roundness without changing layout.

---

### 4.4 Typography (optional, medium effort)

**Goal:** A slightly more distinctive look without harming readability.

**Approach:**

- Choose one readable font (e.g. Google Fonts: **DM Sans**, **Plus Jakarta Sans**, or **Source Sans 3**) for body and UI; optionally a second for headings.
- Add dependency (e.g. `google_fonts`) or bundle font assets; set in `ThemeData` via `textTheme` and `primaryTextTheme`.
- Ensure all text styles in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) use the chosen family; avoid forcing font in every widget.

**Result:** Clearer identity; still accessible and professional.

---

### 4.5 App bar and bottom navigation (low impact)

**Goal:** Slightly more polished chrome.

**Approach:**

- **App bar**: Give it a subtle surface (e.g. `surfaceContainerLow` or a very light tint) so it’s not plain white-on-white; keep elevation 0 or use `scrolledUnderElevation` only when scrolled. Optionally use `titleMedium` for the title.
- **Bottom nav**: Add a selected indicator (e.g. small pill or underline) or ensure selected item uses primary + slightly bolder label so the active tab is obvious at a glance.

**Result:** Clearer chrome hierarchy and tab state.

---

### 4.6 Splash screen (low impact)

**Goal:** Brief branding and a calmer loading experience.

**Approach:**

- Add a small logo or app name (text) above the spinner so the splash isn’t only "Setting up database...".
- Use theme primary for spinner and text; keep layout simple (centered column). If you add a logo asset, keep it small and legible at 1x.

**Result:** First screen feels intentional and aligned with the app name.

---

### 4.7 Replace remaining magic numbers (low impact)

**Goal:** Align with design tokens.

**Approach:**

- In SectionOneHeader and elsewhere, replace e.g. `vertical: 10` with `AppSpacing.sm` or `AppSpacing.md`; `borderRadius: 30` with a radius token; `blurRadius: 20` with a named constant if you introduce shadow tokens. Do this as you touch those files for other changes.

**Result:** Easier to tune spacing and shadows globally.

---

## 5. Implementation order (suggested)

1. **Quick wins (no new tokens):** Section title style (4.2), app bar surface (4.5), splash logo/text (4.6). Small, visible improvement.
2. **High impact:** Semantic colors (4.1) and use them in section one and section three.
3. **Consistency:** Radius/elevation tokens (4.3) and replace magic numbers (4.7) in the same files.
4. **Optional:** Typography (4.4), bottom nav indicator (4.5).

---

## 6. What not to do

- Do not add a dark theme in this pass unless it’s a separate, agreed task; the proposal above keeps a single source of semantic colors so dark theme can be added later.
- Do not change behavior or navigation; only visuals and theme.
- Do not duplicate long rule text; follow [CLAUDE.md](CLAUDE.md) and [docs/plans/implementation_plan.md](implementation_plan.md) for TDD, naming, and commits. When implementing, add tests only where they add value (e.g. theme/color usage might be covered indirectly by existing widget/screen tests).

---

## 7. References

- Theme: [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)
- Spacing: [lib/core/theme/app_spacing.dart](lib/core/theme/app_spacing.dart)
- Dashboard sections: [lib/presentation/ui/widgets/dashboard/](lib/presentation/ui/widgets/dashboard/)
- Home: [lib/presentation/ui/screens/home_screen.dart](lib/presentation/ui/screens/home_screen.dart)
- Plan and rules: [docs/plans/implementation_plan.md](implementation_plan.md), [CLAUDE.md](CLAUDE.md)
