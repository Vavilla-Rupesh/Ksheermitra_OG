import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Gradient Button with shadow and animation
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 56.0,
    this.borderRadius = DairyRadius.md,
    this.padding,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors.primary, colors.primaryLight],
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? (widget.gradient ?? defaultGradient)
                  : const LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                    ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: isEnabled ? colors.buttonShadow : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled
                    ? () {
                        _controller.forward().then((_) => _controller.reverse());
                        widget.onPressed?.call();
                      }
                    : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Padding(
                  padding: widget.padding ??
                      const EdgeInsets.symmetric(horizontal: DairySpacing.lg),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: colors.textOnPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: DairySpacing.sm),
                              ],
                              Text(
                                widget.text,
                                style: DairyTypography.button(isDark: isDark),
                              ),
                            ],
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

/// Secondary Outline Button with premium styling
class PremiumOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;

  const PremiumOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();
    final buttonColor = color ?? colors.primary;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DairyRadius.md),
        border: Border.all(color: buttonColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DairyRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DairySpacing.lg),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: buttonColor, size: 20),
                    const SizedBox(width: DairySpacing.sm),
                  ],
                  Text(
                    text,
                    style: DairyTypography.button(isDark: isDark).copyWith(color: buttonColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text Button with premium styling
class PremiumTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const PremiumTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? DairyColors.dark() : DairyColors.light();
    final buttonColor = color ?? colors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(
          horizontal: DairySpacing.md,
          vertical: DairySpacing.sm,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: DairySpacing.sm),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: buttonColor,
            ),
          ),
        ],
      ),
    );
  }
}

