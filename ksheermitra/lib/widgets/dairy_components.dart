import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/dairy_theme.dart';

/// KsheerMitra Premium UI Components
/// Modern inputs, navigation, and utility widgets
/// Following Material 3 guidelines with clean aesthetics

// ============================================================================
// PREMIUM INPUT FIELD
// ============================================================================

class DairyTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;

  const DairyTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: DairyTypography.label(isDark: isDark),
          ),
          const SizedBox(height: DairySpacing.sm),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: DairyTypography.bodyLarge(isDark: isDark),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: DairySpacing.md,
              vertical: DairySpacing.buttonPaddingV,
            ),
            filled: true,
            fillColor: enabled
                ? colors.surface
                : colors.surfaceVariant.withOpacity(0.5),
            hintStyle: DairyTypography.body(
              color: colors.textTertiary,
              isDark: isDark,
            ),
            errorStyle: DairyTypography.caption(
              color: colors.error,
              isDark: isDark,
            ),
            border: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: DairyRadius.defaultBorderRadius,
              borderSide: BorderSide(color: colors.borderLight),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SEARCH INPUT FIELD
// ============================================================================

class DairySearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const DairySearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Container(
      height: DairySpacing.touchTarget,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: DairyRadius.defaultBorderRadius,
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: DairyTypography.body(isDark: isDark),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: DairyTypography.body(
            color: colors.textTertiary,
            isDark: isDark,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DairySpacing.md,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colors.textTertiary,
            size: 22,
          ),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM BOTTOM NAVIGATION BAR
// ============================================================================

class DairyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DairyNavItem> items;

  const DairyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: DairySpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: DairySpacing.md,
                            vertical: DairySpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primarySurface
                                : Colors.transparent,
                            borderRadius: DairyRadius.pillBorderRadius,
                          ),
                          child: Icon(
                            isSelected
                                ? item.activeIcon ?? item.icon
                                : item.icon,
                            color: isSelected
                                ? colors.primary
                                : colors.textTertiary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: DairyTypography.navLabel(
                            color: isSelected
                                ? colors.primary
                                : colors.textTertiary,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class DairyNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const DairyNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

// ============================================================================
// PREMIUM APP BAR
// ============================================================================

class DairyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;

  const DairyAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? colors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      leading: leading ??
          (showBackButton && canPop
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.textPrimary,
                    size: 20,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: DairyTypography.headingSmall(isDark: isDark),
                )
              : null),
      actions: actions,
    );
  }
}

// ============================================================================
// LOADING INDICATOR
// ============================================================================

class DairyLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? message;

  const DairyLoadingIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    final isDark = context.isDarkMode;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? colors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: DairySpacing.md),
            Text(
              message!,
              style: DairyTypography.body(isDark: isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class DairyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DairyEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Center(
      child: Padding(
        padding: DairySpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: DairySpacing.lg),
            Text(
              title,
              style: DairyTypography.headingMedium(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: DairySpacing.sm),
              Text(
                subtitle!,
                style: DairyTypography.body(isDark: isDark),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DairySpacing.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SHIMMER LOADING EFFECT
// ============================================================================

class DairyShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const DairyShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = DairyRadius.sm,
  });

  @override
  State<DairyShimmer> createState() => _DairyShimmerState();
}

class _DairyShimmerState extends State<DairyShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
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
    final baseColor = isDark
        ? DairyColorsDark.surfaceVariant
        : DairyColorsLight.surfaceVariant;
    final highlightColor = isDark
        ? DairyColorsDark.surface
        : DairyColorsLight.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// QUANTITY SELECTOR
// ============================================================================

class DairyQuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int minQuantity;
  final int maxQuantity;
  final double height;

  const DairyQuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
    this.height = 36,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: DairyRadius.smallBorderRadius,
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onTap: quantity > minQuantity
                ? () => onChanged(quantity - 1)
                : null,
            colors: colors,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: DairyTypography.bodyLarge(isDark: isDark),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onTap: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
    required DairyColors colors,
  }) {
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: DairyRadius.smallBorderRadius,
      child: Container(
        width: 36,
        height: double.infinity,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? colors.textPrimary : colors.textDisabled,
        ),
      ),
    );
  }
}

// ============================================================================
// AVATAR COMPONENT
// ============================================================================

class DairyAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;

  const DairyAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final bgColor = backgroundColor ?? colors.primarySurface;
    final fgColor = foregroundColor ?? colors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(fgColor, isDark),
            )
          : _buildPlaceholder(fgColor, isDark),
    );
  }

  Widget _buildPlaceholder(Color fgColor, bool isDark) {
    if (initials != null) {
      return Center(
        child: Text(
          initials!.toUpperCase(),
          style: DairyTypography.label(color: fgColor, isDark: isDark),
        ),
      );
    }
    return Icon(
      icon ?? Icons.person,
      color: fgColor,
      size: size * 0.5,
    );
  }
}

// ============================================================================
// CHIP COMPONENT
// ============================================================================

class DairyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? selectedColor;

  const DairyChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final accentColor = selectedColor ?? colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : colors.surface,
          borderRadius: DairyRadius.pillBorderRadius,
          border: Border.all(
            color: isSelected ? accentColor : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.textOnPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: DairyTypography.label(
                color: isSelected ? colors.textOnPrimary : colors.textPrimary,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SNACKBAR HELPER
// ============================================================================

class DairySnackbar {
  static void show(
    BuildContext context, {
    required String message,
    DairySnackbarType type = DairySnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = context.dairyColors;

    Color backgroundColor;
    Color textColor = DairyColorsLight.textOnPrimary;
    IconData icon;

    switch (type) {
      case DairySnackbarType.success:
        backgroundColor = colors.success;
        icon = Icons.check_circle;
        break;
      case DairySnackbarType.error:
        backgroundColor = colors.error;
        icon = Icons.error;
        break;
      case DairySnackbarType.warning:
        backgroundColor = colors.warning;
        icon = Icons.warning;
        break;
      case DairySnackbarType.info:
        backgroundColor = colors.textPrimary;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: DairySpacing.sm),
            Expanded(
              child: Text(
                message,
                style: DairyTypography.body(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        margin: const EdgeInsets.all(DairySpacing.md),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: textColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}

enum DairySnackbarType { success, error, warning, info }

