import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Helper to detect and decode Base64 image strings.
/// Supports both "data:image/...;base64,..." format and plain base64.
class Base64ImageHelper {
  /// Returns true if the string is a Base64-encoded image.
  static bool isBase64(String value) {
    return value.startsWith('data:image');
  }

  /// Decodes a Base64 image string to bytes.
  static Uint8List decode(String value) {
    String base64Str = value;
    // Strip the data URI prefix if present
    if (value.contains(',')) {
      base64Str = value.split(',').last;
    }
    return base64Decode(base64Str);
  }

  /// Returns an ImageProvider for the given image string.
  /// Handles both Base64 and network URLs.
  static ImageProvider getImageProvider(String imageString) {
    if (isBase64(imageString)) {
      return MemoryImage(decode(imageString));
    } else {
      return NetworkImage(imageString);
    }
  }

  /// Returns an Image widget for the given image string.
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
