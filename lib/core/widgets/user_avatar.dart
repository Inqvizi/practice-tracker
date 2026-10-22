import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/avatar_service.dart';
import '../theme/app_colors.dart';

/// Віджет для відображення аватара користувача з підтримкою:
/// 1. Локально завантаженого файлу з компʼютера (Uint8List bytes)
/// 2. Мережевого посилання (HTTPS URL або пресети Dicebear)
/// 3. Fallback на стильні ініціали імені студента.
class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final String? initials;
  final Uint8List? localImageBytes;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 20,
    this.initials,
    this.localImageBytes,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Student';
    final userInitials = initials ?? _getInitials(displayName);
    final photoUrl = user?.photoURL;

    // Якщо передано байти напряму (наприклад, у ProfileScreen)
    if (localImageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: MemoryImage(localImageBytes!),
      );
    }

    // Якщо є локальний uid, перевіряємо збережений локальний аватар
    final uid = user?.uid;
    if (uid != null) {
      return FutureBuilder<Uint8List?>(
        future: AvatarService.getLocalAvatar(uid),
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes != null && bytes.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.primary,
              backgroundImage: MemoryImage(bytes),
            );
          }

          return _buildNetworkOrInitials(photoUrl, userInitials);
        },
      );
    }

    return _buildNetworkOrInitials(photoUrl, userInitials);
  }

  Widget _buildNetworkOrInitials(String? photoUrl, String userInitials) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.sidebarActive,
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (exception, stackTrace) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.sidebarActive,
      child: Text(
        userInitials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
