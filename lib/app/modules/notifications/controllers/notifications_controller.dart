import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/services/auth_service.dart';

class NotificationItem {
  const NotificationItem({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.section,
    required this.timeLabel,
    required this.createdAt,
    this.isUnread = true,
  });

  final String? id;
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
      debugPrint('📬 [NOTIF-KARYAWAN] Loading notifications...');
      
      // Call real notification API
      final response = await _authService.getNotifications();
      
      if (response == null) {
        debugPrint('⚠️ [NOTIF-KARYAWAN] No response from API, using dummy data');
        _showDummyNotifications();
        return;
      }
      
      debugPrint('✅ [NOTIF-KARYAWAN] Got notifications response');
      
      // Parse notifications from API response
      final items = _parseNotificationsFromApi(response);
      
      if (items.isEmpty) {
        debugPrint('ℹ️ [NOTIF-KARYAWAN] No notifications found');
      } else {
        debugPrint('📋 [NOTIF-KARYAWAN] Parsed ${items.length} notifications');
      }
      
      notifications.value = items;
    } catch (e) {
      debugPrint('❌ [NOTIF-KARYAWAN] Error loading notifications: $e');
      _showDummyNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  List<NotificationItem> _parseNotificationsFromApi(Map<String, dynamic> response) {
    // Extract notifications list from response
    // Based on API doc: { success: true, data: { mari_list: [...] } }
    final data = _asMap(response['data']);
    final notifList = data?['mari_list'] as List? ?? 
                     response['mari_list'] as List? ??
                     data?['notifications'] as List? ??
                     response['notifications'] as List? ??
                     const [];
    
    debugPrint('📋 [NOTIF-KARYAWAN] Found ${notifList.length} raw notifications');
    debugPrint('📋 [NOTIF-KARYAWAN] Response structure: ${response.keys.toList()}');
    if (data != null) {
      debugPrint('📋 [NOTIF-KARYAWAN] Data keys: ${data.keys.toList()}');
    }
    
    return notifList.whereType<Map>().map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      
      // Extract fields from notification API response
      final id = item['id']?.toString() ?? '';
      final type = item['tipe']?.toString() ?? item['type']?.toString() ?? 'system';
      final title = item['judul']?.toString() ?? item['title']?.toString() ?? 'Notifikasi';
      final message = item['pesan']?.toString() ?? item['message']?.toString() ?? 'Ada notifikasi baru';
      final senderName = item['nama_lengkap']?.toString() ?? 'System';
      final readAt = item['read_at'];
      final createdAt = _dateFromApi(item['created_at']?.toString());
      
      // Check if unread: read_at is null or empty string
      final isUnread = readAt == null || readAt.toString().isEmpty || readAt.toString() == 'null';
      
      debugPrint('  - ID: $id, Type: $type, Title: $title, Message: $message, Read: ${!isUnread}, Sender: $senderName');
      
      return NotificationItem(
        id: id,
        type: type,
        title: title,
        message: message,
        section: _sectionFromDate(createdAt),
        timeLabel: _timeAgo(createdAt),
        createdAt: createdAt,
        isUnread: isUnread,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DateTime _dateFromApi(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  String _sectionFromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'TERBARU';
    if (day == today.subtract(const Duration(days: 1))) return 'KEMARIN';
    return 'SEBELUMNYA';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  /// Mark single notification as read
  Future<void> markAsRead(NotificationItem item) async {
    final index = notifications.indexWhere((n) => n == item);
    if (index != -1 && notifications[index].isUnread) {
      // Optimistically update UI
      notifications[index] = NotificationItem(
        id: item.id,
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        isUnread: false,
      );
      notifications.refresh();
      
      // Call API to mark as read
      if (item.id != null && item.id!.isNotEmpty) {
        debugPrint('📬 [NOTIF-KARYAWAN] Marking notification ${item.id} as read');
        try {
          await _authService.markNotificationRead(item.id!);
          debugPrint('✅ [NOTIF-KARYAWAN] Notification marked as read');
        } catch (e) {
          debugPrint('❌ [NOTIF-KARYAWAN] Failed to mark as read: $e');
        }
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    
    debugPrint('📬 [NOTIF-KARYAWAN] Marking all notifications as read');
    
    // Update all notifications to read
    notifications.value = notifications.map((item) {
      return NotificationItem(
        id: item.id,
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        isUnread: false,
      );
    }).toList();
    
    // Call API for each unread notification
    try {
      final unreadIds = notifications
          .where((n) => n.id != null && n.id!.isNotEmpty)
          .map((n) => n.id!)
          .toList();
      
      for (final id in unreadIds) {
        await _authService.markNotificationRead(id);
      }
      
      debugPrint('✅ [NOTIF-KARYAWAN] All notifications marked as read');
      
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
    } catch (e) {
      debugPrint('❌ [NOTIF-KARYAWAN] Failed to mark all as read: $e');
    }
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
