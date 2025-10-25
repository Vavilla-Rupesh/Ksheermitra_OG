import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/delivery_boy.dart';
import '../utils/auth_storage.dart';

class AdminService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Delivery Boy Management

  Future<List<DeliveryBoy>> getDeliveryBoys() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/delivery-boys'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List deliveryBoys = data['data'];
        return deliveryBoys.map((db) => DeliveryBoy.fromJson(db)).toList();
      } else {
        throw Exception('Failed to load delivery boys');
      }
    } catch (e) {
      throw Exception('Error fetching delivery boys: $e');
    }
  }

  Future<DeliveryBoy> createDeliveryBoy({
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/delivery-boys'),
        headers: headers,
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return DeliveryBoy.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create delivery boy');
      }
    } catch (e) {
      throw Exception('Error creating delivery boy: $e');
    }
  }

  Future<DeliveryBoy> updateDeliveryBoy({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (email != null) body['email'] = email;
      if (address != null) body['address'] = address;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (isActive != null) body['isActive'] = isActive;

      final response = await http.put(
        Uri.parse('$baseUrl/admin/delivery-boys/$id'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryBoy.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update delivery boy');
      }
    } catch (e) {
      throw Exception('Error updating delivery boy: $e');
    }
  }

  Future<Map<String, dynamic>> getDeliveryBoyDetails(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/delivery-boys/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load delivery boy details');
      }
    } catch (e) {
      throw Exception('Error fetching delivery boy details: $e');
    }
  }

  // Area Management

  Future<List<Area>> getAreas() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/areas'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List areas = data['data'];
        return areas.map((a) => Area.fromJson(a)).toList();
      } else {
        throw Exception('Failed to load areas');
      }
    } catch (e) {
      throw Exception('Error fetching areas: $e');
    }
  }

  Future<Area> createArea({
    required String name,
    String? description,
    String? deliveryBoyId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/areas'),
        headers: headers,
        body: json.encode({
          'name': name,
          'description': description,
          'deliveryBoyId': deliveryBoyId,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Area.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to create area');
      }
    } catch (e) {
      throw Exception('Error creating area: $e');
    }
  }

  Future<Map<String, dynamic>> assignAreaWithMap({
    required String areaId,
    required String deliveryBoyId,
    List<LatLngBoundary>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
    String? mapLink,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/assign-area-with-map'),
        headers: headers,
        body: json.encode({
          'areaId': areaId,
          'deliveryBoyId': deliveryBoyId,
          'boundaries': boundaries?.map((b) => b.toJson()).toList(),
          'centerLatitude': centerLatitude,
          'centerLongitude': centerLongitude,
          'mapLink': mapLink,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to assign area');
      }
    } catch (e) {
      throw Exception('Error assigning area: $e');
    }
  }

  Future<Area> updateAreaBoundaries({
    required String areaId,
    List<LatLngBoundary>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
    String? mapLink,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/areas/$areaId/boundaries'),
        headers: headers,
        body: json.encode({
          'boundaries': boundaries?.map((b) => b.toJson()).toList(),
          'centerLatitude': centerLatitude,
          'centerLongitude': centerLongitude,
          'mapLink': mapLink,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Area.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update area boundaries');
      }
    } catch (e) {
      throw Exception('Error updating area boundaries: $e');
    }
  }

  Future<Area> getAreaWithCustomers(String areaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/areas/$areaId/customers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Area.fromJson(data['data']);
      } else {
        throw Exception('Failed to load area details');
      }
    } catch (e) {
      throw Exception('Error fetching area details: $e');
    }
  }

  // Dashboard Stats

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard stats: $e');
    }
  }
}

