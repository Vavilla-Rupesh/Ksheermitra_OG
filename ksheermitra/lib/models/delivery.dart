import 'product.dart';
import 'user.dart';

class Delivery {
  final String id;
  final String customerId;
  final String subscriptionId;
  final String productId;
  final String deliveryBoyId;
  final DateTime deliveryDate;
  final double quantity;
  final double amount;
  final String status;
  final String? notes;
  final User? customer;
  final Product? product;
  final User? deliveryBoy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Delivery({
    required this.id,
    required this.customerId,
    required this.subscriptionId,
    required this.productId,
    required this.deliveryBoyId,
    required this.deliveryDate,
    required this.quantity,
    required this.amount,
    required this.status,
    this.notes,
    this.customer,
    this.product,
    this.deliveryBoy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      subscriptionId: json['subscriptionId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      deliveryBoyId: json['deliveryBoyId']?.toString() ?? '',
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.tryParse(json['deliveryDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      quantity: json['quantity'] != null
          ? double.tryParse(json['quantity'].toString()) ?? 0.0
          : 0.0,
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? User.fromJson(json['customer'])
          : null,
      product: json['product'] != null && json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'])
          : null,
      deliveryBoy: json['deliveryBoy'] != null && json['deliveryBoy'] is Map<String, dynamic>
          ? User.fromJson(json['deliveryBoy'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'subscriptionId': subscriptionId,
      'productId': productId,
      'deliveryBoyId': deliveryBoyId,
      'deliveryDate': deliveryDate.toIso8601String(),
      'quantity': quantity,
      'amount': amount,
      'status': status,
      'notes': notes,
    };
  }

  bool get isPending => status == 'pending';
  bool get isDelivered => status == 'delivered';
  bool get isMissed => status == 'missed';
  bool get isCancelled => status == 'cancelled';
}
