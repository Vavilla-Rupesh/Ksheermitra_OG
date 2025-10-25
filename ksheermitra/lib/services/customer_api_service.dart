import '../models/subscription.dart';
import '../models/product.dart';
import '../models/delivery.dart';
import '../models/invoice.dart';
import '../models/user.dart';
import '../models/monthly_breakout.dart';
import 'api_service.dart';

class CustomerApiService {
  final ApiService _apiService = ApiService();

  // Profile Management
  Future<User> getProfile() async {
    final response = await _apiService.get('/customer/profile');
    return User.fromJson(response['data']);
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiService.put('/customer/profile', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    });
    return User.fromJson(response['data']);
  }

  // Product Management
  Future<List<Product>> getProducts() async {
    final response = await _apiService.get('/customer/products');
    return (response['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // Multi-Product Subscription Management
  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> subscriptionData) async {
    final response = await _apiService.post('/customer/subscriptions', subscriptionData);
    return response;
  }

  Future<List<Subscription>> getSubscriptions() async {
    final response = await _apiService.get('/customer/subscriptions');
    return (response['data'] as List)
        .map((json) => Subscription.fromJson(json))
        .toList();
  }

  Future<Subscription> getSubscriptionDetails(String id) async {
    final response = await _apiService.get('/customer/subscriptions/$id');
    return Subscription.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> updateSubscription(String id, Map<String, dynamic> updateData) async {
    final response = await _apiService.put('/customer/subscriptions/$id', updateData);
    return response;
  }

  Future<Map<String, dynamic>> addProductsToSubscription(String id, List<Map<String, dynamic>> products) async {
    final response = await _apiService.post('/customer/subscriptions/$id/products', {
      'products': products,
    });
    return response;
  }

  Future<Map<String, dynamic>> removeProductFromSubscription(String id, String productId) async {
    final response = await _apiService.delete('/customer/subscriptions/$id/products/$productId');
    return response;
  }

  Future<Map<String, dynamic>> pauseSubscription({
    required String id,
    required String pauseStartDate,
    required String pauseEndDate,
  }) async {
    final response = await _apiService.post(
      '/customer/subscriptions/$id/pause',
      {
        'pauseStartDate': pauseStartDate,
        'pauseEndDate': pauseEndDate,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> resumeSubscription(String id) async {
    final response = await _apiService.post(
      '/customer/subscriptions/$id/resume',
      {},
    );
    return response;
  }

  Future<Map<String, dynamic>> cancelSubscription(String id) async {
    final response = await _apiService.post(
      '/customer/subscriptions/$id/cancel',
      {},
    );
    return response;
  }

  Future<Map<String, dynamic>> updateTodayDelivery(String id, List<Map<String, dynamic>> items) async {
    final response = await _apiService.post(
      '/customer/subscriptions/$id/today',
      {
        'items': items,
      },
    );
    return response;
  }

  // Delivery Management
  Future<List<Delivery>> getDeliveryHistory({String? startDate, String? endDate}) async {
    final response = await _apiService.get('/customer/deliveries', queryParams: {
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return (response['data'] as List)
        .map((json) => Delivery.fromJson(json))
        .toList();
  }

  // Invoice Management
  Future<List<Invoice>> getInvoices() async {
    final response = await _apiService.get('/customer/invoices');
    return (response['data'] as List)
        .map((json) => Invoice.fromJson(json))
        .toList();
  }

  // Monthly Breakout Management
  Future<MonthlyBreakoutResponse> getSubscriptionMonthlyBreakout(
    String subscriptionId, {
    int? year,
    int? month,
  }) async {
    final response = await _apiService.get(
      '/customer/subscriptions/$subscriptionId/monthly-breakout',
      queryParams: {
        if (year != null) 'year': year.toString(),
        if (month != null) 'month': month.toString(),
      },
    );
    return MonthlyBreakoutResponse.fromJson(response['data']);
  }

  Future<CustomerMonthlyBreakout> getCustomerMonthlyBreakout(
    int year,
    int month,
  ) async {
    final response = await _apiService.get(
      '/customer/monthly-breakout/$year/$month',
    );
    return CustomerMonthlyBreakout.fromJson(response['data']);
  }

  Future<Map<String, dynamic>> modifyDeliveryProducts(
    String deliveryId,
    List<Map<String, dynamic>> products,
  ) async {
    final response = await _apiService.put(
      '/customer/deliveries/$deliveryId/products',
      {'products': products},
    );
    return response;
  }

  Future<Map<String, dynamic>> generateMonthlyInvoice(
    int year,
    int month,
  ) async {
    final response = await _apiService.post(
      '/customer/monthly-invoice/$year/$month',
      {},
    );
    return response;
  }

  Future<Invoice?> getMonthlyInvoice(int year, int month) async {
    try {
      final response = await _apiService.get(
        '/customer/monthly-invoice/$year/$month',
      );
      return Invoice.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
}
