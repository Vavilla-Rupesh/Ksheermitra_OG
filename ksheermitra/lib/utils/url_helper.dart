import 'package:url_launcher/url_launcher.dart' as launcher;

class UrlHelper {
  static Future<bool> launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      return launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> launchWhatsApp({required String message, String? phoneNumber}) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = phoneNumber != null
        ? 'https://wa.me/$phoneNumber?text=$encodedMessage'
        : 'https://wa.me/?text=$encodedMessage';
    return launchUrl(url);
  }
}

