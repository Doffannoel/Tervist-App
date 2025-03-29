import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';

class MapData {
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final List<Polyline> polylines;

  MapData({
    required this.routePoints,
    required this.markers,
    required this.polylines,
  });
}

class MapService {
  // Default center untuk fallback (Yogyakarta)
  static const LatLng defaultCenter = LatLng(-7.7672, 110.3785);
  
  // Location service
  static final Location _location = Location();
  
  // Untuk live location tracking
  static LatLng _currentLocation = defaultCenter;
  static final List<LatLng> _routeHistory = [defaultCenter];
  static StreamController<LatLng>? _locationController;
  static bool _isTracking = false;
  static StreamSubscription<LocationData>? _locationSubscription;
  
  /// Inisialisasi location service
  static Future<void> initLocationService() async {
    try {
      // Mengatur akurasi lokasi tinggi
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000, // Interval update dalam ms
        distanceFilter: 5, // Minimum jarak (meter) untuk update
      );
    } catch (e) {
      print('Error initializing location service: $e');
    }
  }
  
  /// Get initial map data untuk layar running
  static Future<MapData> getInitialMapData() async {
    try {
      // Coba dapatkan lokasi saat ini
      final locationData = await _location.getLocation();
      final currentLocation = LatLng(
        locationData.latitude ?? defaultCenter.latitude, 
        locationData.longitude ?? defaultCenter.longitude
      );
      
      // Gunakan lokasi saat ini atau fallback ke default
      _currentLocation = currentLocation;
      _routeHistory.clear();
      _routeHistory.add(_currentLocation);
      
      // Create markers
      final List<Marker> markers = [
        Marker(
          point: _currentLocation,
          width: 80,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ),
      ];
      
      // Create polylines
      final List<Polyline> polylines = [
        Polyline(
          points: _routeHistory,
          color: const Color(0xFF2AAF7F), // primaryGreen
          strokeWidth: 5,
        ),
      ];
      
      return MapData(
        routePoints: _routeHistory,
        markers: markers,
        polylines: polylines,
      );
    } catch (e) {
      print('Error getting initial location: $e');
      // Fallback ke default map data jika gagal
      return _getDefaultMapData();
    }
  }
  
  /// Fallback ke map data default
  static MapData _getDefaultMapData() {
    // Reset route history
    _routeHistory.clear();
    _routeHistory.add(defaultCenter);
    _currentLocation = defaultCenter;
    
    // Create markers
    final List<Marker> markers = [
      Marker(
        point: defaultCenter,
        width: 80,
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
      ),
    ];
    
    // Create polylines
    final List<Polyline> polylines = [
      Polyline(
        points: _routeHistory,
        color: const Color(0xFF2AAF7F), // primaryGreen
        strokeWidth: 5,
      ),
    ];
    
    return MapData(
      routePoints: _routeHistory,
      markers: markers,
      polylines: polylines,
    );
  }
  
  /// Get updates lokasi secara real-time
  static Stream<LatLng> getLiveLocationStream() {
    // Jika controller tidak ada atau tertutup, buat yang baru
    if (_locationController == null || _locationController!.isClosed) {
      _locationController = StreamController<LatLng>.broadcast();
      
      // Reset route history jika memulai stream baru
      _routeHistory.clear();
      _routeHistory.add(_currentLocation);
      
      // Kirim lokasi awal
      _locationController!.add(_currentLocation);
      
      // Mulai pelacakan lokasi jika belum dimulai
      if (!_isTracking) {
        _startLocationTracking();
      }
    }
    
    return _locationController!.stream;
  }
  
  /// Mulai pelacakan lokasi
  static void _startLocationTracking() {
    _isTracking = true;
    
    // Batalkan langganan sebelumnya jika ada
    _locationSubscription?.cancel();
    
    // Langganan ke updates lokasi
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        // Update current location
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        
        // Add to route history
        _routeHistory.add(_currentLocation);
        
        // Send to stream
        _locationController?.add(_currentLocation);
      }
    });
  }
  
  /// Get current location
  static LatLng getCurrentLocation() {
    return _currentLocation;
  }
  
  /// Get entire route history
  static List<LatLng> getRouteHistory() {
    return List.from(_routeHistory);
  }
  
  /// Stop location updates
  static void stopLocationUpdates() {
    _isTracking = false;
    _locationSubscription?.cancel();
    _locationController?.close();
  }
  
  /// Create a MapData object dari state saat ini
  static MapData getCurrentMapData() {
    final List<Marker> markers = [
      Marker(
        point: _currentLocation,
        width: 80,
        height: 80,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
      ),
    ];
    
    final List<Polyline> polylines = [
      Polyline(
        points: _routeHistory,
        color: const Color(0xFF2AAF7F), // primaryGreen
        strokeWidth: 5,
      ),
    ];
    
    return MapData(
      routePoints: _routeHistory,
      markers: markers,
      polylines: polylines,
    );
  }
}