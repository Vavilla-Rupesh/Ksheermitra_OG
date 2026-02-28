/// Invoice Service
///
/// Handles invoice generation, PDF creation, and submission workflow.
/// Supports both individual delivery invoices and daily summary invoices.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../../../../config/api_config.dart';
import '../../../../utils/storage_helper.dart';

/// Status of an invoice
enum InvoiceStatus {
  /// Invoice has been generated
  generated,

  /// Invoice has been submitted for approval
  submitted,

  /// Invoice has been approved by admin
  approved,

  /// Invoice has been rejected by admin
  rejected,

  /// Invoice is pending review
  pending,
}

/// Type of invoice
enum InvoiceType {
  /// Individual delivery invoice
  delivery,

  /// Daily summary invoice for all deliveries
  dailySummary,

  /// Customer-specific invoice
  customer,
}

/// Represents an invoice
class Invoice {
  final String id;
  final String invoiceNumber;
  final InvoiceType type;
  final InvoiceStatus status;
  final String? deliveryBoyId;
  final String? deliveryBoyName;
  final String? customerId;
  final String? customerName;
  final DateTime invoiceDate;
  final double totalAmount;
  final List<InvoiceItem> items;
  final String? notes;
  final String? pdfUrl;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.status,
    this.deliveryBoyId,
    this.deliveryBoyName,
    this.customerId,
    this.customerName,
    required this.invoiceDate,
    required this.totalAmount,
    required this.items,
    this.notes,
    this.pdfUrl,
    this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      type: _parseType(json['invoiceType'] ?? json['type']),
      status: _parseStatus(json['status']),
      deliveryBoyId: json['deliveryBoyId'],
      deliveryBoyName: json['deliveryBoyName'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.parse(json['invoiceDate'].toString())
          : DateTime.now(),
      totalAmount: _parseDouble(json['totalAmount']) ?? 0.0,
      items: _parseItems(json['items'] ?? json['metadata']?['deliveries']),
      notes: json['notes'],
      pdfUrl: json['pdfUrl'],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      approvedBy: json['approvedBy'],
      rejectionReason: json['rejectionReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static InvoiceType _parseType(dynamic type) {
    if (type == null) return InvoiceType.delivery;
    final typeStr = type.toString().toLowerCase();
    if (typeStr.contains('daily') || typeStr.contains('summary')) {
      return InvoiceType.dailySummary;
    }
    if (typeStr.contains('customer')) {
      return InvoiceType.customer;
    }
    return InvoiceType.delivery;
  }

  static InvoiceStatus _parseStatus(dynamic status) {
    if (status == null) return InvoiceStatus.generated;
    switch (status.toString().toLowerCase()) {
      case 'submitted':
        return InvoiceStatus.submitted;
      case 'approved':
        return InvoiceStatus.approved;
      case 'rejected':
        return InvoiceStatus.rejected;
      case 'pending':
        return InvoiceStatus.pending;
      default:
        return InvoiceStatus.generated;
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<InvoiceItem> _parseItems(dynamic items) {
    if (items == null) return [];
    if (items is! List) return [];
    return items.map((i) => InvoiceItem.fromJson(i)).toList();
  }

  /// Whether invoice can be submitted
  bool get canSubmit => status == InvoiceStatus.generated;

  /// Whether invoice is finalized
  bool get isFinalized =>
      status == InvoiceStatus.approved || status == InvoiceStatus.rejected;
}

/// Item in an invoice
class InvoiceItem {
  final String? deliveryId;
  final String? productId;
  final String description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final String? customerName;
  final String? customerPhone;

  const InvoiceItem({
    this.deliveryId,
    this.productId,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.customerName,
    this.customerPhone,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    final quantity = _parseDouble(json['quantity']) ?? 1.0;
    final unitPrice = _parseDouble(json['price'] ?? json['unitPrice']) ?? 0.0;

    return InvoiceItem(
      deliveryId: json['deliveryId'],
      productId: json['productId'],
      description: json['description'] ??
          json['productName'] ??
          json['customerName'] ??
          'Item',
      quantity: quantity,
      unit: json['unit'] ?? 'pcs',
      unitPrice: unitPrice,
      totalPrice: _parseDouble(json['totalPrice'] ?? json['amount']) ??
          (quantity * unitPrice),
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Service for managing invoices
class InvoiceService {
  final Dio _dio;

  InvoiceService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.requestTimeout,
          receiveTimeout: ApiConfig.requestTimeout,
          headers: ApiConfig.defaultHeaders,
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('Invoice API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  /// Generates a daily summary invoice for all completed deliveries
  ///
  /// [date] - The date to generate invoice for (defaults to today)
  Future<Invoice> generateDailySummaryInvoice({DateTime? date}) async {
    try {
      final invoiceDate = date ?? DateTime.now();
      final dateString =
          '${invoiceDate.year}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}';

      final response = await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/generate-invoice',
        data: {'date': dateString},
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to generate invoice',
          code: 'GENERATION_FAILED',
        );
      }

      return Invoice.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'GENERATION_FAILED',
      );
    }
  }

  /// Submits an invoice for admin approval
  Future<Invoice> submitInvoice(String invoiceId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.deliveryBoyEndpoint}/invoices/$invoiceId/submit',
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to submit invoice',
          code: 'SUBMISSION_FAILED',
        );
      }

      return Invoice.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'SUBMISSION_FAILED',
      );
    }
  }

