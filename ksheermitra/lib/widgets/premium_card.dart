import 'package:flutter/material.dart';
import '../config/theme.dart';

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
    this.borderRadius = AppTheme.radiusLarge,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (backgroundColor ?? AppTheme.cardColor) : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppTheme.cardShadow,
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
    return PremiumCard(
      gradient: AppTheme.productCardGradient,
      shadows: AppTheme.productCardShadow(AppTheme.primaryColor),
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
    return PremiumCard(
      gradient: isPremium ? AppTheme.premiumCardGradient : null,
      shadows: isPremium ? AppTheme.premiumCardShadow : AppTheme.cardShadow,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}
