import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервіс для збереження та завантаження локального фото профілю студента.
/// Дозволяє обирати локальні файли (PNG, JPG) з компʼютера та зберігати їх у сховищі браузера.
abstract final class AvatarService {
  static const String _keyPrefix = 'custom_user_avatar_';

  /// Зберігає байти локального фото у сховищі
  static Future<void> saveLocalAvatar(String uid, Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = base64Encode(bytes);
    await prefs.setString('$_keyPrefix$uid', base64String);
  }

  /// Отримує байти локального фото для користувача
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

  /// Видаляє локальне фото (наприклад, якщо вибрано пресет або аватар видалено)
  static Future<void> clearLocalAvatar(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$uid');
    } catch (_) {
      // Ігноруємо помилки очищення
    }
  }
}
