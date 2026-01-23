import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:saobracajke/domain/models/accident_model.dart';
import 'package:saobracajke/presentation/logic/traffic_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccidents();
  }

  Future<void> _loadAccidents() async {
    setState(() => _isLoading = true);
    await ref.read(trafficProvider.notifier).loadAccidents();
    setState(() => _isLoading = false);
  }

  // Get marker color based on accident type
  Color _getMarkerColor(String type) {
    if (type.contains('poginulim')) {
      return Colors.red;
    } else if (type.contains('povredjenim')) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Create custom marker widget
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trafficProvider);

    // Group accidents by location for clustering
    final markers = <Marker>[];
    for (var accident in state.accidents) {
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
      body: _isLoading
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
                    // Bounds for Serbia (approximate)
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(41.8, 18.8), // Southwest
                        const LatLng(46.2, 23.0), // Northeast
                      ),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.saobracajke',
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
                Positioned(bottom: 20, right: 20, child: _buildLegend()),
                // Info card
                if (state.accidents.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: _buildInfoCard(state.accidents.length),
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
          _buildLegendItem(Colors.red, 'Sa poginulim'),
          const SizedBox(height: 4),
          _buildLegendItem(Colors.orange, 'Sa povređenim'),
          const SizedBox(height: 4),
          _buildLegendItem(Colors.green, 'Materijalna šteta'),
        ],
      ),
    );
  }

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

  Widget _buildInfoCard(int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'Prikazano nesreća: $count',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

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
