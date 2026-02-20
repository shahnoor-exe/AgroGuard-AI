import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Notification model
class AppNotification {

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.onTap,
    this.isRead = false,
  });
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final VoidCallback? onTap;
  bool isRead;
}

/// Notification types
enum NotificationType {
  info,
  success,
  warning,
  error,
  critical,
}

/// Notification service for managing app notifications
class NotificationService extends ChangeNotifier {
  final Logger _logger = Logger();
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Show notification
  void showNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    VoidCallback? onTap,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      onTap: onTap,
    );

    _notifications.insert(0, notification);
    _logger.i('Notification: $title - $message');

    // Auto-dismiss info notifications after 5 seconds
    if (type == NotificationType.info) {
      Future.delayed(const Duration(seconds: 5), () {
        dismissNotification(notification.id);
      });
    }

    notifyListeners();
  }

  /// Mark as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  /// Dismiss notification
  void dismissNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Clear all
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Show critical alert for disease detection
  void showDiseaseAlert(String disease, double confidence, String crop) {
    showNotification(
      title: 'Critical Disease Detected!',
      message: '$disease detected in $crop (${(confidence * 100).toStringAsFixed(1)}%)',
      type: NotificationType.critical,
    );
  }

  /// Show success notification
  void showSuccess(String title, [String? message]) {
    showNotification(
      title: title,
      message: message ?? 'Operation completed successfully',
      type: NotificationType.success,
    );
  }

  /// Show error notification
  void showError(String title, [String? message]) {
    showNotification(
      title: title,
      message: message ?? 'An error occurred',
      type: NotificationType.error,
    );
  }
}

/// Notification UI Widget
class NotificationBanner extends StatelessWidget {

  const NotificationBanner({
    required this.notification, required this.onDismiss, Key? key,
  }) : super(key: key);
  final AppNotification notification;
  final VoidCallback onDismiss;

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.critical:
        return Colors.red.shade700;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.critical:
        return Icons.priority_high;
      case NotificationType.info:
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: color),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
