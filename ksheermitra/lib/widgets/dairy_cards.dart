import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';
import 'dairy_buttons.dart';

/// KsheerMitra Premium Card System — Blue Ecosystem
/// Stripe-inspired card designs with hover lift animations
/// Radius: 16px, Padding: 24px, Premium shadows

// ============================================================================
// BASE DAIRY CARD - Foundation for all cards
// Hover: translateY(-4px), enhanced shadow, 0.25s ease
// ============================================================================

class DairyCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;
  final bool enableLiftEffect;

  const DairyCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = DairyRadius.lg,
    this.showBorder = true,
    this.showShadow = true,
    this.enableLiftEffect = true,
  });

  @override
  State<DairyCard> createState() => _DairyCardState();
}

class _DairyCardState extends State<DairyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _liftController;
  late Animation<double> _liftAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _liftController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _liftAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _liftController, curve: Curves.easeOut),
    );
    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _liftController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _liftController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    if (widget.enableLiftEffect && widget.onTap != null) {
      _liftController.forward();
    }
  }

  void _onHoverEnd() {
    if (widget.enableLiftEffect && widget.onTap != null) {
      _liftController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    final bgColor = widget.backgroundColor ?? colors.card;
    final borderCol = widget.borderColor ?? colors.border;

    return AnimatedBuilder(
      animation: _liftController,
      builder: (context, child) {
        final normalShadow = widget.showShadow && !isDark ? colors.cardShadow : <BoxShadow>[];
        final hoverShadow = widget.showShadow && !isDark ? colors.cardHoverShadow : <BoxShadow>[];

        // Interpolate shadow
        final currentShadow = _shadowAnimation.value == 0.0
            ? normalShadow
            : hoverShadow;

        final content = Container(
          padding: widget.padding ?? DairySpacing.cardContentPadding,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.showBorder || isDark
                ? Border.all(color: borderCol, width: 1)
                : null,
            boxShadow: currentShadow,
          ),
          child: widget.child,
        );

        final transformed = Transform.translate(
          offset: Offset(0, _liftAnimation.value),
          child: content,
        );

        if (widget.onTap != null) {
          return GestureDetector(
            onTapDown: (_) => _onHoverStart(),
            onTapUp: (_) {
              _onHoverEnd();
              widget.onTap?.call();
            },
            onTapCancel: () => _onHoverEnd(),
            onLongPressStart: (_) => _onHoverStart(),
            onLongPressEnd: (_) => _onHoverEnd(),
            child: MouseRegion(
              onEnter: (_) => _onHoverStart(),
              onExit: (_) => _onHoverEnd(),
              child: transformed,
            ),
          );
        }

        return transformed;
      },
    );
  }
}

// ============================================================================
// ELEVATED DAIRY CARD - Card with more prominent shadow + lift
// ============================================================================

class DairyElevatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;

  const DairyElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = DairyRadius.lg,
  });

  @override
  State<DairyElevatedCard> createState() => _DairyElevatedCardState();
}

class _DairyElevatedCardState extends State<DairyElevatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _lift = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    final colors = context.dairyColors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _lift.value),
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? colors.card,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: isDark ? Border.all(color: colors.border, width: 1) : Border.all(color: colors.border, width: 1),
              boxShadow: !isDark ? (_controller.value > 0 ? colors.cardHoverShadow : colors.elevatedShadow) : null,
            ),
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) {
                _controller.reverse();
                widget.onTap?.call();
              },
              onTapCancel: () => _controller.reverse(),
              child: MouseRegion(
                onEnter: (_) => _controller.forward(),
                onExit: (_) => _controller.reverse(),
                child: Padding(
                  padding: widget.padding ?? DairySpacing.cardContentPadding,
                  child: widget.child,
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
// PRODUCT CARD - For displaying dairy products in grids/lists
// Modern grocery app design with image, name, price, and CTA
// ============================================================================

class DairyProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String? unit;
  final String? description;
  final String? imageUrl;
  final Widget? imageWidget;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final bool showAddButton;
  final bool isOutOfStock;
  final String? badge;
  final Color? badgeColor;
  final double? imageHeight;

  const DairyProductCard({
    super.key,
    required this.name,
    required this.price,
    this.unit,
    this.description,
    this.imageUrl,
    this.imageWidget,
    this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
    this.isOutOfStock = false,
    this.badge,
    this.badgeColor,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return DairyCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DairyRadius.lg),
                ),
                child: Container(
                  height: imageHeight ?? 140,
                  width: double.infinity,
                  color: isDark
                      ? colors.surfaceVariant
                      : colors.surface,
                  child: imageWidget ??
                      (imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(colors),
                            )
                          : _buildPlaceholder(colors)),
                ),
              ),
              // Out of stock overlay
              if (isOutOfStock)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DairyRadius.lg),
                    ),
                    child: Container(
                      color: colors.background.withOpacity(0.7),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DairySpacing.md,
                            vertical: DairySpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: DairyRadius.pillBorderRadius,
                          ),
                          child: Text(
                            'Out of Stock',
                            style: DairyTypography.badge(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Badge (e.g., "Fresh", "Sale", "New")
              if (badge != null && !isOutOfStock)
                Positioned(
                  top: DairySpacing.sm,
                  left: DairySpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DairySpacing.sm,
                      vertical: DairySpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? colors.primary,
                      borderRadius: DairyRadius.smallBorderRadius,
                    ),
                    child: Text(
                      badge!,
                      style: DairyTypography.badge(),
                    ),
                  ),
                ),
            ],
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(DairySpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  name,
                  style: DairyTypography.productName(isDark: isDark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (description != null) ...[
                  const SizedBox(height: DairySpacing.xs),
                  Text(
                    description!,
                    style: DairyTypography.caption(isDark: isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: DairySpacing.sm),

                // Price and Add Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹$price',
                            style: DairyTypography.price(isDark: isDark),
                          ),
                          if (unit != null)
                            Text(
                              unit!,
                              style: DairyTypography.caption(isDark: isDark),
                            ),
                        ],
                      ),
                    ),

                    // Add Button
                    if (showAddButton)
                      DairyAddButton(
                        onPressed: onAddPressed,
                        isEnabled: !isOutOfStock,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(DairyColors colors) {
    return Center(
      child: Icon(
        Icons.local_drink_outlined,
        size: 48,
        color: colors.textTertiary.withOpacity(0.5),
      ),
    );
  }
}

