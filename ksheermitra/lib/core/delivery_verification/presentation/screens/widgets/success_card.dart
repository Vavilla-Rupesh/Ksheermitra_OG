/// Success Card Widget
///
/// Displays successful delivery verification result.
library;

import 'package:flutter/material.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_verification_result.dart';

/// Card showing successful delivery verification
class SuccessCard extends StatelessWidget {
  final DeliveryVerificationResult? result;

  const SuccessCard({
    super.key,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Delivery Verified!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Order has been marked as delivered',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),

            if (result != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Verified at',
                      _formatTime(result!.verifiedAt),
                    ),
                    if (result!.distanceMeters != null)
                      _buildInfoRow(
                        'Distance',
                        '${result!.distanceMeters!.toStringAsFixed(1)}m',
                      ),
                    if (result!.deliveryId != null)
                      _buildInfoRow(
                        'Delivery ID',
                        result!.deliveryId!.substring(0, 8),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

