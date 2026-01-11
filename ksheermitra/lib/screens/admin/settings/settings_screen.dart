import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoRefresh = true;
  String _refreshInterval = '5';
  String _currency = 'INR';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Push Notifications',
              'Receive alerts for new orders and updates',
              Icons.notifications,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme throughout the app',
              Icons.dark_mode,
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            const Divider(height: 1),
            _buildDropdownTile(
              'Language',
              'Select your preferred language',
              Icons.language,
              _language,
              ['English', 'Hindi', 'Marathi', 'Gujarati'],
              (value) => setState(() => _language = value!),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Data & Sync'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Auto Refresh',
              'Automatically refresh dashboard data',
              Icons.sync,
              _autoRefresh,
              (value) => setState(() => _autoRefresh = value),
            ),
            const Divider(height: 1),
            _buildDropdownTile(
              'Refresh Interval',
              'How often to refresh data (minutes)',
              Icons.timer,
              _refreshInterval,
              ['1', '5', '10', '15', '30'],
              (value) => setState(() => _refreshInterval = value!),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Clear Cache',
              'Free up storage by clearing cached data',
              Icons.cleaning_services,
              () => _clearCache(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Business'),
          _buildSettingsCard([
            _buildDropdownTile(
              'Currency',
              'Select your business currency',
              Icons.currency_rupee,
              _currency,
              ['INR', 'USD', 'EUR', 'GBP'],
              (value) => setState(() => _currency = value!),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Business Profile',
              'Manage your business information',
              Icons.business,
              () => _showBusinessProfile(),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Payment Settings',
              'Configure payment methods',
              Icons.payment,
              () => _showPaymentSettings(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Security'),
          _buildSettingsCard([
            _buildActionTile(
              'Change Password',
              'Update your account password',
              Icons.lock,
              () => _showChangePassword(),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Active Sessions',
              'Manage your login sessions',
              Icons.devices,
              () => _showActiveSessions(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          _buildSettingsCard([
            _buildActionTile(
              'Export Data',
              'Download all your business data',
              Icons.download,
              () => _exportData(),
            ),
            const Divider(height: 1),
            _buildActionTile(
              'Backup',
              'Create a backup of your data',
              Icons.backup,
              () => _createBackup(),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryColor;
          }
          return Colors.grey;
        }),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showBusinessProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              initialValue: 'Ksheer Mitra Dairy',
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '+91 9876543210',
              decoration: const InputDecoration(
                labelText: 'Business Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: 'admin@ksheermitra.com',
              decoration: const InputDecoration(
                labelText: 'Business Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: '123, Dairy Complex, Main Road',
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Business Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Business profile updated')),
                  );
                },
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPaymentSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Cash'),
              subtitle: const Text('Accept cash payments'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('UPI'),
              subtitle: const Text('Accept UPI payments'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Card'),
              subtitle: const Text('Accept card payments'),
              value: true,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.green),
              title: const Text('This Device'),
              subtitle: const Text('Active now'),
              trailing: const Chip(label: Text('Current')),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.computer, color: Colors.grey),
              title: const Text('Chrome on Windows'),
              subtitle: const Text('Last active 2 hours ago'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out from all other devices')),
              );
            },
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This will export all your business data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Export'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data export started. You will be notified when complete.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _createBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Backup'),
        content: const Text('This will create a backup of all your data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Backup'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

