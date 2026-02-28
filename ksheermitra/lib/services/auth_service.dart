import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> sendOTP(String phone) async {
    return await _apiService.post('/auth/send-otp', {'phone': phone}, requiresAuth: false);
  }

  Future<Map<String, dynamic>> verifyOTP(String phone, String otp) async {
    final response = await _apiService.post('/auth/verify-otp', {
      'phone': phone,
      'otp': otp,
    }, requiresAuth: false);

    // Only save token and user if registration is complete
    if (response['success'] == true &&
        response['requiresRegistration'] != true &&
        response['token'] != null) {
      await _apiService.setToken(response['token']);
      await saveUser(User.fromJson(response['user']));
    }

    return response;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String otp,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'otp': otp,
    };

    if (email != null && email.isNotEmpty) data['email'] = email;
    if (address != null && address.isNotEmpty) data['address'] = address;
    if (latitude != null) data['latitude'] = latitude.toString();
    if (longitude != null) data['longitude'] = longitude.toString();

    final response = await _apiService.post('/auth/register', data, requiresAuth: false);

    if (response['success'] == true && response['token'] != null) {
      await _apiService.setToken(response['token']);
      await saveUser(User.fromJson(response['user']));
    }

    return response;
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<User?> getUser() async {
    try {
      // Load the token back into ApiService
      await _apiService.loadToken();

      // Fetch fresh user data from API
      final response = await _apiService.get('/customer/profile');

      if (response['success'] == true && response['data'] != null) {
        final user = User.fromJson(response['data']);
        // Update cached data with fresh data from API
        await saveUser(user);
        return user;
      }
    } catch (e) {
      debugPrint('Error fetching user from API: $e');
      // Fall back to cached data if API fails
    }

    // Fallback to cached data if API call fails
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<void> refreshToken(String refreshToken) async {
    final response = await _apiService.post('/auth/refresh-token', {
      'refreshToken': refreshToken,
    });

    if (response['success'] == true && response['token'] != null) {
      await _apiService.setToken(response['token']);
    }
  }
}
