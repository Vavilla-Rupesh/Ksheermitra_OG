import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/admin_api_service.dart';

class CustomerProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  List<User> _customers = [];
  Map<String, dynamic>? _pagination;
  bool _isLoading = false;
  String? _error;

  List<User> get customers => _customers;
  Map<String, dynamic>? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers({
    int page = 1,
    int limit = 50,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminApi.getCustomers(
        page: page,
        limit: limit,
        search: search,
      );
      _customers = result['customers'];
      _pagination = result['pagination'];
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<User>> loadCustomersWithLocations() async {
    try {
      return await _adminApi.getCustomersWithLocations();
    } catch (e) {
      debugPrint('Error loading customers with locations: $e');
      return [];
    }
  }

  Future<User?> getCustomerDetails(String customerId) async {
    try {
      return await _adminApi.getCustomerDetails(customerId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading customer details: $e');
      return null;
    }
  }

  User? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<User> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final customer = await _adminApi.createCustomer(
      name: name,
      phone: phone,
      email: email,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
    // Reload the list to include the new customer
    await loadCustomers();
    return customer;
  }
}
