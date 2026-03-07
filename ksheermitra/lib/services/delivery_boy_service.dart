import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/delivery_boy.dart';
import '../models/delivery.dart';
import '../utils/auth_storage.dart';

class DeliveryBoyService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get assigned area with customers
  Future<Area> getAssignedArea() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boy/area'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Area.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw Exception('No area assigned yet');
      } else {
        throw Exception('Failed to load assigned area');
      }
    } catch (e) {
      throw Exception('Error fetching assigned area: $e');
    }
  }

  // Start delivery for the day
  Future<Map<String, dynamic>> startDelivery({String? date}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/delivery-boy/start-delivery'),
        headers: headers,
        body: json.encode({
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        throw Exception('No pending deliveries found for today');
      } else {
        throw Exception('Failed to start delivery');
      }
    } catch (e) {
      throw Exception('Error starting delivery: $e');
    }
  }

  // Mark delivery as complete (sends WhatsApp to customer)
  Future<Delivery> markDeliveryComplete({
    required String deliveryId,
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/delivery-boy/delivery/$deliveryId/status'),
        headers: headers,
        body: json.encode({
          'status': 'delivered',
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Delivery.fromJson(data['data']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to mark delivery complete');
      }
    } catch (e) {
      throw Exception('Error marking delivery complete: $e');
    }
  }

  // Get delivery statistics
  Future<DeliveryStats> getDeliveryStats({String? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = date != null ? '?date=$date' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boy/stats$queryParams'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryStats.fromJson(data['data']);
      } else {
        throw Exception('Failed to load delivery stats');
      }
    } catch (e) {
      throw Exception('Error fetching delivery stats: $e');
    }
  }

  // Get optimized route
  Future<Map<String, dynamic>> getOptimizedRoute({String? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = date != null ? '?date=$date' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boy/route$queryParams'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load optimized route');
      }
    } catch (e) {
      throw Exception('Error fetching optimized route: $e');
    }
  }

  // Get delivery history
  Future<List<Delivery>> getDeliveryHistory({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String>[];

      if (startDate != null) queryParams.add('startDate=$startDate');
      if (endDate != null) queryParams.add('endDate=$endDate');
      if (status != null) queryParams.add('status=$status');

      final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boy/history$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List deliveries = data['data'];
        return deliveries.map((d) => Delivery.fromJson(d)).toList();
      } else {
        throw Exception('Failed to load delivery history');
      }
    } catch (e) {
      throw Exception('Error fetching delivery history: $e');
    }
  }

  // Generate end-of-day report
  Future<Map<String, dynamic>> generateEndOfDayReport({String? date}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/delivery-boy/end-of-day-report'),
        headers: headers,
        body: json.encode({
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        throw Exception('No deliveries found for the specified date');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to generate report');
      }
    } catch (e) {
      throw Exception('Error generating end-of-day report: $e');
    }
  }

  // Get assigned customers
  Future<List<dynamic>> getAssignedCustomers({String? date}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = date != null ? '?date=$date' : '';
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boy/customers$queryParams'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load assigned customers');
      }
    } catch (e) {
      throw Exception('Error fetching assigned customers: $e');
    }
  }
}

