import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/delivery_models.dart';
import '../utils/storage_helper.dart';

class DeliveryService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.requestTimeout,
    receiveTimeout: ApiConfig.requestTimeout,
    headers: ApiConfig.defaultHeaders,
  ));

  DeliveryService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Delivery Boy Endpoints

  Future<Map<String, dynamic>> getDeliveryMap({String? date}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/delivery-map',
        queryParameters: date != null ? {'date': date} : null,
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Customer>> getAssignedCustomers({String? date}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/customers',
        queryParameters: date != null ? {'date': date} : null,
      );

      final List<dynamic> data = response.data['data'];
      return data.map((c) => Customer.fromJson(c['customer'])).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Customer> getCustomerDetails(String customerId, {String? date}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/customers/$customerId',
        queryParameters: date != null ? {'date': date} : null,
      );
      return Customer.fromJson(response.data['data']['customer']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOptimizedRoute({String? date}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/route',
        queryParameters: date != null ? {'date': date} : null,
      );
      return response.data['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateDeliveryStatus({
    required String deliveryId,
    required String status,
    String? notes,
  }) async {
    try {
      await _dio.patch(
        '${ApiConfig.deliveryBoyEndpoint}/delivery/$deliveryId/status',
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DeliveryStats> getDeliveryStats({String? date, String period = 'today'}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/stats',
        queryParameters: {
          'period': period,
          if (date != null) 'date': date,
        },
      );
      return DeliveryStats.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/update-location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> generateDailyInvoice({String? date}) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/generate-invoice',
        data: {
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Area?> getMyArea() async {
    try {
      final response = await _dio.get('${ApiConfig.deliveryBoyEndpoint}/area');
      return response.data['data'] != null
          ? Area.fromJson(response.data['data'])
          : null;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTodaysSummary() async {
    try {
      final response = await _dio.get('${ApiConfig.deliveryBoyEndpoint}/summary');
      return response.data['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Admin Endpoints

  Future<List<DeliveryBoy>> getAllDeliveryBoys() async {
    try {
      final response = await _dio.get('${ApiConfig.adminEndpoint}/delivery-boys');
      final List<dynamic> data = response.data['data'];
      return data.map((d) => DeliveryBoy.fromJson(d)).toList();
    } catch (e) {
      throw _handleError(e);
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
      final response = await _dio.post(
        '${ApiConfig.adminEndpoint}/delivery-boys',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return DeliveryBoy.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
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
      final response = await _dio.put(
        '${ApiConfig.adminEndpoint}/delivery-boys/$id',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (isActive != null) 'isActive': isActive,
        },
      );
      return DeliveryBoy.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DeliveryBoy> getDeliveryBoyDetails(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.adminEndpoint}/delivery-boys/$id');
      return DeliveryBoy.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Area>> getAllAreas() async {
    try {
      final response = await _dio.get('${ApiConfig.adminEndpoint}/areas');
      final List<dynamic> data = response.data['data'];
      return data.map((a) => Area.fromJson(a)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Area> createArea({
    required String name,
    String? description,
    List<LatLngPoint>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
    String? mapLink,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.adminEndpoint}/areas',
        data: {
          'name': name,
          'description': description,
          'boundaries': boundaries?.map((b) => b.toJson()).toList(),
          'centerLatitude': centerLatitude,
          'centerLongitude': centerLongitude,
          'mapLink': mapLink,
        },
      );
      return Area.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assignAreaToDeliveryBoy({
    required String areaId,
    required String deliveryBoyId,
    List<LatLngPoint>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
    String? mapLink,
  }) async {
    try {
      await _dio.post(
        '${ApiConfig.adminEndpoint}/assign-area-with-map',
        data: {
          'areaId': areaId,
          'deliveryBoyId': deliveryBoyId,
          'boundaries': boundaries?.map((b) => b.toJson()).toList(),
          'centerLatitude': centerLatitude,
          'centerLongitude': centerLongitude,
          'mapLink': mapLink,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Area> getAreaWithCustomers(String areaId) async {
    try {
      final response = await _dio.get('${ApiConfig.adminEndpoint}/areas/$areaId/customers');
      return Area.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('${ApiConfig.adminEndpoint}/dashboard/stats');
      return response.data['data'];
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data['message'] != null) {
        return error.response!.data['message'];
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          return 'Server error. Please try again later.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'An unexpected error occurred.';
      }
    }
    return error.toString();
  }
}
