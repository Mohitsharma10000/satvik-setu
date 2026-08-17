import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Helper to detect and decode Base64 image strings in Admin App.
/// Supports both "data:image/...;base64,..." format and plain base64 or network URLs.
class Base64ImageHelper {
  static bool isBase64(String value) {
    return value.startsWith('data:image');
  }

  static Uint8List decode(String value) {
    String base64Str = value;
    if (value.contains(',')) {
      base64Str = value.split(',').last;
    }
    return base64Decode(base64Str);
  }

  static ImageProvider getImageProvider(String imageString) {
    if (isBase64(imageString)) {
      return MemoryImage(decode(imageString));
    } else {
      return NetworkImage(imageString);
    }
  }

  static Widget getImageWidget(String imageString, {BoxFit fit = BoxFit.cover, double? height, double? width}) {
    if (isBase64(imageString)) {
      return Image.memory(
        decode(imageString),
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Image.network(
        imageString,
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }
}
