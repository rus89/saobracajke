import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:saobracajke/domain/accident_types.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/presentation/logic/accidents_provider.dart';
import 'package:saobracajke/presentation/logic/dashboard_provider.dart';

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

    // Group accidents by location for clustering
    final accidents = accidentsAsync.value ?? [];
    final markers = <Marker>[];
    for (var accident in accidents) {
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          // Custom cluster builder
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade600,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Legend
                Positioned(bottom: 20, left: 20, child: _buildLegend()),
                // Filters card (floating)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            initialValue: dashboardState.selectedYear,
                            decoration: const InputDecoration(
                              labelText: 'Izaberite godinu',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: dashboardState.availableYears.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (year) {
                              if (year == null) return;
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setYear(year);
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String?>(
                            initialValue: dashboardState.selectedDept,
                            decoration: const InputDecoration(
                              labelText: 'Izaberite policijsku upravu',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Sve policijske uprave'),
                              ),
                              ...dashboardState.departments.map(
                                (dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ),
                              ),
                            ],
                            onChanged: (dept) {
                              ref
                                  .read(dashboardProvider.notifier)
                                  .setDepartment(dept);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            mini: true,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'zoom_out',
            mini: true,
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'recenter',
            mini: true,
            onPressed: () {
              _mapController.move(const LatLng(44.0165, 21.0059), 7.0);
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Legenda',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            AccidentTypes.markerColor(AccidentTypes.fatalities),
            AccidentTypes.displayLabel(AccidentTypes.fatalities),
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            AccidentTypes.markerColor(AccidentTypes.injuries),
            AccidentTypes.displayLabel(AccidentTypes.injuries),
          ),
          const SizedBox(height: 4),
          _buildLegendItem(
            AccidentTypes.markerColor(AccidentTypes.materialDamage),
            AccidentTypes.displayLabel(AccidentTypes.materialDamage),
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  //----------------------------------------------------------------------------
  void _showAccidentDetails(AccidentModel accident) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accident.type,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          accident.department,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today,
                'Datum',
                '${accident.date.day}.${accident.date.month}.${accident.date.year}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.access_time,
                'Vreme',
                '${accident.date.hour}:${accident.date.minute.toString().padLeft(2, '0')}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_city, 'Stanica', accident.station),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.people, 'Učesnici', accident.participants),
              if (accident.officialDesc != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Opis:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  accident.officialDesc!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  //----------------------------------------------------------------------------
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  //----------------------------------------------------------------------------
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filteri'),
          content: const Text(
            'Filtere možete primeniti na početnom ekranu pomoću padajućih menija za godinu i policijsku upravu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('U redu'),
            ),
          ],
        );
      },
    );
  }
}
