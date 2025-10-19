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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      address: json['address'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      areaId: json['areaId'],
      isActive: json['isActive'] ?? true,
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
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';
  bool get isDeliveryBoy => role == 'delivery_boy';
}
