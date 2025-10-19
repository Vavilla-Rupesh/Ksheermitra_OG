import 'product.dart';

class Subscription {
  final String id;
  final String customerId;
  final String productId;
  final double quantity;
  final String frequency;
  final List<int>? selectedDays;
  final String startDate;
  final String? endDate;
  final String status;
  final String? pauseStartDate;
  final String? pauseEndDate;
  final Product? product;

  Subscription({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.frequency,
    this.selectedDays,
    required this.startDate,
    this.endDate,
    required this.status,
    this.pauseStartDate,
    this.pauseEndDate,
    this.product,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customerId: json['customerId'],
      productId: json['productId'],
      quantity: double.parse(json['quantity'].toString()),
      frequency: json['frequency'],
      selectedDays: json['selectedDays'] != null 
          ? List<int>.from(json['selectedDays'])
          : null,
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
      pauseStartDate: json['pauseStartDate'],
      pauseEndDate: json['pauseEndDate'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'productId': productId,
      'quantity': quantity,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'pauseStartDate': pauseStartDate,
      'pauseEndDate': pauseEndDate,
    };
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';
}
