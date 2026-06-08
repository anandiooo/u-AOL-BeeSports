import 'package:beesports/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Default to Jakarta if no initial position
    _selectedLocation = LatLng(
      widget.initialLat ?? -6.2088,
      widget.initialLng ?? 106.8456,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Pick Location', style: AppTextStyles.sectionTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.beesports',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Coordinate display
          Positioned(
            top: DesignConfig.spacingXl,
            left: DesignConfig.spacingXl,
            right: DesignConfig.spacingXl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: DesignConfig.spacingLg, vertical: DesignConfig.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(DesignConfig.roundedLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, color: AppColors.neonGreen, size: 20),
                  const SizedBox(width: DesignConfig.spacingMd),
                  Expanded(
                    child: Text(
                      '${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}',
                      style: AppTextStyles.bodySecondary.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confirm button
          Positioned(
            bottom: DesignConfig.spacing2xl,
            left: DesignConfig.spacingXl,
            right: DesignConfig.spacingXl,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.pop({
                    'lat': _selectedLocation.latitude,
                    'lng': _selectedLocation.longitude,
                  });
                },
                child: const Text('Confirm Location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

