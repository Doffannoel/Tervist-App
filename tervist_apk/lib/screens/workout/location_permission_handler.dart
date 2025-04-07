import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationPermissionHandler {
  // Singleton instance
  static final LocationPermissionHandler _instance = LocationPermissionHandler._internal();
  factory LocationPermissionHandler() => _instance;
  LocationPermissionHandler._internal();

  // Location service instance
  final Location _location = Location();
  bool _permissionGranted = false;

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      // Check location service
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Check permission
      PermissionStatus permissionStatus = await _location.hasPermission();
      _permissionGranted = permissionStatus == PermissionStatus.granted || 
                          permissionStatus == PermissionStatus.grantedLimited;
      
      return _permissionGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission(BuildContext context) async {
    try {
      // First check if permission is already granted
      bool hasPermission = await isLocationPermissionGranted();
      if (hasPermission) {
        return true;
      }

      // Request location permission
      PermissionStatus permissionStatus = await _location.requestPermission();
      _permissionGranted = permissionStatus == PermissionStatus.granted || 
                          permissionStatus == PermissionStatus.grantedLimited;
      
      // If permission denied or permanently denied, show dialog
      if (!_permissionGranted) {
        // Check if user permanently denied permission
        if (permissionStatus == PermissionStatus.denied || 
            permissionStatus == PermissionStatus.deniedForever) {
          // Show dialog to guide user to app settings
          if (context.mounted) {
            await _showOpenSettingsDialog(context);
          }
        }
      }
      
      return _permissionGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Show dialog to open settings
  Future<void> _showOpenSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lokasi Diperlukan'),
          content: const Text(
            'Aplikasi memerlukan akses ke lokasi Anda untuk melacak aktivitas lari. '
            'Silakan aktifkan izin lokasi di pengaturan perangkat Anda.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Gunakan metode openAppSettings() dari Location package
                _location.requestPermission();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  // Show location services disabled dialog
  Future<void> showLocationServicesDisabledDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Layanan Lokasi Dinonaktifkan'),
          content: const Text(
            'Layanan lokasi dinonaktifkan. Mohon aktifkan GPS di perangkat Anda '
            'untuk menggunakan fitur pelacakan aktivitas lari.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool serviceEnabled = await _location.requestService();
                if (!serviceEnabled && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon aktifkan GPS untuk melanjutkan'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Aktifkan GPS'),
            ),
          ],
        );
      },
    );
  }

  // Dapatkan lokasi terkini
  Future<LocationData?> getCurrentLocation() async {
    try {
      if (await isLocationPermissionGranted()) {
        return await _location.getLocation();
      }
      return null;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Setup continuous location updates
  Stream<LocationData> getLocationStream() {
    try {
      // Konfigurasi interval update lokasi
      _location.changeSettings(
        interval: 1000, // Update setiap 1 detik
        distanceFilter: 5, // Minimal 5 meter perubahan untuk update
      );
      
      // Enable background mode jika diperlukan untuk tracking ketika app di latar belakang
      // _location.enableBackgroundMode(enable: true);
      
      // Return location updates stream
      return _location.onLocationChanged;
    } catch (e) {
      print('Error setting up location stream: $e');
      rethrow;
    }
  }
}