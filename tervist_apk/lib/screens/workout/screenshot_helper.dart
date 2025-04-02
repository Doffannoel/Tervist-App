import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenshotHelper {
  static Future<Uint8List?> captureFromWidget(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    try {
      RenderRepaintBoundary? boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        debugPrint('Boundary tidak ditemukan');
        return null;
      }
      
      // Berikan waktu untuk memastikan UI telah dirender sepenuhnya
      await Future.delayed(const Duration(milliseconds: 20));
      
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      debugPrint('Error saat mengambil screenshot: $e');
      return null;
    }
  }

  static Future<File?> saveToFile(Uint8List imageBytes, {String? customName}) async {
    try {
      final directory = await getTemporaryDirectory();
      String fileName = customName ?? 'tervist_workout_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('Error saat menyimpan file: $e');
      return null;
    }
  }

  static Future<bool> shareImage(File file, {String? message}) async {
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message ?? 'Check out my workout with Tervist!',
      );
      return true;
    } catch (e) {
      debugPrint('Error saat berbagi gambar: $e');
      return false;
    }
  }
  
  // Save to file in Downloads or Pictures directory (accessible in gallery)
  static Future<File?> saveToDownloads(Uint8List imageBytes) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          debugPrint('Storage permission denied');
          return null;
        }
        
        // For Android 13+ (API 33+)
        if (await Permission.photos.isPermanentlyDenied == false) {
          final photoStatus = await Permission.photos.request();
          if (!photoStatus.isGranted) {
            debugPrint('Photos permission denied');
            // Continue anyway as storage permission is granted
          }
        }
      } else if (Platform.isIOS) {
        final photoStatus = await Permission.photos.request();
        if (!photoStatus.isGranted) {
          debugPrint('Photos permission denied');
          return null;
        }
      }
      
      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android, save to Downloads or Pictures directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = Directory('/storage/emulated/0/Pictures');
          if (!await directory.exists()) {
            // Fallback to external storage
            directory = await getExternalStorageDirectory();
          }
        }
      } else {
        // For iOS, use the Documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        debugPrint('Could not find a suitable directory to save the image');
        return null;
      }
      
      // Create a file in the directory
      String fileName = 'tervist_workout_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      
      // Write image bytes to file
      await file.writeAsBytes(imageBytes);
      return file;
    } catch (e) {
      debugPrint('Error saat menyimpan ke Downloads: $e');
      return null;
    }
  }
}