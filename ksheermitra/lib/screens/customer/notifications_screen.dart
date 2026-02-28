import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/dairy_theme.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/premium_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'mark_all_read':
                      provider.markAllAsRead();
                      break;
                    case 'clear_all':
                      _showClearAllDialog(context, provider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, size: 20),
                        SizedBox(width: 12),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Clear all', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(DairySpacing.md),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationCard(context, notification, provider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: DairyColorsLight.textTertiary,
          ),
          const SizedBox(height: DairySpacing.md),
          Text(
            'No Notifications',
            style: DairyTypography.headingSmall(),
          ),
          const SizedBox(height: DairySpacing.sm),
          Text(
            'You\'re all caught up! Check back later.',
            style: DairyTypography.body(color: DairyColorsLight.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    NotificationProvider provider,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: DairySpacing.md),
        decoration: BoxDecoration(
          color: DairyColorsLight.error,
          borderRadius: DairyRadius.defaultBorderRadius,
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // In a real app, you'd restore the notification here
                provider.refresh();
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: DairySpacing.sm),
        color: notification.isRead
            ? DairyColorsLight.surface
            : DairyColorsLight.primarySurface,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
            _showNotificationDetails(context, notification);
          },
          borderRadius: DairyRadius.defaultBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(DairySpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                    borderRadius: DairyRadius.defaultBorderRadius,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: DairySpacing.sm + 4),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: DairyTypography.bodyLarge().copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: DairyColorsLight.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: DairyTypography.bodySmall(
                          color: DairyColorsLight.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DairySpacing.sm),
                      Text(
                        notification.timeAgo,
                        style: DairyTypography.caption(
                          color: DairyColorsLight.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'delivery':
        return Icons.local_shipping;
      case 'subscription':
        return Icons.subscriptions;
      case 'payment':
        return Icons.payment;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'delivery':
        return DairyColorsLight.primary;
      case 'subscription':
        return DairyColorsLight.info;
      case 'payment':
        return DairyColorsLight.success;
      case 'promotion':
        return DairyColorsLight.secondary;
      case 'system':
        return DairyColorsLight.textSecondary;
      default:
        return DairyColorsLight.primary;
    }
  }

  void _showNotificationDetails(BuildContext context, AppNotification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DairyRadius.xl)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(DairySpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DairyColorsLight.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DairySpacing.lg),

              // Icon and Type
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                      borderRadius: DairyRadius.defaultBorderRadius,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: DairySpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: DairyTypography.headingSmall(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.timeAgo,
                          style: DairyTypography.caption(
                            color: DairyColorsLight.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DairySpacing.lg),

              // Message
              Text(
                notification.message,
                style: DairyTypography.body(),
              ),

              const SizedBox(height: DairySpacing.xl),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DairyColorsLight.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

