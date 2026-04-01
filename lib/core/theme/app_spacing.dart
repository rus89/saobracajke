// ABOUTME: Centralized spacing and border-radius constants for consistent layout across the app.
// ABOUTME: Includes padding, gap, minimum touch target size, and radius tokens.
/// Centralized spacing tokens for consistent layout.
/// Use these instead of magic numbers for padding and gaps.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// Minimum touch target size (Material guideline: 48x48 logical pixels).
  static const double minTouchTarget = 48.0;

  // ---------- Border-radius tokens ----------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusPill = 999.0;
}
