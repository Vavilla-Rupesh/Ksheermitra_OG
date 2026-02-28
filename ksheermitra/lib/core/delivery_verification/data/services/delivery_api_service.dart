/// Delivery API Service
///
/// Handles all backend API calls for delivery verification.
/// The backend performs its own distance validation for security.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ksheermitra/config/api_config.dart';
import 'package:ksheermitra/utils/storage_helper.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_location.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_order.dart';
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_verification_result.dart';

/// Service for backend delivery API communication.
///
/// All delivery completions must be validated by the backend.
/// The frontend validation is only for UX - backend is the source of truth.
class DeliveryApiService {
  final Dio _dio;

  /// Creates the delivery API service with configured Dio instance
  DeliveryApiService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.requestTimeout,
    receiveTimeout: ApiConfig.requestTimeout,
    headers: ApiConfig.defaultHeaders,
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Log error details for debugging
        debugPrint('API Error: ${error.message}');
        debugPrint('Status Code: ${error.response?.statusCode}');
        debugPrint('Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  /// Creates a DeliveryApiService with a custom Dio instance (for testing)
  DeliveryApiService.withDio(this._dio);

  /// Fetches pending deliveries for the current delivery agent
  ///
  /// Returns list of [DeliveryOrder] that are pending or in progress.
  Future<List<DeliveryOrder>> getPendingDeliveries({String? date}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/delivery-map',
        queryParameters: date != null ? {'date': date} : null,
      );

      if (response.data['success'] != true) {
        throw DeliveryApiException(
          message: response.data['message'] ?? 'Failed to fetch deliveries',
          code: 'FETCH_FAILED',
        );
      }

      final routes = response.data['data']['routes'] as List<dynamic>? ?? [];
      return routes.map((route) => DeliveryOrder.fromJson(route)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is DeliveryApiException) rethrow;
      throw DeliveryApiException(
        message: 'Failed to fetch deliveries: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Verifies delivery location and marks order as delivered.
  ///
  /// The backend will:
  /// 1. Re-calculate the distance between agent and destination
  /// 2. Validate the agent is within allowed radius
  /// 3. Log the verification attempt with timestamp and coordinates
  /// 4. Update order status if validation passes
  ///
  /// Returns [DeliveryVerificationResult] indicating success or failure.
  ///
  /// IMPORTANT: Do NOT trust frontend validation alone. This method
  /// sends coordinates to backend for re-verification.
  Future<DeliveryVerificationResult> verifyAndCompleteDelivery({
    required String deliveryId,
    required DeliveryLocation agentLocation,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/verify-delivery',
        data: {
          'deliveryId': deliveryId,
          'agentLatitude': agentLocation.latitude,
          'agentLongitude': agentLocation.longitude,
          'agentAccuracy': agentLocation.accuracy,
          'timestamp': DateTime.now().toIso8601String(),
          'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return DeliveryVerificationResult.success(
          agentLocation: agentLocation,
          destinationLocation: DeliveryLocation(
            latitude: _parseDouble(response.data['data']['destinationLatitude']),
            longitude: _parseDouble(response.data['data']['destinationLongitude']),
          ),
          distanceMeters: _parseDouble(response.data['data']['distance']),
          allowedRadiusMeters: _parseDouble(response.data['data']['allowedRadius'] ?? 100),
          deliveryId: deliveryId,
        );
      } else {
        // Backend rejected - could be outside radius or other validation failure
        final errorCode = response.data['errorCode'] ?? 'VERIFICATION_FAILED';
        final distance = response.data['data']?['distance'];
        final allowedRadius = response.data['data']?['allowedRadius'];

        if (errorCode == 'OUTSIDE_RADIUS') {
          return DeliveryVerificationResult.backendRejected(
            errorMessage: response.data['message'] ?? 'You are outside the delivery zone.',
            errorCode: errorCode,
            distanceMeters: distance != null ? _parseDouble(distance) : null,
            allowedRadiusMeters: allowedRadius != null ? _parseDouble(allowedRadius) : null,
          );
        }

        return DeliveryVerificationResult.backendRejected(
          errorMessage: response.data['message'] ?? 'Delivery verification failed.',
          errorCode: errorCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return DeliveryVerificationResult.networkError(
          errorMessage: 'Request timed out. Please check your connection.',
        );
      }

      if (e.response == null) {
        return DeliveryVerificationResult.networkError(
          errorMessage: 'No internet connection. Please try again.',
        );
      }

      // Server returned an error response
      final data = e.response?.data;
      if (data is Map) {
        return DeliveryVerificationResult.backendRejected(
          errorMessage: data['message'] ?? 'Server error occurred.',
          errorCode: data['errorCode'],
        );
      }

      return DeliveryVerificationResult.networkError(
        errorMessage: 'Server error: ${e.response?.statusCode}',
      );
    } catch (e) {
      return DeliveryVerificationResult.unknown(
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  /// Updates delivery status without location verification.
  ///
  /// Used for status updates that don't require geofence validation
  /// (e.g., marking as "in progress", adding notes).
  Future<void> updateDeliveryStatus({
    required String customerId,
    required String status,
    String? notes,
    String? date,
  }) async {
    try {
      await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/update-status',
        queryParameters: date != null ? {'date': date} : null,
        data: {
          'customerId': customerId,
          'status': status,
          'notes': notes,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates agent's current location on the server.
  ///
  /// Used for real-time tracking and route optimization.
  Future<void> updateAgentLocation(DeliveryLocation location) async {
    try {
      await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/update-location',
        data: {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'accuracy': location.accuracy,
          'timestamp': location.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'speed': location.speed,
          'heading': location.heading,
        },
      );
    } on DioException catch (e) {
      // Location updates are non-critical, log but don't throw
      debugPrint('Failed to update agent location: ${e.message}');
    }
  }

  /// Gets the allowed delivery radius from server configuration.
  ///
  /// Returns radius in meters. Defaults to 100m if not configured.
  Future<double> getAllowedDeliveryRadius() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/config',
      );
      return _parseDouble(response.data['data']?['allowedDeliveryRadius'] ?? 100);
    } catch (e) {
      return 100.0; // Default 100 meters
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  DeliveryApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const DeliveryApiException(
        message: 'Connection timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }

    if (e.response == null) {
      return const DeliveryApiException(
        message: 'No internet connection.',
        code: 'NO_CONNECTION',
      );
    }

    final data = e.response?.data;
    if (data is Map) {
      return DeliveryApiException(
        message: data['message'] ?? 'Server error',
        code: data['errorCode'] ?? 'SERVER_ERROR',
        statusCode: e.response?.statusCode,
      );
    }

    return DeliveryApiException(
      message: 'Server error: ${e.response?.statusCode}',
      code: 'SERVER_ERROR',
      statusCode: e.response?.statusCode,
    );
  }
}

/// Exception thrown by delivery API operations
class DeliveryApiException implements Exception {
  final String message;
  final String code;
  final int? statusCode;

  const DeliveryApiException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  @override
  String toString() => 'DeliveryApiException: $message (code: $code)';
}

