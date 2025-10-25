class DeliveryBoy {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final Area? area;
  final DateTime? createdAt;

  DeliveryBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.area,
    this.createdAt,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      isActive: json['isActive'] ?? true,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
    };
  }
}

class Area {
  final String id;
  final String name;
  final String? description;
  final String? deliveryBoyId;
  final List<LatLngPoint>? boundaries;
  final double? centerLatitude;
  final double? centerLongitude;
  final String? mapLink;
  final bool isActive;
  final DeliveryBoy? deliveryBoy;
  final List<Customer>? customers;

  Area({
    required this.id,
    required this.name,
    this.description,
    this.deliveryBoyId,
    this.boundaries,
    this.centerLatitude,
    this.centerLongitude,
    this.mapLink,
    this.isActive = true,
    this.deliveryBoy,
    this.customers,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    List<LatLngPoint>? boundaries;
    if (json['boundaries'] != null) {
      boundaries = (json['boundaries'] as List)
          .map((b) => LatLngPoint.fromJson(b))
          .toList();
    }

    return Area(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deliveryBoyId: json['deliveryBoyId'],
      boundaries: boundaries,
      centerLatitude: json['centerLatitude'] != null
          ? double.parse(json['centerLatitude'].toString())
          : null,
      centerLongitude: json['centerLongitude'] != null
          ? double.parse(json['centerLongitude'].toString())
          : null,
      mapLink: json['mapLink'],
      isActive: json['isActive'] ?? true,
      deliveryBoy: json['deliveryBoy'] != null
          ? DeliveryBoy.fromJson(json['deliveryBoy'])
          : null,
      customers: json['customers'] != null
          ? (json['customers'] as List).map((c) => Customer.fromJson(c)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deliveryBoyId': deliveryBoyId,
      'boundaries': boundaries?.map((b) => b.toJson()).toList(),
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'mapLink': mapLink,
      'isActive': isActive,
    };
  }
}

class LatLngPoint {
  final double lat;
  final double lng;

  LatLngPoint({required this.lat, required this.lng});

  factory LatLngPoint.fromJson(Map<String, dynamic> json) {
    return LatLngPoint(
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<Subscription>? subscriptions;
  final String? deliveryStatus;
  final double? todayAmount;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.subscriptions,
    this.deliveryStatus,
    this.todayAmount,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      subscriptions: json['subscriptions'] != null
          ? (json['subscriptions'] as List).map((s) => Subscription.fromJson(s)).toList()
          : null,
      deliveryStatus: json['deliveryStatus'],
      todayAmount: json['todayAmount'] != null ? double.parse(json['todayAmount'].toString()) : null,
    );
  }
}

class DeliveryStats {
  final int pending;
  final int delivered;
  final int missed;
  final int cancelled;
  final int totalDelivered;
  final int totalMissed;
  final double totalAmount;
  final double collectedAmount;

  DeliveryStats({
    this.pending = 0,
    this.delivered = 0,
    this.missed = 0,
    this.cancelled = 0,
    this.totalDelivered = 0,
    this.totalMissed = 0,
    this.totalAmount = 0.0,
    this.collectedAmount = 0.0,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      pending: json['pending'] ?? 0,
      delivered: json['delivered'] ?? 0,
      missed: json['missed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      totalDelivered: json['totalDelivered'] ?? 0,
      totalMissed: json['totalMissed'] ?? 0,
      totalAmount: json['totalAmount'] != null ? double.parse(json['totalAmount'].toString()) : 0.0,
      collectedAmount: json['collectedAmount'] != null ? double.parse(json['collectedAmount'].toString()) : 0.0,
    );
  }
}

class Subscription {
  final String id;
  final String customerId;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<SubscriptionProduct>? products;

  Subscription({
    required this.id,
    required this.customerId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.products,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customerId: json['customerId'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      products: json['products'] != null
          ? (json['products'] as List).map((p) => SubscriptionProduct.fromJson(p)).toList()
          : null,
    );
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
}

class Product {
  final String id;
  final String name;
  final String? description;
  final String unit;
  final double pricePerUnit;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.unit,
    required this.pricePerUnit,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      unit: json['unit'],
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      imageUrl: json['imageUrl'],
    );
  }
}

