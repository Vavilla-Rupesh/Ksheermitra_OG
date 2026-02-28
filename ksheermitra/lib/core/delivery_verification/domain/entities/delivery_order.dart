/// Delivery Order Entity
/// Represents a delivery order with destination and verification requirements.
library;

import 'delivery_location.dart';

/// Status of a delivery order
enum DeliveryOrderStatus {
  pending,
  inProgress,
  delivered,
  failed,
  cancelled,
}

/// A delivery order that needs to be verified before completion
class DeliveryOrder {
  /// Unique identifier for the delivery
  final String id;

  /// Associated order ID
  final String? orderId;

  /// Customer ID for this delivery
  final String customerId;

  /// Customer name
  final String customerName;

  /// Customer phone number
  final String? customerPhone;

  /// Delivery address as string
  final String deliveryAddress;

  /// Destination location for geofence verification
  final DeliveryLocation destination;

  /// Maximum allowed radius in meters for delivery verification
  final double allowedRadiusMeters;

  /// Current status of the delivery
  final DeliveryOrderStatus status;

  /// List of items in this delivery
  final List<DeliveryItem> items;

  /// Total amount for this delivery
  final double totalAmount;

  /// Notes for the delivery agent
  final String? notes;

  /// Scheduled delivery date
  final DateTime deliveryDate;

  /// When the delivery was created
  final DateTime? createdAt;

  /// When the delivery was last updated
  final DateTime? updatedAt;

  /// When the delivery was completed
  final DateTime? completedAt;

  /// Agent location at time of delivery (after verification)
  final DeliveryLocation? verifiedLocation;

  const DeliveryOrder({
    required this.id,
    this.orderId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.deliveryAddress,
    required this.destination,
    this.allowedRadiusMeters = 100.0, // Default 100 meters
    required this.status,
    required this.items,
    required this.totalAmount,
    this.notes,
    required this.deliveryDate,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.verifiedLocation,
  });

  /// Creates a DeliveryOrder from API JSON response
  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] ?? json['deliveryId'],
      orderId: json['orderId'],
      customerId: json['customerId'] ?? json['customer']?['id'] ?? '',
      customerName: json['customerName'] ?? json['customer']?['name'] ?? 'Unknown',
      customerPhone: json['customerPhone'] ?? json['customer']?['phone'],
      deliveryAddress: json['deliveryAddress'] ?? json['address'] ?? json['customer']?['address'] ?? '',
      destination: DeliveryLocation(
        latitude: _parseDouble(json['latitude'] ?? json['customer']?['latitude'] ?? json['destination']?['latitude'] ?? 0),
        longitude: _parseDouble(json['longitude'] ?? json['customer']?['longitude'] ?? json['destination']?['longitude'] ?? 0),
      ),
      allowedRadiusMeters: _parseDouble(json['allowedRadiusMeters'] ?? json['allowedRadius'] ?? 100.0),
      status: _parseStatus(json['status']),
      items: _parseItems(json['items']),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['amount'] ?? 0),
      notes: json['notes'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'].toString().split('T')[0])
          : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      verifiedLocation: json['verifiedLocation'] != null
          ? DeliveryLocation.fromJson(json['verifiedLocation'])
          : null,
    );
  }

  /// Converts to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'destination': destination.toJson(),
      'allowedRadiusMeters': allowedRadiusMeters,
      'status': status.name,
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'deliveryDate': deliveryDate.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'verifiedLocation': verifiedLocation?.toJson(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DeliveryOrderStatus _parseStatus(dynamic status) {
    if (status == null) return DeliveryOrderStatus.pending;
    final statusStr = status.toString().toLowerCase().replaceAll('-', '');
    switch (statusStr) {
      case 'pending':
        return DeliveryOrderStatus.pending;
      case 'inprogress':
        return DeliveryOrderStatus.inProgress;
      case 'delivered':
        return DeliveryOrderStatus.delivered;
      case 'failed':
        return DeliveryOrderStatus.failed;
      case 'cancelled':
        return DeliveryOrderStatus.cancelled;
      default:
        return DeliveryOrderStatus.pending;
    }
  }

  static List<DeliveryItem> _parseItems(dynamic items) {
    if (items == null) return [];
    if (items is! List) return [];
    return items.map((item) => DeliveryItem.fromJson(item)).toList();
  }

  /// Returns true if the delivery has a valid destination
  bool get hasValidDestination => destination.isValid;

  /// Returns true if the delivery is still pending or in progress
  bool get canBeDelivered =>
      status == DeliveryOrderStatus.pending ||
      status == DeliveryOrderStatus.inProgress;

  /// Creates a copy with updated fields
  DeliveryOrder copyWith({
    String? id,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    DeliveryLocation? destination,
    double? allowedRadiusMeters,
    DeliveryOrderStatus? status,
    List<DeliveryItem>? items,
    double? totalAmount,
    String? notes,
    DateTime? deliveryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DeliveryLocation? verifiedLocation,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      destination: destination ?? this.destination,
      allowedRadiusMeters: allowedRadiusMeters ?? this.allowedRadiusMeters,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      verifiedLocation: verifiedLocation ?? this.verifiedLocation,
    );
  }

  @override
  String toString() {
    return 'DeliveryOrder(id: $id, customer: $customerName, status: $status)';
  }
}

/// An item in a delivery order
class DeliveryItem {
  final String? id;
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double price;
  final String? imageUrl;

  const DeliveryItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    this.imageUrl,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      productId: json['productId'] ?? json['product']?['id'] ?? '',
      productName: json['productName'] ?? json['product']?['name'] ?? 'Unknown Product',
      quantity: _parseDouble(json['quantity']),
      unit: json['unit'] ?? json['product']?['unit'] ?? 'unit',
      price: _parseDouble(json['price']),
      imageUrl: json['imageUrl'] ?? json['product']?['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double get totalPrice => quantity * price;

  @override
  String toString() {
    return 'DeliveryItem(product: $productName, qty: $quantity $unit)';
  }
}

