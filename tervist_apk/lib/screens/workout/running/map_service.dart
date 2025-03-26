import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapData {
  final List<LatLng> routePoints;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

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
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: routePoints.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
    
    // Create polylines
    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: const Color(0xFF2AAF7F), // primaryGreen
        width: 5,
      ),
    };
    
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
  
  /// Calculate distance between two points (in kilometers)
  // static double calculateDistance(LatLng point1, LatLng point2) {
  //   // Haversine formula would be implemented here for actual distance calculation
  //   // This is a simplified version
  //   const double earthRadius = 6371; // in kilometers
  //   final double lat1 = point1.latitude * (3.14159 / 180);
  //   final double lat2 = point2.latitude * (3.14159 / 180);
  //   final double lng1 = point1.longitude * (3.14159 / 180);
  //   final double lng2 = point2.longitude * (3.14159 / 180);
    
  //   final double dLat = lat2 - lat1;
  //   final double dLng = lng2 - lng1;
    
  //   final double a = 
  //       (dLat/2).sin() * (dLat/2).sin() +
  //       (dLng/2).sin() * (dLng/2).sin() * lat1.cos() * lat2.cos();
  //   final double c = 2 * a.sqrt().atan2((1-a).sqrt());
    
  // //   return earthRadius * c;
  // // }
  
  // /// Calculate total distance of a route
  // static double calculateRouteDistance(List<LatLng> routePoints) {
  //   double totalDistance = 0;
    
  //   for (int i = 0; i < routePoints.length - 1; i++) {
  //     totalDistance += calculateDistance(routePoints[i], routePoints[i + 1]);
  //   }
    
  //   return totalDistance;
  // }
  
  /// Adds required dependencies to pubspec.yaml
  /// 
  /// To use Google Maps in your Flutter app, you need to add the following to your pubspec.yaml:
  /// ```yaml
  /// dependencies:
  ///   google_maps_flutter: ^2.5.0
  ///   location: ^5.0.3
  /// ```
  /// 
  /// You also need to set up your API keys:
  /// 
  /// For Android:
  /// - Add your API key to android/app/src/main/AndroidManifest.xml:
  /// ```xml
  /// <manifest ...>
  ///   <application ...>
  ///     <meta-data
  ///       android:name="com.google.android.geo.API_KEY"
  ///       android:value="YOUR_API_KEY"/>
  /// ```
  /// 
  /// For iOS:
  /// - Add your API key to ios/Runner/AppDelegate.swift:
  /// ```swift
  /// import UIKit
  /// import Flutter
  /// import GoogleMaps
  /// 
  /// @UIApplicationMain
  /// @objc class AppDelegate: FlutterAppDelegate {
  ///   override func application(
  ///     _ application: UIApplication,
  ///     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ///   ) -> Bool {
  ///     GMSServices.provideAPIKey("YOUR_API_KEY")
  ///     GeneratedPluginRegistrant.register(with: self)
  ///     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  ///   }
  /// }
  /// ```
  static void setupGuidelines() {
    // This is just a documentation method - no actual implementation
  }
}