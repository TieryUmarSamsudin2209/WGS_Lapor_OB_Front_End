import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/services/auth_service.dart';

class NotificationItem {
  const NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.section,
    required this.timeLabel,
    required this.createdAt,
    this.isUnread = true,
  });

  final String type;
  final String title;
  final String message;
  final String section;
  final String timeLabel;
  final DateTime createdAt;
  final bool isUnread;
}

class NotificationsController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final activeFilter = 'Semua'.obs;

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      // For both online and offline, we display the dummy notifications from the user's photo
      _showDummyNotifications();
    } catch (_) {
      _showDummyNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark single notification as read
  void markAsRead(NotificationItem item) {
    final index = notifications.indexWhere((n) => n == item);
    if (index != -1 && notifications[index].isUnread) {
      notifications[index] = NotificationItem(
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        isUnread: false,
      );
      notifications.refresh();
      
      // TODO: Call API to mark as read
      // await _authService.markNotificationAsRead(item.id);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    
    // Update all notifications to read
    notifications.value = notifications.map((item) {
      return NotificationItem(
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        isUnread: false,
      );
    }).toList();
    
    Get.snackbar(
      'success'.tr,
      'all_notifications_marked_read'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2BC36A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
    
    // TODO: Call API to mark all as read
    // await _authService.markAllNotificationsAsRead();
  }

  void _showDummyNotifications() {
    final now = DateTime.now();
    notifications.value = [
      NotificationItem(
        type: 'resolved',
        title: 'Laporan Selesai',
        message: 'Masalah "Tumpahan air di Lobby" telah diselesaikan oleh Janha (OB).',
        section: 'TERBARU',
        timeLabel: '2 mnt yang lalu',
        createdAt: now.subtract(const Duration(minutes: 2)),
        isUnread: true,
      ),
      NotificationItem(
        type: 'received',
        title: 'Laporan Diterima',
        message: 'Laporan Anda mengenai "AC Bocor di Ruang Meeting 4" telah diterima dan sedang diproses oleh tim teknisi.',
        section: 'TERBARU',
        timeLabel: '1 jam yang lalu',
        createdAt: now.subtract(const Duration(hours: 1)),
        isUnread: true,
      ),
      NotificationItem(
        type: 'status_update',
        title: 'Pembaruan Status',
        message: 'Status fasilitas Lift B2 telah diperbarui menjadi Beroperasi Normal setelah pemeliharaan rutin.',
        section: 'SEBELUMNYA',
        timeLabel: 'Kemarin',
        createdAt: now.subtract(const Duration(days: 1)),
        isUnread: false,
      ),
      NotificationItem(
        type: 'resolved',
        title: 'Laporan Selesai',
        message: 'Laporan "Kertas Habis di Printer Lt. 3" telah ditangani oleh Staff Layanan.',
        section: 'SEBELUMNYA',
        timeLabel: '2 hari yang lalu',
        createdAt: now.subtract(const Duration(days: 2)),
        isUnread: false,
      ),
    ];
  }

  List<NotificationItem> get filteredNotifications {
    final filter = activeFilter.value;
    if (filter == 'Laporan') {
      return notifications.where((item) => item.type == 'report' || item.type == 'resolved' || item.type == 'received').toList();
    } else if (filter == 'Info') {
      return notifications.where((item) => item.type == 'system' || item.type == 'status_update' || item.type == 'info').toList();
    }
    return notifications;
  }

  Map<String, List<NotificationItem>> get groupedNotifications {
    final grouped = <String, List<NotificationItem>>{};
    for (final item in filteredNotifications) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }
    return grouped;
  }
}
