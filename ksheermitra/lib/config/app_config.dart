class AppConfig {
  static const String appName = 'Ksheermitra';
  static const String baseUrl = 'https://4e3e4f924aea.ngrok-free.app/api';
  
  static const String googleMapsApiKey = 'API_KEY_HERE';
  
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  static const int otpLength = 6;
  static const int otpResendTimeout = 60;
  
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;
  static const double mapZoom = 14.0;
}
