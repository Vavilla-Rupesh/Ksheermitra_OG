/// Delivery Location Entity
/// Represents a geographic location for delivery verification.
///
/// This entity is used throughout the delivery verification module
/// to represent both agent positions and delivery destinations.
library;

class DeliveryLocation {
  /// Latitude coordinate in degrees (-90 to 90)
  final double latitude;

  /// Longitude coordinate in degrees (-180 to 180)
  final double longitude;

  /// Optional accuracy of the GPS reading in meters
  final double? accuracy;

  /// Timestamp when this location was captured
  final DateTime? timestamp;

  /// Optional altitude in meters above sea level
  final double? altitude;

  /// Optional heading/bearing in degrees (0-360)
  final double? heading;

  /// Optional speed in meters per second
  final double? speed;

  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
    this.altitude,
    this.heading,
    this.speed,
  });

  /// Creates a DeliveryLocation from a JSON map
  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      accuracy: json['accuracy'] != null ? _parseDouble(json['accuracy']) : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      altitude: json['altitude'] != null ? _parseDouble(json['altitude']) : null,
      heading: json['heading'] != null ? _parseDouble(json['heading']) : null,
      speed: json['speed'] != null ? _parseDouble(json['speed']) : null,
    );
  }

  /// Converts the DeliveryLocation to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (altitude != null) 'altitude': altitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    };
  }

  /// Helper method to parse double from various types
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw ArgumentError('Cannot parse $value to double');
  }

  /// Returns true if this location has valid coordinates
  bool get isValid {
    return latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180;
  }

  /// Returns true if this location has high accuracy (within 20 meters)
  bool get isHighAccuracy => accuracy != null && accuracy! <= 20;

  /// Returns true if this location has acceptable accuracy (within 100 meters)
  bool get isAcceptableAccuracy => accuracy != null && accuracy! <= 100;

  @override
  String toString() {
    return 'DeliveryLocation(lat: $latitude, lng: $longitude, accuracy: ${accuracy ?? "unknown"}m)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeliveryLocation &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  /// Creates a copy of this location with optional parameter overrides
  DeliveryLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
    double? altitude,
    double? heading,
    double? speed,
  }) {
    return DeliveryLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
    );
  }
}

