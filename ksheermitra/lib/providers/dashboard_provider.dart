import 'package:flutter/foundation.dart';
import '../models/dashboard_stats.dart';
import '../services/admin_api_service.dart';

class DashboardProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _adminApi.getDashboardStats();
      _lastRefresh = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading dashboard stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDashboardStats();
  }

  bool shouldRefresh() {
    if (_lastRefresh == null) return true;
    final difference = DateTime.now().difference(_lastRefresh!);
    return difference.inMinutes >= 5; // Auto-refresh every 5 minutes
  }
}
