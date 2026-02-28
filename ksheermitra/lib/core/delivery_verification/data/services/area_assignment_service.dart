/// Area Assignment Service
///
/// Handles area assignment operations for delivery boys.
/// Provides real-time area and customer data fetching.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/api_config.dart';
import '../../../../utils/storage_helper.dart';

/// Represents an assigned area with customers
class AssignedArea {
  final String id;
  final String name;
  final String? description;
  final double? centerLatitude;
  final double? centerLongitude;
  final List<AreaBoundaryPoint> boundaries;
  final List<AssignedCustomer> customers;
  final DateTime assignedDate;

  const AssignedArea({
    required this.id,
    required this.name,
    this.description,
    this.centerLatitude,
    this.centerLongitude,
    required this.boundaries,
    required this.customers,
    required this.assignedDate,
  });

  factory AssignedArea.fromJson(Map<String, dynamic> json) {
    return AssignedArea(
      id: json['id'] ?? json['areaId'] ?? '',
      name: json['name'] ?? 'Unknown Area',
      description: json['description'],
      centerLatitude: _parseDouble(json['centerLatitude']),
      centerLongitude: _parseDouble(json['centerLongitude']),
      boundaries: _parseBoundaries(json['boundaries']),
      customers: _parseCustomers(json['customers']),
      assignedDate: json['assignedDate'] != null
          ? DateTime.parse(json['assignedDate'].toString())
          : DateTime.now(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<AreaBoundaryPoint> _parseBoundaries(dynamic boundaries) {
    if (boundaries == null) return [];
    if (boundaries is! List) return [];
    return boundaries
        .map((b) => AreaBoundaryPoint.fromJson(b))
        .toList();
  }

  static List<AssignedCustomer> _parseCustomers(dynamic customers) {
    if (customers == null) return [];
    if (customers is! List) return [];
    return customers
        .map((c) => AssignedCustomer.fromJson(c))
        .toList();
  }

  /// Gets customers filtered by delivery status
  List<AssignedCustomer> getCustomersByStatus(String status) {
    return customers.where((c) => c.deliveryStatus == status).toList();
  }

  /// Gets pending customers
  List<AssignedCustomer> get pendingCustomers =>
      getCustomersByStatus('pending');

  /// Gets delivered customers
  List<AssignedCustomer> get deliveredCustomers =>
      getCustomersByStatus('delivered');

  /// Total pending deliveries count
  int get pendingCount => pendingCustomers.length;

  /// Total delivered count
  int get deliveredCount => deliveredCustomers.length;
}

/// Boundary point for area polygon
class AreaBoundaryPoint {
  final double lat;
  final double lng;

  const AreaBoundaryPoint({
    required this.lat,
    required this.lng,
  });

  factory AreaBoundaryPoint.fromJson(Map<String, dynamic> json) {
    return AreaBoundaryPoint(
      lat: _parseDouble(json['lat'] ?? json['latitude']) ?? 0.0,
      lng: _parseDouble(json['lng'] ?? json['longitude']) ?? 0.0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
  };
}

/// Customer assigned for delivery
class AssignedCustomer {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String deliveryStatus;
  final String? deliveryId;
  final double totalAmount;
  final List<AssignedDeliveryItem> items;
  final String? notes;

  const AssignedCustomer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    required this.deliveryStatus,
    this.deliveryId,
    required this.totalAmount,
    required this.items,
    this.notes,
  });

  factory AssignedCustomer.fromJson(Map<String, dynamic> json) {
    return AssignedCustomer(
      id: json['id'] ?? json['customerId'] ?? '',
      name: json['name'] ?? json['customerName'] ?? 'Unknown',
      phone: json['phone'] ?? json['customerPhone'],
      address: json['address'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      deliveryStatus: json['deliveryStatus'] ?? json['status'] ?? 'pending',
      deliveryId: json['deliveryId'],
      totalAmount: _parseDouble(json['totalAmount'] ?? json['amount']) ?? 0.0,
      items: _parseItems(json['items']),
      notes: json['notes'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<AssignedDeliveryItem> _parseItems(dynamic items) {
    if (items == null) return [];
    if (items is! List) return [];
    return items.map((i) => AssignedDeliveryItem.fromJson(i)).toList();
  }

  /// Whether customer has valid coordinates
  bool get hasValidLocation => latitude != null && longitude != null;

  /// Whether delivery is pending
  bool get isPending => deliveryStatus == 'pending';

  /// Whether delivery is complete
  bool get isDelivered => deliveryStatus == 'delivered';
}

/// Item in a delivery
class AssignedDeliveryItem {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double price;

  const AssignedDeliveryItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory AssignedDeliveryItem.fromJson(Map<String, dynamic> json) {
    return AssignedDeliveryItem(
      productId: json['productId'] ?? json['product']?['id'] ?? '',
      productName: json['productName'] ?? json['product']?['name'] ?? 'Unknown',
      quantity: _parseDouble(json['quantity']) ?? 0.0,
      unit: json['unit'] ?? json['product']?['unit'] ?? 'pcs',
      price: _parseDouble(json['price']) ?? 0.0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Total price for this item
  double get total => quantity * price;
}

/// Service for managing area assignments
class AreaAssignmentService {
  final Dio _dio;

  AreaAssignmentService() : _dio = Dio(BaseOptions(
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
        debugPrint('AreaAssignment API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Gets the assigned area for the current delivery boy for today
  ///
  /// Returns null if no area is assigned.
  Future<AssignedArea?> getTodaysAssignedArea() async {
    return getAssignedArea(date: DateTime.now());
  }

  /// Gets the assigned area for a specific date
  ///
  /// [date] - The date to fetch assignment for
  Future<AssignedArea?> getAssignedArea({DateTime? date}) async {
    try {
      final queryDate = date ?? DateTime.now();
      final dateString = '${queryDate.year}-${queryDate.month.toString().padLeft(2, '0')}-${queryDate.day.toString().padLeft(2, '0')}';

      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/delivery-map',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] != true) {
        return null;
      }

      final data = response.data['data'];
      if (data == null || data['area'] == null) {
        return null;
      }

      // Combine area and customers data
      final areaJson = data['area'] as Map<String, dynamic>;
      areaJson['customers'] = data['customers'] ?? [];
      areaJson['assignedDate'] = dateString;

      return AssignedArea.fromJson(areaJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No assignment found
      }
      throw AreaAssignmentException(
        message: _extractErrorMessage(e),
        code: 'FETCH_FAILED',
      );
    } catch (e) {
      throw AreaAssignmentException(
        message: 'Failed to fetch assigned area: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Gets delivery statistics for today
  Future<DeliveryStatistics> getTodaysStats() async {
    return getStats(date: DateTime.now());
  }

  /// Gets delivery statistics for a specific date
  Future<DeliveryStatistics> getStats({DateTime? date}) async {
    try {
      final queryDate = date ?? DateTime.now();
      final dateString = '${queryDate.year}-${queryDate.month.toString().padLeft(2, '0')}-${queryDate.day.toString().padLeft(2, '0')}';

      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/stats',
        queryParameters: {'date': dateString},
      );

      if (response.data['success'] != true) {
        throw AreaAssignmentException(
          message: response.data['message'] ?? 'Failed to fetch stats',
          code: 'FETCH_FAILED',
        );
      }

      return DeliveryStatistics.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AreaAssignmentException(
        message: _extractErrorMessage(e),
        code: 'FETCH_FAILED',
      );
    }
  }

  /// Checks if an area is assigned for today
  Future<bool> hasAssignedArea() async {
    final area = await getTodaysAssignedArea();
    return area != null;
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Network error occurred';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      default:
        return 'Network error occurred';
    }
  }
}

/// Delivery statistics
class DeliveryStatistics {
  final int totalDeliveries;
  final int completedDeliveries;
  final int pendingDeliveries;
  final int failedDeliveries;
  final double totalAmount;
  final double collectedAmount;

  const DeliveryStatistics({
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.pendingDeliveries,
    required this.failedDeliveries,
    required this.totalAmount,
    required this.collectedAmount,
  });

  factory DeliveryStatistics.fromJson(Map<String, dynamic> json) {
    return DeliveryStatistics(
      totalDeliveries: json['totalDeliveries'] ?? json['total'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? json['delivered'] ?? 0,
      pendingDeliveries: json['pendingDeliveries'] ?? json['pending'] ?? 0,
      failedDeliveries: json['failedDeliveries'] ?? json['failed'] ?? 0,
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      collectedAmount: _parseDouble(json['collectedAmount']) ?? 0.0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Completion percentage
  double get completionPercentage {
    if (totalDeliveries == 0) return 0;
    return (completedDeliveries / totalDeliveries) * 100;
  }

  /// Pending amount
  double get pendingAmount => totalAmount - collectedAmount;
}

/// Exception for area assignment operations
class AreaAssignmentException implements Exception {
  final String message;
  final String code;

  const AreaAssignmentException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'AreaAssignmentException: $message ($code)';
}

