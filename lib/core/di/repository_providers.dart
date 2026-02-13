import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/traffic_repository.dart';
import '../../data/repositories/traffic_repository.dart' as data;

/// Provides the concrete [TrafficRepository] implementation.
/// Override this provider in tests or in main to inject a different implementation.
final repositoryProvider = Provider<TrafficRepository>((ref) {
  return data.SqliteTrafficRepository();
});
