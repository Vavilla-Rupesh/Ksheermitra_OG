import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I create a subscription?',
      answer: 'Go to the Products section, select your desired products, choose quantity and delivery frequency, then confirm your subscription. You can choose daily, alternate days, or custom delivery schedules.',
    ),
    FAQItem(
      question: 'How can I pause my subscription?',
      answer: 'Go to Subscriptions tab, select the subscription you want to pause, and tap on "Pause Subscription". You can specify the pause duration or pause indefinitely.',
    ),
    FAQItem(
      question: 'What are the delivery timings?',
      answer: 'Our standard delivery time is between 5:00 AM to 8:00 AM. You\'ll receive a notification when your delivery is on the way.',
    ),
    FAQItem(
      question: 'How do I pay for my subscription?',
      answer: 'You can pay through UPI, credit/debit cards, or pay cash to your delivery person. Monthly bills are generated automatically and can be viewed in the Billing section.',
    ),
    FAQItem(
      question: 'Can I change my delivery address?',
      answer: 'Yes, go to Profile > Manage Address to update your delivery location. Changes will be effective from the next delivery.',
    ),
    FAQItem(
      question: 'What if I miss a delivery?',
      answer: 'If you\'re not available, our delivery person will try to contact you. You can also mark specific dates as "Skip" in advance from your subscription settings.',
    ),
    FAQItem(
      question: 'How do I cancel my subscription?',
      answer: 'Go to Subscriptions, select the subscription, and tap "Cancel Subscription". Please note that cancellation takes effect from the next billing cycle.',
    ),
    FAQItem(
      question: 'Are the products fresh?',
      answer: 'Yes! We source directly from local dairy farms and deliver within hours of collection. All products are quality tested and stored in temperature-controlled conditions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help?',
                    style: DairyTypography.headingSmall(),
                  ),
                  const SizedBox(height: DairySpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.phone,
                          title: 'Call Us',
                          subtitle: '24/7 Support',
                          color: DairyColorsLight.primary,
                          onTap: () => _launchPhone(),
                        ),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.chat,
                          title: 'WhatsApp',
                          subtitle: 'Quick Response',
                          color: DairyColorsLight.success,
                          onTap: () => _launchWhatsApp(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DairySpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: 'Write to us',
                          color: DairyColorsLight.info,
                          onTap: () => _launchEmail(),
                        ),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.feedback,
                          title: 'Feedback',
                          subtitle: 'Share thoughts',
                          color: DairyColorsLight.secondary,
                          onTap: () => _showFeedbackDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // FAQs Section
            Padding(
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: DairyTypography.headingSmall(),
                  ),
                  const SizedBox(height: DairySpacing.md),
                  ..._faqs.map((faq) => _buildFAQTile(faq)),
                ],
              ),
            ),

            const Divider(),

            // Contact Info
            Padding(
              padding: const EdgeInsets.all(DairySpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: DairyTypography.headingSmall(),
                  ),
                  const SizedBox(height: DairySpacing.md),
                  _buildContactInfo(
                    Icons.phone,
                    'Phone',
                    '+91 98765 43210',
                  ),
                  _buildContactInfo(
                    Icons.email,
                    'Email',
                    'support@ksheermitra.com',
                  ),
                  _buildContactInfo(
                    Icons.access_time,
                    'Support Hours',
                    '24/7 Available',
                  ),
                  _buildContactInfo(
                    Icons.location_on,
                    'Address',
                    'Ksheermitra Dairy, Industrial Area, City - 560001',
                  ),
                ],
              ),
            ),

            const SizedBox(height: DairySpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
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
              Text(
                title,
                style: DairyTypography.label().copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQTile(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: DairySpacing.sm),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: DairyTypography.bodyLarge().copyWith(fontWeight: FontWeight.w500),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          DairySpacing.md,
          0,
          DairySpacing.md,
          DairySpacing.md,
        ),
        children: [
          Text(
            faq.answer,
            style: DairyTypography.body(color: DairyColorsLight.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DairyColorsLight.surface,
              borderRadius: DairyRadius.smallBorderRadius,
            ),
            child: Icon(icon, size: 20, color: DairyColorsLight.primary),
          ),
          const SizedBox(width: DairySpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                ),
                Text(
                  value,
                  style: DairyTypography.body(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+919876543210');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showSnackBar('Could not launch phone app');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/919876543210?text=Hi, I need help with Ksheermitra app');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch WhatsApp');
      }
    } catch (e) {
      _showSnackBar('WhatsApp not installed');
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@ksheermitra.com',
      query: 'subject=Help Request&body=Hi, I need assistance with...',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showSnackBar('Could not launch email app');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Share Your Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How would you rate your experience?',
                  style: DairyTypography.body(),
                ),
                const SizedBox(height: DairySpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: DairyColorsLight.warning,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() => selectedRating = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: DairySpacing.md),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Your feedback (optional)',
                    hintText: 'Tell us what you think...',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Thank you for your feedback!');
              },
              child: const Text('Submit'),
            ),
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

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

