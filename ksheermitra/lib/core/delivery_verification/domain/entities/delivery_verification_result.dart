/// Delivery Verification Result Entity
/// Represents the result of a delivery verification attempt.
library;

import 'delivery_location.dart';

/// Enumeration of possible verification statuses
enum VerificationStatus {
  /// Verification successful - within allowed radius
  success,

  /// Verification failed - outside allowed radius
  outsideRadius,

  /// GPS is disabled on the device
  gpsDisabled,

  /// Location permission denied by user
  permissionDenied,

  /// Location request timed out
  timeout,

  /// Backend rejected the verification
  backendRejected,

  /// Network error during verification
  networkError,

  /// Unknown error occurred
  unknown,
}

/// Result of a delivery verification attempt
class DeliveryVerificationResult {
  /// The verification status
  final VerificationStatus status;

  /// Whether the verification was successful
  final bool isSuccess;

  /// The agent's location at verification time
  final DeliveryLocation? agentLocation;

  /// The delivery destination location
  final DeliveryLocation? destinationLocation;

  /// Distance between agent and destination in meters
  final double? distanceMeters;

  /// Maximum allowed radius for delivery in meters
  final double? allowedRadiusMeters;

  /// Human-readable message describing the result
  final String message;

  /// Error code from backend (if applicable)
  final String? errorCode;

  /// Timestamp of the verification
  final DateTime verifiedAt;

  /// Delivery ID that was verified
  final String? deliveryId;

  /// Order ID that was verified
  final String? orderId;

  const DeliveryVerificationResult({
    required this.status,
    required this.isSuccess,
    this.agentLocation,
    this.destinationLocation,
    this.distanceMeters,
    this.allowedRadiusMeters,
    required this.message,
    this.errorCode,
    required this.verifiedAt,
    this.deliveryId,
    this.orderId,
  });

  /// Creates a successful verification result
  factory DeliveryVerificationResult.success({
    required DeliveryLocation agentLocation,
    required DeliveryLocation destinationLocation,
    required double distanceMeters,
    required double allowedRadiusMeters,
    String? deliveryId,
    String? orderId,
  }) {
    return DeliveryVerificationResult(
      status: VerificationStatus.success,
      isSuccess: true,
      agentLocation: agentLocation,
      destinationLocation: destinationLocation,
      distanceMeters: distanceMeters,
      allowedRadiusMeters: allowedRadiusMeters,
      message: 'Delivery verification successful. Distance: ${distanceMeters.toStringAsFixed(1)}m',
      verifiedAt: DateTime.now(),
      deliveryId: deliveryId,
      orderId: orderId,
    );
  }

  /// Creates a failed verification due to being outside radius
  factory DeliveryVerificationResult.outsideRadius({
    required DeliveryLocation agentLocation,
    required DeliveryLocation destinationLocation,
    required double distanceMeters,
    required double allowedRadiusMeters,
    String? deliveryId,
    String? orderId,
  }) {
    return DeliveryVerificationResult(
      status: VerificationStatus.outsideRadius,
      isSuccess: false,
      agentLocation: agentLocation,
      destinationLocation: destinationLocation,
      distanceMeters: distanceMeters,
      allowedRadiusMeters: allowedRadiusMeters,
      message: 'You are ${distanceMeters.toStringAsFixed(0)}m away. Please move within ${allowedRadiusMeters.toStringAsFixed(0)}m of the delivery location.',
      verifiedAt: DateTime.now(),
      deliveryId: deliveryId,
      orderId: orderId,
    );
  }

  /// Creates a failed verification due to GPS being disabled
  factory DeliveryVerificationResult.gpsDisabled() {
    return DeliveryVerificationResult(
      status: VerificationStatus.gpsDisabled,
      isSuccess: false,
      message: 'GPS is disabled. Please enable location services to verify delivery.',
      verifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed verification due to permission denied
  factory DeliveryVerificationResult.permissionDenied() {
    return DeliveryVerificationResult(
      status: VerificationStatus.permissionDenied,
      isSuccess: false,
      message: 'Location permission denied. Please grant location access in settings.',
      verifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed verification due to timeout
  factory DeliveryVerificationResult.timeout() {
    return DeliveryVerificationResult(
      status: VerificationStatus.timeout,
      isSuccess: false,
      message: 'Location request timed out. Please try again in an open area.',
      verifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed verification due to backend rejection
  factory DeliveryVerificationResult.backendRejected({
    String? errorMessage,
    String? errorCode,
    double? distanceMeters,
    double? allowedRadiusMeters,
  }) {
    return DeliveryVerificationResult(
      status: VerificationStatus.backendRejected,
      isSuccess: false,
      distanceMeters: distanceMeters,
      allowedRadiusMeters: allowedRadiusMeters,
      message: errorMessage ?? 'Server rejected the delivery verification.',
      errorCode: errorCode,
      verifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed verification due to network error
  factory DeliveryVerificationResult.networkError({String? errorMessage}) {
    return DeliveryVerificationResult(
      status: VerificationStatus.networkError,
      isSuccess: false,
      message: errorMessage ?? 'Network error. Please check your connection and try again.',
      verifiedAt: DateTime.now(),
    );
  }

  /// Creates a failed verification due to unknown error
  factory DeliveryVerificationResult.unknown({String? errorMessage}) {
    return DeliveryVerificationResult(
      status: VerificationStatus.unknown,
      isSuccess: false,
      message: errorMessage ?? 'An unexpected error occurred. Please try again.',
      verifiedAt: DateTime.now(),
    );
  }

  /// Converts to JSON for logging/transmission
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'isSuccess': isSuccess,
      'agentLocation': agentLocation?.toJson(),
      'destinationLocation': destinationLocation?.toJson(),
      'distanceMeters': distanceMeters,
      'allowedRadiusMeters': allowedRadiusMeters,
      'message': message,
      'errorCode': errorCode,
      'verifiedAt': verifiedAt.toIso8601String(),
      'deliveryId': deliveryId,
      'orderId': orderId,
    };
  }

  @override
  String toString() {
    return 'DeliveryVerificationResult(status: $status, isSuccess: $isSuccess, distance: ${distanceMeters?.toStringAsFixed(1)}m)';
  }
}

