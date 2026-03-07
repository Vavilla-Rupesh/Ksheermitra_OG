import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// KsheerMitra Premium Button System — Blue Ecosystem
/// Modern, accessible, min 44px height, 10px radius
/// Scale 0.97 on press for premium micro-interaction

// ============================================================================
// PRIMARY BUTTON - Main CTA with blue #2563EB
// Height: 44px, Radius: 10px, Bold text, Scale animation on press
// ============================================================================

class DairyPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const DairyPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = DairySpacing.touchTarget,
    this.width,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<DairyPrimaryButton> createState() => _DairyPrimaryButtonState();
}

class _DairyPrimaryButtonState extends State<DairyPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final bgColor = widget.backgroundColor ?? colors.primary;
    final fgColor = widget.foregroundColor ?? colors.textOnPrimary;
    final disabledBgColor = isDark
        ? DairyColorsDark.textDisabled
        : DairyColorsLight.textDisabled;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: isEnabled ? bgColor : disabledBgColor,
                borderRadius: DairyRadius.buttonBorderRadius,
                boxShadow: isEnabled && !isDark ? colors.buttonShadow : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: DairyRadius.buttonBorderRadius,
                  splashColor: fgColor.withOpacity(0.1),
                  highlightColor: fgColor.withOpacity(0.05),
                  child: Padding(
                    padding: widget.padding ?? DairySpacing.buttonInternalPadding,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.leadingIcon != null) ...[
                                  Icon(
                                    widget.leadingIcon,
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    size: 20,
                                  ),
                                  const SizedBox(width: DairySpacing.sm),
                                ],
                                Text(
                                  widget.text,
                                  style: DairyTypography.button(
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    isDark: isDark,
                                  ),
                                ),
                                if (widget.trailingIcon != null) ...[
                                  const SizedBox(width: DairySpacing.sm),
                                  Icon(
                                    widget.trailingIcon,
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SECONDARY BUTTON - Outlined style for secondary actions
// White bg, border #CBD5E1, primary text
// ============================================================================

class DairySecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double? width;
  final Color? borderColor;
  final Color? textColor;

  const DairySecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = DairySpacing.touchTarget,
    this.width,
    this.borderColor,
    this.textColor,
  });

  @override
  State<DairySecondaryButton> createState() => _DairySecondaryButtonState();
}

