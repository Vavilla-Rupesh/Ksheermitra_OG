/// Geofence Utility
///
/// Provides distance calculation using the Haversine formula
/// for accurate geofence validation.
library;

import 'dart:math' as math;
import 'package:ksheermitra/core/delivery_verification/domain/entities/delivery_location.dart';

/// Utility class for geofence-related calculations.
///
/// Uses the Haversine formula for accurate distance calculation
/// on a spherical Earth model.
class GeofenceUtil {
  // Earth's radius in meters
  static const double _earthRadiusMeters = 6371000.0;

  // Private constructor to prevent instantiation
  GeofenceUtil._();

  /// Calculates the distance between two geographic coordinates.
  ///
  /// Uses the Haversine formula for accurate great-circle distance
  /// calculation on a spherical Earth.
  ///
  /// Parameters:
  /// - [lat1], [lon1]: First coordinate (latitude, longitude) in degrees
  /// - [lat2], [lon2]: Second coordinate (latitude, longitude) in degrees
  ///
  /// Returns: Distance in meters
  ///
  /// Example:
  /// ```dart
  /// final distance = GeofenceUtil.calculateDistance(
  ///   12.9716,  // lat1
  ///   77.5946,  // lon1
  ///   12.9815,  // lat2
  ///   77.5990,  // lon2
  /// );
  /// print('Distance: ${distance}m'); // ~1100m
  /// ```
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert degrees to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double deltaLatRad = _degreesToRadians(lat2 - lat1);
    final double deltaLonRad = _degreesToRadians(lon2 - lon1);

    // Haversine formula
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLonRad / 2) *
            math.sin(deltaLonRad / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// Calculates distance between two DeliveryLocation objects.
  ///
  /// Convenience method that wraps [calculateDistance].
  ///
  /// Returns: Distance in meters
  static double calculateDistanceBetweenLocations(
    DeliveryLocation location1,
    DeliveryLocation location2,
  ) {
    return calculateDistance(
      location1.latitude,
      location1.longitude,
      location2.latitude,
      location2.longitude,
    );
  }

  /// Checks if a location is within a specified radius of a center point.
  ///
  /// Parameters:
  /// - [location]: The location to check
  /// - [center]: The center point of the geofence
  /// - [radiusMeters]: The radius of the geofence in meters
  ///
  /// Returns: true if location is within the radius, false otherwise
  static bool isWithinRadius(
    DeliveryLocation location,
    DeliveryLocation center,
    double radiusMeters,
  ) {
    final distance = calculateDistanceBetweenLocations(location, center);
    return distance <= radiusMeters;
  }

  /// Checks if a location is within a geofence and returns detailed result.
  ///
  /// Returns a [GeofenceCheckResult] with distance and within-radius status.
  static GeofenceCheckResult checkGeofence(
    DeliveryLocation location,
    DeliveryLocation center,
    double radiusMeters,
  ) {
    final distance = calculateDistanceBetweenLocations(location, center);
    return GeofenceCheckResult(
      distance: distance,
      radiusMeters: radiusMeters,
      isWithinRadius: distance <= radiusMeters,
      location: location,
      center: center,
    );
  }

  /// Converts degrees to radians.
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Converts radians to degrees.
  static double _radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  /// Calculates the initial bearing from point 1 to point 2.
  ///
  /// Returns: Bearing in degrees (0-360, where 0 is North)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final deltaLonRad = _degreesToRadians(lon2 - lon1);

    final y = math.sin(deltaLonRad) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLonRad);

    final bearingRad = math.atan2(y, x);
    final bearingDeg = _radiansToDegrees(bearingRad);

    // Normalize to 0-360
    return (bearingDeg + 360) % 360;
  }

  /// Calculates a destination point given start point, bearing, and distance.
  ///
  /// Parameters:
  /// - [startLat], [startLon]: Starting coordinate in degrees
  /// - [bearingDegrees]: Initial bearing in degrees (0 = North)
  /// - [distanceMeters]: Distance to travel in meters
  ///
  /// Returns: Destination [DeliveryLocation]
  static DeliveryLocation calculateDestination(
    double startLat,
    double startLon,
    double bearingDegrees,
    double distanceMeters,
  ) {
    final lat1Rad = _degreesToRadians(startLat);
    final lon1Rad = _degreesToRadians(startLon);
    final bearingRad = _degreesToRadians(bearingDegrees);
    final angularDistance = distanceMeters / _earthRadiusMeters;

    final lat2Rad = math.asin(
      math.sin(lat1Rad) * math.cos(angularDistance) +
          math.cos(lat1Rad) * math.sin(angularDistance) * math.cos(bearingRad),
    );

    final lon2Rad = lon1Rad +
        math.atan2(
          math.sin(bearingRad) * math.sin(angularDistance) * math.cos(lat1Rad),
          math.cos(angularDistance) - math.sin(lat1Rad) * math.sin(lat2Rad),
        );

    return DeliveryLocation(
      latitude: _radiansToDegrees(lat2Rad),
      longitude: _radiansToDegrees(lon2Rad),
    );
  }

  /// Generates points around a center for visualizing a geofence circle.
  ///
  /// Parameters:
  /// - [center]: Center point of the circle
  /// - [radiusMeters]: Radius in meters
  /// - [numPoints]: Number of points to generate (default: 36 = every 10°)
  ///
  /// Returns: List of [DeliveryLocation] points forming the circle
  static List<DeliveryLocation> generateCirclePoints(
    DeliveryLocation center,
    double radiusMeters, {
    int numPoints = 36,
  }) {
    final points = <DeliveryLocation>[];
    final degreeStep = 360.0 / numPoints;

    for (int i = 0; i < numPoints; i++) {
      final bearing = i * degreeStep;
      final point = calculateDestination(
        center.latitude,
        center.longitude,
        bearing,
        radiusMeters,
      );
      points.add(point);
    }

    // Close the circle
    points.add(points.first);
    return points;
  }
}

/// Result of a geofence check
class GeofenceCheckResult {
  /// Distance from location to center in meters
  final double distance;

  /// Configured geofence radius in meters
  final double radiusMeters;

  /// Whether the location is within the radius
  final bool isWithinRadius;

  /// The checked location
  final DeliveryLocation location;

  /// The geofence center
  final DeliveryLocation center;

  const GeofenceCheckResult({
    required this.distance,
    required this.radiusMeters,
    required this.isWithinRadius,
    required this.location,
    required this.center,
  });

  /// How far outside the radius (negative if inside)
  double get distanceFromBoundary => distance - radiusMeters;

  /// Percentage of distance to radius (100% = at boundary, <100% = inside)
  double get percentageOfRadius => (distance / radiusMeters) * 100;

  /// Human-readable status message
  String get statusMessage {
    if (isWithinRadius) {
      return 'Within delivery zone (${distance.toStringAsFixed(0)}m from destination)';
    } else {
      return 'Outside delivery zone. ${distanceFromBoundary.toStringAsFixed(0)}m too far.';
    }
  }

  @override
  String toString() {
    return 'GeofenceCheckResult(distance: ${distance.toStringAsFixed(1)}m, '
        'radius: ${radiusMeters.toStringAsFixed(1)}m, '
        'isWithin: $isWithinRadius)';
  }
}

