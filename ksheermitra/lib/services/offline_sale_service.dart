import '../models/offline_sale.dart';
import 'api_service.dart';

class OfflineSaleService {
  final ApiService _apiService;

  OfflineSaleService(this._apiService);

  /// Create a new offline sale
  Future<OfflineSale> createOfflineSale(CreateOfflineSaleRequest request) async {
    try {
      final response = await _apiService.post(
        '/admin/offline-sales',
        request.toJson(),
      );

      if (response['success'] == true) {
        return OfflineSale.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create offline sale');
      }
    } catch (e) {
      throw Exception('Failed to create offline sale: $e');
    }
  }

  /// Get all offline sales with optional filters
  Future<List<OfflineSale>> getOfflineSales({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.get(
        '/admin/offline-sales',
        queryParams: queryParams,
      );

      if (response['success'] == true) {
        final salesList = response['data']['sales'] as List;
        return salesList.map((json) => OfflineSale.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch offline sales');
      }
    } catch (e) {
      throw Exception('Failed to fetch offline sales: $e');
    }
  }

  /// Get offline sale by ID
  Future<OfflineSale> getOfflineSaleById(String id) async {
    try {
      final response = await _apiService.get('/admin/offline-sales/$id');

      if (response['success'] == true) {
        return OfflineSale.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch offline sale');
      }
    } catch (e) {
      throw Exception('Failed to fetch offline sale: $e');
    }
  }

  /// Get sales statistics
  Future<SalesStats> getSalesStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.get(
        '/admin/offline-sales/stats',
        queryParams: queryParams,
      );

      if (response['success'] == true) {
        return SalesStats.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch sales stats');
      }
    } catch (e) {
      throw Exception('Failed to fetch sales stats: $e');
    }
  }

  /// Get admin daily invoice
  Future<Map<String, dynamic>> getAdminDailyInvoice(String date) async {
    try {
      final response = await _apiService.get(
        '/admin/invoices/admin-daily',
        queryParams: {'date': date},
      );

      if (response['success'] == true) {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch daily invoice');
      }
    } catch (e) {
      throw Exception('Failed to fetch daily invoice: $e');
    }
  }
}

