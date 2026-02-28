class ApiConfig {
  // API endpoints

  static const String baseUrl = 'https://d6d7-2401-4900-8fcc-1974-20c5-1c37-cbf0-e6de.ngrok-free.app/api';
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

