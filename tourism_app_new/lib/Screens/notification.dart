import 'package:flutter/material.dart';
import 'package:tourism_app_new/constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Booking Confirmed',
      subtitle:
          'Your reservation at Seaside Paradise, Maldives has been successfully confirmed. Check in begins at 2:00 PM on your arrival date.',
      date: DateTime.now(),
      icon: Icons.check_circle,
      color: Colors.green,
    ),
    NotificationItem(
      title: 'Upcoming Stay Reminder',
      subtitle:
          'This is a reminder that your stay at Elite Cloud Resort begins tomorrow. Please ensure your travel details are in order.',
      date: DateTime.now().subtract(const Duration(hours: 1)),
      icon: Icons.notifications,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'Rate Your Experience',
      subtitle:
          'We hope you had a pleasant stay at Hilltop Odyssey. Please take a moment to rate your experience.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.star,
      color: Colors.orange,
    ),
    NotificationItem(
      title: 'New Message from Host',
      subtitle:
          'You have a new message from the host regarding your inquiry. Tap here to view the message.',
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.message,
      color: Colors.purple,
    ),
    NotificationItem(
      title: 'Limited Availability Alert',
      subtitle:
          'The property Location Villa is running out of availability for your selected dates. Consider booking soon to avoid disappointment.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.warning,
      color: Colors.red,
    ),
    NotificationItem(
      title: 'Price Drop Notification',
      subtitle:
          'The rate for Seaside Bliss Villa has been reduced for May 5-12. Check the offer from the available booking option.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.trending_down,
      color: Colors.green,
    ),
    NotificationItem(
      title: 'Upcoming Stay Reminder',
      subtitle:
          'This is a reminder that your stay at Elite Cloud Resort begins tomorrow. Please ensure your travel details are in order.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.notifications,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'Rate Your Experience',
      subtitle:
          'We hope you had a pleasant stay at Hilltop Odyssey. Please take a moment to rate your experience.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.star,
      color: Colors.orange,
    ),
  ];

  void _clearAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedNotifications();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty ? null : _clearAllNotifications,
            child: Text(
              'Clear all',
              style: TextStyle(
                color: notifications.isEmpty ? Colors.grey : Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body:
          notifications.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No new notifications to show',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'at this moment',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _buildNotificationWidgets(grouped).length,
                itemBuilder: (context, index) {
                  return _buildNotificationWidgets(grouped)[index];
                },
              ),
    );
  }

  Map<String, List<NotificationItem>> _groupedNotifications() {
    final grouped = <String, List<NotificationItem>>{};
    final now = DateTime.now();

    for (final notification in notifications) {
      final date = notification.date;
      final difference = now.difference(date).inDays;
      String key;

      if (difference == 0) {
        key = 'Today';
      } else if (difference == 1) {
        key = 'Yesterday';
      } else {
        key = '$difference days ago';
      }

      grouped.putIfAbsent(key, () => []).add(notification);
    }

    return grouped;
  }

  List<Widget> _buildNotificationWidgets(
    Map<String, List<NotificationItem>> grouped,
  ) {
    final widgets = <Widget>[];

    final sectionOrder = ['Today', 'Yesterday'];

    for (final section in sectionOrder) {
      if (grouped.containsKey(section)) {
        widgets.add(_buildDateHeader(section));
        widgets.addAll(grouped[section]!.map(_buildNotificationCard));
      }
    }

    for (final entry in grouped.entries) {
      if (!sectionOrder.contains(entry.key)) {
        widgets.add(_buildDateHeader(entry.key));
        widgets.addAll(entry.value.map(_buildNotificationCard));
      }
    }

    return widgets;
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.mainGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 55,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: Icon(notification.icon, color: Colors.black, size: 23),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${notification.title}'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.color,
  });
}
