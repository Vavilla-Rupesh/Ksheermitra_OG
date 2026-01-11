import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final List<LatLng>? boundaries;
  final double? centerLatitude;
  final double? centerLongitude;
  final String? mapLink;

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
    this.boundaries,
    this.centerLatitude,
    this.centerLongitude,
    this.mapLink,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    List<LatLng>? boundaries;
    if (json['boundaries'] != null) {
      try {
        boundaries = (json['boundaries'] as List)
            .map((point) => LatLng(
                  point['latitude'] ?? 0.0,
                  point['longitude'] ?? 0.0,
                ))
            .toList();
      } catch (e) {
        boundaries = null;
      }
    }

    return Area(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Area',
      description: json['description']?.toString(),
      deliveryBoyId: json['deliveryBoyId']?.toString(),
      deliveryBoy: json['deliveryBoy'] != null && json['deliveryBoy'] is Map<String, dynamic>
          ? User.fromJson(json['deliveryBoy'])
          : null,
      customers: json['customers'] != null && json['customers'] is List
          ? (json['customers'] as List)
              .where((c) => c != null && c is Map<String, dynamic>)
              .map((c) => User.fromJson(c))
              .toList()
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      boundaries: boundaries,
      centerLatitude: json['centerLatitude'] != null
          ? double.tryParse(json['centerLatitude'].toString())
          : null,
      centerLongitude: json['centerLongitude'] != null
          ? double.tryParse(json['centerLongitude'].toString())
          : null,
      mapLink: json['mapLink']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deliveryBoyId': deliveryBoyId,
      'isActive': isActive,
      if (boundaries != null)
        'boundaries': boundaries!.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
      if (centerLatitude != null) 'centerLatitude': centerLatitude,
      if (centerLongitude != null) 'centerLongitude': centerLongitude,
      if (mapLink != null) 'mapLink': mapLink,
    };
  }

  int get customerCount => customers?.length ?? 0;
}
