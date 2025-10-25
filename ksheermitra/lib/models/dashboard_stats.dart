class DashboardStats {
  final int totalCustomers;
  final int activeCustomers;
  final int totalDeliveryBoys;
  final int activeDeliveryBoys;
  final int todaysDeliveries;
  final int todaysPending;
  final int todaysDelivered;
  final int todaysMissed;
  final double todaysRevenue;
  final int activeSubscriptions;
  final int totalProducts;
  final int totalAreas;
  final double pendingPayments;
  final double collectedPayments;

  DashboardStats({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalDeliveryBoys,
    required this.activeDeliveryBoys,
    required this.todaysDeliveries,
    required this.todaysPending,
    required this.todaysDelivered,
    required this.todaysMissed,
    required this.todaysRevenue,
    required this.activeSubscriptions,
    required this.totalProducts,
    required this.totalAreas,
    required this.pendingPayments,
    required this.collectedPayments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCustomers: json['totalCustomers'] ?? 0,
      activeCustomers: json['activeCustomers'] ?? 0,
      totalDeliveryBoys: json['totalDeliveryBoys'] ?? 0,
      activeDeliveryBoys: json['activeDeliveryBoys'] ?? 0,
      todaysDeliveries: json['todaysDeliveries'] ?? 0,
      todaysPending: json['todaysPending'] ?? 0,
      todaysDelivered: json['todaysDelivered'] ?? 0,
      todaysMissed: json['todaysMissed'] ?? 0,
      todaysRevenue: double.parse((json['todaysRevenue'] ?? 0).toString()),
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalAreas: json['totalAreas'] ?? 0,
      pendingPayments: double.parse((json['pendingPayments'] ?? 0).toString()),
      collectedPayments: double.parse((json['collectedPayments'] ?? 0).toString()),
    );
  }
}
