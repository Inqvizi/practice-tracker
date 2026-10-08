import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Skill chip pill widget displaying an acquired technical skill.
/// Supports an optional onDeleted callback for entry edit forms.
class SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;

  const SkillChip({
    super.key,
    required this.label,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm + 2,
        right: onDeleted != null ? 4 : AppSpacing.sm + 2,
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.chipText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 2),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.chipText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
