class ApiConfig {
  // API endpoints

  static const String baseUrl = 'https://04c0-115-99-42-21.ngrok-free.app/api';
  static const String authEndpoint = '/auth';
  static const String adminEndpoint = '/admin';
  static const String customerEndpoint = '/customer';
  static const String deliveryBoyEndpoint = '/delivery-boy';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 60);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
}

