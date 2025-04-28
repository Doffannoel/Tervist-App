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

  // Untuk menyimpan data rute setelah sesi berakhir
  static final List<LatLng> _savedRouteHistory = [];

  // Untuk markers dan polylines
  static List<Marker> _currentMarkers = [];
  static List<Polyline> _currentPolylines = [];
  static List<Marker> _savedMarkers = [];
  static List<Polyline> _savedPolylines = [];

  static StreamController<LatLng>? _locationController;
  static bool _isTracking = false;
  static bool _isSessionActive =
      false; // Flag to track if session is active (after GO)
  static bool _isPaused = false; // Flag to track if tracking is paused
  static StreamSubscription<LocationData>? _locationSubscription;

  // Tambahkan property untuk menyimpan lokasi terakhir yang valid
  static LatLng _lastValidLocation = defaultCenter;
  static bool _hasValidLocation = false;

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

      if (locationData.latitude != null && locationData.longitude != null) {
        final currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);

        // Gunakan lokasi saat ini
        _currentLocation = currentLocation;
        _lastValidLocation =
            currentLocation; // Simpan sebagai lokasi valid terakhir
        _hasValidLocation = true;
      }

      // Buat list dengan minimal satu point untuk menghindari empty bounds error
      final List<LatLng> initialPoints = [_currentLocation];

      // Create markers
      _currentMarkers = [
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
      _currentPolylines = [
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
        markers: _currentMarkers,
        polylines: _currentPolylines,
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
    _currentMarkers = [
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
    _currentPolylines = [
      Polyline(
        points:
            initialPoints, // Gunakan initialPoints untuk menghindari bounds error
        color: Colors.transparent, // Buat transparan untuk sementara
        strokeWidth: 0,
      ),
    ];

    return MapData(
      routePoints: initialPoints,
      markers: _currentMarkers,
      polylines: _currentPolylines,
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

        // Simpan lokasi valid terakhir
        _lastValidLocation = _currentLocation;
        _hasValidLocation = true;

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

            // Update markers dan polylines
            _updateMapVisuals();
          }
        }

        // 🛰️ Kirim update lokasi ke stream, selalu kirim walaupun session ga aktif
        _locationController?.add(_currentLocation);
      }
    });
  }

  /// Update markers dan polylines berdasarkan routeHistory
  static void _updateMapVisuals() {
    // Update marker untuk posisi saat ini
    _currentMarkers = [
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

    // Jika ada rute, tampilkan polyline
    if (_routeHistory.isNotEmpty) {
      _currentPolylines = [
        Polyline(
          points: List.from(_routeHistory),
          color: const Color(0xFF2AAF7F),
          strokeWidth: 5,
        ),
      ];
    } else {
      // Polyline kosong jika tidak ada rute
      _currentPolylines = [
        Polyline(
          points: [_currentLocation],
          color: Colors.transparent,
          strokeWidth: 0,
        ),
      ];
    }
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
    // Jika memiliki lokasi valid, kembalikan itu
    if (_hasValidLocation) {
      return _lastValidLocation;
    }

    // Jika sedang tracking dan ada rute, gunakan titik terakhir dari rute
    if (_isSessionActive && _routeHistory.isNotEmpty) {
      return _routeHistory.last;
    }

    // Jika sudah berhenti tracking tapi ada rute tersimpan, gunakan titik terakhir dari rute tersimpan
    if (!_isSessionActive && _savedRouteHistory.isNotEmpty) {
      return _savedRouteHistory.last;
    }

    // Fallback ke lokasi saat ini (yang mungkin defaultCenter)
    return _currentLocation;
  }

  /// Get entire route history
  static List<LatLng> getRouteHistory() {
    // Jika dalam sesi aktif, kembalikan rute aktif
    if (_isSessionActive) {
      // Jika rute kosong tapi kita punya lokasi valid, tambahkan lokasi saat ini
      if (_routeHistory.isEmpty && _hasValidLocation) {
        return [_lastValidLocation];
      }
      return List.from(_routeHistory);
    }

    // Jika sesi sudah berakhir, kembalikan rute yang tersimpan
    if (_savedRouteHistory.isNotEmpty) {
      return List.from(_savedRouteHistory);
    }

    // Jika tidak ada rute tersimpan tapi kita punya lokasi valid, kembalikan lokasi itu
    if (_hasValidLocation) {
      return [_lastValidLocation];
    }

    // Fallback ke lokasi saat ini (mungkin defaultCenter)
    if (_routeHistory.isEmpty) {
      return [_currentLocation];
    }

    return List.from(_routeHistory);
  }

  /// Stop location updates
  static void stopLocationUpdates() {
    _isTracking = false;
    _locationSubscription?.cancel();
    _locationController?.close();

    // Jangan reset data rute di sini - karena kita masih perlu untuk summary
  }

  /// Create a MapData object dari state saat ini
  static MapData getCurrentMapData() {
    // Jika dalam sesi aktif, gunakan data langsung
    if (_isSessionActive) {
      // Jika rute kosong, pastikan minimal berisi lokasi saat ini
      List<LatLng> currentPoints = _routeHistory.isNotEmpty
          ? List.from(_routeHistory)
          : [_currentLocation];

      return MapData(
        routePoints: currentPoints,
        markers: _currentMarkers,
        polylines: _currentPolylines,
      );
    }

    // Jika sesi berakhir, gunakan data tersimpan
    if (_savedRouteHistory.isNotEmpty) {
      return MapData(
        routePoints: List.from(_savedRouteHistory),
        markers: _savedMarkers,
        polylines: _savedPolylines,
      );
    }

    // Fallback ke data saat ini jika tidak ada data tersimpan
    List<LatLng> points = _routeHistory.isNotEmpty
        ? List.from(_routeHistory)
        : [_currentLocation];

    return MapData(
      routePoints: points,
      markers: _currentMarkers,
      polylines: _currentPolylines,
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

    // Tambahkan lokasi saat ini sebagai titik pertama jika kita punya lokasi valid
    if (_hasValidLocation) {
      _routeHistory.add(_lastValidLocation);
      _updateMapVisuals();
    }
  }

  /// Tambahkan titik rute manual
  static void addRoutePoint(LatLng point) {
    // Cek jika point sudah ada di rute untuk menghindari duplikasi
    bool isDuplicate = false;
    for (var existingPoint in _routeHistory) {
      if ((existingPoint.latitude - point.latitude).abs() < 0.000001 &&
          (existingPoint.longitude - point.longitude).abs() < 0.000001) {
        isDuplicate = true;
        break;
      }
    }

    if (!isDuplicate) {
      _routeHistory.add(point);
      _updateMapVisuals();
    }
  }

  static Future<LatLng?> getCurrentLocationAsync() async {
    try {
      // Try to get the current location
      LatLng currentLocation = MapService.getCurrentLocation();
      return currentLocation;
    } catch (e) {
      print('❌ Error getting current location: $e');
      // Return null if we can't get the location
      return null;
    }
  }

  /// Method untuk menghentikan session
  static void stopSession() {
    // Simpan rute sebelum mengakhiri sesi
    if (_routeHistory.isNotEmpty) {
      _savedRouteHistory.clear();
      _savedRouteHistory.addAll(_routeHistory);

      // Simpan juga markers dan polylines
      _savedMarkers = List.from(_currentMarkers);
      _savedPolylines = List.from(_currentPolylines);
    } else if (_hasValidLocation) {
      // Jika rute kosong tapi kita punya lokasi valid, gunakan itu
      _savedRouteHistory.clear();
      _savedRouteHistory.add(_lastValidLocation);

      // Buat markers dan polylines sederhana
      _savedMarkers = [
        Marker(
          point: _lastValidLocation,
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

      _savedPolylines = [
        Polyline(
          points: [_lastValidLocation],
          color: const Color(0xFF2AAF7F),
          strokeWidth: 5,
        ),
      ];
    }

    // Set flag sesi menjadi tidak aktif
    _isSessionActive = false;
    _isPaused = false; // Reset pause state
  }

  /// Metode untuk memeriksa status session
  static bool isSessionActive() {
    return _isSessionActive;
  }

  /// Method untuk memeriksa status pause
  static bool isPaused() {
    return _isPaused;
  }

  /// Mendapatkan lokasi tengah dari rute untuk digunakan di peta
  static LatLng getMapCenter() {
    // Jika sesi aktif dan ada rute, hitung center dari rute
    if (_isSessionActive && _routeHistory.length > 1) {
      double latSum = 0;
      double lngSum = 0;

      for (var point in _routeHistory) {
        latSum += point.latitude;
        lngSum += point.longitude;
      }

      return LatLng(
        latSum / _routeHistory.length,
        lngSum / _routeHistory.length,
      );
    }

    // Jika sesi berakhir dan ada rute tersimpan, hitung center dari rute tersimpan
    if (!_isSessionActive && _savedRouteHistory.length > 1) {
      double latSum = 0;
      double lngSum = 0;

      for (var point in _savedRouteHistory) {
        latSum += point.latitude;
        lngSum += point.longitude;
      }

      return LatLng(
        latSum / _savedRouteHistory.length,
        lngSum / _savedRouteHistory.length,
      );
    }

    // Jika tidak ada rute, gunakan lokasi saat ini
    return getCurrentLocation();
  }

  /// Reset data rute (biasanya dipanggil saat kembali ke layar awal)
  static void resetRouteData() {
    _savedRouteHistory.clear();
    _savedMarkers.clear();
    _savedPolylines.clear();
  }
}
