import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Empty State Widget — Remastered
class PremiumEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container with subtle gradient
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.12),
                    primary.withValues(alpha: 0.04),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: DairySpacing.lg),
            Text(
              title,
              style: DairyTypography.headingSmall(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DairySpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DairySpacing.lg),
              child: Text(
                message,
                style: DairyTypography.body(isDark: isDark),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: DairySpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DairySpacing.lg,
                    vertical: DairySpacing.buttonPaddingV,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: DairyRadius.largeBorderRadius,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
