import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for managing WhatsApp Admin QR Code Login
///
/// This service handles:
/// - Getting QR code for WhatsApp session
/// - Checking session status
/// - Monitoring session expiration
/// - Resetting sessions
class WhatsAppLoginService {
  final String baseUrl;
  final String username;
  final String password;

  late String _basicAuth;

  WhatsAppLoginService({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) {
    _basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  }

  /// Get WhatsApp QR code for login
  ///
  /// Returns a Data URL containing the base64 encoded PNG image
  Future<WhatsAppQRResponse> getQRCode() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/whatsapp-login/get-qr'),
        headers: {
          'Authorization': _basicAuth,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WhatsAppQRResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid admin credentials');
      } else {
        throw Exception('Failed to get QR code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting QR code: $e');
    }
  }

  /// Get current WhatsApp session status
  Future<WhatsAppSessionStatus> getSessionStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/whatsapp-login/status'),
        headers: {
          'Authorization': _basicAuth,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return WhatsAppSessionStatus.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid admin credentials');
      }
      throw Exception('Failed to get session status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting session status: $e');
    }
  }

  /// Get detailed session info with expiration alert
  Future<WhatsAppSessionInfo> getSessionInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/whatsapp-login/info'),
        headers: {
          'Authorization': _basicAuth,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return WhatsAppSessionInfo.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid admin credentials');
      }
      throw Exception('Failed to get session info: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting session info: $e');
    }
  }

  /// Reset WhatsApp session and request new QR code
  Future<void> resetSession() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/whatsapp-login/reset'),
        headers: {
          'Authorization': _basicAuth,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return;
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid admin credentials');
      }
      throw Exception('Failed to reset session: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error resetting session: $e');
    }
  }

  /// Check if session needs renewal (expiring within specified minutes)
  Future<bool> isSessionExpiringSoon({int minutesThreshold = 60}) async {
    try {
      final info = await getSessionInfo();
      if (info.expirationAlert.isExpiringSoon &&
          info.expirationAlert.minutesUntilExpiry <= minutesThreshold) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Response model for QR code generation
class WhatsAppQRResponse {
  final bool success;
  final String message;
  final String qrCode;
  final String sessionId;
  final int expiresIn;
  final List<String> instructions;

  WhatsAppQRResponse({
    required this.success,
    required this.message,
    required this.qrCode,
    required this.sessionId,
    required this.expiresIn,
    required this.instructions,
  });

  factory WhatsAppQRResponse.fromJson(Map<String, dynamic> json) {
    return WhatsAppQRResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      qrCode: json['data']['qrCode'] ?? '',
      sessionId: json['data']['sessionId'] ?? '',
      expiresIn: json['data']['expiresIn'] ?? 300,
      instructions: List<String>.from(json['data']['instructions'] ?? []),
    );
  }
}

/// Response model for session status
class WhatsAppSessionStatus {
  final String? sessionId;
  final bool isConnected;
  final String connectionState;
  final DateTime? sessionStartedAt;
  final DateTime? sessionExpiresAt;
  final DateTime? lastQrGeneratedAt;
  final int? uptime;
  final int? timeUntilExpiration;

  WhatsAppSessionStatus({
    this.sessionId,
    required this.isConnected,
    required this.connectionState,
    this.sessionStartedAt,
    this.sessionExpiresAt,
    this.lastQrGeneratedAt,
    this.uptime,
    this.timeUntilExpiration,
  });

  factory WhatsAppSessionStatus.fromJson(Map<String, dynamic> json) {
    return WhatsAppSessionStatus(
      sessionId: json['sessionId'],
      isConnected: json['isConnected'] ?? false,
      connectionState: json['connectionState'] ?? 'disconnected',
      sessionStartedAt: json['sessionStartedAt'] != null
          ? DateTime.parse(json['sessionStartedAt'])
          : null,
      sessionExpiresAt: json['sessionExpiresAt'] != null
          ? DateTime.parse(json['sessionExpiresAt'])
          : null,
      lastQrGeneratedAt: json['lastQrGeneratedAt'] != null
          ? DateTime.parse(json['lastQrGeneratedAt'])
          : null,
      uptime: json['uptime'],
      timeUntilExpiration: json['timeUntilExpiration'],
    );
  }

  String get statusText {
    if (isConnected) {
      if (timeUntilExpiration != null && timeUntilExpiration! < 1) {
        return '⚠️ Expiring Soon';
      }
      return '✅ Connected';
    }
    return '❌ Disconnected';
  }

  bool get isHealthy => isConnected && (timeUntilExpiration ?? 0) > 60;
}

/// Response model for detailed session info
class WhatsAppSessionInfo {
  final WhatsAppSessionStatus session;
  final WhatsAppStatus whatsapp;
  final ExpirationAlert expirationAlert;

  WhatsAppSessionInfo({
    required this.session,
    required this.whatsapp,
    required this.expirationAlert,
  });

  factory WhatsAppSessionInfo.fromJson(Map<String, dynamic> json) {
    return WhatsAppSessionInfo(
      session: WhatsAppSessionStatus.fromJson(json['session']),
      whatsapp: WhatsAppStatus.fromJson(json['whatsapp']),
      expirationAlert: ExpirationAlert.fromJson(json['expirationAlert']),
    );
  }
}

/// WhatsApp service status
class WhatsAppStatus {
  final bool isReady;
  final bool isInitializing;
  final int queueLength;
  final bool processing;
  final int reconnectAttempts;
  final int maxReconnectAttempts;

  WhatsAppStatus({
    required this.isReady,
    required this.isInitializing,
    required this.queueLength,
    required this.processing,
    required this.reconnectAttempts,
    required this.maxReconnectAttempts,
  });

  factory WhatsAppStatus.fromJson(Map<String, dynamic> json) {
    return WhatsAppStatus(
      isReady: json['isReady'] ?? false,
      isInitializing: json['isInitializing'] ?? false,
      queueLength: json['queueLength'] ?? 0,
      processing: json['processing'] ?? false,
      reconnectAttempts: json['reconnectAttempts'] ?? 0,
      maxReconnectAttempts: json['maxReconnectAttempts'] ?? 5,
    );
  }
}

/// Expiration alert data
class ExpirationAlert {
  final bool isExpiringSoon;
  final DateTime? expiresAt;
  final int minutesUntilExpiry;
  final String message;

  ExpirationAlert({
    required this.isExpiringSoon,
    this.expiresAt,
    required this.minutesUntilExpiry,
    required this.message,
  });

  factory ExpirationAlert.fromJson(Map<String, dynamic> json) {
    return ExpirationAlert(
      isExpiringSoon: json['isExpiringSoon'] ?? false,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      minutesUntilExpiry: json['minutesUntilExpiry'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

/// Exception for authorization errors
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

