import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

// Class untuk memproses dan mengekstrak pace data dari summary/timestamp
class PaceDataProcessor {
  // Metode untuk mengekstrak pace data dari RoutePoints
  static List<Map<String, dynamic>> extractPaceFromRoutePoints(
    List<LatLng> routePoints,
    double totalDistance,
    double totalDurationInMinutes,
  ) {
    if (routePoints.isEmpty) {
      return [];
    }
    
    List<Map<String, dynamic>> paceData = [];
    int totalKm = totalDistance.floor();
    
    // Pastikan menampilkan maksimal 7 kilometer
    totalKm = totalKm > 7 ? 7 : totalKm;
    
    // Hitung jarak antara tiap titik rute
    List<double> distances = [];
    double distance = 0;
    
    for (int i = 1; i < routePoints.length; i++) {
      LatLng current = routePoints[i];
      LatLng previous = routePoints[i - 1];
      
      // Hitung jarak dengan Haversine formula
      double distanceInKm = _calculateDistance(previous, current);
      distance += distanceInKm;
      distances.add(distance);
    }
    
    // Ekstrak pace per kilometer
    double accumDistance = 0;
    int currentKm = 1;
    double lastPace = 0;
    
    // Jika jarak total terlalu pendek, kembalikan satu titik
    if (totalKm == 0) {
      double averagePace = totalDurationInMinutes > 0 
        ? 60 / totalDurationInMinutes 
        : 0;
      return [{'km': 1, 'pace': averagePace.round()}];
    }
    
    for (int i = 0; i < distances.length; i++) {
      // Jika sudah mencapai kilometer baru
      if (distances[i] >= currentKm && currentKm <= totalKm) {
        // Interpolasi waktu untuk perhitungan pace yang lebih akurat
        double segmentDuration = (totalDurationInMinutes / totalDistance) * currentKm;
        
        // pace dalam km/h (kecepatan)
        double pace = segmentDuration > 0 ? 60 / segmentDuration : 0;
        lastPace = pace;
        
        paceData.add({
          'km': currentKm,
          'pace': pace.round(),
        });
        
        currentKm++;
      }
    }
    
    // Tambahkan kilometer terakhir jika belum selesai
    if (paceData.length < totalKm) {
      // Gunakan pace terakhir sebagai estimasi
      for (int i = paceData.length + 1; i <= totalKm; i++) {
        paceData.add({
          'km': i,
          'pace': lastPace.round(),
        });
      }
    }
    
    return paceData;
  }
  
  // Ekstrak pace dari formattedPace (mis. "5'23"/km atau "10.5 km/h")
  static List<Map<String, dynamic>> extractPaceFromSummary(
    String formattedPace,
    double totalDistance,
    List<Map<String, dynamic>>? existingData,
  ) {
    if (existingData != null && existingData.isNotEmpty) {
      return existingData;
    }
    
    // Pastikan total distance valid (minimal 1 km)
    int totalKm = totalDistance < 1 ? 1 : totalDistance.floor();
    totalKm = totalKm > 7 ? 7 : totalKm;
    
    // Parsing formattedPace untuk mendapatkan nilai pace
    double paceValue = 0;
    
    // Jika format pace dalam menit:detik per km
    if (formattedPace.contains("'") || formattedPace.contains('"')) {
      // Format: "5'23"/km
      String cleanPace = formattedPace.replaceAll('"', '').replaceAll('/km', '');
      List<String> parts = cleanPace.split("'");
      
      if (parts.length == 2) {
        int minutes = int.tryParse(parts[0]) ?? 0;
        int seconds = int.tryParse(parts[1]) ?? 0;
        
        // Convert to km/h: pace = 60 / (minutes + seconds/60)
        double minutesDecimal = minutes + (seconds / 60);
        paceValue = minutesDecimal > 0 ? 60 / minutesDecimal : 0;
      }
    }
    // Jika format pace dalam km/h
    else if (formattedPace.contains('km/h')) {
      // Format: "10.5 km/h"
      String cleanPace = formattedPace.replaceAll('km/h', '').trim();
      paceValue = double.tryParse(cleanPace) ?? 0;
    }
    
    // Generate data pace untuk setiap kilometer
    List<Map<String, dynamic>> paceData = [];
    
    // Jika tidak dapat mengekstrak pace, gunakan nilai default
    if (paceValue <= 0) {
      paceValue = 5; // Default 5 km/h
    }
    
    // Variasi pace untuk tampilan lebih realistis
    for (int i = 1; i <= totalKm; i++) {
      // Tambahkan variasi antara -20% dan +20%
      double variation = 0.8 + (0.4 * (i % 3) / 2);
      double adjustedPace = paceValue * variation;
      
      paceData.add({
        'km': i,
        'pace': adjustedPace.round(),
      });
    }
    
    return paceData;
  }
  
  // Metode untuk menghitung jarak antara dua koordinat dengan Haversine formula
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const int earthRadius = 6371; // km
    
    // Convert latitude and longitude from degrees to radians
    double lat1 = point1.latitude * (math.pi / 180);
    double lon1 = point1.longitude * (math.pi / 180);
    double lat2 = point2.latitude * (math.pi / 180);
    double lon2 = point2.longitude * (math.pi / 180);
    
    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance;
  }
}