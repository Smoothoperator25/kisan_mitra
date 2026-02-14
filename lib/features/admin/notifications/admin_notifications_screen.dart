import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_notification_controller.dart';
import 'admin_notification_model.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  final AdminNotificationController _controller = AdminNotificationController();
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1F4),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF10B981),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'markAllRead',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20, color: Color(0xFF10B981)),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'deleteAll',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete all'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'createTest',
                child: Row(
                  children: [
                    Icon(Icons.add_alert, size: 20, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Create test notification'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(showUnreadOnly: false),
                _buildNotificationsList(showUnreadOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', Icons.all_inclusive),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Store Verification',
              'storeVerification',
              Icons.store,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Farmers',
              'farmerRegistration',
              Icons.agriculture,
            ),
            const SizedBox(width: 8),
            _buildFilterChip('System Alerts', 'systemAlert', Icons.warning),
            const SizedBox(width: 8),
            _buildFilterChip('Activity', 'activityUpdate', Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF10B981),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF10B981),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildNotificationsList({required bool showUnreadOnly}) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: StreamBuilder<List<AdminNotification>>(
        stream: _getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(showUnreadOnly);
          }

          var notifications = snapshot.data!;
          if (showUnreadOnly) {
            notifications = notifications.where((n) => !n.isRead).toList();
          }

          if (notifications.isEmpty) {
            return _buildEmptyState(showUnreadOnly);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Stream<List<AdminNotification>> _getFilteredStream() {
    if (_selectedFilter == 'all') {
      return _controller.getNotificationsStream();
    } else {
      final type = NotificationType.values.firstWhere(
        (t) => t.name == _selectedFilter,
        orElse: () => NotificationType.general,
      );
      return _controller.getNotificationsByType(type);
    }
  }

  Widget _buildNotificationCard(AdminNotification notification) {
    final notificationConfig = _getNotificationConfig(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _controller.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? Colors.grey[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead
                ? Colors.grey[200]!
                : const Color.fromRGBO(16, 185, 129, 0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: notificationConfig['color'].withOpacity(0.1),
                  foregroundColor: notificationConfig['color'],
                  radius: 24,
                  child: Icon(notificationConfig['icon'], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notificationConfig['color'].withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notificationConfig['label'],
                              style: TextStyle(
                                fontSize: 11,
                                color: notificationConfig['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Map<String, dynamic> _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.storeVerification:
        return {
          'icon': Icons.store_outlined,
          'color': const Color(0xFF3B82F6),
          'label': 'Store',
        };
      case NotificationType.farmerRegistration:
        return {
          'icon': Icons.agriculture_outlined,
          'color': const Color(0xFF10B981),
          'label': 'Farmer',
        };
      case NotificationType.systemAlert:
        return {
          'icon': Icons.warning_amber_outlined,
          'color': const Color(0xFFF59E0B),
          'label': 'Alert',
        };
      case NotificationType.activityUpdate:
        return {
          'icon': Icons.trending_up,
          'color': const Color(0xFF8B5CF6),
          'label': 'Activity',
        };
      default:
        return {
          'icon': Icons.notifications_outlined,
          'color': Colors.grey[600],
          'label': 'General',
        };
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  Widget _buildEmptyState(bool showUnreadOnly) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showUnreadOnly
                ? Icons.mark_email_read
                : Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            showUnreadOnly ? 'No unread notifications' : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showUnreadOnly
                ? 'You\'re all caught up!'
                : 'We\'ll notify you when something happens',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(AdminNotification notification) async {
    // Mark as read
    if (!notification.isRead) {
      await _controller.markAsRead(notification.id);
    }

    // Navigate if action URL exists
    if (notification.actionUrl != null && mounted) {
      Navigator.pushNamed(
        context,
        notification.actionUrl!,
        arguments: notification.metadata,
      );
    }
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'markAllRead':
        try {
          await _controller.markAllAsRead();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
        break;

      case 'deleteAll':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete All Notifications'),
            content: const Text(
              'Are you sure you want to delete all notifications? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete All'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          try {
            await _controller.deleteAllNotifications();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        }
        break;

      case 'createTest':
        try {
          await _controller.createTestNotification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Test notification created'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
        break;
    }
  }
}
