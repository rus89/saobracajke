import 'package:flutter/material.dart';
import 'package:saobracajke/core/theme/app_theme.dart';

/// Canonical accident type keys used across the app (charts, map, counts).
/// Normalizes DB string variance (e.g. "Sa povredjenim" vs "Sa povređenim").
class AccidentTypes {
  AccidentTypes._();

  /// Fatalities — canonical key for lookup and storage.
  static const String fatalities = 'Sa poginulim';

  /// Injuries — canonical key (ASCII "povredjenim" to match DB/CSV).
  static const String injuries = 'Sa povredjenim';

  /// Material damage — canonical key.
  static const String materialDamage = 'Sa mat.stetom';

  /// Display label for legend/UI (e.g. with correct Unicode đ).
  static const String injuriesDisplayLabel = 'Sa povređenim';

  /// Returns canonical type key from raw DB/CSV string.
  /// Handles "povredjenim" / "povređenim" and similar variants.
  static String normalize(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown';
    final lower = raw.toLowerCase();
    if (lower.contains('poginulim')) return fatalities;
    if (lower.contains('povredjenim') || lower.contains('povređenim')) {
      return injuries;
    }
    if (lower.contains('mat.stetom') || lower.contains('štetom') || lower.contains('stetom')) {
      return materialDamage;
    }
    return raw;
  }

  /// Returns marker color for a (possibly raw) type string.
  static Color markerColor(String type) {
    final n = normalize(type);
    if (n == fatalities) return AppTheme.semanticFatalities;
    if (n == injuries) return AppTheme.semanticInjuries;
    return AppTheme.semanticMaterialDamage;
  }

  /// Display label for a canonical type key (for legend).
  static String displayLabel(String canonicalType) {
    switch (canonicalType) {
      case fatalities:
        return fatalities;
      case injuries:
        return injuriesDisplayLabel;
      case materialDamage:
        return 'Materijalna šteta';
      default:
        return canonicalType;
    }
  }

  /// Merges type counts so all keys are canonical (e.g. merges "Sa povređenim" into injuries).
  static Map<String, int> normalizeCounts(Map<String, int> rawCounts) {
    final Map<String, int> out = {};
    for (final e in rawCounts.entries) {
      final key = normalize(e.key);
      out[key] = (out[key] ?? 0) + e.value;
    }
    return out;
  }
}
