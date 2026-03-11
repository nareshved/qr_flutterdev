import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class QrExportService {
  static Future<String?> captureAndSave(RenderRepaintBoundary boundary, String filename) async {
    try {
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/$filename.png';
      File imgFile = File(imagePath);
      await imgFile.writeAsBytes(pngBytes);
      
      return imagePath;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  static Future<bool> saveToGallery(String imagePath) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }
      if (hasAccess) {
        await Gal.putImage(imagePath);
        return true;
      }
      return false;
    } catch(e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }
}
