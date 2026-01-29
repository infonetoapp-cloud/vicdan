import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utility to capture widgets as images and share them
class CardRenderer {
  /// Capture a widget as a PNG image
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Wait for first frame to render
      await Future.delayed(const Duration(milliseconds: 100));

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Save image to temporary file and return path
  static Future<String?> saveToTempFile(
      Uint8List bytes, String filename) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename.png');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  /// Capture widget and share directly
  static Future<void> captureAndShare(
    GlobalKey key, {
    String? text,
    String filename = 'vicdan_share',
  }) async {
    final bytes = await captureWidget(key);
    if (bytes == null) {
      debugPrint('Failed to capture widget');
      return;
    }

    final path = await saveToTempFile(bytes, filename);
    if (path == null) {
      debugPrint('Failed to save image');
      return;
    }

    await Share.shareXFiles(
      [XFile(path)],
      text: text,
    );
  }

  /// Share to Instagram Story specifically
  static Future<void> shareToInstagramStory(GlobalKey key) async {
    await captureAndShare(
      key,
      filename: 'vicdan_story',
      text: 'VİCDAN - Vicdan Arkadaşı 🌿',
    );
  }

  /// Share to WhatsApp
  static Future<void> shareToWhatsApp(GlobalKey key) async {
    await captureAndShare(
      key,
      filename: 'vicdan_whatsapp',
      text: 'VİCDAN uygulaması ile paylaştım 🌿 vicdan.app',
    );
  }

  /// Save to gallery
  static Future<String?> saveToGallery(GlobalKey key) async {
    final bytes = await captureWidget(key);
    if (bytes == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/vicdan_$timestamp.png');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
