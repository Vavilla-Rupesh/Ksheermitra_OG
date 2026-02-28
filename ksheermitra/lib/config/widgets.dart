import 'package:flutter/material.dart';
import 'dart:ui';
import 'dairy_theme.dart';

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
    final buttonGradient = gradient ?? const LinearGradient(
      colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
    );
    final height = _getHeight();
    final fontSize = _getFontSize();

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: buttonGradient,
        borderRadius: DairyRadius.defaultBorderRadius,
        boxShadow: DairyColorsLight.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: DairyRadius.defaultBorderRadius,
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
                    const SizedBox(width: DairySpacing.sm),
                  ],
                  Text(
                    text,
                    style: DairyTypography.button().copyWith(fontSize: fontSize),
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
      color: gradient == null ? DairyColorsLight.card : null,
      borderRadius: isPremium ? DairyRadius.xlBorderRadius : DairyRadius.largeBorderRadius,
      boxShadow: isPremium ? DairyColorsLight.elevatedShadow : DairyColorsLight.cardShadow,
    );

    final content = Container(
      padding: padding ?? const EdgeInsets.all(DairySpacing.md),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: isPremium ? DairyRadius.xlBorderRadius : DairyRadius.largeBorderRadius,
          splashColor: DairyColorsLight.primary.withValues(alpha: 0.1),
          highlightColor: DairyColorsLight.primary.withValues(alpha: 0.05),
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
        color: DairyColorsLight.card,
        borderRadius: DairyRadius.largeBorderRadius,
        boxShadow: DairyColorsLight.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: DairyRadius.largeBorderRadius,
          splashColor: DairyColorsLight.primary.withValues(alpha: 0.1),
          highlightColor: DairyColorsLight.primary.withValues(alpha: 0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(DairySpacing.md),
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
        horizontal: DairySpacing.sm + 4,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: DairyRadius.pillBorderRadius,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
        return const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)]);
      case StatusType.pending:
        return const LinearGradient(colors: [DairyColorsLight.warning, Color(0xFFFFB74D)]);
      case StatusType.delivered:
        return const LinearGradient(colors: [DairyColorsLight.primary, DairyColorsLight.primaryLight]);
      case StatusType.cancelled:
        return const LinearGradient(colors: [DairyColorsLight.error, Color(0xFFE53935)]);
    }
  }

  Color _getColor() {
    switch (status) {
      case StatusType.active:
        return DairyColorsLight.success;
      case StatusType.pending:
        return DairyColorsLight.warning;
      case StatusType.delivered:
        return DairyColorsLight.primary;
      case StatusType.cancelled:
        return DairyColorsLight.error;
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
                gradient: LinearGradient(
                  colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
                ),
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
      style: DairyTypography.bodyLarge(),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: DairyColorsLight.primary)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: DairyColorsLight.primary),
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
            color: DairyColorsLight.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: DairySpacing.md),
            Text(
              message!,
              style: DairyTypography.body(),
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
        padding: const EdgeInsets.all(DairySpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: DairyColorsLight.textTertiary,
            ),
            const SizedBox(height: DairySpacing.lg),
            Text(
              title,
              style: DairyTypography.headingSmall(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DairySpacing.sm + 4),
            Text(
              message,
              style: DairyTypography.body(),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: DairySpacing.lg),
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
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: borderRadius ?? DairyRadius.xlBorderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? DairyRadius.xlBorderRadius,
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
        horizontal: DairySpacing.md,
        vertical: DairySpacing.sm + 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DairyTypography.headingSmall()),
                if (subtitle != null) ...[
                  const SizedBox(height: DairySpacing.xs),
                  Text(subtitle!, style: DairyTypography.bodySmall()),
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
        gradient: gradient ?? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F8E8), // primarySurface
            DairyColorsLight.background,
            DairyColorsLight.surface,
          ],
        ),
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
      style: DairyTypography.price(),
    );
  }
}
