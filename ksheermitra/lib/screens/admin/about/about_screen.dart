import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final String _version = '1.0.0';
  final String _buildNumber = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // App Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_drink,
                    size: 80,
                    color: AppTheme.primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'Ksheer Mitra',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Milk Delivery System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $_version (Build $_buildNumber)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(Icons.people, 'Customer Management'),
                    _buildFeatureItem(Icons.delivery_dining, 'Delivery Tracking'),
                    _buildFeatureItem(Icons.subscriptions, 'Subscription Management'),
                    _buildFeatureItem(Icons.shopping_cart, 'In-Store Sales'),
                    _buildFeatureItem(Icons.receipt_long, 'Invoice Generation'),
                    _buildFeatureItem(Icons.analytics, 'Business Analytics'),
                    _buildFeatureItem(Icons.map, 'Area Management'),
                    _buildFeatureItem(Icons.notifications, 'WhatsApp Notifications'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Contact
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact & Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                      title: const Text('Email'),
                      subtitle: const Text('support@ksheermitra.com'),
                      onTap: () => _launchEmail(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
                      title: const Text('Phone'),
                      subtitle: const Text('+91 9876543210'),
                      onTap: () => _launchPhone(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                      title: const Text('Website'),
                      subtitle: const Text('www.ksheermitra.com'),
                      onTap: () => _launchWebsite(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Legal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primaryColor),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showTermsOfService(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showPrivacyPolicy(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info, color: AppTheme.primaryColor),
                      title: const Text('Licenses'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLicenses(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Copyright
            Text(
              '© ${DateTime.now().year} Ksheer Mitra. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ❤️ in India',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _launchEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening email client...')),
    );
  }

  void _launchPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening phone dialer...')),
    );
  }

  void _launchWebsite() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening website...')),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'These Terms of Service govern your use of the Ksheer Mitra application.\n\n'
            '1. Acceptance of Terms\n'
            'By using this application, you agree to be bound by these terms.\n\n'
            '2. Use of Service\n'
            'You agree to use this service only for lawful purposes.\n\n'
            '3. User Account\n'
            'You are responsible for maintaining the confidentiality of your account.\n\n'
            '4. Data Privacy\n'
            'We respect your privacy and protect your data as per our Privacy Policy.\n\n'
            '5. Modifications\n'
            'We reserve the right to modify these terms at any time.\n\n'
            'For full terms, please contact support@ksheermitra.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Ksheer Mitra Privacy Policy\n\n'
            'We value your privacy and are committed to protecting your personal information.\n\n'
            '1. Information We Collect\n'
            '- Personal information (name, phone, address)\n'
            '- Usage data and analytics\n'
            '- Location data (with your permission)\n\n'
            '2. How We Use Your Information\n'
            '- To provide and improve our services\n'
            '- To communicate with you\n'
            '- To process transactions\n\n'
            '3. Data Security\n'
            'We implement industry-standard security measures to protect your data.\n\n'
            '4. Third-Party Services\n'
            'We may use third-party services that collect information.\n\n'
            '5. Your Rights\n'
            'You have the right to access, modify, or delete your personal data.\n\n'
            'For full policy, please contact support@ksheermitra.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Ksheer Mitra',
      applicationVersion: _version,
      applicationLegalese: '© ${DateTime.now().year} Ksheer Mitra',
    );
  }
}

