import 'user.dart';

class Area {
  final String id;
  final String name;
  final String? description;
  final String? deliveryBoyId;
  final User? deliveryBoy;
  final List<User>? customers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Area({
    required this.id,
    required this.name,
    this.description,
    this.deliveryBoyId,
    this.deliveryBoy,
    this.customers,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deliveryBoyId: json['deliveryBoyId'],
      deliveryBoy: json['deliveryBoy'] != null 
          ? User.fromJson(json['deliveryBoy']) 
          : null,
      customers: json['customers'] != null
          ? (json['customers'] as List).map((c) => User.fromJson(c)).toList()
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deliveryBoyId': deliveryBoyId,
      'isActive': isActive,
    };
  }

  int get customerCount => customers?.length ?? 0;
}
