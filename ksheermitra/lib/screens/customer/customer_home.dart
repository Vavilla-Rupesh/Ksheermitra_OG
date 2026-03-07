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
    final primary = Theme.of(context).colorScheme.primary;

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
        title: Text('Ksheermitra', style: DairyTypography.headingSmall()),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(context, DairyPageRoute(page: const NotificationsScreen()));
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
                          style: DairyTypography.badge(),
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
        selectedItemColor: primary,
        unselectedItemColor: DairyColorsLight.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions_outlined), activeIcon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(user) {
    final primary = Theme.of(context).colorScheme.primary;
    final colors = context.dairyColors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DairySpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Welcome Card with gradient
          DairySlideUp(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DairySpacing.cardPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, primary.withValues(alpha: 0.85)],
                ),
                borderRadius: DairyRadius.xlBorderRadius,
                boxShadow: [
                  BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Icon(Icons.person, size: 30, color: primary),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back!', style: DairyTypography.body(color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text(
                              user?.name ?? 'Customer',
                              style: DairyTypography.headingMedium(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DairySpacing.md),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: DairySpacing.sm + 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 16),
                      const SizedBox(width: DairySpacing.sm),
                      Text(user?.phone ?? '', style: DairyTypography.bodySmall(color: Colors.white)),
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
                          child: Text(user.address!, style: DairyTypography.bodySmall(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: DairySpacing.sectionSpacing),

          // Quick Actions Section
          DairySlideUp(
            delay: const Duration(milliseconds: 100),
            child: Text('Quick Actions', style: DairyTypography.headingSmall()),
          ),
          const SizedBox(height: DairySpacing.md),
          DairySlideUp(
            delay: const Duration(milliseconds: 150),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: DairySpacing.md,
              crossAxisSpacing: DairySpacing.md,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard('Browse Products', Icons.shopping_bag_outlined, DairyColorsLight.info, () async {
                  await Navigator.push(context, DairyPageRoute(page: const ProductSelectionScreen()));
                  if (mounted) Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
                }),
                _buildActionCard('My Subscriptions', Icons.subscriptions_outlined, DairyColorsLight.success, () => setState(() => _currentIndex = 1)),
                _buildActionCard('View Bills', Icons.receipt_long_outlined, DairyColorsLight.warning, () {
                  Navigator.push(context, DairyPageRoute(page: const BillingScreen()));
                }),
                _buildActionCard('Monthly Breakout', Icons.calendar_month_outlined, const Color(0xFF6366F1), () {
                  Navigator.push(context, DairyPageRoute(page: const MonthlyBreakoutScreen()));
                }),
              ],
            ),
          ),
          const SizedBox(height: DairySpacing.sectionSpacing),

          // Active Subscriptions Summary
          Consumer<SubscriptionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const PremiumLoadingWidget(message: 'Loading subscriptions...');
              }

              if (provider.subscriptions.isEmpty) {
                return DairySlideUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DairySpacing.cardPadding + 4),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: DairyRadius.xlBorderRadius,
                      boxShadow: colors.cardShadow,
                      border: context.isDarkMode ? Border.all(color: colors.border) : null,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.subscriptions_outlined, size: 56, color: primary.withValues(alpha: 0.4)),
                        const SizedBox(height: DairySpacing.md),
                        Text('No Active Subscriptions', style: DairyTypography.headingSmall()),
                        const SizedBox(height: DairySpacing.sm),
                        Text('Start a subscription for regular deliveries', textAlign: TextAlign.center, style: DairyTypography.body()),
                        const SizedBox(height: DairySpacing.lg),
                        PremiumButton(
                          text: 'Browse Products',
                          icon: Icons.add_circle,
                          onPressed: () async {
                            await Navigator.push(context, DairyPageRoute(page: const ProductSelectionScreen()));
                            if (mounted) Provider.of<SubscriptionProvider>(context, listen: false).loadSubscriptions();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              return DairySlideUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Active Subscriptions', style: DairyTypography.headingSmall()),
                        PremiumTextButton(text: 'View All', onPressed: () => setState(() => _currentIndex = 1)),
                      ],
                    ),
                    const SizedBox(height: DairySpacing.md),
                    ...provider.subscriptions.take(3).map((subscription) {
                      final productCount = subscription.products?.length ?? 0;
                      final displayText = productCount == 1
                          ? subscription.products![0].product?.name ?? 'Product'
                          : '$productCount products';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: DairySpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.all(DairySpacing.md),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: DairyRadius.xlBorderRadius,
                            boxShadow: colors.cardShadow,
                            border: context.isDarkMode ? Border.all(color: colors.border) : null,
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _currentIndex = 1),
                            borderRadius: DairyRadius.xlBorderRadius,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(DairySpacing.sm + 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [DairyColorsLight.success, const Color(0xFF66BB6A)]),
                                    borderRadius: DairyRadius.defaultBorderRadius,
                                  ),
                                  child: const Icon(Icons.subscriptions, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: DairySpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(displayText, style: DairyTypography.bodyLarge()),
                                      const SizedBox(height: DairySpacing.xs),
                                      Text(
                                        '${subscription.totalQuantity.toStringAsFixed(1)} total • ${subscription.frequencyDisplay}',
                                        style: DairyTypography.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                subscription.isActive
                                    ? PremiumBadge.active(subscription.status)
                                    : PremiumBadge.pending(subscription.status),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    final colors = context.dairyColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: DairyRadius.xlBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(DairySpacing.md),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: DairyRadius.xlBorderRadius,
            boxShadow: colors.cardShadow,
            border: context.isDarkMode ? Border.all(color: colors.border) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DairySpacing.sm + 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: DairySpacing.sm + 4),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DairyTypography.label().copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(user) {
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DairySpacing.screenPaddingH),
      child: Column(
        children: [
          const SizedBox(height: DairySpacing.lg),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.8)]),
              boxShadow: [
                BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.person, size: 52, color: Colors.white),
          ),
          const SizedBox(height: DairySpacing.md),
          Text(user?.name ?? 'Customer', style: DairyTypography.headingLarge()),
          const SizedBox(height: DairySpacing.sm),
          Text(user?.phone ?? '', style: DairyTypography.body()),
          const SizedBox(height: DairySpacing.xl),

          // Profile Options
          _buildProfileOption(icon: Icons.person_outline, title: 'Edit Profile', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const EditProfileScreen()));
          }),
          _buildProfileOption(icon: Icons.location_on_outlined, title: 'Manage Address', subtitle: user?.address ?? 'Add your address', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const ManageAddressScreen()));
          }),
          _buildProfileOption(icon: Icons.receipt_long_outlined, title: 'Billing & Invoices', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const BillingScreen()));
          }),
          _buildProfileOption(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const NotificationsScreen()));
          }),
          _buildProfileOption(icon: Icons.help_outline, title: 'Help & Support', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const HelpSupportScreen()));
          }),
          _buildProfileOption(icon: Icons.info_outline, title: 'About', onTap: () {
            Navigator.push(context, DairyPageRoute(page: const AboutScreen()));
          }),
          const SizedBox(height: DairySpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout', style: DairyTypography.headingSmall()),
                    content: Text('Are you sure you want to logout?', style: DairyTypography.body()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: DairyColorsLight.error),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (mounted) Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout, color: DairyColorsLight.error),
              label: Text('Logout', style: DairyTypography.button(color: DairyColorsLight.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: DairyColorsLight.error),
                padding: const EdgeInsets.symmetric(vertical: DairySpacing.buttonPaddingV),
                shape: RoundedRectangleBorder(borderRadius: DairyRadius.largeBorderRadius),
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
    final primary = Theme.of(context).colorScheme.primary;
    final colors = context.dairyColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DairySpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: DairyRadius.xlBorderRadius,
          boxShadow: colors.cardShadow,
          border: context.isDarkMode ? Border.all(color: colors.border) : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.xs),
          leading: Container(
            padding: const EdgeInsets.all(DairySpacing.sm),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: DairyRadius.defaultBorderRadius,
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          title: Text(title, style: DairyTypography.bodyLarge()),
          subtitle: subtitle != null ? Text(subtitle, style: DairyTypography.caption(), maxLines: 1, overflow: TextOverflow.ellipsis) : null,
          trailing: Icon(Icons.chevron_right, color: DairyColorsLight.textTertiary),
          onTap: onTap,
        ),
      ),
    );
  }
}
