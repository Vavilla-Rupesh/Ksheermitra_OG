import 'subscription.dart';

class User {
  final String id;
  final String? name;
  final String phone;
  final String? email;
  final String role;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? areaId;
  final bool isActive;
  final List<Subscription>? subscriptions;

  User({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    required this.role,
    this.address,
    this.latitude,
    this.longitude,
    this.areaId,
    required this.isActive,
    this.subscriptions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'customer',
      address: json['address']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      areaId: json['areaId']?.toString(),
      isActive: json['isActive'] ?? true,
      subscriptions: json['subscriptions'] != null
          ? (json['subscriptions'] as List)
              .map((s) => Subscription.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'areaId': areaId,
      'isActive': isActive,
      if (subscriptions != null) 'subscriptions': subscriptions!.map((s) => s.toJson()).toList(),
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
  bool get isDeliveryBoy => role == 'delivery_boy';
}
