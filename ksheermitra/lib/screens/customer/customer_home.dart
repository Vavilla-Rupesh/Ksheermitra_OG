import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../config/theme.dart';
import '../../widgets/premium_widgets.dart';
import 'product_selection_screen.dart';
import 'subscriptions_screen.dart';
import 'delivery_history_screen.dart';
import 'billing_screen.dart';
import 'monthly_breakout_screen.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.local_drink);
            },
          ),
        ),
        title: const Text('Ksheermitra'),
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
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(user),
          const SubscriptionsScreen(),
          const DeliveryHistoryScreen(),
          _buildProfileTab(user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Welcome Card with gradient
          PremiumCard(
            gradient: AppTheme.premiumCardGradient,
            shadows: AppTheme.premiumCardShadow,
            padding: const EdgeInsets.all(AppTheme.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'Customer',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppTheme.space12),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white70, size: 16),
                    const SizedBox(width: AppTheme.space8),
                    Text(
                      user?.phone ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (user?.address != null && user!.address!.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.space8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: AppTheme.space8),
                      Expanded(
                        child: Text(
                          user.address!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          // Quick Actions Section
          const Text(
            'Quick Actions',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppTheme.space12,
            crossAxisSpacing: AppTheme.space12,
            childAspectRatio: 1.3,
            children: [
              _buildActionCard(
                'Browse Products',
                Icons.shopping_bag,
                AppTheme.infoBlue,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductSelectionScreen()),
                  );
                  if (mounted) {
                    Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
                  }
                },
              ),
              _buildActionCard(
                'My Subscriptions',
                Icons.subscriptions,
                AppTheme.successGreen,
                () => setState(() => _currentIndex = 1),
              ),
              _buildActionCard(
                'View Bills',
                Icons.receipt_long,
                AppTheme.warningOrange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BillingScreen()),
                  );
                },
              ),
              _buildActionCard(
                'Monthly Breakout',
                Icons.calendar_month,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MonthlyBreakoutScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space24),

          // Active Subscriptions Summary
          Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const PremiumLoadingWidget(
                  message: 'Loading subscriptions...',
                );
              }

              if (provider.subscriptions.isEmpty) {
                return PremiumCard(
                  padding: const EdgeInsets.all(AppTheme.space20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.subscriptions_outlined,
                        size: 60,
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppTheme.space12),
                      const Text(
                        'No Active Subscriptions',
                        style: AppTheme.h4,
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        'Start a subscription for regular deliveries',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppTheme.space16),
                      PremiumButton(
                        text: 'Browse Products',
                        icon: Icons.add_circle,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProductSelectionScreen(),
                            ),
                          );
                          if (mounted) {
                            Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
                          }
                        },
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Subscriptions',
                        style: AppTheme.h4,
                      ),
                      PremiumTextButton(
                        text: 'View All',
                        onPressed: () => setState(() => _currentIndex = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space12),
                  ...provider.subscriptions.take(3).map((subscription) {
                    final productCount = subscription.products?.length ?? 0;
                    final displayText = productCount == 1
                        ? subscription.products![0].product?.name ?? 'Product'
                        : '$productCount products';

                    return ProductCard(
                      padding: const EdgeInsets.all(AppTheme.space16),
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.space12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.activeGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: const Icon(
                              Icons.subscriptions,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppTheme.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayText,
                                  style: AppTheme.h5,
                                ),
                                const SizedBox(height: AppTheme.space4),
                                Text(
                                  '${subscription.totalQuantity.toStringAsFixed(1)} total • ${subscription.frequencyDisplay}',
                                  style: AppTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          subscription.isActive
                              ? PremiumBadge.active(subscription.status)
                              : PremiumBadge.pending(subscription.status),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return ProductCard(
      padding: const EdgeInsets.all(AppTheme.space16),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: AppTheme.space12),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.labelText.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.space20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryButtonGradient,
              boxShadow: AppTheme.premiumCardShadow,
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: AppTheme.space16),
          Text(
            user?.name ?? 'Customer',
            style: AppTheme.h2,
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            user?.phone ?? '',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space32),

          // Profile Options
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon')),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Manage Address',
            subtitle: user?.address ?? 'Add your address',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manage address coming soon')),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.receipt_long,
            title: 'Billing & Invoices',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillingScreen()),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon')),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About coming soon')),
              );
            },
          ),
          const SizedBox(height: 20),
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
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
