import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/presentation/logic/accidents_provider.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/shimmer_skeleton.dart';
import 'package:saobracajke/presentation/ui/widgets/year_department_filter.dart';

//-------------------------------------------------------------------------------
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

//-------------------------------------------------------------------------------
class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  //----------------------------------------------------------------------------
  Color _getMarkerColor(String type) => AccidentTypes.markerColor(type);

  //----------------------------------------------------------------------------
  Widget _buildMarker(String type, int count) {
    final color = _getMarkerColor(type);
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, color: color, size: 40),
        if (count > 1)
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  //----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final accidentsAsync = ref.watch(accidentsProvider);

    final theme = Theme.of(context);

    if (accidentsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa Nesreća'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(),
              tooltip: 'Filteri',
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppSpacing.minTouchTarget,
                  AppSpacing.minTouchTarget,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Nije moguće učitati listu nesreća.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(accidentsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group accidents by location for clustering
    final accidents = accidentsAsync.value ?? [];
    final markers = <Marker>[];
    for (final accident in accidents) {
      markers.add(
        Marker(
          point: LatLng(accident.lat, accident.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _showAccidentDetails(accident);
            },
            child: _buildMarker(accident.type, 1),
          ),
        ),
      );
    }

    final isLoading = accidentsAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Nesreća'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Filteri',
            style: IconButton.styleFrom(
              minimumSize: const Size(
                AppSpacing.minTouchTarget,
                AppSpacing.minTouchTarget,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Semantics(
              label: 'Učitavanje mape',
              child: MapSkeleton(),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // Center on Serbia
                    initialCenter: const LatLng(44.0165, 21.0059),
                    initialZoom: 7.0,
                    minZoom: 6.5,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.serbiaOpenData.saobracajke',
                      maxZoom: 19,
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 80,
                        size: const Size(50, 50),
                        markers: markers,
                        builder: (context, markers) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(bottom: 20, left: 20, child: _buildLegend(context)),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: YearDepartmentFilter(
                            selectedYear: dashboardState.selectedYear,
                            availableYears: dashboardState.availableYears,
                            selectedDept: dashboardState.selectedDept,
                            departments: dashboardState.departments,
                            compact: true,
                            onYearChanged: (year) {
                              if (year == null) return;
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setYear(year);
                            },
                            onDepartmentChanged: (dept) {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setDepartment(dept);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Semantics(
            label: 'Zoom in',
            button: true,
            child: FloatingActionButton(
              heroTag: 'zoom_in',
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'Zoom out',
            button: true,
            child: FloatingActionButton(
              heroTag: 'zoom_out',
              onPressed: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              },
              child: const Icon(Icons.remove),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: 'Center map on Serbia',
            button: true,
            child: FloatingActionButton(
              heroTag: 'recenter',
              onPressed: () {
                _mapController.move(const LatLng(44.0165, 21.0059), 7.0);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Map legend: accident types by color',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Legenda', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            _buildLegendItem(
              context,
              AccidentTypes.markerColor(AccidentTypes.fatalities),
              AccidentTypes.displayLabel(AccidentTypes.fatalities),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildLegendItem(
              context,
              AccidentTypes.markerColor(AccidentTypes.injuries),
              AccidentTypes.displayLabel(AccidentTypes.injuries),
            ),
            const SizedBox(height: AppSpacing.xs),
            _buildLegendItem(
              context,
              AccidentTypes.markerColor(AccidentTypes.materialDamage),
              AccidentTypes.displayLabel(AccidentTypes.materialDamage),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  //----------------------------------------------------------------------------
  void _showAccidentDetails(AccidentModel accident) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Semantics(
          label: 'Accident details: ${accident.type}, ${accident.department}',
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: _getMarkerColor(accident.type),
                      size: 30,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            accident.type,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            accident.department,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildDetailRow(
                  ctx,
                  Icons.calendar_today,
                  'Datum',
                  '${accident.date.day}.${accident.date.month}.${accident.date.year}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(
                  ctx,
                  Icons.access_time,
                  'Vreme',
                  '${accident.date.hour}:${accident.date.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(
                  ctx,
                  Icons.location_city,
                  'Stanica',
                  accident.station,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(
                  ctx,
                  Icons.people,
                  'Učesnici',
                  accident.participants,
                ),
                if (accident.officialDesc != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Opis:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    accident.officialDesc!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  //----------------------------------------------------------------------------
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Filteri'),
          content: const Text(
            'Filtere možete primeniti na početnom ekranu pomoću padajućih menija za godinu i policijsku upravu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('U redu'),
            ),
          ],
        );
      },
    );
  }
}