class _DairySecondaryButtonState extends State<DairySecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // In dark mode, use white border/text; in light mode, use primary green
    final color = widget.borderColor ??
        (isDark ? colors.textPrimary : colors.primary);
    final fgColor = widget.textColor ?? color;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (isEnabled) _animationController.forward();
            },
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: isDark ? Colors.transparent : Colors.white,
                borderRadius: DairyRadius.buttonBorderRadius,
                border: Border.all(
                  color: isEnabled ? (widget.borderColor ?? colors.border) : colors.border.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: DairyRadius.buttonBorderRadius,
                  splashColor: color.withOpacity(0.1),
                  highlightColor: color.withOpacity(0.05),
                  child: Padding(
                    padding: DairySpacing.buttonInternalPadding,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.leadingIcon != null) ...[
                                  Icon(
                                    widget.leadingIcon,
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    size: 20,
                                  ),
                                  const SizedBox(width: DairySpacing.sm),
                                ],
                                Text(
                                  widget.text,
                                  style: DairyTypography.button(
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    isDark: isDark,
                                  ),
                                ),
                                if (widget.trailingIcon != null) ...[
                                  const SizedBox(width: DairySpacing.sm),
                                  Icon(
                                    widget.trailingIcon,
                                    color: isEnabled
                                        ? fgColor
                                        : fgColor.withOpacity(0.4),
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// TEXT BUTTON - For tertiary/less important actions
// ============================================================================

class DairyTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? textColor;
  final bool isUnderlined;

  const DairyTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.textColor,
    this.isUnderlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final color = textColor ?? colors.primary;
    final isEnabled = onPressed != null;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(64, DairySpacing.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(
              leadingIcon,
              size: 18,
              color: isEnabled ? color : color.withOpacity(0.4),
            ),
            const SizedBox(width: DairySpacing.xs),
          ],
          Text(
            text,
            style: DairyTypography.button(
              color: isEnabled ? color : color.withOpacity(0.4),
              isDark: isDark,
            ).copyWith(
              decoration: isUnderlined ? TextDecoration.underline : null,
              decorationColor: color,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: DairySpacing.xs),
            Icon(
              trailingIcon,
              size: 18,
              color: isEnabled ? color : color.withOpacity(0.4),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// ICON BUTTON - Circular icon button with touch feedback
// ============================================================================

class DairyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const DairyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = DairySpacing.touchTarget,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    final fgColor = iconColor ?? colors.textPrimary;
    final bgColor = backgroundColor ?? Colors.transparent;
    final isEnabled = onPressed != null;

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(
              icon,
              color: isEnabled ? fgColor : fgColor.withOpacity(0.4),
              size: iconSize,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// ============================================================================
// CTA BUTTON - Special accent button for high-conversion actions
// Uses secondary color for maximum visibility
// ============================================================================

class DairyCtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;

  const DairyCtaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height = DairySpacing.touchTarget,
  });

  @override
  State<DairyCtaButton> createState() => _DairyCtaButtonState();
}

class _DairyCtaButtonState extends State<DairyCtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final bgColor = colors.secondary;
    final fgColor = colors.textOnSecondary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (isEnabled) _animationController.forward();
            },
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: widget.height,
              decoration: BoxDecoration(
                color: isEnabled ? bgColor : bgColor.withOpacity(0.5),
                borderRadius: DairyRadius.buttonBorderRadius,
                boxShadow: isEnabled && !isDark
                    ? [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: DairyRadius.buttonBorderRadius,
                  child: Padding(
                    padding: DairySpacing.buttonInternalPadding,
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.leadingIcon != null) ...[
                                  Icon(widget.leadingIcon, color: fgColor, size: 20),
                                  const SizedBox(width: DairySpacing.sm),
                                ],
                                Text(
                                  widget.text,
                                  style: DairyTypography.button(
                                    color: fgColor,
                                    isDark: isDark,
                                  ),
                                ),
                                if (widget.trailingIcon != null) ...[
                                  const SizedBox(width: DairySpacing.sm),
                                  Icon(widget.trailingIcon, color: fgColor, size: 20),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// DANGER BUTTON - For destructive actions (#EF4444)
// ============================================================================

class DairyDangerButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final double height;

  const DairyDangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.height = DairySpacing.touchTarget,
  });

  @override
  State<DairyDangerButton> createState() => _DairyDangerButtonState();
}

class _DairyDangerButtonState extends State<DairyDangerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    const dangerColor = Color(0xFFEF4444);

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: GestureDetector(
            onTapDown: (_) { if (isEnabled) _controller.forward(); },
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: widget.height,
              decoration: BoxDecoration(
                color: isEnabled ? dangerColor : dangerColor.withOpacity(0.5),
                borderRadius: DairyRadius.buttonBorderRadius,
                boxShadow: isEnabled && !isDark
                    ? [BoxShadow(color: dangerColor.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? widget.onPressed : null,
                  borderRadius: DairyRadius.buttonBorderRadius,
                  child: Padding(
                    padding: DairySpacing.buttonInternalPadding,
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.leadingIcon != null) ...[
                                  Icon(widget.leadingIcon, color: Colors.white, size: 20),
                                  const SizedBox(width: DairySpacing.sm),
                                ],
                                Text(widget.text, style: DairyTypography.button(color: Colors.white, isDark: isDark)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SMALL BUTTON - Compact button for tight spaces
// ============================================================================

class DairySmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final Color? color;

  const DairySmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final isEnabled = onPressed != null;

    final bgColor = isPrimary
        ? (color ?? colors.primary)
        : Colors.transparent;
    final fgColor = isPrimary
        ? colors.textOnPrimary
        : (color ?? colors.primary);
    final borderColor = isPrimary ? null : (color ?? colors.primary);

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? bgColor : bgColor.withOpacity(0.5),
        borderRadius: DairyRadius.smallBorderRadius,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: DairyRadius.smallBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fgColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  text,
                  style: DairyTypography.label(color: fgColor, isDark: isDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FLOATING ADD BUTTON - For quick add actions in product cards
// ============================================================================

class DairyAddButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double size;

  const DairyAddButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    final canTap = onPressed != null && isEnabled;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: canTap ? colors.primary : colors.textDisabled,
        borderRadius: DairyRadius.smallBorderRadius,
        boxShadow: canTap && !context.isDarkMode
            ? [
                BoxShadow(
                  color: colors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onPressed : null,
          borderRadius: DairyRadius.smallBorderRadius,
          child: Icon(
            Icons.add,
            color: colors.textOnPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

