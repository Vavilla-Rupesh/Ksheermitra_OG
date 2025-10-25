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
      id: json['id'],
      customerId: json['customerId'],
      subscriptionId: json['subscriptionId'],
      productId: json['productId'],
      deliveryBoyId: json['deliveryBoyId'],
      deliveryDate: DateTime.parse(json['deliveryDate']),
      quantity: double.parse(json['quantity'].toString()),
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      notes: json['notes'],
      customer: json['customer'] != null 
          ? User.fromJson(json['customer']) 
          : null,
      product: json['product'] != null 
          ? Product.fromJson(json['product']) 
          : null,
      deliveryBoy: json['deliveryBoy'] != null 
          ? User.fromJson(json['deliveryBoy']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
