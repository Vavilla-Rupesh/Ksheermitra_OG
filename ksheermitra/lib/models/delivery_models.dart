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
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isActive: json['isActive'] ?? true,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
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
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      deliveryBoyId: json['deliveryBoyId'] as String?,
      boundaries: boundaries,
      centerLatitude: json['centerLatitude'] != null
          ? double.tryParse(json['centerLatitude'].toString())
          : null,
      centerLongitude: json['centerLongitude'] != null
          ? double.tryParse(json['centerLongitude'].toString())
          : null,
      mapLink: json['mapLink'] as String?,
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
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
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
  final String? deliveryId;

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
    this.deliveryId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      subscriptions: json['subscriptions'] != null
          ? (json['subscriptions'] as List).map((s) => Subscription.fromJson(s)).toList()
          : null,
      deliveryStatus: json['deliveryStatus'] as String?,
      todayAmount: json['todayAmount'] != null ? double.tryParse(json['todayAmount'].toString()) : null,
      deliveryId: json['deliveryId'] as String?,
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
      totalAmount: json['totalAmount'] != null ? double.tryParse(json['totalAmount'].toString()) ?? 0.0 : 0.0,
      collectedAmount: json['collectedAmount'] != null ? double.tryParse(json['collectedAmount'].toString()) ?? 0.0 : 0.0,
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
      id: (json['id'] as String?) ?? '',
      customerId: (json['customerId'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'active',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'].toString()) : null,
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
      id: (json['id'] as String?) ?? '',
      subscriptionId: (json['subscriptionId'] as String?) ?? '',
      productId: (json['productId'] as String?) ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0.0,
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
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      unit: (json['unit'] as String?) ?? '',
      pricePerUnit: double.tryParse(json['pricePerUnit']?.toString() ?? '') ?? 0.0,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

