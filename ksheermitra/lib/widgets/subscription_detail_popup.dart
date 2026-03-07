import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../config/dairy_theme.dart';

class SubscriptionDetailPopup extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionDetailPopup({
    super.key,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = subscription.status.toLowerCase() == 'active';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DairyRadius.xxl),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(DairySpacing.lg),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)])
                    : const LinearGradient(colors: [DairyColorsLight.warning, Color(0xFFFFB74D)]),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(DairyRadius.xxl),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DairySpacing.sm + 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(DairyRadius.md),
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.frequencyDisplay,
                          style: DairyTypography.headingSmall(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: DairySpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DairySpacing.sm,
                            vertical: DairySpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(DairyRadius.pill),
                          ),
                          child: Text(
                            subscription.status.toUpperCase(),
                            style: DairyTypography.badge(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DairySpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Products Section
                    if (subscription.products != null && subscription.products!.isNotEmpty) ...[
                      Text(
                        'Products',
                        style: DairyTypography.headingSmall(),
                      ),
                      const SizedBox(height: DairySpacing.md),
                      ...subscription.products!.map((sp) => Container(
                        margin: const EdgeInsets.only(bottom: DairySpacing.sm),
                        padding: const EdgeInsets.all(DairySpacing.md),
                        decoration: BoxDecoration(
                          color: DairyColorsLight.surface,
                          borderRadius: BorderRadius.circular(DairyRadius.md),
                          border: Border.all(color: DairyColorsLight.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(DairySpacing.sm),
                              decoration: BoxDecoration(
                                color: DairyColorsLight.primarySurface,
                                borderRadius: BorderRadius.circular(DairyRadius.sm),
                              ),
                              child: const Icon(
                                Icons.local_drink,
                                color: DairyColorsLight.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: DairySpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sp.product?.name ?? 'Product',
                                    style: DairyTypography.productName(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: DairySpacing.xs),
                                  Text(
                                    '${sp.quantity.toStringAsFixed(1)} ${sp.product?.unit ?? ''}',
                                    style: DairyTypography.caption(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: DairySpacing.sm),
                            Flexible(
                              child: Text(
                                '₹${(sp.quantity * (sp.product?.pricePerUnit ?? 0)).toStringAsFixed(2)}',
                                style: DairyTypography.label(color: DairyColorsLight.success),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: DairySpacing.md),
                    ],

                    // Total Cost
                    Container(
                      padding: const EdgeInsets.all(DairySpacing.md),
                      decoration: BoxDecoration(
                        color: DairyColorsLight.primarySurface,
                        borderRadius: BorderRadius.circular(DairyRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Total per delivery',
                              style: DairyTypography.bodyLarge(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: DairySpacing.sm),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${subscription.totalCostPerDelivery.toStringAsFixed(2)}',
                                style: DairyTypography.headingMedium(color: DairyColorsLight.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DairySpacing.lg),
                    const Divider(color: DairyColorsLight.border),
                    const SizedBox(height: DairySpacing.md),

                    // Subscription Details
                    Text(
                      'Subscription Details',
                      style: DairyTypography.headingSmall(),
                    ),
                    const SizedBox(height: DairySpacing.md),

                    _buildDetailRow(
                      Icons.repeat,
                      'Frequency',
                      subscription.frequencyDisplay,
                    ),

                    if (subscription.selectedDays != null && subscription.selectedDays!.isNotEmpty)
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Delivery Days',
                        _getDaysText(subscription.selectedDays!),
                      ),

                    _buildDetailRow(
                      Icons.event,
                      'Start Date',
                      DateFormat('MMM dd, yyyy').format(
                        DateTime.parse(subscription.startDate),
                      ),
                    ),

                    if (subscription.endDate != null)
                      _buildDetailRow(
                        Icons.event_busy,
                        'End Date',
                        DateFormat('MMM dd, yyyy').format(
                          DateTime.parse(subscription.endDate!),
                        ),
                      ),

                    if (subscription.autoRenewal)
                      _buildDetailRow(
                        Icons.autorenew,
                        'Auto Renewal',
                        'Enabled',
                      ),

                    if (subscription.isPaused) ...[
                      const SizedBox(height: DairySpacing.md),
                      const Divider(color: DairyColorsLight.border),
                      const SizedBox(height: DairySpacing.md),
                      _buildDetailRow(
                        Icons.pause_circle,
                        'Paused From',
                        DateFormat('MMM dd, yyyy').format(
                          DateTime.parse(subscription.pauseStartDate!),
                        ),
                      ),
                      if (subscription.pauseEndDate != null)
                        _buildDetailRow(
                          Icons.play_circle,
                          'Resume On',
                          DateFormat('MMM dd, yyyy').format(
                            DateTime.parse(subscription.pauseEndDate!),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: DairyColorsLight.textSecondary),
          const SizedBox(width: DairySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DairyTypography.caption(),
                ),
                const SizedBox(height: DairySpacing.xs),
                Text(
                  value,
                  style: DairyTypography.bodyLarge(),
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDaysText(List<int> days) {
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days.map((d) => dayNames[d]).join(', ');
  }
}
