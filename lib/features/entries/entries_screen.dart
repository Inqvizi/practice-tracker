import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/practice_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/skill_chip.dart';
import '../../core/widgets/status_badge.dart';

/// Screen FR-5 Read + FR-7: Practice entries listing with interactive filtering,
/// status badges, skill tags, and deletion confirmation dialog.
class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final _searchController = TextEditingController();
  late List<PracticeEntry> _entries;
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _entries = List.from(MockData.initialEntries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PracticeEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesQuery = query.isEmpty ||
          entry.title.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query);

      final matchesStatus = _selectedStatusFilter == 'All' ||
          (_selectedStatusFilter == 'Done' &&
              entry.status == PracticeStatus.done) ||
          (_selectedStatusFilter == 'In progress' &&
              entry.status == PracticeStatus.inProgress);

      return matchesQuery && matchesStatus;
    }).toList();
  }

  double get _totalHours =>
      _entries.fold(0.0, (sum, entry) => sum + entry.hours);

  void _confirmDelete(PracticeEntry entry) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text(
          'Delete practice entry?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${entry.title}"? This action cannot be undone.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        if (!mounted) return;
        setState(() {
          _entries.removeWhere((e) => e.id == entry.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${entry.title}"'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;

    return AppScaffold(
      currentRoute: AppRoutes.entries,
      breadcrumb: 'Workspace > Practice Entries',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSpacing.desktopBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    _buildHeader(context, isDesktop),
                    const SizedBox(height: AppSpacing.xl),

                    // Filter Bar Card
                    _buildFilterCard(isDesktop),
                    const SizedBox(height: AppSpacing.xl),

                    // Entries List / Table
                    _buildEntriesContainer(context, filtered, isDesktop),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Practice log', color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xs + 2),
            const Text(
              'Practice entries',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_entries.length} entries · ${_totalHours.toStringAsFixed(1)} total hours recorded',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        PrimaryButton(
          text: 'Add entry',
          isFullWidth: false,
          icon: const Icon(Icons.add_rounded, size: 18),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.entryForm);
          },
        ),
      ],
    );
  }

  Widget _buildFilterCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search Field
          SizedBox(
            width: isDesktop ? 340 : double.infinity,
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by task title or description…',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Status Dropdown
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All statuses')),
                  DropdownMenuItem(value: 'Done', child: Text('Done')),
                  DropdownMenuItem(
                      value: 'In progress', child: Text('In progress')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStatusFilter = val);
                  }
                },
              ),
            ),
          ),

          // Date Range Mock Indicators
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  '05/01/2025  to  05/31/2025',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesContainer(
      BuildContext context, List<PracticeEntry> items, bool isDesktop) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: const [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No practice entries found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try clearing search keywords or status filters.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = items[index];

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date badge
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    entry.date,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Main Details & Skills
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          StatusBadge(status: entry.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${entry.hours} hrs',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: entry.skills
                                  .map((s) => SkillChip(label: s))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Actions: Edit & Delete
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Edit entry',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.entryForm);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.danger,
                      ),
                      tooltip: 'Delete entry',
                      onPressed: () => _confirmDelete(entry),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
