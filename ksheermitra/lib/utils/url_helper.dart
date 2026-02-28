import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Helper class for URL launching operations
class UrlHelper {
  /// Launch a URL in an external application
  static Future<bool> launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await url_launcher.canLaunchUrl(uri)) {
        return await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Launch WhatsApp with a pre-filled message
  static Future<bool> launchWhatsApp({String? phone, required String message}) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = phone != null && phone.isNotEmpty
          ? 'https://wa.me/$phone?text=$encodedMessage'
          : 'https://wa.me/?text=$encodedMessage';
      return await launchUrl(whatsappUrl);
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Launch phone dialer
  static Future<bool> launchPhone(String phone) async {
    try {
      return await launchUrl('tel:$phone');
    } catch (e) {
      debugPrint('Error launching phone: $e');
      return false;
    }
  }

  /// Launch email client
  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    try {
      final params = <String, String>{};
      if (subject != null) params['subject'] = subject;
      if (body != null) params['body'] = body;

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final emailUrl = queryString.isNotEmpty
          ? 'mailto:$email?$queryString'
          : 'mailto:$email';

      return await launchUrl(emailUrl);
    } catch (e) {
      debugPrint('Error launching email: $e');
      return false;
    }
  }

  /// Check if a URL can be launched
  static Future<bool> canLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await url_launcher.canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }
}

