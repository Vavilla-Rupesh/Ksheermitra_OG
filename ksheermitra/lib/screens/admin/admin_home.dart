import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../config/theme.dart';
import '../../widgets/premium_widgets.dart';
import 'dashboard/dashboard_screen.dart';
import 'products/product_list_screen.dart';
import 'customers/customer_list_screen.dart';
import 'delivery_boys/delivery_boy_list_screen.dart';
import 'areas/area_list_screen.dart';
import 'invoices/invoice_list_screen.dart';
import 'offline_sales/offline_sales_list_screen.dart';
import 'analytics/analytics_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';
import 'about/about_screen.dart';

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
              _showNotificationsDialog();
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
                  icon: Icons.shopping_cart,
                  title: 'In-Store Sales',
                  subtitle: 'Manage offline sales',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OfflineSalesListScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
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

  void _showNotificationsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All notifications marked as read')),
                      );
                    },
                    child: const Text(
                      'Mark all read',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  final stats = provider.stats;

                  // Build notification items based on real data
                  final notifications = <Map<String, dynamic>>[];

                  if (stats != null) {
                    if (stats.todaysPending > 0) {
                      notifications.add({
                        'icon': Icons.local_shipping,
                        'color': Colors.orange,
                        'title': 'Pending Deliveries',
                        'message': '${stats.todaysPending} deliveries are pending for today',
                        'time': 'Now',
                        'isNew': true,
                      });
                    }

                    if (stats.pendingPayments > 0) {
                      notifications.add({
                        'icon': Icons.payment,
                        'color': Colors.red,
                        'title': 'Pending Payments',
                        'message': '₹${stats.pendingPayments.toStringAsFixed(0)} in pending payments',
                        'time': 'Today',
                        'isNew': true,
                      });
                    }

                    if (stats.todaysDelivered > 0) {
                      notifications.add({
                        'icon': Icons.check_circle,
                        'color': Colors.green,
                        'title': 'Deliveries Completed',
                        'message': '${stats.todaysDelivered} deliveries completed successfully',
                        'time': 'Today',
                        'isNew': false,
                      });
                    }

                    notifications.add({
                      'icon': Icons.people,
                      'color': Colors.blue,
                      'title': 'Customer Update',
                      'message': '${stats.activeCustomers} active customers in your network',
                      'time': 'Today',
                      'isNew': false,
                    });

                    notifications.add({
                      'icon': Icons.subscriptions,
                      'color': Colors.purple,
                      'title': 'Active Subscriptions',
                      'message': '${stats.activeSubscriptions} subscriptions are currently active',
                      'time': 'Today',
                      'isNew': false,
                    });
                  }

                  if (notifications.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: (notif['color'] as Color).withValues(alpha: 0.1),
                          child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(notif['title'] as String)),
                            if (notif['isNew'] as bool)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['message'] as String),
                            const SizedBox(height: 4),
                            Text(
                              notif['time'] as String,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
