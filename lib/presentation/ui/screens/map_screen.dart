// ABOUTME: Interactive map screen displaying traffic accident markers clustered on OpenStreetMap tiles.
// ABOUTME: Supports filtering by year/department, color-coded markers by accident type, and detail bottom sheets.
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:saobracajke/core/theme/app_spacing.dart';
import 'package:saobracajke/core/theme/app_theme.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/presentation/logic/accidents_provider.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';
import 'package:saobracajke/presentation/ui/widgets/map/accident_detail_sheet.dart';
import 'package:saobracajke/presentation/ui/widgets/map/glassy_fab.dart';
import 'package:saobracajke/presentation/ui/widgets/map/map_legend.dart';
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
  Widget _buildMarker(String type) {
    final color = _getMarkerColor(type);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.scaffoldBg, width: 2),
      ),
    );
  }

  //----------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final dashboardState = dashboardAsync.value;
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
      final dateLabel =
          '${accident.date.day}.${accident.date.month}.${accident.date.year}';
      markers.add(
        Marker(
          point: LatLng(accident.lat, accident.lng),
          width: 44,
          height: 44,
          child: Semantics(
            label: '${accident.type}, ${accident.department}, $dateLabel',
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showAccidentDetails(accident),
              child: Center(child: _buildMarker(accident.type)),
            ),
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
          ? Semantics(
              label: 'Loading map data',
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
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
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.serbiaOpenData.saobracajke',
                      retinaMode: RetinaMode.isHighDensity(context),
                      maxZoom: 20,
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 45,
                        disableClusteringAtZoom: 16,
                        size: const Size(50, 50),
                        markers: markers,
                        builder: (context, markers) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                              border: Border.all(
                                color: AppTheme.scaffoldBg,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  spreadRadius: 4,
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              markers.length.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () {},
                        ),
                        TextSourceAttribution(
                          'CARTO',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20 + MediaQuery.paddingOf(context).bottom,
                  left: 20,
                  child: const MapLegend(),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withValues(alpha: 0.92),
                              border: Border.all(color: AppTheme.outline),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: YearDepartmentFilter(
                              selectedYear: dashboardState?.selectedYear,
                              availableYears:
                                  dashboardState?.availableYears ?? const [],
                              selectedDept: dashboardState?.selectedDept,
                              departments:
                                  dashboardState?.departments ?? const [],
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
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GlassyFab(
            heroTag: 'zoom_in',
            semanticLabel: 'Zoom in',
            icon: Icons.add,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassyFab(
            heroTag: 'zoom_out',
            semanticLabel: 'Zoom out',
            icon: Icons.remove,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassyFab(
            heroTag: 'recenter',
            semanticLabel: 'Center map on Serbia',
            icon: Icons.my_location,
            onPressed: () {
              _mapController.move(const LatLng(44.0165, 21.0059), 7.0);
            },
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  void _showAccidentDetails(AccidentModel accident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AccidentDetailSheet(accident: accident),
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
