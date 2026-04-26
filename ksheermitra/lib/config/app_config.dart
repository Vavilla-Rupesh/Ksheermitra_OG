class AppConfig {
  static const String appName = 'Ksheermitra';
  static const String baseUrl = 'https://ksheermitra-backend.onrender.com/api';
  
  static const String googleMapsApiKey = 'AIzaSyCnN2T4O5Q11DGMQ0GGPT7G61A7kkOK6Jg';
  
  // Increased timeout for OTP and WhatsApp operations
  static const Duration requestTimeout = Duration(seconds: 60);
  static const Duration connectionTimeout = Duration(seconds: 60);

  static const int otpLength = 6;
  static const int otpResendTimeout = 60;

  static const double defaultLatitude = 14.4426;
  static const double defaultLongitude = 79.9864;
  static const double mapZoom = 14.0;
}
