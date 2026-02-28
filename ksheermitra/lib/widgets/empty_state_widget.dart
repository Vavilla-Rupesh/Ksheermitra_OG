import 'package:flutter/material.dart';
import '../config/dairy_theme.dart';

/// Premium Empty State Widget
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DairyColorsLight.primary.withValues(alpha: 0.1),
                    DairyColorsLight.primary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: DairyColorsLight.primary.withValues(alpha: 0.6),
              ),
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
              const SizedBox(height: DairySpacing.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DairySpacing.xl,
                    vertical: DairySpacing.md,
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

