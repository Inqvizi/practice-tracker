import 'package:flutter/material.dart';
import '../models/practice_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Status badge pill with a colored indicator dot (Done / In progress).
class StatusBadge extends StatelessWidget {
  final PracticeStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == PracticeStatus.done;
    final bgColor = isDone
        ? AppColors.statusDoneBackground
        : AppColors.statusProgressBackground;
    final textColor = isDone
        ? AppColors.statusDoneText
        : AppColors.statusProgressText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
