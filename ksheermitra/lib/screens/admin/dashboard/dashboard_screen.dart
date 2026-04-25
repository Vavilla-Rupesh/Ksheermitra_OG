import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../models/dashboard_stats.dart';
import '../../../config/dairy_theme.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/dairy_animations.dart';
import '../offline_sales/offline_sales_list_screen.dart';
import '../customers/customer_map_screen.dart';
import '../products/product_list_screen.dart';
import '../customers/add_customer_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.stats == null) {
            return Padding(
              padding: const EdgeInsets.all(DairySpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DairySpacing.lg),
                  ShimmerLoading(width: 200, height: 28, borderRadius: DairyRadius.sm),
                  const SizedBox(height: DairySpacing.lg),
                  const SkeletonCardLoader(itemCount: 6, crossAxisCount: 2),
                ],
              ),
            );
          }

          if (provider.error != null && provider.stats == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DairySpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: DairyColorsLight.errorSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 40, color: DairyColorsLight.error),
                    ),
                    const SizedBox(height: DairySpacing.lg),
                    Text('Something went wrong', style: DairyTypography.headingSmall()),
                    const SizedBox(height: DairySpacing.sm),
                    Text(
                      provider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: DairyTypography.body(),
                    ),
                    const SizedBox(height: DairySpacing.lg),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadDashboardStats(),
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DairySpacing.screenPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DairySlideUp(child: _buildHeader(provider)),
                  const SizedBox(height: DairySpacing.sectionSpacing),
                  DairySlideUp(delay: const Duration(milliseconds: 100), child: _buildQuickActions()),
                  const SizedBox(height: DairySpacing.sectionSpacing),
                  DairySlideUp(delay: const Duration(milliseconds: 200), child: _buildStatsGrid(provider.stats!)),
                  const SizedBox(height: DairySpacing.sectionSpacing),
                  DairySlideUp(delay: const Duration(milliseconds: 300), child: _buildDeliveryStatusChart(provider.stats!)),
                  const SizedBox(height: DairySpacing.sectionSpacing),
                  DairySlideUp(delay: const Duration(milliseconds: 400), child: _buildRevenueCard(provider.stats!)),
                  const SizedBox(height: DairySpacing.lg),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(DashboardProvider provider) {
    final lastRefresh = provider.lastRefresh;
    final timeAgo = lastRefresh != null ? _getTimeAgo(lastRefresh) : 'Never';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard', style: DairyTypography.headingLarge()),
            const SizedBox(height: DairySpacing.xs),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: DairySpacing.md, vertical: DairySpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: DairyRadius.pillBorderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: DairySpacing.xs),
              Text(timeAgo, style: DairyTypography.caption(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    final primary = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: DairySpacing.md,
          crossAxisSpacing: DairySpacing.md,
          childAspectRatio: 1.25,
          children: [
            _buildStatCard('Total Customers', stats.totalCustomers.toString(), Icons.people_outline, const Color(0xFF2563EB), subtitle: '${stats.activeCustomers} active'),
            _buildStatCard('Delivery Boys', stats.totalDeliveryBoys.toString(), Icons.delivery_dining, const Color(0xFF0EA5E9), subtitle: '${stats.activeDeliveryBoys} active'),
            _buildStatCard('Today\'s Deliveries', stats.todaysDeliveries.toString(), Icons.local_shipping_outlined, const Color(0xFF6366F1), subtitle: '${stats.todaysDelivered} delivered'),
            _buildStatCard('Today\'s Revenue', '₹${stats.todaysRevenue.toStringAsFixed(0)}', Icons.currency_rupee, const Color(0xFF8B5CF6), subtitle: 'From deliveries'),
            _buildStatCard('Subscriptions', stats.activeSubscriptions.toString(), Icons.subscriptions_outlined, const Color(0xFF0891B2), subtitle: 'Active'),
            _buildStatCard('Products', stats.totalProducts.toString(), Icons.inventory_2_outlined, primary, subtitle: '${stats.totalAreas} areas'),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    final colors = context.dairyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: DairyRadius.xlBorderRadius,
        boxShadow: colors.cardShadow,
        border: context.isDarkMode ? Border.all(color: colors.border) : null,
      ),
      padding: const EdgeInsets.all(DairySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: DairyRadius.defaultBorderRadius,
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: DairySpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: DairyTypography.headingMedium()),
          ),
          const SizedBox(height: 2),
          Text(title, style: DairyTypography.caption(), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(subtitle, style: DairyTypography.caption(color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDeliveryStatusChart(DashboardStats stats) {
    final total = stats.todaysDeliveries;
    if (total == 0) return const SizedBox.shrink();
    final colors = context.dairyColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: DairyRadius.xlBorderRadius,
        boxShadow: colors.cardShadow,
        border: context.isDarkMode ? Border.all(color: colors.border) : null,
      ),
      padding: DairySpacing.cardContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Delivery Status', style: DairyTypography.headingSmall()),
          const SizedBox(height: DairySpacing.lg),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats.todaysPending.toDouble(),
                    title: '${stats.todaysPending}\nPending',
                    color: DairyColorsLight.warning,
                    radius: 80,
                    titleStyle: DairyTypography.badge(),
                  ),
                  PieChartSectionData(
                    value: stats.todaysDelivered.toDouble(),
                    title: '${stats.todaysDelivered}\nDelivered',
                    color: DairyColorsLight.success,
                    radius: 80,
                    titleStyle: DairyTypography.badge(),
                  ),
                  PieChartSectionData(
                    value: stats.todaysMissed.toDouble(),
                    title: '${stats.todaysMissed}\nMissed',
                    color: DairyColorsLight.error,
                    radius: 80,
                    titleStyle: DairyTypography.badge(),
                  ),
                ],
                sectionsSpace: 3,
                centerSpaceRadius: 44,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(DashboardStats stats) {
    final colors = context.dairyColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: DairyRadius.xlBorderRadius,
        boxShadow: colors.cardShadow,
        border: context.isDarkMode ? Border.all(color: colors.border) : null,
      ),
      padding: DairySpacing.cardContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: DairyTypography.headingSmall()),
          const SizedBox(height: DairySpacing.md),
          Row(
            children: [
              Expanded(child: _buildRevenueItem('Collected', stats.collectedPayments, DairyColorsLight.success)),
              const SizedBox(width: DairySpacing.md),
              Expanded(child: _buildRevenueItem('Pending', stats.pendingPayments, DairyColorsLight.warning)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(DairySpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: DairyRadius.largeBorderRadius,
      ),
      child: Column(
        children: [
          Text(title, style: DairyTypography.label(color: color)),
          const SizedBox(height: DairySpacing.sm),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: DairyTypography.headingSmall(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: DairyTypography.headingSmall()),
        const SizedBox(height: DairySpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionCard('In-Store Sales', Icons.shopping_cart_outlined, primary, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OfflineSalesListScreen()));
              }),
            ),
            const SizedBox(width: DairySpacing.md),
            Expanded(
              child: _buildActionCard('Add Customer', Icons.person_add_outlined, const Color(0xFF0EA5E9), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
              }),
            ),
          ],
        ),
        const SizedBox(height: DairySpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionCard('Add Product', Icons.add_box_outlined, const Color(0xFF6366F1), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductFormScreen(product: null)));
              }),
            ),
            const SizedBox(width: DairySpacing.md),
            Expanded(
              child: _buildActionCard('View Map', Icons.map_outlined, const Color(0xFF8B5CF6), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerMapScreen()));
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: DairyRadius.xlBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(DairySpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.8)],
            ),
            borderRadius: DairyRadius.xlBorderRadius,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(DairySpacing.sm + 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: DairyRadius.defaultBorderRadius,
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: DairySpacing.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: DairyTypography.label(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
