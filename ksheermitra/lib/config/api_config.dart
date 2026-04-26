class ApiConfig {
  // API endpoints

  static const String baseUrl = 'https://816a-2401-4900-8fcc-afbc-1e5-db52-448-37f5.ngrok-free.app/api';
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

