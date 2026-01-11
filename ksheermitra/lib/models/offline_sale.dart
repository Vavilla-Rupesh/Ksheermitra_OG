class OfflineSale {
  final String id;
  final String saleNumber;
  final DateTime saleDate;
  final String adminId;
  final double totalAmount;
  final List<OfflineSaleItem> items;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final String? notes;
  final String? invoiceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfflineSale({
    required this.id,
    required this.saleNumber,
    required this.saleDate,
    required this.adminId,
    required this.totalAmount,
    required this.items,
    this.customerName,
    this.customerPhone,
    required this.paymentMethod,
    this.notes,
    this.invoiceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfflineSale.fromJson(Map<String, dynamic> json) {
    return OfflineSale(
      id: json['id'],
      saleNumber: json['saleNumber'],
      saleDate: DateTime.parse(json['saleDate']),
      adminId: json['adminId'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      items: (json['items'] as List)
          .map((item) => OfflineSaleItem.fromJson(item))
          .toList(),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      paymentMethod: json['paymentMethod'],
      notes: json['notes'],
      invoiceId: json['invoiceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'saleNumber': saleNumber,
      'saleDate': saleDate.toIso8601String(),
      'adminId': adminId,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'customerName': customerName,
      'customerPhone': customerPhone,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'invoiceId': invoiceId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class OfflineSaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final double pricePerUnit;
  final double amount;

  OfflineSaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.amount,
  });

  factory OfflineSaleItem.fromJson(Map<String, dynamic> json) {
    return OfflineSaleItem(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      unit: json['unit'],
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      amount: double.parse(json['amount'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'amount': amount,
    };
  }
}

class SalesStats {
  final int totalSales;
  final double totalRevenue;
  final double averageSaleAmount;

  SalesStats({
    required this.totalSales,
    required this.totalRevenue,
    required this.averageSaleAmount,
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      totalSales: int.parse(json['totalSales']?.toString() ?? '0'),
      totalRevenue: double.parse(json['totalRevenue']?.toString() ?? '0'),
      averageSaleAmount: double.parse(json['averageSaleAmount']?.toString() ?? '0'),
    );
  }
}

class CreateOfflineSaleRequest {
  final List<CreateOfflineSaleItem> items;
  final String? customerName;
  final String? customerPhone;
  final String paymentMethod;
  final String? notes;

  CreateOfflineSaleRequest({
    required this.items,
    this.customerName,
    this.customerPhone,
    this.paymentMethod = 'cash',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'items': items.map((item) => item.toJson()).toList(),
      'paymentMethod': paymentMethod,
    };

    // Only include optional fields if they have values
    if (customerName != null && customerName!.isNotEmpty) {
      data['customerName'] = customerName;
    }
    if (customerPhone != null && customerPhone!.isNotEmpty) {
      data['customerPhone'] = customerPhone;
    }
    if (notes != null && notes!.isNotEmpty) {
      data['notes'] = notes;
    }

    return data;
  }
}

class CreateOfflineSaleItem {
  final String productId;
  final int quantity;

  CreateOfflineSaleItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

