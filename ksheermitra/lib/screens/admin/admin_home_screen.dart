import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'delivery_boys_screen.dart';
import 'offline_sales/offline_sales_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        'In-Store Sales',
                        Icons.shopping_cart,
                        AppTheme.primaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OfflineSalesListScreen(),
                          ),
                        ),
                      ),
                      _buildDashboardCard(
                        context,
                        'Delivery Boys',
                        Icons.delivery_dining,
                        const Color(0xFF42A5F5),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeliveryBoysScreen(),
                          ),
                        ),
                      ),
                      _buildDashboardCard(
                        context,
                        'Customers',
                        Icons.people,
                        const Color(0xFF66BB6A),
                        () {
                          // Navigate to customers screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Customers')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Products',
                        Icons.inventory,
                        const Color(0xFFFF9800),
                        () {
                          // Navigate to products screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Products')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Areas',
                        Icons.map,
                        const Color(0xFF9C27B0),
                        () {
                          // Navigate to areas screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Areas')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Subscriptions',
                        Icons.repeat,
                        const Color(0xFF00BCD4),
                        () {
                          // Navigate to subscriptions screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Subscriptions')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Invoices',
                        Icons.receipt_long,
                        const Color(0xFFF44336),
                        () {
                          // Navigate to invoices screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Invoices')),
                          );
                        },
                      ),
                      _buildDashboardCard(
                        context,
                        'Reports',
                        Icons.analytics,
                        const Color(0xFF607D8B),
                        () {
                          // Navigate to reports screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Navigate to Reports')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.appBarGradient,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage your business',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
