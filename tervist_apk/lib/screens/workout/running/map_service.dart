import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  // This simulates a central location in Yogyakarta, Indonesia based on the map in your screenshot
  static const LatLng defaultCenter = LatLng(-7.7672, 110.3785);
  
  /// Get initial map data for the running screen
  static Future<MapData> getInitialMapData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create sample route points (this would normally come from GPS or stored data)
    final List<LatLng> routePoints = [
      defaultCenter,
      const LatLng(-7.7674, 110.3790),
      const LatLng(-7.7678, 110.3795),
      const LatLng(-7.7682, 110.3800),
      const LatLng(-7.7685, 110.3805),
    ];
    
    // Create markers
    final List<Marker> markers = [
      Marker(
        point: routePoints.first,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 30,
        ),
      ),
    ];
    
    // Create polylines
    final List<Polyline> polylines = [
      Polyline(
        points: routePoints,
        color: const Color(0xFF2AAF7F), // primaryGreen
        strokeWidth: 5,
      ),
    ];
    
    return MapData(
      routePoints: routePoints,
      markers: markers,
      polylines: polylines,
    );
  }
  
  /// Get real-time location updates (this would use GPS in a real app)
  static Future<LatLng> getCurrentLocation() async {
    // In a real app, this would use location services like geolocator
    // Here we're just returning a simulated value
    return defaultCenter;
  }
  
  /// Adds required dependencies to pubspec.yaml
  /// 
  /// To use Flutter Map in your Flutter app, you need to add the following to your pubspec.yaml:
  /// ```yaml
  /// dependencies:
  ///   flutter_map: ^6.0.0
  ///   latlong2: ^0.9.0
  ///   location: ^5.0.3
  /// ```
  /// 
  /// For location permissions:
  /// 
  /// For Android:
  /// - Add to android/app/src/main/AndroidManifest.xml:
  /// ```xml
  /// <uses-permission android:name="android.permission.INTERNET" />
  /// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  /// <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  /// ```
  /// 
  /// For iOS:
  /// - Add to ios/Runner/Info.plist:
  /// ```xml
  /// <key>NSLocationWhenInUseUsageDescription</key>
  /// <string>This app needs access to location when open.</string>
  /// <key>NSLocationAlwaysUsageDescription</key>
  /// <string>This app needs access to location when in the background.</string>
  /// ```
  static void setupGuidelines() {
    // This is just a documentation method - no actual implementation
  }
}