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
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      type: json['type'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      customerId: json['customerId'],
      deliveryBoyId: json['deliveryBoyId'],
      totalAmount: double.parse(json['totalAmount'].toString()),
      paidAmount: double.parse(json['paidAmount'].toString()),
      paymentStatus: json['paymentStatus'],
      pdfPath: json['pdfPath'],
      notes: json['notes'],
      customer: json['customer'] != null 
          ? User.fromJson(json['customer']) 
          : null,
      deliveryBoy: json['deliveryBoy'] != null 
          ? User.fromJson(json['deliveryBoy']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
