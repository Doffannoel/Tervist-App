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
  static bool _isSessionActive =
      false; // Flag to track if session is active (after GO)
  static bool _isPaused = false; // Flag to track if tracking is paused
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
      // Inisialisasi location service terlebih dahulu
      await initLocationService();

      // Coba dapatkan lokasi saat ini
      final locationData = await _location.getLocation();
      final currentLocation = LatLng(
          locationData.latitude ?? defaultCenter.latitude,
          locationData.longitude ?? defaultCenter.longitude);

      // Gunakan lokasi saat ini atau fallback ke default
      _currentLocation = currentLocation;

      // Buat list dengan minimal satu point untuk menghindari empty bounds error
      final List<LatLng> initialPoints = [_currentLocation];

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

      // Polyline kosong sebelum GO button ditekan
      final List<Polyline> polylines = [
        Polyline(
          points:
              initialPoints, // Gunakan initialPoints untuk menghindari bounds error
          color: Colors.transparent, // Buat transparan untuk sementara
          strokeWidth: 0,
        ),
      ];

      return MapData(
        routePoints:
            initialPoints, // Gunakan initialPoints dengan current location
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
    _routeHistory.clear();
    _currentLocation = defaultCenter;

    // Buat list dengan minimal satu point untuk menghindari empty bounds error
    final List<LatLng> initialPoints = [defaultCenter];

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

    // Polyline dengan satu point untuk menghindari bounds error
    final List<Polyline> polylines = [
      Polyline(
        points:
            initialPoints, // Gunakan initialPoints untuk menghindari bounds error
        color: Colors.transparent, // Buat transparan untuk sementara
        strokeWidth: 0,
      ),
    ];

    return MapData(
      routePoints: initialPoints,
      markers: markers,
      polylines: polylines,
    );
  }

  /// Get updates lokasi secara real-time
  static Stream<LatLng> getLiveLocationStream() {
    // Jika controller tidak ada atau tertutup, buat yang baru
    if (_locationController == null || _locationController!.isClosed) {
      _locationController = StreamController<LatLng>.broadcast();

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

    // Mulai langganan lokasi
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        // Update lokasi terkini
        _currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);

        // 🚦 Cek apakah session aktif dan belum dipause
        if (_isSessionActive && !_isPaused) {
          bool shouldAddPoint = false;

          if (_routeHistory.isEmpty) {
            // 🟢 Titik pertama, langsung tambahkan
            shouldAddPoint = true;
          } else {
            // 🔁 Bandingkan dengan titik terakhir
            final lastPoint = _routeHistory.last;
            final distance = _calculateDistance(lastPoint, _currentLocation);

            // Tambahkan hanya jika bergerak > 2 meter
            shouldAddPoint = distance > 0.002; // 2 meter dalam kilometer
          }

          if (shouldAddPoint) {
            print("✅ Menambahkan titik ke route: $_currentLocation");
            _routeHistory.add(_currentLocation);
          }
        }

        // 🛰️ Kirim update lokasi ke stream, selalu kirim walaupun session ga aktif
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
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  // Math helpers
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
    _isSessionActive = false;
    _isPaused = false; // Reset pause state
    _locationSubscription?.cancel();
    _locationController?.close();
  }

  /// Create a MapData object dari state saat ini
  static MapData getCurrentMapData() {
    // Pastikan selalu ada minimal satu point
    List<LatLng> currentPoints = _isSessionActive && _routeHistory.isNotEmpty
        ? List.from(_routeHistory)
        : [_currentLocation];

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
        // Gunakan currentPoints untuk menghindari empty list
        points: currentPoints,
        color: _isSessionActive ? const Color(0xFF2AAF7F) : Colors.transparent,
        strokeWidth: _isSessionActive ? 5 : 0,
      ),
    ];

    return MapData(
      routePoints: currentPoints,
      markers: markers,
      polylines: polylines,
    );
  }

  /// Set pause state
  static void setPaused(bool paused) {
    _isPaused = paused;
  }

  /// Method untuk memulai session (dipanggil saat GO ditekan)
  static void startSession() {
    _isSessionActive = true;
    _isPaused = false; // Ensure not paused when starting
    _routeHistory.clear();
    // _routeHistory.add(_currentLocation); // Add current location as first point
  }

  /// Method untuk menghentikan session
  static void stopSession() {
    _isSessionActive = false;
    _isPaused = false; // Reset pause state
    // Route history dipertahankan untuk summary screen
  }

  /// Metode untuk memeriksa status session
  static bool isSessionActive() {
    return _isSessionActive;
  }

  /// Method untuk memeriksa status pause
  static bool isPaused() {
    return _isPaused;
  }
}
