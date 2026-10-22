import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/auth/data/auth_scope.dart';
import '../constants/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'search_dialog.dart';
import 'user_avatar.dart';

/// Top application bar containing navigation breadcrumbs, search shortcut,
/// notification bell, and an interactive user dropdown menu.
class TopBar extends StatelessWidget {
  final String breadcrumb;
  final VoidCallback? onMenuPressed;

  const TopBar({
    super.key,
    required this.breadcrumb,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : 'Student';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          if (onMenuPressed != null) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: onMenuPressed,
              tooltip: 'Open navigation',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Breadcrumbs (clickable to return to Dashboard if on another screen)
          Expanded(
            child: InkWell(
              onTap: () {
                if (breadcrumb.contains('Profile') || breadcrumb.contains('Entries')) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      breadcrumb,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Field (desktop/tablet)
          if (MediaQuery.of(context).size.width >= 600) ...[
            InkWell(
              onTap: () => SearchDialog.show(context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                width: 220,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Search anything…',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        '⌘K',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ] else ...[
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => SearchDialog.show(context),
              tooltip: 'Search',
            ),
          ],

          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.notificationDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // Vertical divider
          Container(
            height: 24,
            width: 1,
            color: AppColors.border,
          ),
          const SizedBox(width: AppSpacing.md),

          // User Block with Dropdown Menu
          PopupMenuButton<String>(
            tooltip: 'User profile & actions',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              side: const BorderSide(color: AppColors.border),
            ),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
              } else if (value == 'logout') {
                final authRepo = AuthScope.of(context);
                await authRepo.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Profile & settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Log out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(
                      user: user,
                      radius: 17,
                    ),
                    if (MediaQuery.of(context).size.width >= 768) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.email ?? 'Student',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
