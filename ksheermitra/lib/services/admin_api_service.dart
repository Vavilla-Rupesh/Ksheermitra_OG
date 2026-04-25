import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/area.dart';
import '../models/delivery.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/dashboard_stats.dart';
import 'api_service.dart';

class AdminApiService {
  final ApiService _apiService = ApiService();

  // Dashboard
  Future<DashboardStats> getDashboardStats() async {
    // Note: This endpoint is not yet implemented in the backend.
    // The backend needs to add: GET /admin/dashboard/stats
    // For now, we'll try to call it, but if it fails, return empty stats
    try {
      final response = await _apiService.get('/admin/dashboard/stats');
      return DashboardStats.fromJson(response['data']);
    } catch (e) {
      // If endpoint doesn't exist, return zero stats
      // This allows the UI to work while waiting for backend implementation
      debugPrint('Dashboard stats endpoint not implemented yet: $e');
      return DashboardStats.fromJson({
        'totalCustomers': 0,
        'activeCustomers': 0,
        'totalDeliveryBoys': 0,
        'activeDeliveryBoys': 0,
        'todaysDeliveries': 0,
        'todaysPending': 0,
        'todaysDelivered': 0,
        'todaysMissed': 0,
        'todaysRevenue': 0,
        'activeSubscriptions': 0,
        'totalProducts': 0,
        'totalAreas': 0,
        'pendingPayments': 0,
        'collectedPayments': 0,
      });
    }
  }

  // Customer Management
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _apiService.get(
      '/admin/customers',
      queryParams: queryParams,
    );

