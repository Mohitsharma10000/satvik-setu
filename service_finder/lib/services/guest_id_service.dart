import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GuestIdService {
  static const String _keyGuestId = 'guest_device_id';

  /// Get or create a unique persistent device ID for guest user
  static Future<String> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keyGuestId);
    if (id == null || id.isEmpty) {
      id = 'guest_${const Uuid().v4()}';
      await prefs.setString(_keyGuestId, id);
    }
    return id;
  }
}
