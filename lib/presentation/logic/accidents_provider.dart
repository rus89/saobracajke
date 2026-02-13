import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/repository_providers.dart';
import '../../domain/models/accident_model.dart';
import 'dashboard_provider.dart';

/// Loads accident list for map/list based on current dashboard filters.
/// Single source of truth: when [dashboardProvider]'s year or department
/// changes, this provider refetches automatically. No manual load triggers.
final accidentsProvider = FutureProvider<List<AccidentModel>>((ref) async {
  final dashboard = ref.watch(dashboardProvider);
  final year = dashboard.selectedYear ?? DateTime.now().year;
  final dept = dashboard.selectedDept;
  final repo = ref.read(repositoryProvider);
  final start = DateTime(year, 1, 1);
  final end = DateTime(year, 12, 31, 23, 59, 59);
  return repo.getAccidents(department: dept, startDate: start, endDate: end);
});
