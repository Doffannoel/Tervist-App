import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:math' as math;

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
  static final List<LatLng> _routeHistory = [];
  static StreamController<LatLng>? _locationController;
  static bool _isTracking = false;
  static bool _isSessionActive = false; // Flag to track if session is active (after GO)
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
      
      // PERBAIKAN MASALAH #1: Route history tidak diisi sebelum GO button ditekan
      // _routeHistory.clear();
      // _routeHistory.add(_currentLocation); // Hilangkan line ini
      
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
      
      // PERBAIKAN MASALAH #1: Polyline kosong sebelum GO button ditekan
      final List<Polyline> polylines = [
        Polyline(
          points: [], // Empty points array until GO is pressed
          color: const Color(0xFF2AAF7F), // primaryGreen
          strokeWidth: 5,
        ),
      ];
      
      return MapData(
        routePoints: [], // Empty route points
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
    // PERBAIKAN MASALAH #1: Route history tidak diisi sebelum GO button ditekan
    _routeHistory.clear();
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
    
    // PERBAIKAN MASALAH #1: Polyline kosong sebelum GO button ditekan
    final List<Polyline> polylines = [
      Polyline(
        points: [], // Empty points until GO is pressed
        color: const Color(0xFF2AAF7F), // primaryGreen
        strokeWidth: 5,
      ),
    ];
    
    return MapData(
      routePoints: [],
      markers: markers,
      polylines: polylines,
    );
  }
  
  /// Get updates lokasi secara real-time
  static Stream<LatLng> getLiveLocationStream() {
    // Jika controller tidak ada atau tertutup, buat yang baru
    if (_locationController == null || _locationController!.isClosed) {
      _locationController = StreamController<LatLng>.broadcast();
      
      // PERBAIKAN MASALAH #1: Route history tidak diisi sebelum GO button ditekan
      // Tidak menginisialisasi route history di sini, hanya set current location
      
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
        
        // PERBAIKAN MASALAH #1 & #3: Hanya update route jika session active
        if (_isSessionActive) {
          // PERBAIKAN MASALAH #2: Meningkatkan akurasi dengan filter
          // Hanya tambahkan point baru jika jaraknya cukup signifikan
          bool shouldAddPoint = true;
          
          if (_routeHistory.isNotEmpty) {
            final lastPoint = _routeHistory.last;
            final distance = _calculateDistance(lastPoint, _currentLocation);
            
            // Hanya tambahkan point jika jaraknya lebih dari 2 meter
            shouldAddPoint = distance > 0.002; // 2 meter dalam kilometer
          }
          
          if (shouldAddPoint) {
            // Add to route history
            _routeHistory.add(_currentLocation);
          }
        }
        
        // Send to stream
        _locationController?.add(_currentLocation);
      }
    });
  }
  
  // Helper to calculate distance between points
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert latitude and longitude from degrees to radians
    double lat1 = point1.latitude * (math.pi / 180);
    double lon1 = point1.longitude * (math.pi / 180);
    double lat2 = point2.latitude * (math.pi / 180);
    double lon2 = point2.longitude * (math.pi / 180);
    
    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = math.sin(dLat/2) * math.sin(dLat/2) +
               math.cos(lat1) * math.cos(lat2) *
               math.sin(dLon/2) * math.sin(dLon/2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a));
    double distance = earthRadius * c;
    
    return distance;
  }
  
  // Math helpers - FIXED with math. prefix
  static double _sin(double x) => math.sin(x);
  static double _cos(double x) => math.cos(x);
  static double _sqrt(double x) => math.sqrt(x);
  static double _atan2(double y, double x) => math.atan2(y, x);
  
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
    _isSessionActive = false; // PERBAIKAN MASALAH #3: Reset session active flag
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
        // PERBAIKAN MASALAH #1 & #3: Polyline kosong jika session tidak aktif
        points: _isSessionActive ? _routeHistory : [],
        color: const Color(0xFF2AAF7F), // primaryGreen
        strokeWidth: 5,
      ),
    ];
    
    return MapData(
      routePoints: _isSessionActive ? List.from(_routeHistory) : [],
      markers: markers,
      polylines: polylines,
    );
  }
  
  // PERBAIKAN MASALAH #1: Method baru untuk memulai session (dipanggil saat GO ditekan)
  static void startSession() {
    _isSessionActive = true;
    _routeHistory.clear();
    _routeHistory.add(_currentLocation); // Add current location as first point
  }
  
  // PERBAIKAN MASALAH #3: Method baru untuk menghentikan session
  static void stopSession() {
    _isSessionActive = false;
    // Route history dipertahankan untuk summary screen
  }
  
  // PERBAIKAN MASALAH #3: Metode baru untuk memeriksa status session
  static bool isSessionActive() {
    return _isSessionActive;
  }
}