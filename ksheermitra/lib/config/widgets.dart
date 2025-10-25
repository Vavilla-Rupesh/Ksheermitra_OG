import 'package:flutter/material.dart';
import 'dart:ui';
import 'theme.dart';

/// Premium reusable widgets following the Ksheermitra Design System

// ==================== BUTTONS ====================

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient? gradient;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonGradient = gradient ?? AppTheme.primaryButtonGradient;
    final height = _getHeight();
    final fontSize = _getFontSize();

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 2),
                    const SizedBox(width: AppTheme.space8),
                  ],
                  Text(
                    text,
                    style: AppTheme.buttonText.copyWith(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.large:
        return 56;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.small:
        return 40;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.large:
        return 16;
      case ButtonSize.medium:
        return 15;
      case ButtonSize.small:
        return 14;
    }
  }
}

enum ButtonSize { small, medium, large }

// ==================== CARDS ====================

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final bool isPremium;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? AppTheme.cardColor : null,
      borderRadius: BorderRadius.circular(
        isPremium ? AppTheme.radiusXLarge : AppTheme.radiusLarge,
      ),
      boxShadow: isPremium ? AppTheme.premiumCardShadow : AppTheme.cardShadow,
    );

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.space16),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            isPremium ? AppTheme.radiusXLarge : AppTheme.radiusLarge,
          ),
          splashColor: AppTheme.primaryColor.withOpacity(0.1),
          highlightColor: AppTheme.primaryColor.withOpacity(0.05),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

class ProductCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.productCardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.productCardShadow(AppTheme.primaryColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          splashColor: AppTheme.primaryColor.withOpacity(0.1),
          highlightColor: AppTheme.primaryColor.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==================== STATUS BADGES ====================

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType status;

  const StatusBadge({
    super.key,
    required this.text,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (status) {
      case StatusType.active:
        return AppTheme.activeGradient;
      case StatusType.pending:
        return AppTheme.pendingGradient;
      case StatusType.delivered:
        return AppTheme.deliveredGradient;
      case StatusType.cancelled:
        return AppTheme.dangerButtonGradient;
    }
  }

  Color _getColor() {
    switch (status) {
      case StatusType.active:
        return AppTheme.successGreen;
      case StatusType.pending:
        return AppTheme.warningOrange;
      case StatusType.delivered:
        return AppTheme.primaryColor;
      case StatusType.cancelled:
        return AppTheme.errorRed;
    }
  }
}

enum StatusType { active, pending, delivered, cancelled }

// ==================== APP BAR ====================

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGradient;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      flexibleSpace: showGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.appBarGradient,
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ==================== INPUT FIELD ====================

class PremiumTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const PremiumTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.primaryColor)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: AppTheme.primaryColor),
                onPressed: onSuffixIconTap,
              )
            : null,
      ),
    );
  }
}

// ==================== LOADING INDICATOR ====================

class PremiumLoadingIndicator extends StatelessWidget {
  final String? message;

  const PremiumLoadingIndicator({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.space16),
            Text(
              message!,
              style: AppTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== EMPTY STATE ====================

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppTheme.space24),
            Text(
              title,
              style: AppTheme.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space12),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppTheme.space24),
              PremiumButton(
                text: actionText!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== GLASSMORPHISM CONTAINER ====================

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }
}

// ==================== SECTION HEADER ====================

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.h4),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.space4),
                  Text(subtitle!, style: AppTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ==================== GRADIENT BACKGROUND ====================

class GradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.mainBackground,
      ),
      child: child,
    );
  }
}

// ==================== PRICE DISPLAY ====================

class PriceDisplay extends StatelessWidget {
  final double amount;
  final String currency;
  final bool showCurrency;

  const PriceDisplay({
    super.key,
    required this.amount,
    this.currency = '₹',
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      showCurrency ? '$currency${amount.toStringAsFixed(2)}' : amount.toStringAsFixed(2),
      style: AppTheme.priceText,
    );
  }
}

