import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/area.dart';
import '../services/admin_api_service.dart';

class AreaProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  List<Area> _areas = [];
  bool _isLoading = false;
  String? _error;

  List<Area> get areas => _areas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Area> get activeAreas => _areas.where((a) => a.isActive).toList();

  Future<void> loadAreas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _areas = await _adminApi.getAreas();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading areas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createArea({
    required String name,
    String? description,
    String? deliveryBoyId,
    List<LatLng>? boundaries,
    double? centerLatitude,
    double? centerLongitude,
  }) async {
    try {
      final area = await _adminApi.createArea(
        name: name,
        description: description,
        deliveryBoyId: deliveryBoyId,
        boundaries: boundaries,
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
      );
      _areas.add(area);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating area: $e');
      return false;
    }
  }

  Future<bool> updateArea({
    required String id,
    String? name,
    String? description,
    String? deliveryBoyId,
    bool? isActive,
  }) async {
    try {
      final updatedArea = await _adminApi.updateArea(
        id: id,
        name: name,
        description: description,
        deliveryBoyId: deliveryBoyId,
        isActive: isActive,
      );
      final index = _areas.indexWhere((a) => a.id == id);
      if (index != -1) {
        _areas[index] = updatedArea;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating area: $e');
      return false;
    }
  }

  Future<bool> updateAreaBoundaries({
    required String id,
    required List<LatLng> boundaries,
    required double centerLatitude,
    required double centerLongitude,
  }) async {
    try {
      final updatedArea = await _adminApi.updateAreaBoundaries(
        id: id,
        boundaries: boundaries,
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
      );
      final index = _areas.indexWhere((a) => a.id == id);
      if (index != -1) {
        _areas[index] = updatedArea;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating area boundaries: $e');
      return false;
    }
  }

  Future<bool> assignArea({
    required String customerId,
    required String areaId,
  }) async {
    try {
      await _adminApi.assignArea(customerId: customerId, areaId: areaId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error assigning area: $e');
      return false;
    }
  }

  Future<bool> bulkAssignArea({
    required List<String> customerIds,
    required String areaId,
  }) async {
    try {
      await _adminApi.bulkAssignArea(customerIds: customerIds, areaId: areaId);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error bulk assigning area: $e');
      return false;
    }
  }

  Area? getAreaById(String id) {
    try {
      return _areas.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
