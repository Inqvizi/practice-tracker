import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Eyebrow section label (uppercase, letter-spaced, bold, discrete).
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: color ?? AppColors.primary,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.3,
      ),
    );
  }
}