  /// Gets all invoices for the current delivery boy
  Future<List<Invoice>> getMyInvoices({
    DateTime? startDate,
    DateTime? endDate,
    InvoiceStatus? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }
      if (endDate != null) {
        queryParams['endDate'] =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/invoices',
        queryParameters: queryParams,
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to fetch invoices',
          code: 'FETCH_FAILED',
        );
      }

      final List invoices = response.data['data'] ?? [];
      return invoices.map((i) => Invoice.fromJson(i)).toList();
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'FETCH_FAILED',
      );
    }
  }

  /// Gets a specific invoice by ID
  Future<Invoice> getInvoice(String invoiceId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.deliveryBoyEndpoint}/invoices/$invoiceId',
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Invoice not found',
          code: 'NOT_FOUND',
        );
      }

      return Invoice.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'FETCH_FAILED',
      );
    }
  }

  /// Generates a PDF for the given invoice
  ///
  /// Returns the file path of the generated PDF
  Future<String> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(invoice),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          _buildInvoiceInfo(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 20),
          _buildTotalSection(invoice),
          if (invoice.notes != null) ...[
            pw.SizedBox(height: 20),
            _buildNotesSection(invoice),
          ],
        ],
      ),
    );

    // Save to temporary directory
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Prints the invoice
  Future<void> printInvoice(Invoice invoice) async {
    final pdfPath = await generateInvoicePdf(invoice);
    final file = File(pdfPath);
    final bytes = await file.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: 'Invoice ${invoice.invoiceNumber}',
    );
  }

  /// Shares the invoice PDF
  Future<void> shareInvoice(Invoice invoice) async {
    final pdfPath = await generateInvoicePdf(invoice);
    final file = File(pdfPath);
    final bytes = await file.readAsBytes();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.pdf',
    );
  }

  // PDF building helpers
  pw.Widget _buildPdfHeader(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'KsheerMitra',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal,
                ),
              ),
              pw.Text(
                'Smart Milk Delivery System',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                invoice.invoiceNumber,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }

  pw.Widget _buildInvoiceInfo(Invoice invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice Date:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}'),
              pw.SizedBox(height: 8),
              pw.Text('Status:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(invoice.status.name.toUpperCase()),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (invoice.deliveryBoyName != null) ...[
                pw.Text('Delivery Agent:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(invoice.deliveryBoyName!),
                pw.SizedBox(height: 8),
              ],
              if (invoice.customerName != null) ...[
                pw.Text('Customer:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(invoice.customerName!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.teal50),
          children: [
            _tableCell('Description', isHeader: true),
            _tableCell('Qty', isHeader: true),
            _tableCell('Unit Price', isHeader: true),
            _tableCell('Total', isHeader: true),
          ],
        ),
        // Items
        ...invoice.items.map(
          (item) => pw.TableRow(
            children: [
              _tableCell(item.description),
              _tableCell('${item.quantity} ${item.unit}'),
              _tableCell('₹${item.unitPrice.toStringAsFixed(2)}'),
              _tableCell('₹${item.totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  pw.Widget _buildTotalSection(Invoice invoice) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.teal50,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Total Amount:',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              '₹${invoice.totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildNotesSection(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Notes:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(invoice.notes!),
        ],
      ),
    );
  }

  /// Gets all invoices for admin review (pending, approved, rejected)
  Future<List<Invoice>> getAdminInvoices({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      }
      if (endDate != null) {
        queryParams['endDate'] =
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
      }

      final response = await _dio.get(
        '/admin/invoices',
        queryParameters: queryParams,
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to fetch invoices',
          code: 'FETCH_FAILED',
        );
      }

      final List invoices = response.data['data'] ?? [];
      return invoices.map((i) => Invoice.fromJson(i)).toList();
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'FETCH_FAILED',
      );
    }
  }

  /// Approves an invoice
  Future<Invoice> approveInvoice(String invoiceId) async {
    try {
      final response = await _dio.post(
        '/admin/invoices/$invoiceId/approve',
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to approve invoice',
          code: 'APPROVAL_FAILED',
        );
      }

      return Invoice.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'APPROVAL_FAILED',
      );
    }
  }

  /// Rejects an invoice with an optional reason
  Future<Invoice> rejectInvoice(String invoiceId, String reason) async {
    try {
      final response = await _dio.post(
        '/admin/invoices/$invoiceId/reject',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw InvoiceException(
          message: response.data['message'] ?? 'Failed to reject invoice',
          code: 'REJECTION_FAILED',
        );
      }

      return Invoice.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw InvoiceException(
        message: _extractErrorMessage(e),
        code: 'REJECTION_FAILED',
      );
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Network error occurred';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      default:
        return 'Network error occurred';
    }
  }
}

/// Exception for invoice operations
class InvoiceException implements Exception {
  final String message;
  final String code;

  const InvoiceException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'InvoiceException: $message ($code)';
}

