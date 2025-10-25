import '../config/app_config.dart';

class ImageHelper {
  /// Gets HTTP headers for image requests (including ngrok bypass)
  static Map<String, String> get imageHeaders => {
    'ngrok-skip-browser-warning': 'true',
  };

  /// Constructs full image URL from relative path
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }

    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Get base URL and remove /api suffix
    String baseUrl = AppConfig.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }

    // Clean the image path
    String cleanPath = imagePath;

    // Remove /api/ prefix if it exists in the path
    if (cleanPath.startsWith('/api/')) {
      cleanPath = cleanPath.substring(4); // Remove '/api'
    }

    // Remove leading slash if present
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    // Construct full URL
    final fullUrl = '$baseUrl/$cleanPath';

    // Debug logging
    print('🖼️ Image URL Construction:');
    print('   Input: $imagePath');
    print('   Base URL: ${AppConfig.baseUrl}');
    print('   Clean Base: $baseUrl');
    print('   Clean Path: $cleanPath');
    print('   Final URL: $fullUrl');

    return fullUrl;
  }

  /// Gets the base URL for uploads
  static String get uploadsBaseUrl {
    String baseUrl = AppConfig.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    return '$baseUrl/uploads';
  }
}
