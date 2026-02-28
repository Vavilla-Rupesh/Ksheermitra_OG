import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            // App Logo and Info
            const SizedBox(height: DairySpacing.lg),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: DairyColorsLight.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: DairyColorsLight.primary,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_drink,
                    size: 50,
                    color: DairyColorsLight.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: DairySpacing.md),
            Text(
              'Ksheermitra',
              style: DairyTypography.headingLarge(),
            ),
            const SizedBox(height: 4),
            Text(
              'Fresh Dairy, Delivered Daily',
              style: DairyTypography.body(color: DairyColorsLight.textSecondary),
            ),
            const SizedBox(height: DairySpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DairySpacing.md,
                vertical: DairySpacing.xs,
              ),
              decoration: BoxDecoration(
                color: DairyColorsLight.primarySurface,
                borderRadius: DairyRadius.pillBorderRadius,
              ),
              child: Text(
                'Version $_appVersion (Build $_buildNumber)',
                style: DairyTypography.caption(color: DairyColorsLight.primary),
              ),
            ),

            const SizedBox(height: DairySpacing.xl),
            const Divider(),
            const SizedBox(height: DairySpacing.md),

            // About Description
            Container(
              padding: const EdgeInsets.all(DairySpacing.md),
              decoration: BoxDecoration(
                color: DairyColorsLight.surface,
                borderRadius: DairyRadius.defaultBorderRadius,
              ),
              child: Column(
                children: [
                  Text(
                    'About Ksheermitra',
                    style: DairyTypography.headingSmall(),
                  ),
                  const SizedBox(height: DairySpacing.md),
                  Text(
                    'Ksheermitra is your trusted partner for fresh dairy products delivered right to your doorstep. We work directly with local dairy farmers to bring you the freshest milk and dairy products every morning.\n\n'
                    'Our mission is to make fresh, quality dairy products accessible to every household while supporting local farmers and promoting sustainable dairy farming practices.',
                    style: DairyTypography.body(color: DairyColorsLight.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: DairySpacing.lg),

            // Features List
            _buildFeatureItem(
              Icons.local_shipping,
              'Daily Doorstep Delivery',
              'Fresh products delivered every morning between 5-8 AM',
            ),
            _buildFeatureItem(
              Icons.verified,
              'Quality Assured',
              '100% pure and adulteration-free products',
            ),
            _buildFeatureItem(
              Icons.agriculture,
              'Farm Fresh',
              'Directly sourced from local dairy farms',
            ),
            _buildFeatureItem(
              Icons.subscriptions,
              'Flexible Subscriptions',
              'Customize your delivery schedule as per your needs',
            ),

            const SizedBox(height: DairySpacing.lg),
            const Divider(),
            const SizedBox(height: DairySpacing.md),

            // Links Section
            _buildLinkTile(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              () => _launchUrl('https://ksheermitra.com/privacy'),
            ),
            _buildLinkTile(
              Icons.description_outlined,
              'Terms of Service',
              () => _launchUrl('https://ksheermitra.com/terms'),
            ),
            _buildLinkTile(
              Icons.security_outlined,
              'Refund Policy',
              () => _launchUrl('https://ksheermitra.com/refund'),
            ),
            _buildLinkTile(
              Icons.star_outline,
              'Rate Us',
              () => _showRateDialog(),
            ),
            _buildLinkTile(
              Icons.share_outlined,
              'Share App',
              () => _shareApp(),
            ),

            const SizedBox(height: DairySpacing.lg),

            // Social Links
            Text(
              'Connect With Us',
              style: DairyTypography.label(),
            ),
            const SizedBox(height: DairySpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  'assets/icons/facebook.png',
                  Icons.facebook,
                  DairyColorsLight.info,
                  () => _launchUrl('https://facebook.com/ksheermitra'),
                ),
                const SizedBox(width: DairySpacing.md),
                _buildSocialButton(
                  'assets/icons/instagram.png',
                  Icons.camera_alt,
                  DairyColorsLight.secondary,
                  () => _launchUrl('https://instagram.com/ksheermitra'),
                ),
                const SizedBox(width: DairySpacing.md),
                _buildSocialButton(
                  'assets/icons/twitter.png',
                  Icons.alternate_email,
                  DairyColorsLight.info,
                  () => _launchUrl('https://twitter.com/ksheermitra'),
                ),
                const SizedBox(width: DairySpacing.md),
                _buildSocialButton(
                  'assets/icons/youtube.png',
                  Icons.play_circle_fill,
                  DairyColorsLight.error,
                  () => _launchUrl('https://youtube.com/ksheermitra'),
                ),
              ],
            ),

            const SizedBox(height: DairySpacing.xl),

            // Copyright
            Text(
              '© ${DateTime.now().year} Ksheermitra. All rights reserved.',
              style: DairyTypography.caption(color: DairyColorsLight.textTertiary),
            ),
            const SizedBox(height: 4),
            Text(
              'Made with ❤️ in India',
              style: DairyTypography.caption(color: DairyColorsLight.textTertiary),
            ),

            const SizedBox(height: DairySpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DairyColorsLight.primarySurface,
              borderRadius: DairyRadius.defaultBorderRadius,
            ),
            child: Icon(icon, color: DairyColorsLight.primary, size: 24),
          ),
          const SizedBox(width: DairySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: DairyTypography.bodySmall(color: DairyColorsLight.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      child: ListTile(
        leading: Icon(icon, color: DairyColorsLight.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton(
    String assetPath,
    IconData fallbackIcon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(fallbackIcon, color: color),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open link');
      }
    } catch (e) {
      _showSnackBar('Error opening link');
    }
  }

  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Ksheermitra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 60,
              color: DairyColorsLight.warning,
            ),
            const SizedBox(height: DairySpacing.md),
            Text(
              'If you enjoy using Ksheermitra, please take a moment to rate us on the app store. Your feedback helps us improve!',
              style: DairyTypography.body(color: DairyColorsLight.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Launch app store
              _launchUrl('https://play.google.com/store/apps/details?id=com.ksheermitra.app');
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  void _shareApp() async {
    // Show share dialog with app details
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(DairySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DairyColorsLight.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: DairySpacing.lg),
            Text('Share Ksheermitra', style: DairyTypography.headingSmall()),
            const SizedBox(height: DairySpacing.sm),
            Text(
              'Tell your friends about Ksheermitra for fresh dairy delivery!',
              style: DairyTypography.body(color: DairyColorsLight.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DairySpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.message, 'SMS', Colors.green, () {
                  Navigator.pop(context);
                  _launchUrl('sms:?body=Try Ksheermitra for fresh dairy delivery! Download now: https://ksheermitra.com/app');
                }),
                _buildShareOption(Icons.copy, 'Copy Link', DairyColorsLight.info, () {
                  Navigator.pop(context);
                  _showSnackBar('Link copied to clipboard!');
                }),
                _buildShareOption(Icons.email, 'Email', DairyColorsLight.error, () {
                  Navigator.pop(context);
                  _launchUrl('mailto:?subject=Try Ksheermitra&body=I recommend Ksheermitra for fresh dairy delivery. Download: https://ksheermitra.com/app');
                }),
              ],
            ),
            const SizedBox(height: DairySpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: DairyRadius.defaultBorderRadius,
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: DairySpacing.sm),
            Text(label, style: DairyTypography.label()),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