    final data = response['data'];
    return {
      'customers': (data['customers'] as List)
          .map((json) => User.fromJson(json))
          .toList(),
      'pagination': data['pagination'],
    };
  }

  Future<List<User>> getCustomersWithLocations() async {
    final response = await _apiService.get('/admin/customers/map');
    return (response['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<User> getCustomerDetails(String customerId) async {
    final response = await _apiService.get('/admin/customers/$customerId');
    return User.fromJson(response['data']);
  }

  Future<User> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.post('/admin/customers', {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (address != null && address.isNotEmpty) 'address': address,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    });
    return User.fromJson(response['data']);
  }

  // Delivery Boy Management
  Future<List<User>> getDeliveryBoys() async {
    final response = await _apiService.get('/admin/delivery-boys');
    return (response['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<User> createDeliveryBoy({
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.post('/admin/delivery-boys', {
      'name': name,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    });
    return User.fromJson(response['data']);
  }

  Future<User> updateDeliveryBoy({
    required String id,
    String? name,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    final response = await _apiService.put('/admin/delivery-boys/$id', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (isActive != null) 'isActive': isActive,
    });
    return User.fromJson(response['data']);
  }

  // Area Management
  Future<List<Area>> getAreas() async {
    final response = await _apiService.get('/admin/areas');
    return (response['data'] as List)
        .map((json) => Area.fromJson(json))
        .toList();
  }

  Future<Area> createArea({
    required String name,
    String? description,
    String? deliveryBoyId,
    List<LatLng>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
  }) async {
    final body = {
      'name': name,
      if (description != null) 'description': description,
      if (deliveryBoyId != null) 'deliveryBoyId': deliveryBoyId,
      if (boundaries != null && boundaries.isNotEmpty)
        'boundaries': boundaries.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
      if (centerLatitude != null) 'centerLatitude': centerLatitude.toString(),
      if (centerLongitude != null) 'centerLongitude': centerLongitude.toString(),
    };

    final response = await _apiService.post('/admin/areas', body);
    return Area.fromJson(response['data']);
  }

  Future<Area> updateArea({
    required String id,
    String? name,
    String? description,
    String? deliveryBoyId,
    bool? isActive,
  }) async {
    final response = await _apiService.put('/admin/areas/$id', {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (deliveryBoyId != null) 'deliveryBoyId': deliveryBoyId,
      if (isActive != null) 'isActive': isActive,
    });
    return Area.fromJson(response['data']);
  }

  Future<Area> updateAreaBoundaries({
    required String id,
    required List<LatLng> boundaries,
    required double centerLatitude,
    required double centerLongitude,
  }) async {
    final response = await _apiService.put('/admin/areas/$id/boundaries', {
      'boundaries': boundaries.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'centerLatitude': centerLatitude.toString(),
      'centerLongitude': centerLongitude.toString(),
    });
    return Area.fromJson(response['data']);
  }

  Future<void> deleteArea({required String id}) async {
    await _apiService.delete('/admin/areas/$id');
  }

  Future<void> assignArea({
    required String customerId,
    required String areaId,
  }) async {
    await _apiService.post('/admin/assign-area', {
      'customerId': customerId,
      'areaId': areaId,
    });
  }

  Future<void> bulkAssignArea({
    required List<String> customerIds,
    required String areaId,
  }) async {
    await _apiService.post('/admin/bulk-assign-area', {
      'customerIds': customerIds,
      'areaId': areaId,
    });
  }

  Future<Area> assignAreaWithMap({
    required String areaId,
    required String deliveryBoyId,
    List<LatLng>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
    String? mapLink,
  }) async {
    final body = {
      'areaId': areaId,
      'deliveryBoyId': deliveryBoyId,
      if (boundaries != null && boundaries.isNotEmpty)
        'boundaries': boundaries.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
      if (centerLatitude != null) 'centerLatitude': centerLatitude.toString(),
      if (centerLongitude != null) 'centerLongitude': centerLongitude.toString(),
      if (mapLink != null) 'mapLink': mapLink,
    };

    final response = await _apiService.post('/admin/assign-area-with-map', body);
    return Area.fromJson(response['data']['area']);
  }

  // Product Management
  Future<List<Product>> getProducts() async {
    final response = await _apiService.get('/admin/products');
    return (response['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  Future<Product> createProduct({
    required String name,
    String? description,
    required String unit,
    required double pricePerUnit,
    int? stock,
    String? imagePath,
  }) async {
    final data = {
      'name': name,
      'unit': unit,
      'pricePerUnit': pricePerUnit.toString(),
    };

    if (description != null) data['description'] = description;
    if (stock != null) data['stock'] = stock.toString();

    final files = <String, String>{};
    if (imagePath != null && imagePath.isNotEmpty) {
      files['image'] = imagePath;
    }

    final response = await _apiService.postMultipart(
      '/admin/products',
      data,
      files: files,
    );
    return Product.fromJson(response['data']);
  }

  Future<Product> updateProduct({
    required String id,
    String? name,
    String? description,
    String? unit,
    double? pricePerUnit,
    int? stock,
    bool? isActive,
    String? imagePath,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (unit != null) data['unit'] = unit;
    if (pricePerUnit != null) data['pricePerUnit'] = pricePerUnit.toString();
    if (stock != null) data['stock'] = stock.toString();
    if (isActive != null) data['isActive'] = isActive.toString();

    final files = <String, String>{};
    if (imagePath != null && imagePath.isNotEmpty) {
      files['image'] = imagePath;
    }

    final response = await _apiService.putMultipart(
      '/admin/products/$id',
      data,
      files: files,
    );
    return Product.fromJson(response['data']);
  }

  // Invoice Management
  Future<List<Invoice>> getDailyInvoices({
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (deliveryBoyId != null) queryParams['deliveryBoyId'] = deliveryBoyId;

    final response = await _apiService.get(
      '/admin/invoices/daily',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => Invoice.fromJson(json))
        .toList();
  }

  Future<List<Invoice>> getMonthlyInvoices({
    String? startDate,
    String? endDate,
    String? customerId,
    String? paymentStatus,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (customerId != null) queryParams['customerId'] = customerId;
    if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;

    final response = await _apiService.get(
      '/admin/invoices/monthly',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => Invoice.fromJson(json))
        .toList();
  }

  Future<Invoice> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    final response = await _apiService.put(
      '/admin/invoices/$invoiceId/payment',
      {
        'paidAmount': amount,
        'paymentStatus': amount >= 0 ? 'paid' : 'pending',
        'paymentMethod': paymentMethod,
        if (transactionId != null) 'transactionId': transactionId,
        if (notes != null) 'notes': notes,
      },
    );
    return Invoice.fromJson(response['data']);
  }

  Future<Invoice> updateInvoicePaymentStatus({
    required String invoiceId,
    required String paymentStatus,
    double? paidAmount,
    String? notes,
  }) async {
    final response = await _apiService.put(
      '/admin/invoices/$invoiceId/payment',
      {
        'paymentStatus': paymentStatus,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (notes != null) 'notes': notes,
      },
    );
    return Invoice.fromJson(response['data']);
  }

  // Delivery Management
  Future<List<Delivery>> getDeliveries({
    String? startDate,
    String? endDate,
    String? customerId,
    String? deliveryBoyId,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (customerId != null) queryParams['customerId'] = customerId;
    if (deliveryBoyId != null) queryParams['deliveryBoyId'] = deliveryBoyId;
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get(
      '/admin/deliveries',
      queryParams: queryParams,
    );
    return (response['data'] as List)
        .map((json) => Delivery.fromJson(json))
        .toList();
  }

  // Reports & Analytics
  Future<Map<String, dynamic>> getRevenueReport({
    required String startDate,
    required String endDate,
    String? groupBy,
  }) async {
    final response = await _apiService.get(
      '/admin/reports/revenue',
      queryParams: {
        'startDate': startDate,
        'endDate': endDate,
        if (groupBy != null) 'groupBy': groupBy,
      },
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> getDeliveryReport({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiService.get(
      '/admin/reports/deliveries',
      queryParams: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return response['data'];
  }

  Future<Map<String, dynamic>> getDeliveryBoyPerformance({
    required String deliveryBoyId,
    required String startDate,
    required String endDate,
  }) async {
    final response = await _apiService.get(
      '/admin/reports/delivery-boy/$deliveryBoyId',
      queryParams: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    return response['data'];
  }

  // Notifications
  Future<void> sendWhatsAppMessage({
    required String recipientId,
    required String message,
  }) async {
    await _apiService.post('/admin/notifications/send', {
      'recipientId': recipientId,
      'message': message,
    });
  }

  Future<void> sendBulkWhatsAppMessages({
    required List<String> recipientIds,
    required String message,
  }) async {
    await _apiService.post('/admin/notifications/bulk-send', {
      'recipientIds': recipientIds,
      'message': message,
    });
  }

  // Invoice Generation
  Future<Invoice> generateMonthlyInvoice({
    required String customerId,
    required int year,
    required int month,
  }) async {
    final response = await _apiService.post(
      '/admin/invoices/monthly/generate',
      {
        'customerId': customerId,
        'year': year,
        'month': month,
      },
    );
    return Invoice.fromJson(response['data']);
  }

  Future<Invoice> generateDailyInvoice({
    required String deliveryBoyId,
    required String date,
  }) async {
    final response = await _apiService.post(
      '/admin/invoices/daily/generate',
      {
        'deliveryBoyId': deliveryBoyId,
        'date': date,
      },
    );
    return Invoice.fromJson(response['data']);
  }
}
