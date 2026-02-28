import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../services/admin_api_service.dart';

class InvoiceProvider with ChangeNotifier {
  final AdminApiService _adminApi = AdminApiService();

  List<Invoice> _dailyInvoices = [];
  List<Invoice> _monthlyInvoices = [];
  bool _isLoading = false;
  String? _error;

  List<Invoice> get dailyInvoices => _dailyInvoices;
  List<Invoice> get monthlyInvoices => _monthlyInvoices;
  List<Invoice> get invoices => [..._dailyInvoices, ..._monthlyInvoices];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInvoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load both daily and monthly invoices
      await Future.wait([
        loadDailyInvoices(),
        loadMonthlyInvoices(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDailyInvoices({
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
  }) async {
    try {
      _dailyInvoices = await _adminApi.getDailyInvoices(
        startDate: startDate,
        endDate: endDate,
        deliveryBoyId: deliveryBoyId,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading daily invoices: $e');
    }
  }

  Future<void> loadMonthlyInvoices({
    String? startDate,
    String? endDate,
    String? customerId,
    String? paymentStatus,
  }) async {
    try {
      _monthlyInvoices = await _adminApi.getMonthlyInvoices(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
        paymentStatus: paymentStatus,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading monthly invoices: $e');
    }
  }

  Future<bool> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final updatedInvoice = await _adminApi.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        notes: notes,
      );
      
      // Update in monthly invoices list
      final index = _monthlyInvoices.indexWhere((inv) => inv.id == invoiceId);
      if (index != -1) {
        _monthlyInvoices[index] = updatedInvoice;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error recording payment: $e');
      return false;
    }
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _monthlyInvoices.firstWhere((inv) => inv.id == id);
    } catch (e) {
      try {
        return _dailyInvoices.firstWhere((inv) => inv.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  List<Invoice> get pendingMonthlyInvoices =>
      _monthlyInvoices.where((inv) => inv.isPending).toList();

  List<Invoice> get paidMonthlyInvoices =>
      _monthlyInvoices.where((inv) => inv.isPaid).toList();

  List<Invoice> get overdueMonthlyInvoices =>
      _monthlyInvoices.where((inv) => inv.isOverdue).toList();

  double get totalPendingAmount =>
      pendingMonthlyInvoices.fold(0.0, (sum, inv) => sum + inv.remainingAmount);

  double get totalCollectedAmount =>
      paidMonthlyInvoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);

  /// Generate a monthly invoice for a customer
  Future<Invoice?> generateCustomerInvoice({
    required String customerId,
    required int year,
    required int month,
  }) async {
    try {
      final invoice = await _adminApi.generateMonthlyInvoice(
        customerId: customerId,
        year: year,
        month: month,
      );

      // Add to monthly invoices list
      _monthlyInvoices.insert(0, invoice);
      notifyListeners();

      return invoice;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error generating customer invoice: $e');
      return null;
    }
  }

  /// Generate a daily invoice for a delivery boy
  Future<Invoice?> generateDeliveryBoyInvoice({
    required String deliveryBoyId,
    required String date,
  }) async {
    try {
      final invoice = await _adminApi.generateDailyInvoice(
        deliveryBoyId: deliveryBoyId,
        date: date,
      );

      // Add to daily invoices list
      _dailyInvoices.insert(0, invoice);
      notifyListeners();

      return invoice;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error generating delivery boy invoice: $e');
      return null;
    }
  }
}
