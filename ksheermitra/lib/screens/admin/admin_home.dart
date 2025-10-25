import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/premium_widgets.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'delivery_boys/delivery_boy_list_screen.dart';
import 'areas/area_list_screen.dart';
import 'invoices/invoice_list_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final screens = [
      const DashboardScreen(),
      const CustomerListScreen(),
      const DeliveryBoyListScreen(),
      const ProductListScreen(),
      _buildMoreTab(),
    ];

    return Scaffold(
      appBar: PremiumAppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.local_drink);
            },
          ),
        ),
        title: _getTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    PremiumButton(
                      text: 'Logout',
                      onPressed: () => Navigator.pop(context, true),
                      height: 40,
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Delivery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Customers';
      case 2:
        return 'Delivery Boys';
      case 3:
        return 'Products';
      case 4:
        return 'More';
      default:
        return 'Admin';
    }
  }

  Widget _buildMoreTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.space16),
        children: [
          const Text(
            'Management',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space12),
          PremiumCard(
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.map,
                  title: 'Area Management',
                  subtitle: 'Manage delivery areas',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AreaListScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuTile(
                  icon: Icons.receipt_long,
                  title: 'Invoices',
                  subtitle: 'View and manage invoices',
                  color: AppTheme.infoBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InvoiceListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          const Text(
            'Reports & Analytics',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space12),
          PremiumCard(
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View business analytics',
                  color: AppTheme.successGreen,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analytics coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuTile(
                  icon: Icons.download,
                  title: 'Export Reports',
                  subtitle: 'Download business reports',
                  color: AppTheme.warningOrange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reports coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space24),
          const Text(
            'Settings',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space12),
          PremiumCard(
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.settings,
                  title: 'App Settings',
                  subtitle: 'Configure app settings',
                  color: AppTheme.textSecondary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMenuTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App information',
                  color: AppTheme.infoBlue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('About coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space16), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: AppTheme.h5),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
