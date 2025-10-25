import 'package:flutter/material.dart';
import '../config/theme.dart';

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
      gradient: AppTheme.activeGradient,
      textColor: AppTheme.textOnPrimary,
      icon: Icons.check_circle,
    );
  }

  factory PremiumBadge.pending(String text) {
    return PremiumBadge(
      text: text,
      gradient: AppTheme.pendingGradient,
      textColor: AppTheme.textOnPrimary,
      icon: Icons.schedule,
    );
  }

  factory PremiumBadge.delivered(String text) {
    return PremiumBadge(
      text: text,
      gradient: AppTheme.deliveredGradient,
      textColor: AppTheme.textOnPrimary,
      icon: Icons.done_all,
    );
  }

  factory PremiumBadge.error(String text) {
    return PremiumBadge(
      text: text,
      backgroundColor: AppTheme.errorRed,
      textColor: AppTheme.textOnPrimary,
      icon: Icons.error,
    );
  }

  factory PremiumBadge.info(String text) {
    return PremiumBadge(
      text: text,
      backgroundColor: AppTheme.infoBlue,
      textColor: AppTheme.textOnPrimary,
      icon: Icons.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.space12,
            vertical: AppTheme.space8,
          ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppTheme.primaryColor)
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
              color: textColor ?? AppTheme.textOnPrimary,
            ),
            const SizedBox(width: AppTheme.space4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppTheme.textOnPrimary,
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
    this.backgroundColor = AppTheme.primaryColor,
    this.textColor = AppTheme.textOnPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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

