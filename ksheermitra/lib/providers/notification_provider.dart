import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

/// Provider for managing notifications state
class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  /// Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/notifications');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        _notifications = data
            .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
            .toList();
        _updateUnreadCount();
      } else {
        // If API not available, show demo notifications
        _notifications = _getDemoNotifications();
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      // Fallback to demo notifications for offline/error scenarios
      _notifications = _getDemoNotifications();
      _updateUnreadCount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update local state immediately for better UX
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
        notifyListeners();
      }

      // Try to sync with server
      await _apiService.put('/notifications/$notificationId/read', {});
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      // Local state already updated, so user sees the change
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Update local state immediately
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _updateUnreadCount();
      notifyListeners();

      // Try to sync with server
      await _apiService.put('/notifications/read-all', {});
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Update local state immediately
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();

      // Try to sync with server
      await _apiService.delete('/notifications/$notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      _notifications.clear();
      _updateUnreadCount();
      notifyListeners();

      await _apiService.delete('/notifications/clear-all');
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  /// Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  /// Get demo notifications for testing/offline mode
  List<AppNotification> _getDemoNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'Delivery Completed',
        message: 'Your milk delivery has been completed successfully. Thank you for using Ksheermitra!',
        type: 'delivery',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: '2',
        title: 'Subscription Renewed',
        message: 'Your monthly subscription has been automatically renewed. Next delivery scheduled for tomorrow.',
        type: 'subscription',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: '3',
        title: 'Payment Received',
        message: 'We have received your payment of ₹500. Thank you!',
        type: 'payment',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AppNotification(
        id: '4',
        title: 'Special Offer!',
        message: 'Get 10% off on your next subscription renewal. Use code FRESH10.',
        type: 'promotion',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AppNotification(
        id: '5',
        title: 'App Update Available',
        message: 'A new version of Ksheermitra is available. Update now for new features!',
        type: 'system',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// Refresh notifications
  Future<void> refresh() => loadNotifications();
}

