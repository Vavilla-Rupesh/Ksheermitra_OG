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
      id: json['id'],
      customerId: json['customerId'],
      frequency: json['frequency'],
      selectedDays: json['selectedDays'] != null 
          ? List<int>.from(json['selectedDays'])
          : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      pauseStartDate: json['pauseStartDate'],
      pauseEndDate: json['pauseEndDate'],
      autoRenewal: json['autoRenewal'] ?? false,
      products: json['products'] != null
          ? (json['products'] as List)
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
      id: json['id'],
      subscriptionId: json['subscriptionId'],
      productId: json['productId'],
      quantity: double.parse(json['quantity'].toString()),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
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