// ============================================================================
// HORIZONTAL PRODUCT CARD - Compact horizontal layout
// ============================================================================

class DairyProductCardHorizontal extends StatelessWidget {
  final String name;
  final String price;
  final String? unit;
  final String? description;
  final String? imageUrl;
  final Widget? imageWidget;
  final VoidCallback? onTap;
  final VoidCallback? onAddPressed;
  final bool showAddButton;
  final bool isOutOfStock;

  const DairyProductCardHorizontal({
    super.key,
    required this.name,
    required this.price,
    this.unit,
    this.description,
    this.imageUrl,
    this.imageWidget,
    this.onTap,
    this.onAddPressed,
    this.showAddButton = true,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return DairyCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DairySpacing.sm),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: DairyRadius.defaultBorderRadius,
            child: Container(
              width: 80,
              height: 80,
              color: colors.surface,
              child: imageWidget ??
                  (imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.local_drink_outlined,
                            size: 32,
                            color: colors.textTertiary,
                          ),
                        )
                      : Icon(
                          Icons.local_drink_outlined,
                          size: 32,
                          color: colors.textTertiary,
                        )),
            ),
          ),

          const SizedBox(width: DairySpacing.md),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: DairyTypography.productName(isDark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: DairyTypography.caption(isDark: isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: DairySpacing.xs),
                Row(
                  children: [
                    Text(
                      '₹$price',
                      style: DairyTypography.price(isDark: isDark),
                    ),
                    if (unit != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '/$unit',
                        style: DairyTypography.caption(isDark: isDark),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Add Button
          if (showAddButton)
            DairyAddButton(
              onPressed: onAddPressed,
              isEnabled: !isOutOfStock,
              size: 36,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUBSCRIPTION CARD - For displaying active subscriptions
// ============================================================================

class DairySubscriptionCard extends StatelessWidget {
  final String productName;
  final String quantity;
  final String frequency;
  final String status;
  final String? nextDelivery;
  final String? price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onEdit;
  final bool isPaused;

  const DairySubscriptionCard({
    super.key,
    required this.productName,
    required this.quantity,
    required this.frequency,
    required this.status,
    this.nextDelivery,
    this.price,
    this.imageUrl,
    this.onTap,
    this.onPause,
    this.onEdit,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return DairyElevatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with status badge
          Row(
            children: [
              // Product image (small)
              if (imageUrl != null)
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(right: DairySpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: DairyRadius.smallBorderRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: DairyRadius.smallBorderRadius,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.local_drink_outlined,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: DairyTypography.headingSmall(isDark: isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$quantity • $frequency',
                      style: DairyTypography.bodySmall(isDark: isDark),
                    ),
                  ],
                ),
              ),
              DairyBadge(
                text: status,
                type: _getStatusBadgeType(),
              ),
            ],
          ),

          const SizedBox(height: DairySpacing.md),

          // Delivery info
          Container(
            padding: const EdgeInsets.all(DairySpacing.sm),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: DairyRadius.smallBorderRadius,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: DairySpacing.sm),
                Expanded(
                  child: Text(
                    nextDelivery != null
                        ? 'Next delivery: $nextDelivery'
                        : 'No upcoming delivery',
                    style: DairyTypography.bodySmall(isDark: isDark),
                  ),
                ),
                if (price != null)
                  Text(
                    '₹$price',
                    style: DairyTypography.label(
                      color: colors.primary,
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons
          if (onPause != null || onEdit != null) ...[
            const SizedBox(height: DairySpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onPause != null)
                  DairyTextButton(
                    text: isPaused ? 'Resume' : 'Pause',
                    leadingIcon: isPaused ? Icons.play_arrow : Icons.pause,
                    onPressed: onPause,
                  ),
                if (onEdit != null)
                  DairyTextButton(
                    text: 'Edit',
                    leadingIcon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  DairyBadgeType _getStatusBadgeType() {
    switch (status.toLowerCase()) {
      case 'active':
        return DairyBadgeType.success;
      case 'paused':
        return DairyBadgeType.warning;
      case 'cancelled':
        return DairyBadgeType.error;
      default:
        return DairyBadgeType.neutral;
    }
  }
}

// ============================================================================
// ORDER CARD - For displaying orders/deliveries
// ============================================================================

class DairyOrderCard extends StatelessWidget {
  final String orderId;
  final String date;
  final String status;
  final String totalAmount;
  final int itemCount;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const DairyOrderCard({
    super.key,
    required this.orderId,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    this.onTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return DairyCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$orderId',
                style: DairyTypography.headingSmall(isDark: isDark),
              ),
              DairyBadge(
                text: status,
                type: _getStatusBadgeType(),
              ),
            ],
          ),

          const SizedBox(height: DairySpacing.sm),

          // Date
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: DairyTypography.bodySmall(isDark: isDark),
              ),
            ],
          ),

          const SizedBox(height: DairySpacing.md),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: DairySpacing.md),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount item${itemCount > 1 ? 's' : ''}',
                style: DairyTypography.body(isDark: isDark),
              ),
              Text(
                '₹$totalAmount',
                style: DairyTypography.price(isDark: isDark),
              ),
            ],
          ),

          if (onViewDetails != null) ...[
            const SizedBox(height: DairySpacing.md),
            DairyTextButton(
              text: 'View Details',
              trailingIcon: Icons.arrow_forward_ios,
              onPressed: onViewDetails,
            ),
          ],
        ],
      ),
    );
  }

  DairyBadgeType _getStatusBadgeType() {
    switch (status.toLowerCase()) {
      case 'delivered':
        return DairyBadgeType.success;
      case 'pending':
      case 'processing':
        return DairyBadgeType.warning;
      case 'cancelled':
        return DairyBadgeType.error;
      case 'shipped':
      case 'out for delivery':
        return DairyBadgeType.info;
      default:
        return DairyBadgeType.neutral;
    }
  }
}

