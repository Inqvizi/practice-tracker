import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable application brand logo widget.
/// Supports dark mode or light tile mode (e.g., inside the dark registration hero panel).
class AppLogo extends StatelessWidget {
  final bool inverted;
  final double iconSize;
  final double fontSize;

  const AppLogo({
    super.key,
    this.inverted = false,
    this.iconSize = 36.0,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = inverted ? AppColors.textLight : AppColors.textPrimary;
    final trackerColor = inverted ? AppColors.sidebarActive : AppColors.primary;
    final tileColor = inverted ? AppColors.surface : AppColors.primary;
    final iconColor = inverted ? AppColors.primary : AppColors.textLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            boxShadow: inverted
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.trending_up_rounded,
              color: iconColor,
              size: iconSize * 0.6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Practice',
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                height: 1.1,
              ),
            ),
            Text(
              'TRACKER',
              style: TextStyle(
                color: trackerColor,
                fontSize: fontSize * 0.6,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
