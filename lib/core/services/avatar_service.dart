import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for saving and loading local student profile photo.
/// Enables selecting local image files (PNG, JPG) and storing them in browser storage.
abstract final class AvatarService {
  static const String _keyPrefix = 'custom_user_avatar_';

  /// Saves local avatar bytes in local storage
  static Future<void> saveLocalAvatar(String uid, Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = base64Encode(bytes);
    await prefs.setString('$_keyPrefix$uid', base64String);
  }

  /// Retrieves local avatar bytes for user
  static Future<Uint8List?> getLocalAvatar(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString('$_keyPrefix$uid');
      if (base64String == null || base64String.isEmpty) return null;
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  /// Removes local avatar (e.g. when switching to preset or resetting)
  static Future<void> clearLocalAvatar(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$uid');
    } catch (_) {
      // Ignore cleanup errors
    }
  }
}
