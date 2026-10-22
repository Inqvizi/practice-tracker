import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../data/mock_data.dart';
import '../models/practice_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Interactive Quick Search & Command Palette modal dialog.
/// Supports searching across application routes and practice diary records.
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (context) => const SearchDialog(),
    );
  }

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();

    // 1. Filter Navigation Actions
    final actions = [
      (
        title: 'Dashboard',
        subtitle: 'Main overview & term metrics',
        icon: Icons.home_rounded,
        route: AppRoutes.dashboard,
      ),
      (
        title: 'Practice Entries',
        subtitle: 'View and manage all practice logs',
        icon: Icons.assignment_outlined,
        route: AppRoutes.entries,
      ),
      (
        title: 'New Entry',
        subtitle: 'Log new practice hours and tasks',
        icon: Icons.add_circle_outline_rounded,
        route: AppRoutes.entryForm,
      ),
      (
        title: 'Profile & Settings',
        subtitle: 'Account, avatar, and password security',
        icon: Icons.person_outline_rounded,
        route: AppRoutes.profile,
      ),
    ].where((item) {
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query);
    }).toList();

    // 2. Filter Practice Entries
    final matchingEntries = MockData.initialEntries.where((entry) {
      if (query.isEmpty) return false;
      return entry.title.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query) ||
          entry.skills.any((s) => s.toLowerCase().contains(query));
    }).toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) => setState(() => _query = val),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search pages, actions, skills, or tasks…',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Search Results List
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  shrinkWrap: true,
                  children: [
                    // Navigation Group
                    if (actions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.xs,
                          AppSpacing.sm,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          query.isEmpty ? 'QUICK NAVIGATION' : 'NAVIGATION',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...actions.map((item) => _buildResultTile(
                            icon: item.icon,
                            title: item.title,
                            subtitle: item.subtitle,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(item.route);
                            },
                          )),
                    ],

                    // Entries Group
                    if (matchingEntries.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.xs,
                          AppSpacing.sm,
                          AppSpacing.xs,
                        ),
                        child: Text(
                          'PRACTICE ENTRIES',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...matchingEntries.map((entry) => _buildEntryTile(
                            entry: entry,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed(AppRoutes.entries);
                            },
                          )),
                    ],

                    // Empty state
                    if (actions.isEmpty && matchingEntries.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 36,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'No results found for "$_query"',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search practice tasks, logs, and workspaces',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Esc to close',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.sidebarActive,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }

  Widget _buildEntryTile({
    required PracticeEntry entry,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: const Icon(
          Icons.task_alt_rounded,
          color: AppColors.primary,
          size: 18,
        ),
      ),
      title: Text(
        entry.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${entry.date} · ${entry.hours} hrs · ${entry.skills.join(", ")}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 12,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }
}
