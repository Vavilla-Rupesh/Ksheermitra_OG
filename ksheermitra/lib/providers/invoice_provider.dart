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
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDailyInvoices({
    String? startDate,
    String? endDate,
    String? deliveryBoyId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyInvoices = await _adminApi.getDailyInvoices(
        startDate: startDate,
        endDate: endDate,
        deliveryBoyId: deliveryBoyId,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading daily invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMonthlyInvoices({
    String? startDate,
    String? endDate,
    String? customerId,
    String? paymentStatus,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _monthlyInvoices = await _adminApi.getMonthlyInvoices(
        startDate: startDate,
        endDate: endDate,
        customerId: customerId,
        paymentStatus: paymentStatus,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading monthly invoices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
