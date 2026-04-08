// ABOUTME: Riverpod dependency injection for repository layer.
// ABOUTME: Provides the concrete TrafficRepository and SharedPreferences, overridable in tests.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/traffic_repository.dart' as data;
import '../../domain/repositories/traffic_repository.dart';

/// Provides the concrete [TrafficRepository] implementation.
/// Override this provider in tests or in main to inject a different implementation.
final repositoryProvider = Provider<TrafficRepository>((ref) {
  return data.SqliteTrafficRepository();
});

/// Provides [SharedPreferences] for persistent storage.
/// Must be overridden in [ProviderScope] at app startup with an initialized instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden before use');
});
