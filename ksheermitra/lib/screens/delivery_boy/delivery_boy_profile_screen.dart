import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/dairy_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/premium_widgets.dart';
import 'delivery_boy_earnings_screen.dart';
import 'delivery_boy_history_screen.dart';

class DeliveryBoyProfileScreen extends StatefulWidget {
  const DeliveryBoyProfileScreen({super.key});

  @override
  State<DeliveryBoyProfileScreen> createState() => _DeliveryBoyProfileScreenState();
}

class _DeliveryBoyProfileScreenState extends State<DeliveryBoyProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _licenseController = TextEditingController();

  // Stats
  Map<String, dynamic> _stats = {
    'totalDeliveries': 0,
    'completedToday': 0,
    'rating': 0.0,
    'onTimeRate': 0,
    'totalEarnings': 0.0,
    'thisMonthEarnings': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
    }
  }

  Future<void> _loadStats() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/delivery-boy/stats');
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _stats = response['data'] as Map<String, dynamic>;
        });
      } else {
        // Show empty/default stats if API returns no data
        setState(() {
          _stats = {
            'totalDeliveries': 0,
            'completedToday': 0,
            'rating': 0.0,
            'onTimeRate': 0,
            'totalEarnings': 0.0,
            'thisMonthEarnings': 0.0,
          };
        });
      }
    } catch (e) {
      // Show error state with zero values instead of mock data
      debugPrint('Error loading stats: $e');
      setState(() {
        _stats = {
          'totalDeliveries': 0,
          'completedToday': 0,
          'rating': 0.0,
          'onTimeRate': 0,
          'totalEarnings': 0.0,
          'thisMonthEarnings': 0.0,
        };
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put('/delivery-boy/profile', {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'vehicleNumber': _vehicleController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
      });

      if (response['success'] == true) {
        await context.read<AuthProvider>().loadUser();
        setState(() => _isEditing = false);
        _showSnackBar('Profile updated successfully!', isError: false);
      } else {
        _showSnackBar('Failed to update profile: ${response['message'] ?? 'Unknown error'}', isError: true);
        setState(() => _isEditing = false);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      _showSnackBar('Error updating profile: $e', isError: true);
      setState(() => _isEditing = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? DairyColorsLight.error : DairyColorsLight.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),

            const SizedBox(height: DairySpacing.lg),

            // Stats Cards
            if (!_isEditing) ...[
              _buildStatsSection(),
              const SizedBox(height: DairySpacing.lg),
            ],

            // Profile Form
            if (_isEditing)
              _buildEditForm()
            else
              _buildProfileDetails(user),

            const SizedBox(height: DairySpacing.lg),

            // Actions
            if (!_isEditing) ...[
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark],
        ),
        borderRadius: DairyRadius.largeBorderRadius,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.delivery_dining,
              size: 50,
              color: DairyColorsLight.primary,
            ),
          ),
          const SizedBox(height: DairySpacing.md),
          Text(
            user?.name ?? 'Delivery Partner',
            style: DairyTypography.headingMedium(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DairySpacing.md,
              vertical: DairySpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: DairyRadius.pillBorderRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_stats['rating']} Rating',
                  style: DairyTypography.label(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Performance', style: DairyTypography.headingSmall()),
        const SizedBox(height: DairySpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Deliveries',
                '${_stats['totalDeliveries']}',
                Icons.local_shipping,
                DairyColorsLight.primary,
              ),
            ),
            const SizedBox(width: DairySpacing.md),
            Expanded(
              child: _buildStatCard(
                'Today',
                '${_stats['completedToday']}',
                Icons.today,
                DairyColorsLight.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: DairySpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'On-Time Rate',
                '${_stats['onTimeRate']}%',
                Icons.timer,
                DairyColorsLight.success,
              ),
            ),
            const SizedBox(width: DairySpacing.md),
            Expanded(
              child: _buildStatCard(
                'This Month',
                '₹${_stats['thisMonthEarnings']}',
                Icons.account_balance_wallet,
                DairyColorsLight.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: DairyRadius.defaultBorderRadius,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: DairySpacing.sm),
            Text(
              value,
              style: DairyTypography.headingSmall(),
            ),
            Text(
              label,
              style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DairySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: DairyTypography.headingSmall()),
            const SizedBox(height: DairySpacing.md),
            _buildDetailRow(Icons.person, 'Name', user?.name ?? 'Not set'),
            _buildDetailRow(Icons.phone, 'Phone', user?.phone ?? 'Not set'),
            _buildDetailRow(Icons.email, 'Email', user?.email ?? 'Not set'),
            _buildDetailRow(Icons.two_wheeler, 'Vehicle', _vehicleController.text.isEmpty ? 'Not set' : _vehicleController.text),
            _buildDetailRow(Icons.badge, 'License', _licenseController.text.isEmpty ? 'Not set' : _licenseController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DairyColorsLight.surface,
              borderRadius: DairyRadius.smallBorderRadius,
            ),
            child: Icon(icon, size: 20, color: DairyColorsLight.primary),
          ),
          const SizedBox(width: DairySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DairyTypography.caption(color: DairyColorsLight.textSecondary),
                ),
                Text(value, style: DairyTypography.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(DairySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: DairyTypography.headingSmall()),
              const SizedBox(height: DairySpacing.md),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: DairySpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: DairySpacing.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                enabled: false,
              ),
              const SizedBox(height: DairySpacing.md),
              TextFormField(
                controller: _vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  prefixIcon: Icon(Icons.two_wheeler),
                  hintText: 'e.g., KA01AB1234',
                ),
              ),
              const SizedBox(height: DairySpacing.md),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'License Number',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: DairySpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: DairyColorsLight.primary),
            title: const Text('Delivery History'),
            subtitle: const Text('View past deliveries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to delivery history
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeliveryBoyHistoryScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: DairyColorsLight.success),
            title: const Text('Earnings'),
            subtitle: const Text('View your earnings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DeliveryBoyEarningsScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.help, color: DairyColorsLight.info),
            title: const Text('Help & Support'),
            subtitle: const Text('Get assistance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),
        ),
        const SizedBox(height: DairySpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DairyColorsLight.error,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await context.read<AuthProvider>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout, color: DairyColorsLight.error),
            label: const Text('Logout', style: TextStyle(color: DairyColorsLight.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: DairyColorsLight.error),
            ),
          ),
        ),
      ],
    );
  }
}

