import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/admin_api_service.dart';

class DeliveryBoyProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  List<User> _deliveryBoys = [];
  bool _isLoading = false;
  String? _error;

  List<User> get deliveryBoys => _deliveryBoys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<User> get activeDeliveryBoys =>
      _deliveryBoys.where((db) => db.isActive).toList();

  Future<void> loadDeliveryBoys() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveryBoys = await _adminApi.getDeliveryBoys();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading delivery boys: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDeliveryBoy({
    required String name,
    required String phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final deliveryBoy = await _adminApi.createDeliveryBoy(
        name: name,
        phone: phone,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      _deliveryBoys.add(deliveryBoy);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating delivery boy: $e');
      return false;
    }
  }

  Future<bool> updateDeliveryBoy({
    required String id,
    String? name,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    try {
      final updatedDb = await _adminApi.updateDeliveryBoy(
        id: id,
        name: name,
        email: email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isActive: isActive,
      );
      final index = _deliveryBoys.indexWhere((db) => db.id == id);
      if (index != -1) {
        _deliveryBoys[index] = updatedDb;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating delivery boy: $e');
      return false;
    }
  }

  User? getDeliveryBoyById(String id) {
    try {
      return _deliveryBoys.firstWhere((db) => db.id == id);
    } catch (e) {
      return null;
    }
  }
}
