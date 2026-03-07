import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Loading Widget with branded styling
class PremiumLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const PremiumLoadingWidget({
    super.key,
    this.message,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              backgroundColor: colors.surface,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: DairySpacing.md),
            Text(
              message!,
              style: DairyTypography.body(isDark: context.isDarkMode),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer Loading Effect for cards
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = DairyRadius.md,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
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
    _animation = Tween<double>(begin: -2, end: 2).animate(
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
    final baseColor = isDark ? DairyColorsDark.surfaceVariant : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? DairyColorsDark.surface : const Color(0xFFF9FAFB);

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
              colors: [baseColor, highlightColor, baseColor],
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

/// Skeleton Loader - Card shaped shimmer grid for loading states
class SkeletonCardLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const SkeletonCardLoader({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: DairySpacing.md,
        crossAxisSpacing: DairySpacing.md,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: DairyRadius.xlBorderRadius,
        border: Border.all(color: colors.border, width: 1),
      ),
      padding: DairySpacing.cardContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoading(width: 36, height: 36, borderRadius: DairyRadius.sm),
          const SizedBox(height: DairySpacing.sm),
          ShimmerLoading(width: double.infinity, height: 16, borderRadius: DairyRadius.sm),
          const SizedBox(height: DairySpacing.xs),
          ShimmerLoading(width: 80, height: 12, borderRadius: DairyRadius.sm),
        ],
      ),
    );
  }
}

/// Skeleton List Loader for list loading states
class SkeletonListLoader extends StatelessWidget {
  final int itemCount;

  const SkeletonListLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final colors = context.dairyColors;
    return Column(
      children: List.generate(itemCount, (index) => Padding(
        padding: const EdgeInsets.only(bottom: DairySpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: DairyRadius.xlBorderRadius,
            border: Border.all(color: colors.border, width: 1),
          ),
          padding: DairySpacing.cardContentPadding,
          child: Row(
            children: [
              ShimmerLoading(width: 48, height: 48, borderRadius: DairyRadius.md),
              const SizedBox(width: DairySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: double.infinity, height: 16, borderRadius: DairyRadius.sm),
                    const SizedBox(height: DairySpacing.sm),
                    ShimmerLoading(width: 120, height: 12, borderRadius: DairyRadius.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
