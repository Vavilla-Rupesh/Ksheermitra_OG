import '../models/monthly_breakout.dart';
import '../models/delivery.dart';
import '../models/invoice.dart';
import 'api_service.dart';

class MonthlyBreakoutService {
  final ApiService _apiService = ApiService();

  /// Get monthly breakout for a specific subscription
  Future<MonthlyBreakoutResponse> getSubscriptionMonthlyBreakout({
    required String subscriptionId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        '/customer/subscriptions/$subscriptionId/monthly-breakout',
        queryParams: {
          'year': year,
          'month': month,
        },
      );

      return MonthlyBreakoutResponse.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get monthly breakout for all customer subscriptions
  Future<CustomerMonthlyBreakout> getCustomerMonthlyBreakout({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        '/customer/monthly-breakout/$year/$month',
      );

      return CustomerMonthlyBreakout.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Modify products for a specific delivery
  Future<Delivery> modifyDeliveryProducts({
    required String deliveryId,
    required List<DeliveryProductModification> products,
  }) async {
    try {
      final response = await _apiService.put(
        '/customer/deliveries/$deliveryId/products',
        {
          'products': products.map((p) => p.toJson()).toList(),
        },
      );

      return Delivery.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate monthly invoice
  Future<Invoice> generateMonthlyInvoice({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.post(
        '/customer/monthly-invoice/$year/$month',
        {},
      );

      return Invoice.fromJson(response['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get monthly invoice
  Future<Invoice?> getMonthlyInvoice({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _apiService.get(
        '/customer/monthly-invoice/$year/$month',
      );

      if (response['success']) {
        return Invoice.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      // Return null if invoice not found
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// Calculate expected monthly amount for a subscription
  Future<double> calculateMonthlyAmount({
    required String subscriptionId,
    required int year,
    required int month,
  }) async {
    final breakout = await getSubscriptionMonthlyBreakout(
      subscriptionId: subscriptionId,
      year: year,
      month: month,
    );
    return breakout.totalAmount;
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

/// Model for modifying delivery products
class DeliveryProductModification {
  final String productId;
  final double quantity;
  final bool isOneTime;

  DeliveryProductModification({
    required this.productId,
    required this.quantity,
    this.isOneTime = false,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'isOneTime': isOneTime,
      };
}
