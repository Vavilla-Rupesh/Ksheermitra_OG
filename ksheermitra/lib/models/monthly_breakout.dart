class MonthlyBreakoutResponse {
  final String subscriptionId;
  final int year;
  final int month;
  final String monthName;
  final String periodStart;
  final String periodEnd;
  final double totalAmount;
  final double deliveredAmount;
  final double pendingAmount;
  final double cancelledAmount;
  final int deliveryCount;
  final int deliveredCount;
  final int pendingCount;
  final List<DailyBreakout> breakout;

  MonthlyBreakoutResponse({
    required this.subscriptionId,
    required this.year,
    required this.month,
    required this.monthName,
    required this.periodStart,
    required this.periodEnd,
    required this.totalAmount,
    required this.deliveredAmount,
    required this.pendingAmount,
    required this.cancelledAmount,
    required this.deliveryCount,
    required this.deliveredCount,
    required this.pendingCount,
    required this.breakout,
  });

  factory MonthlyBreakoutResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyBreakoutResponse(
      subscriptionId: json['subscriptionId'],
      year: json['year'],
      month: json['month'],
      monthName: json['monthName'],
      periodStart: json['periodStart'],
      periodEnd: json['periodEnd'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveredAmount: (json['deliveredAmount'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      cancelledAmount: (json['cancelledAmount'] as num).toDouble(),
      deliveryCount: json['deliveryCount'],
      deliveredCount: json['deliveredCount'],
      pendingCount: json['pendingCount'],
      breakout: (json['breakout'] as List)
          .map((item) => DailyBreakout.fromJson(item))
          .toList(),
    );
  }
}

class DailyBreakout {
  final String id;
  final String date;
  final String dayOfWeek;
  final String status;
  final double amount;
  final List<DeliveryItem> items;
  final String? deliveredAt;
  final String? notes;
  final bool isEditable;

  DailyBreakout({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.status,
    required this.amount,
    required this.items,
    this.deliveredAt,
    this.notes,
    required this.isEditable,
  });

  factory DailyBreakout.fromJson(Map<String, dynamic> json) {
    return DailyBreakout(
      id: json['id'],
      date: json['date'],
      dayOfWeek: json['dayOfWeek'],
      status: json['status'],
      amount: (json['amount'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => DeliveryItem.fromJson(item))
          .toList(),
      deliveredAt: json['deliveredAt'],
      notes: json['notes'],
      isEditable: json['isEditable'] ?? false,
    );
  }

  bool get isPending => status == 'pending';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isMissed => status == 'missed';
}

class DeliveryItem {
  final String id;
  final String productId;
  final String productName;
  final double quantity;
  final double price;
  final String unit;
  final double pricePerUnit;
  final bool isOneTime;

  DeliveryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.pricePerUnit,
    required this.isOneTime,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      unit: json['unit'],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      isOneTime: json['isOneTime'] ?? false,
    );
  }
}

class CustomerMonthlyBreakout {
  final String customerId;
  final int year;
  final int month;
  final String monthName;
  final double totalAmount;
  final double deliveredAmount;
  final double pendingAmount;
  final int subscriptionCount;
  final List<MonthlyBreakoutResponse> subscriptions;

  CustomerMonthlyBreakout({
    required this.customerId,
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalAmount,
    required this.deliveredAmount,
    required this.pendingAmount,
    required this.subscriptionCount,
    required this.subscriptions,
  });

  factory CustomerMonthlyBreakout.fromJson(Map<String, dynamic> json) {
    return CustomerMonthlyBreakout(
      customerId: json['customerId'],
      year: json['year'],
      month: json['month'],
      monthName: json['monthName'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveredAmount: (json['deliveredAmount'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      subscriptionCount: json['subscriptionCount'],
      subscriptions: (json['subscriptions'] as List)
          .map((item) => MonthlyBreakoutResponse.fromJson(item))
          .toList(),
    );
  }
}

