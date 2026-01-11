import 'product.dart';

class Subscription {
  final String id;
  final String customerId;
  final String frequency;
  final List<int>? selectedDays;
  final String startDate;
  final String? endDate;
  final String status;
  final String? pauseStartDate;
  final String? pauseEndDate;
  final bool autoRenewal;
  final List<SubscriptionProduct>? products;

  Subscription({
    required this.id,
    required this.customerId,
    required this.frequency,
    this.selectedDays,
    required this.startDate,
    this.endDate,
    required this.status,
    this.pauseStartDate,
    this.pauseEndDate,
    this.autoRenewal = false,
    this.products,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? 'daily',
      selectedDays: json['selectedDays'] != null
          ? List<int>.from(json['selectedDays'])
          : null,
      startDate: json['startDate']?.toString() ?? DateTime.now().toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString() ?? 'active',
      pauseStartDate: json['pauseStartDate']?.toString(),
      pauseEndDate: json['pauseEndDate']?.toString(),
      autoRenewal: json['autoRenewal'] ?? false,
      products: json['products'] != null && json['products'] is List
          ? (json['products'] as List)
              .where((p) => p != null && p is Map<String, dynamic>)
              .map((p) => SubscriptionProduct.fromJson(p))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'pauseStartDate': pauseStartDate,
      'pauseEndDate': pauseEndDate,
      'autoRenewal': autoRenewal,
    };
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';

  // Get total quantity per delivery
  double get totalQuantity {
    if (products == null) return 0;
    return products!.fold(0, (sum, sp) => sum + sp.quantity);
  }

  // Get total cost per delivery
  double get totalCostPerDelivery {
    if (products == null) return 0;
    return products!.fold(0, (sum, sp) => sum + (sp.quantity * (sp.product?.pricePerUnit ?? 0)));
  }

  // Get frequency display text
  String get frequencyDisplay {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'monthly':
        return 'Monthly';
      case 'daterange':
        return 'Date Range';
      case 'custom':
      case 'weekly':
        if (selectedDays != null && selectedDays!.isNotEmpty) {
          final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          return selectedDays!.map((d) => dayNames[d]).join(', ');
        }
        return 'Custom';
      default:
        return frequency;
    }
  }
}

class SubscriptionProduct {
  final String id;
  final String subscriptionId;
  final String productId;
  final double quantity;
  final Product? product;

  SubscriptionProduct({
    required this.id,
    required this.subscriptionId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) {
    return SubscriptionProduct(
      id: json['id']?.toString() ?? '',
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] != null
          ? double.tryParse(json['quantity'].toString()) ?? 0.0
          : 0.0,
      product: json['product'] != null && json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      'productId': productId,
      'quantity': quantity,
    };
  }
}
