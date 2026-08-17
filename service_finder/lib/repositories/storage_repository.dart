import 'dart:convert';
import 'dart:io';

/// Converts image files to Base64 strings for storage in Firestore.
/// This avoids the need for Firebase Storage (which requires Blaze plan).
class StorageRepository {

  StorageRepository();

  /// Converts a file to a Base64 data URI string.
  /// Returns a string like "data:image/jpeg;base64,/9j/4AAQ..."
  Future<String> _fileToBase64(File file) async {
    if (!file.existsSync() || file.path.isEmpty || file.lengthSync() == 0) {
      throw Exception('Invalid file: File does not exist or is empty.');
    }

    final bytes = await file.readAsBytes();
    
    // Compress if too large (Firestore doc limit is ~1MB)
    // Each image should be kept under ~300KB for 3 images to fit in one doc
    final base64String = base64Encode(bytes);
    
    return 'data:image/jpeg;base64,$base64String';
  }

  Future<String> uploadProfileImage(File file) {
    return _fileToBase64(file);
  }

  Future<String> uploadAadhaarFront(File file) {
    return _fileToBase64(file);
  }

  Future<String> uploadAadhaarBack(File file) {
    return _fileToBase64(file);
  }
}
