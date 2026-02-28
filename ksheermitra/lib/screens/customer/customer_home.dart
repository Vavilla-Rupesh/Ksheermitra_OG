import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/notification_provider.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';
import 'product_selection_screen.dart';
import 'subscriptions_screen.dart';
import 'delivery_history_screen.dart';
import 'billing_screen.dart';
import 'monthly_breakout_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'manage_address_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (notificationProvider.hasUnread)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: DairyColorsLight.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${notificationProvider.unreadCount > 9 ? '9+' : notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
        selectedItemColor: DairyColorsLight.primary,
        unselectedItemColor: DairyColorsLight.textTertiary,
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
      padding: const EdgeInsets.all(DairySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Welcome Card with gradient
          PremiumCard(
            gradient: const LinearGradient(colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark]),
            shadows: DairyColorsLight.elevatedShadow,
            padding: const EdgeInsets.all(DairySpacing.lg - 4),
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
                        color: DairyColorsLight.primary,
                      ),
                    ),
                    const SizedBox(width: DairySpacing.md),
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
                const SizedBox(height: DairySpacing.md),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: DairySpacing.sm + 4),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white70, size: 16),
                    const SizedBox(width: DairySpacing.sm),
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
                  const SizedBox(height: DairySpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: DairySpacing.sm),
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
          const SizedBox(height: DairySpacing.lg),

          // Quick Actions Section
          Text(
            'Quick Actions',
            style: DairyTypography.headingSmall(),
          ),
          const SizedBox(height: DairySpacing.sm + 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: DairySpacing.sm + 4,
            crossAxisSpacing: DairySpacing.sm + 4,
            childAspectRatio: 1.3,
            children: [
              _buildActionCard(
                'Browse Products',
                Icons.shopping_bag,
                DairyColorsLight.info,
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
                DairyColorsLight.success,
                () => setState(() => _currentIndex = 1),
              ),
              _buildActionCard(
                'View Bills',
                Icons.receipt_long,
                DairyColorsLight.warning,
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
          const SizedBox(height: DairySpacing.lg),

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
                  padding: const EdgeInsets.all((DairySpacing.md + 4)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.subscriptions_outlined,
                        size: 60,
                        color: DairyColorsLight.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: (DairySpacing.sm + 4)),
                      Text(
                        'No Active Subscriptions',
                        style: DairyTypography.headingSmall(),
                      ),
                      const SizedBox(height: DairySpacing.sm),
                      Text(
                        'Start a subscription for regular deliveries',
                        textAlign: TextAlign.center,
                        style: DairyTypography.body(),
                      ),
                      const SizedBox(height: DairySpacing.md),
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
                      Text(
                        'Active Subscriptions',
                        style: DairyTypography.headingSmall(),
                      ),
                      PremiumTextButton(
                        text: 'View All',
                        onPressed: () => setState(() => _currentIndex = 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: (DairySpacing.sm + 4)),
                  ...provider.subscriptions.take(3).map((subscription) {
                    final productCount = subscription.products?.length ?? 0;
                    final displayText = productCount == 1
                        ? subscription.products![0].product?.name ?? 'Product'
                        : '$productCount products';

                    return ProductCard(
                      padding: const EdgeInsets.all(DairySpacing.md),
                      onTap: () => setState(() => _currentIndex = 1),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all((DairySpacing.sm + 4)),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [DairyColorsLight.success, Color(0xFF66BB6A)]),
                              borderRadius: BorderRadius.circular(DairyRadius.md),
                            ),
                            child: const Icon(
                              Icons.subscriptions,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: (DairySpacing.sm + 4)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayText,
                                  style: DairyTypography.bodyLarge(),
                                ),
                                const SizedBox(height: DairySpacing.xs),
                                Text(
                                  '${subscription.totalQuantity.toStringAsFixed(1)} total • ${subscription.frequencyDisplay}',
                                  style: DairyTypography.bodySmall(),
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
      padding: const EdgeInsets.all(DairySpacing.md),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all((DairySpacing.sm + 4)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: (DairySpacing.sm + 4)),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: DairyTypography.label().copyWith(
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
      padding: const EdgeInsets.all(DairySpacing.md),
      child: Column(
        children: [
          const SizedBox(height: (DairySpacing.md + 4)),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [DairyColorsLight.primary, DairyColorsLight.primaryDark]),
              boxShadow: DairyColorsLight.elevatedShadow,
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: DairySpacing.md),
          Text(
            user?.name ?? 'Customer',
            style: DairyTypography.headingLarge(),
          ),
          const SizedBox(height: DairySpacing.sm),
          Text(
            user?.phone ?? '',
            style: DairyTypography.body(),
          ),
          const SizedBox(height: DairySpacing.xl),

          // Profile Options
          _buildProfileOption(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Manage Address',
            subtitle: user?.address ?? 'Add your address',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageAddressScreen()),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
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
