import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/premium_widgets.dart';

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
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
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
          // Welcome Card with Gradient
          PremiumCard(
            gradient: AppTheme.premiumCardGradient,
            shadows: AppTheme.premiumCardShadow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'Delivery Boy',
                            style: const TextStyle(
                              fontSize: 24,
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
                const Text(
                  '🚀 Ready for today\'s deliveries?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space24),
          const Text(
            'Today\'s Deliveries',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space12),

          // Delivery Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Pending',
                  count: '0',
                  icon: Icons.pending_actions,
                  gradient: AppTheme.pendingGradient,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildStatCard(
                  label: 'Completed',
                  count: '0',
                  icon: Icons.check_circle,
                  gradient: AppTheme.deliveredGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          _buildStatCard(
            label: 'Missed',
            count: '0',
            icon: Icons.cancel,
            gradient: LinearGradient(
              colors: [AppTheme.errorRed, AppTheme.errorRed.withValues(alpha: 0.7)],
            ),
            isWide: true,
          ),

          const SizedBox(height: AppTheme.space24),

          // Action Buttons
          PremiumButton(
            text: 'Start Route Navigation',
            icon: Icons.navigation,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Route navigation coming soon')),
              );
            },
            width: double.infinity,
          ),
          const SizedBox(height: AppTheme.space12),
          PremiumButton(
            text: 'Generate Daily Invoice',
            icon: Icons.receipt,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice generation coming soon')),
              );
            },
            gradient: AppTheme.secondaryButtonGradient,
            width: double.infinity,
          ),
          const SizedBox(height: AppTheme.space12),
          PremiumOutlineButton(
            text: 'View Delivery History',
            icon: Icons.history,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History coming soon')),
              );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required IconData icon,
    required LinearGradient gradient,
    bool isWide = false,
  }) {
    return PremiumCard(
      gradient: gradient,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isWide ? 40 : 32),
          const SizedBox(height: AppTheme.space8),
          Text(
            count,
            style: TextStyle(
              fontSize: isWide ? 32 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return PremiumEmptyState(
      icon: Icons.map_outlined,
      title: 'Route Map',
      message: 'Map view with delivery routes will be displayed here',
      actionText: 'View Deliveries',
      onAction: () {
        setState(() => _currentIndex = 0);
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Statistics',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.space16),

          // Weekly Stats
          PremiumCard(
            gradient: AppTheme.productCardGradient,
            child: Column(
              children: [
                const Text(
                  'This Week',
                  style: AppTheme.h4,
                ),
                const SizedBox(height: AppTheme.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Total', '0', Icons.local_shipping),
                    _buildMiniStat('On-Time', '0', Icons.access_time),
                    _buildMiniStat('Rating', '0.0', Icons.star),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space16),

          // Monthly Stats
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This Month',
                  style: AppTheme.h4,
                ),
                const SizedBox(height: AppTheme.space16),
                _buildStatRow('Total Deliveries', '0', Icons.inventory),
                const SizedBox(height: AppTheme.space12),
                _buildStatRow('Successful', '0', Icons.check_circle_outline),
                const SizedBox(height: AppTheme.space12),
                _buildStatRow('Missed', '0', Icons.cancel_outlined),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space16),

          // Earnings (if applicable)
          PremiumCard(
            gradient: AppTheme.premiumCardGradient,
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: AppTheme.space12),
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.currency_rupee, color: Colors.white, size: 24),
                    Text(
                      '0.00',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 28),
        const SizedBox(height: AppTheme.space8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: AppTheme.space8),
            Text(label, style: AppTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: AppTheme.h5.copyWith(color: AppTheme.primaryColor),
        ),
      ],
    );
  }
}
