import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Card Widget with gradient, shadow, and smooth animations
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final double borderRadius;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.backgroundColor,
    this.shadows,
    this.borderRadius = DairyRadius.lg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();

    final content = Container(
      padding: padding ?? const EdgeInsets.all(DairySpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (backgroundColor ?? colors.card) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? colors.cardShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Premium Card with Product Gradient
class ProductCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();

    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.card,
          colors.primarySurface,
        ],
      ),
      shadows: [
        BoxShadow(
          color: colors.primary.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}

/// Premium Subscription Card with special styling
class SubscriptionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isPremium;

  const SubscriptionCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();

    return PremiumCard(
      gradient: isPremium ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.primary,
          colors.primaryLight,
        ],
      ) : null,
      shadows: isPremium ? [
        BoxShadow(
          color: colors.primary.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ] : colors.cardShadow,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}
