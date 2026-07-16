import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/services/auth_service.dart';
import '../../../shared/services/notification_socket.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.section,
    required this.timeLabel,
    required this.createdAt,
    this.isUnread = true,
  });

  final String id;
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

  NotificationSocketClient? _socketClient;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _initSocket();
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    _socketClient?.dispose();
    super.onClose();
  }

  void _initSocket() {
    if (!_authService.isLoggedIn) return;
    try {
      _socketClient = createNotificationSocketClient();
      final uri = _authService.notificationWebSocketUri();
      _socketClient!.connect(uri);
      _socketSubscription = _socketClient!.messages.listen((message) {
        _handleSocketMessage(message);
      });
    } catch (_) {}
  }

  void _handleSocketMessage(Map<String, dynamic> message) {
    final notification = _notificationFromApi(message, 'TERBARU');
    if (notification != null) {
      notifications.insert(0, notification);
    }
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await _authService.getNotifications();
      if (response != null) {
        _parseApiResponse(response);
        return;
      }
      _showDummyNotifications();
    } catch (_) {
      _showDummyNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  void _parseApiResponse(Map<String, dynamic> response) {
    final data = _asMap(response['data']);
    if (data == null) {
      _showDummyNotifications();
      return;
    }

    final items = <NotificationItem>[];

    final hariIni = _asList(data['hari_ini']);
    if (hariIni != null) {
      for (final raw in hariIni) {
        final item = _notificationFromApi(raw, 'TERBARU');
        if (item != null) items.add(item);
      }
    }

    final kemarin = _asList(data['kemarin']);
    if (kemarin != null) {
      for (final raw in kemarin) {
        final item = _notificationFromApi(raw, 'SEBELUMNYA');
        if (item != null) items.add(item);
      }
    }

    if (items.isEmpty) {
      _showDummyNotifications();
      return;
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifications.value = items;
  }

  NotificationItem? _notificationFromApi(dynamic raw, String section) {
    final map = _asMap(raw);
    if (map == null) return null;

    final id = map['id']?.toString() ?? '';
    if (id.isEmpty) return null;

    return NotificationItem(
      id: id,
      type: _mapNotificationType(map['tipe']?.toString() ?? ''),
      title: map['judul']?.toString() ?? '',
      message: map['pesan']?.toString() ?? '',
      section: section,
      timeLabel: _formatTimeAgo(
        _parseDate(map['created_at']?.toString()),
      ),
      createdAt: _parseDate(map['created_at']?.toString()),
      isUnread: !_isTruthy(map['is_read']),
    );
  }

  String _mapNotificationType(String tipe) {
    switch (tipe.toUpperCase()) {
      case 'LAPORAN_BARU':
      case 'LAPORAN':
      case 'REPORT':
        return 'report';
      case 'SELESAI':
      case 'RESOLVED':
      case 'LAPORAN_SELESAI':
        return 'resolved';
      case 'DITERIMA':
      case 'RECEIVED':
      case 'LAPORAN_DITERIMA':
        return 'received';
      case 'STATUS_UPDATE':
      case 'INFO':
      case 'SYSTEM':
      case 'PEMBARUAN_STATUS':
        return 'status_update';
      default:
        return 'info';
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase().trim();
    return text == 'true' || text == '1' || text == 'yes';
  }

  Future<void> markAsRead(NotificationItem item) async {
    final index = notifications.indexWhere((n) => n.id == item.id);
    if (index == -1 || !notifications[index].isUnread) return;

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

    await _authService.markNotificationRead(item.id);
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

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

    final success = await _authService.markAllNotificationsRead();
    if (success) {
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
    }
  }

  void _showDummyNotifications() {
    final now = DateTime.now();
    notifications.value = [
      NotificationItem(
        id: 'dummy_1',
        type: 'resolved',
        title: 'Laporan Selesai',
        message: 'Masalah "Tumpahan air di Lobby" telah diselesaikan oleh Janha (OB).',
        section: 'TERBARU',
        timeLabel: '2 mnt yang lalu',
        createdAt: now.subtract(const Duration(minutes: 2)),
        isUnread: true,
      ),
      NotificationItem(
        id: 'dummy_2',
        type: 'received',
        title: 'Laporan Diterima',
        message: 'Laporan Anda mengenai "AC Bocor di Ruang Meeting 4" telah diterima dan sedang diproses oleh tim teknisi.',
        section: 'TERBARU',
        timeLabel: '1 jam yang lalu',
        createdAt: now.subtract(const Duration(hours: 1)),
        isUnread: true,
      ),
      NotificationItem(
        id: 'dummy_3',
        type: 'status_update',
        title: 'Pembaruan Status',
        message: 'Status fasilitas Lift B2 telah diperbarui menjadi Beroperasi Normal setelah pemeliharaan rutin.',
        section: 'SEBELUMNYA',
        timeLabel: 'Kemarin',
        createdAt: now.subtract(const Duration(days: 1)),
        isUnread: false,
      ),
      NotificationItem(
        id: 'dummy_4',
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

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<dynamic>? _asList(dynamic value) {
    if (value is List) return value;
    return null;
  }
}
