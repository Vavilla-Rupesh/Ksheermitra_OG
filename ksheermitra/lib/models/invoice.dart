import 'user.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String type;
  final DateTime invoiceDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String? customerId;
  final String? deliveryBoyId;
  final double totalAmount;
  final double paidAmount;
  final String paymentStatus;
  final String? pdfPath;
  final String? notes;
  final User? customer;
  final User? deliveryBoy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? deliveryDetails;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.invoiceDate,
    required this.periodStart,
    required this.periodEnd,
    this.customerId,
    this.deliveryBoyId,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentStatus,
    this.pdfPath,
    this.notes,
    this.customer,
    this.deliveryBoy,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryDetails,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoiceNumber']?.toString() ?? '',
      type: json['type']?.toString() ?? 'customer',
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.tryParse(json['invoiceDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      periodStart: json['periodStart'] != null
          ? DateTime.tryParse(json['periodStart'].toString()) ?? DateTime.now()
          : DateTime.now(),
      periodEnd: json['periodEnd'] != null
          ? DateTime.tryParse(json['periodEnd'].toString()) ?? DateTime.now()
          : DateTime.now(),
      customerId: json['customerId']?.toString(),
      deliveryBoyId: json['deliveryBoyId']?.toString(),
      totalAmount: json['totalAmount'] != null
          ? double.tryParse(json['totalAmount'].toString()) ?? 0.0
          : 0.0,
      paidAmount: json['paidAmount'] != null
          ? double.tryParse(json['paidAmount'].toString()) ?? 0.0
          : 0.0,
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      pdfPath: json['pdfPath']?.toString(),
      notes: json['notes']?.toString(),
      customer: json['customer'] != null && json['customer'] is Map<String, dynamic>
          ? User.fromJson(json['customer'])
          : null,
      deliveryBoy: json['deliveryBoy'] != null && json['deliveryBoy'] is Map<String, dynamic>
          ? User.fromJson(json['deliveryBoy'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deliveryDetails: json['deliveryDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'type': type,
      'invoiceDate': invoiceDate.toIso8601String(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'customerId': customerId,
      'deliveryBoyId': deliveryBoyId,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'paymentStatus': paymentStatus,
      'pdfPath': pdfPath,
      'notes': notes,
    };
  }

  bool get isPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isPartiallyPaid => paymentStatus == 'partially_paid';
  bool get isOverdue => paymentStatus == 'overdue';
  
  bool get isDaily => type == 'daily';
  bool get isMonthly => type == 'monthly';

  double get remainingAmount => totalAmount - paidAmount;
}
