import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    debugPrint('✅ Token saved: ${token.substring(0, 20)}...');
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      debugPrint('✅ Token loaded: ${_token!.substring(0, 20)}...');
    } else {
      debugPrint('❌ No token found in storage');
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    debugPrint('🗑️ Token cleared');
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Bypass ngrok browser warning
      'User-Agent': 'KsheerMitra-App', // Custom user agent
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
      debugPrint('🔐 Including auth header in request');
    } else if (includeAuth && _token == null) {
      debugPrint('⚠️ Auth required but no token available!');
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      debugPrint('📤 POST $endpoint (requiresAuth: $requiresAuth)');
      debugPrint('📦 Request payload: ${json.encode(data)}');
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');

      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
        body: json.encode(data),
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          debugPrint('⏱️ Request timeout for POST $endpoint');
          throw Exception('Request timeout. Please check your connection and try again.');
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ POST $endpoint failed: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      }

      final response = await http.get(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
      ).timeout(
        AppConfig.requestTimeout,
        onTimeout: () {
          debugPrint('⏱️ Request timeout for GET $endpoint');
          throw Exception('Request timeout. Please check your connection and try again.');
        },
      );

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ GET $endpoint failed: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Request timed out. Please try again.');
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await http.put(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
        body: json.encode(data),
      ).timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await http.delete(
        url,
        headers: _getHeaders(includeAuth: requiresAuth),
      ).timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? files,
    bool requiresAuth = true,
  }) async {
    try {
      debugPrint('📤 POST (multipart) $endpoint (requiresAuth: $requiresAuth)');

      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers (without Content-Type, it will be set automatically)
      if (requiresAuth && _token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
        debugPrint('🔐 Including auth header in multipart request');
      }

      // Add text fields
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            final file = await http.MultipartFile.fromPath(
              entry.key,
              entry.value,
            );
            request.files.add(file);
            debugPrint('📎 Added file: ${entry.key} = ${entry.value}');
          }
        }
      }

      final streamedResponse = await request.send().timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ POST (multipart) $endpoint failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? files,
    bool requiresAuth = true,
  }) async {
    try {
      debugPrint('📤 PUT (multipart) $endpoint (requiresAuth: $requiresAuth)');

      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('PUT', url);

      // Add headers
      if (requiresAuth && _token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
        debugPrint('🔐 Including auth header in multipart request');
      }

      // Add text fields
      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            final file = await http.MultipartFile.fromPath(
              entry.key,
              entry.value,
            );
            request.files.add(file);
            debugPrint('📎 Added file: ${entry.key} = ${entry.value}');
          }
        }
      }

      final streamedResponse = await request.send().timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      debugPrint('❌ PUT (multipart) $endpoint failed: $e');
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Handle validation errors with details
      if (data['errors'] != null && data['errors'] is List) {
        final errorMessages = (data['errors'] as List)
            .map((e) => '${e['field']}: ${e['message']}')
            .join('\n');
        debugPrint('❌ Validation errors:\n$errorMessages');
        throw Exception('${data['message'] ?? 'Request failed'}\n$errorMessages');
      }
      throw Exception(data['message'] ?? 'Request failed');
    }
  }
}
