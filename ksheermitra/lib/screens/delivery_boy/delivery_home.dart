import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/dairy_theme.dart';
import '../../widgets/premium_widgets.dart';
import 'delivery_map_screen.dart';
import 'route_navigation_screen.dart';
import 'invoice_generation_screen.dart';
import 'delivery_boy_history_screen.dart';
import 'delivery_boy_profile_screen.dart';

class DeliveryHome extends StatefulWidget {
  const DeliveryHome({super.key});

  @override
  State<DeliveryHome> createState() => _DeliveryHomeState();
}

class _DeliveryHomeState extends State<DeliveryHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final primary = Theme.of(context).colorScheme.primary;

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
        title: 'Delivery Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(context, DairyPageRoute(page: const DeliveryBoyProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout', style: DairyTypography.headingSmall()),
                  content: Text('Are you sure you want to logout?', style: DairyTypography.body()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: DairyColorsLight.error),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(user),
          _buildMapTab(),
          _buildStatsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: primary,
        unselectedItemColor: DairyColorsLight.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Route'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Stats'),
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
          // Welcome Card with Gradient
          DairySlideUp(
            child: Container(
              width: double.infinity,
              padding: DairySpacing.cardContentPadding,
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
                        padding: const EdgeInsets.all(DairySpacing.sm + 4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.delivery_dining, color: primary, size: 28),
                      ),
                      const SizedBox(width: DairySpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome,', style: DairyTypography.body(color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text(
                              user?.name ?? 'Delivery Boy',
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
                  Text(
                    '🚀 Ready for today\'s deliveries?',
                    style: DairyTypography.bodyLarge(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: DairySpacing.sectionSpacing),
          DairySlideUp(
            delay: const Duration(milliseconds: 100),
            child: Text('Today\'s Deliveries', style: DairyTypography.headingSmall()),
          ),
          const SizedBox(height: DairySpacing.md),

          // Delivery Stats Cards
          DairySlideUp(
            delay: const Duration(milliseconds: 150),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Pending',
                    count: '0',
                    icon: Icons.pending_actions,
                    color: DairyColorsLight.warning,
                  ),
                ),
                const SizedBox(width: DairySpacing.md),
                Expanded(
                  child: _buildStatCard(
                    label: 'Completed',
                    count: '0',
                    icon: Icons.check_circle_outline,
                    color: DairyColorsLight.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DairySpacing.md),
          DairySlideUp(
            delay: const Duration(milliseconds: 200),
            child: _buildStatCard(
              label: 'Missed',
              count: '0',
              icon: Icons.cancel_outlined,
              color: DairyColorsLight.error,
              isWide: true,
            ),
          ),

          const SizedBox(height: DairySpacing.sectionSpacing),

          // Action Buttons
          DairySlideUp(
            delay: const Duration(milliseconds: 250),
            child: Column(
              children: [
                PremiumButton(
                  text: 'Start Route Navigation',
                  icon: Icons.navigation,
                  onPressed: () {
                    Navigator.push(context, DairyPageRoute(page: const RouteNavigationScreen()));
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: DairySpacing.md),
                PremiumButton(
                  text: 'Generate Daily Invoice',
                  icon: Icons.receipt,
                  onPressed: () {
                    Navigator.push(context, DairyPageRoute(page: const InvoiceGenerationScreen()));
                  },
                  gradient: LinearGradient(
                    colors: [colors.secondary, colors.secondary.withValues(alpha: 0.8)],
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: DairySpacing.md),
                PremiumOutlineButton(
                  text: 'View Delivery History',
                  icon: Icons.history,
                  onPressed: () {
                    Navigator.push(context, DairyPageRoute(page: const DeliveryBoyHistoryScreen()));
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      padding: DairySpacing.cardContentPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: DairyRadius.xlBorderRadius,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isWide ? 36 : 28),
          const SizedBox(height: DairySpacing.sm),
          Text(count, style: DairyTypography.headingLarge(color: Colors.white)),
          const SizedBox(height: DairySpacing.xs),
          Text(label, style: DairyTypography.label(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return DeliveryMapScreen();
  }

  Widget _buildStatsTab() {
    final primary = Theme.of(context).colorScheme.primary;
    final colors = context.dairyColors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DairySpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Statistics', style: DairyTypography.headingMedium()),
          const SizedBox(height: DairySpacing.lg),

          // Weekly Stats
          Container(
            width: double.infinity,
            padding: DairySpacing.cardContentPadding,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: DairyRadius.xlBorderRadius,
              boxShadow: colors.cardShadow,
              border: context.isDarkMode ? Border.all(color: colors.border) : null,
            ),
            child: Column(
              children: [
                Text('This Week', style: DairyTypography.headingSmall()),
                const SizedBox(height: DairySpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Total', '0', Icons.local_shipping_outlined),
                    _buildMiniStat('On-Time', '0', Icons.access_time),
                    _buildMiniStat('Rating', '0.0', Icons.star_outline),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: DairySpacing.md),

          // Monthly Stats
          Container(
            width: double.infinity,
            padding: DairySpacing.cardContentPadding,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: DairyRadius.xlBorderRadius,
              boxShadow: colors.cardShadow,
              border: context.isDarkMode ? Border.all(color: colors.border) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Month', style: DairyTypography.headingSmall()),
                const SizedBox(height: DairySpacing.md),
                _buildStatRow('Total Deliveries', '0', Icons.inventory_2_outlined),
                const SizedBox(height: DairySpacing.md),
                _buildStatRow('Successful', '0', Icons.check_circle_outline),
                const SizedBox(height: DairySpacing.md),
                _buildStatRow('Missed', '0', Icons.cancel_outlined),
              ],
            ),
          ),

          const SizedBox(height: DairySpacing.md),

          // Earnings
          Container(
            width: double.infinity,
            padding: DairySpacing.cardContentPadding,
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
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 36),
                const SizedBox(height: DairySpacing.sm + 4),
                Text('Total Earnings', style: DairyTypography.body(color: Colors.white70)),
                const SizedBox(height: DairySpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.white, size: 24),
                    Text('0.00', style: DairyTypography.headingXLarge(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: primary, size: 24),
        const SizedBox(height: DairySpacing.sm),
        Text(value, style: DairyTypography.headingSmall()),
        const SizedBox(height: DairySpacing.xs),
        Text(label, style: DairyTypography.caption()),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: DairySpacing.sm),
            Text(label, style: DairyTypography.body()),
          ],
        ),
        Text(value, style: DairyTypography.bodyLarge(color: primary)),
      ],
    );
  }
}