// ============================================================================
// STATS CARD - For displaying statistics/metrics
// ============================================================================

class DairyStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DairyStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return DairyCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? colors.primary).withOpacity(0.1),
              borderRadius: DairyRadius.defaultBorderRadius,
            ),
            child: Icon(
              icon,
              color: iconColor ?? colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: DairySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DairyTypography.caption(isDark: isDark),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: DairyTypography.headingMedium(isDark: isDark),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: DairyTypography.caption(
                      color: colors.primary,
                      isDark: isDark,
                    ),
                  ),
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

// ============================================================================
// BADGE COMPONENT
// ============================================================================

enum DairyBadgeType { success, warning, error, info, neutral, primary }

class DairyBadge extends StatelessWidget {
  final String text;
  final DairyBadgeType type;
  final bool filled;
  final IconData? icon;

  const DairyBadge({
    super.key,
    required this.text,
    this.type = DairyBadgeType.neutral,
    this.filled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    Color bgColor;
    Color textColor;

    switch (type) {
      case DairyBadgeType.success:
        bgColor = filled ? colors.success : colors.successSurface;
        textColor = filled ? colors.textOnPrimary : colors.success;
        break;
      case DairyBadgeType.warning:
        bgColor = filled ? colors.warning : colors.warningSurface;
        textColor = filled ? colors.textOnPrimary : colors.warning;
        break;
      case DairyBadgeType.error:
        bgColor = filled ? colors.error : colors.errorSurface;
        textColor = filled ? colors.textOnPrimary : colors.error;
        break;
      case DairyBadgeType.info:
        bgColor = filled ? colors.info : colors.infoSurface;
        textColor = filled ? colors.textOnPrimary : colors.info;
        break;
      case DairyBadgeType.primary:
        bgColor = filled ? colors.primary : colors.primarySurface;
        textColor = filled ? colors.textOnPrimary : colors.primary;
        break;
      case DairyBadgeType.neutral:
        bgColor = colors.surfaceVariant;
        textColor = colors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DairySpacing.sm,
        vertical: DairySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: DairyRadius.pillBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: DairyTypography.badge(color: textColor),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO CARD - Simple informational card
// ============================================================================

class DairyInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DairyInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;
    final accent = accentColor ?? colors.primary;

    return DairyCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: DairyRadius.smallBorderRadius,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: DairySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DairyTypography.bodyLarge(isDark: isDark),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: DairyTypography.caption(isDark: isDark),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: colors.textTertiary,
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// DIVIDER COMPONENT
// ============================================================================

class DairyDivider extends StatelessWidget {
  final double height;
  final double? indent;
  final double? endIndent;
  final Color? color;

  const DairyDivider({
    super.key,
    this.height = DairySpacing.md,
    this.indent,
    this.endIndent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;

    return Divider(
      height: height,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: color ?? colors.divider,
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class DairySectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const DairySectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.dairyColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DairySpacing.screenPaddingH,
        vertical: DairySpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: DairyTypography.headingMedium(isDark: isDark),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: DairyTypography.label(
                  color: colors.primary,
                  isDark: isDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

