import 'package:flutter/material.dart';
import '../../features/auth/data/auth_scope.dart';
import '../constants/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_logo.dart';
import 'section_label.dart';
import 'user_avatar.dart';

/// Navigation sidebar component.
/// Used directly as a desktop left panel and as a Drawer content for mobile/narrow views.
class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.currentRoute,
  });

  void _navigateTo(BuildContext context, String route) {
    if (currentRoute == route) {
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
      return;
    }

    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      final authRepo = AuthScope.of(context);
      await authRepo.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      // Ігноруємо помилки або AuthGate оновить інтерфейс
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).currentUser;
    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : 'Student';
    final email = user?.email ?? '';

    return Container(
      width: AppSpacing.sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: AppLogo(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Workspace Section Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SectionLabel('Workspace', color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Menu Items
          _SidebarItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            isActive: currentRoute == AppRoutes.dashboard,
            onTap: () => _navigateTo(context, AppRoutes.dashboard),
          ),
          _SidebarItem(
            icon: Icons.assignment_outlined,
            label: 'Practice Entries',
            isActive: currentRoute == AppRoutes.entries ||
                currentRoute == AppRoutes.entryForm,
            onTap: () => _navigateTo(context, AppRoutes.entries),
          ),
          _SidebarItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isActive: currentRoute == AppRoutes.profile,
            onTap: () => _navigateTo(context, AppRoutes.profile),
          ),

          const Spacer(),

          // Bottom Mini Profile & Log Out
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    UserAvatar(
                      user: user,
                      radius: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            email.isNotEmpty ? email : 'Student',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                InkWell(
                  onTap: () => _logOut(context),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 6,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Log out',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 11,
            ),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 3,
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
