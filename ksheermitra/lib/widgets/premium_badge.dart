import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Status Badge with gradient
class PremiumBadge extends StatelessWidget {
  final String text;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const PremiumBadge({
    super.key,
    required this.text,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.fontSize = 12.0,
    this.padding,
  });

  factory PremiumBadge.active(String text) {
    return PremiumBadge(
      text: text,
      gradient: const LinearGradient(
        colors: [DairyColorsLight.success, Color(0xFF16A34A)],
      ),
      textColor: DairyColorsLight.textOnPrimary,
      icon: Icons.check_circle,
    );
  }

  factory PremiumBadge.pending(String text) {
    return PremiumBadge(
      text: text,
      gradient: const LinearGradient(
        colors: [DairyColorsLight.warning, Color(0xFFD97706)],
      ),
      textColor: DairyColorsLight.textOnPrimary,
      icon: Icons.schedule,
    );
  }

  factory PremiumBadge.delivered(String text) {
    return PremiumBadge(
      text: text,
      gradient: const LinearGradient(
        colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
      ),
      textColor: DairyColorsLight.textOnPrimary,
      icon: Icons.done_all,
    );
  }

  factory PremiumBadge.error(String text) {
    return PremiumBadge(
      text: text,
      backgroundColor: DairyColorsLight.error,
      textColor: DairyColorsLight.textOnPrimary,
      icon: Icons.error,
    );
  }

  factory PremiumBadge.info(String text) {
    return PremiumBadge(
      text: text,
      backgroundColor: DairyColorsLight.info,
      textColor: DairyColorsLight.textOnPrimary,
      icon: Icons.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: DairySpacing.sm,
            vertical: DairySpacing.xs,
          ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(DairyRadius.pill),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? DairyColorsLight.primary)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: textColor ?? DairyColorsLight.textOnPrimary,
            ),
            const SizedBox(width: DairySpacing.xs),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor ?? DairyColorsLight.textOnPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Badge without icon
class CompactBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const CompactBadge({
    super.key,
    required this.text,
    this.backgroundColor = DairyColorsLight.primary,
    this.textColor = DairyColorsLight.textOnPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DairySpacing.sm,
        vertical: DairySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DairyRadius.sm),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

