class DeliveryBoy {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? areaId;
  final bool isActive;
  final Area? area;
  final DateTime? lastLogin;

  DeliveryBoy({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.areaId,
    required this.isActive,
    this.area,
    this.lastLogin,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      areaId: json['areaId'],
      isActive: json['isActive'] ?? true,
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
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
      'areaId': areaId,
      'isActive': isActive,
    };
  }
}

class Area {
  final String id;
  final String name;
  final String? description;
  final String? deliveryBoyId;
  final List<LatLngBoundary>? boundaries;
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
    required this.isActive,
    this.deliveryBoy,
    this.customers,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deliveryBoyId: json['deliveryBoyId'],
      boundaries: json['boundaries'] != null
          ? (json['boundaries'] as List).map((b) => LatLngBoundary.fromJson(b)).toList()
          : null,
      centerLatitude: json['centerLatitude'] != null ? double.tryParse(json['centerLatitude'].toString()) : null,
      centerLongitude: json['centerLongitude'] != null ? double.tryParse(json['centerLongitude'].toString()) : null,
      mapLink: json['mapLink'],
      isActive: json['isActive'] ?? true,
      deliveryBoy: json['deliveryBoy'] != null ? DeliveryBoy.fromJson(json['deliveryBoy']) : null,
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

class LatLngBoundary {
  final double lat;
  final double lng;

  LatLngBoundary({required this.lat, required this.lng});

  factory LatLngBoundary.fromJson(Map<String, dynamic> json) {
    return LatLngBoundary(
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }
}

class DeliveryStats {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final double totalAmount;

  DeliveryStats({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.totalAmount,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      totalDeliveries: json['totalDeliveries'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

