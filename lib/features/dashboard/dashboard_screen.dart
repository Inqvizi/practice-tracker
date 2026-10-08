import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/practice_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';

/// Screen FR-4: Dashboard screen displaying student metrics and recent diary entries.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentRoute: AppRoutes.dashboard,
      breadcrumb: 'Workspace > Dashboard',
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
                    // Welcome Header Row
                    _buildHeader(context, isDesktop),
                    const SizedBox(height: AppSpacing.xl),

                    // Metrics Stat Cards Row
                    _buildStatCards(isDesktop),
                    const SizedBox(height: AppSpacing.xl),

                    // Recent Activity Card
                    _buildRecentActivity(context, isDesktop),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SectionLabel(
                'Spring term 2025 · Monday, May 26',
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xs + 2),
              Text(
                'Welcome back, Oleksandr',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Here's a clear view of your practice progress this term.",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        PrimaryButton(
          text: 'New entry',
          isFullWidth: false,
          icon: const Icon(Icons.add_rounded, size: 18),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.entryForm);
          },
        ),
      ],
    );
  }

  Widget _buildStatCards(bool isDesktop) {
    const card1 = StatCard(
      title: 'Total entries',
      value: '24',
      badgeText: 'This term',
      subtitle: '19 completed · 5 in progress',
    );

    const card2 = StatCard(
      title: 'Total hours logged',
      value: '48.5',
      badgeText: '↑ 12%',
      badgeColor: AppColors.statusDoneBackground,
      badgeTextColor: AppColors.statusDoneText,
      subtitle: '+6.5 hours · this week',
    );

    const card3 = StatCard(
      title: 'Skills acquired',
      value: '9',
      badgeText: '+2 recent',
      chips: ['TypeScript', 'PostgreSQL'],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(child: card1),
          SizedBox(width: AppSpacing.lg),
          Expanded(child: card2),
          SizedBox(width: AppSpacing.lg),
          Expanded(child: card3),
        ],
      );
    } else {
      return Column(
        children: const [
          card1,
          SizedBox(height: AppSpacing.md),
          card2,
          SizedBox(height: AppSpacing.md),
          card3,
        ],
      );
    }
  }

  Widget _buildRecentActivity(BuildContext context, bool isDesktop) {
    final entries = MockData.initialEntries;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Card Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Recent activity',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your five most recent practice entries',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.entries);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View all entries',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Entries Table / List
          if (isDesktop)
            _buildDesktopTable(context, entries)
          else
            _buildMobileEntriesList(context, entries),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, List<PracticeEntry> entries) {
    return Column(
      children: [
        // Table Header
        Container(
          color: AppColors.surfaceMuted,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: const [
              SizedBox(
                width: 130,
                child: Text(
                  'DATE',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'TASK',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  'HOURS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(
                width: 130,
                child: Text(
                  'STATUS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ACTION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Table Rows
        ...entries.map((entry) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        entry.date,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${entry.hours} hrs',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusBadge(status: entry.status),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.entryForm);
                          },
                          child: const Text(
                            'View details',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMobileEntriesList(BuildContext context, List<PracticeEntry> entries) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          title: Text(
            entry.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${entry.date} · ${entry.hours} hrs',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              StatusBadge(status: entry.status),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(AppRoutes.entryForm);
          },
        );
      },
    );
  }
}
