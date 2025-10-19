import 'package:flutter/foundation.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/customer/subscriptions');
      if (response['success'] == true) {
        _subscriptions = (response['data'] as List)
            .map((json) => Subscription.fromJson(json))
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSubscription(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/customer/subscriptions', data);
      _isLoading = false;
      notifyListeners();
      
      if (response['success'] == true) {
        await loadSubscriptions();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> pauseSubscription(String id, String startDate, String endDate) async {
    try {
      final response = await _apiService.post(
        '/customer/subscriptions/$id/pause',
        {
          'pauseStartDate': startDate,
          'pauseEndDate': endDate,
        },
      );
      
      if (response['success'] == true) {
        await loadSubscriptions();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resumeSubscription(String id) async {
    try {
      final response = await _apiService.post(
        '/customer/subscriptions/$id/resume',
        {},
      );
      
      if (response['success'] == true) {
        await loadSubscriptions();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
