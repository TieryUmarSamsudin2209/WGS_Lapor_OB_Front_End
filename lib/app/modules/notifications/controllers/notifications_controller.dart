import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/services/auth_service.dart';
import '../../../shared/services/notification_socket.dart';

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
    this.reportId,
    this.laporanId,
    this.data,
  });

  final String? id;
  final String type;
  final String title;
  final String message;
  final String section;
  final String timeLabel;
  final DateTime createdAt;
  final bool isUnread;
  final String? reportId;
  final String? laporanId;
  final Map<String, dynamic>? data;
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
    final item = _asMap(message) ?? {};
    if (item.isEmpty) return;
    final id = item['id']?.toString() ?? '';
    final type = item['tipe']?.toString() ?? item['type']?.toString() ?? 'system';
    final title = item['judul']?.toString() ?? item['title']?.toString() ?? 'Notifikasi';
    final body = item['pesan']?.toString() ?? item['message']?.toString() ?? '';
    final readAt = item['read_at'];
    final createdAt = _parseDate(item['created_at']?.toString());
    final isUnread = readAt == null || readAt.toString().isEmpty || readAt.toString() == 'null';
    final reportId = item['laporan_id']?.toString() ?? item['report_id']?.toString();
    final laporanId = item['laporan_id']?.toString();

    notifications.insert(0, NotificationItem(
      id: id.isNotEmpty ? id : null,
      type: type,
      title: title,
      message: body,
      section: 'TERBARU',
      timeLabel: _formatTimeAgo(createdAt),
      createdAt: createdAt,
      isUnread: isUnread,
      reportId: reportId,
      laporanId: laporanId,
      data: item,
    ));
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;

    try {
      final response = await _authService.getNotifications();

      if (response == null) {
        notifications.value = [];
        return;
      }

      final items = _parseNotificationsFromApi(response);

      if (items.isEmpty) {
        notifications.value = [];
        return;
      }

      notifications.value = items;
    } catch (_) {
      notifications.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  List<NotificationItem> _parseNotificationsFromApi(Map<String, dynamic> response) {
    final data = _asMap(response['data']);
    final List<dynamic> allNotifications = [];

    if (data != null) {
      final hariIni = data['hari_ini'];
      if (hariIni is List) {
        allNotifications.addAll(hariIni);
      }
      final kemarin = data['kemarin'];
      if (kemarin is List) {
        allNotifications.addAll(kemarin);
      }
      final sebelumnya = data['sebelumnya'];
      if (sebelumnya is List) {
        allNotifications.addAll(sebelumnya);
      }
    }

    final notifList = data?['mari_list'] as List? ??
                     response['mari_list'] as List? ??
                     data?['notifications'] as List? ??
                     response['notifications'] as List?;

    if (notifList != null) {
      allNotifications.addAll(notifList);
    }

    return allNotifications.whereType<Map>().map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      final id = item['id']?.toString() ?? '';
      final type = _mapNotificationType(item['tipe']?.toString() ?? item['type']?.toString() ?? '');
      final title = item['judul']?.toString() ?? item['title']?.toString() ?? 'Notifikasi';
      final message = item['pesan']?.toString() ?? item['message']?.toString() ?? '';
      final readAt = item['read_at'];
      final createdAt = _parseDate(item['created_at']?.toString());
      final isUnread = readAt == null || readAt.toString().isEmpty || readAt.toString() == 'null';
      final reportId = item['laporan_id']?.toString() ?? item['report_id']?.toString();
      final laporanId = item['laporan_id']?.toString();

      return NotificationItem(
        id: id.isNotEmpty ? id : null,
        type: type,
        title: title,
        message: message,
        section: _sectionFromDate(createdAt),
        timeLabel: _formatTimeAgo(createdAt),
        createdAt: createdAt,
        isUnread: isUnread,
        reportId: reportId,
        laporanId: laporanId,
        data: item,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
      case 'DITOLAK':
      case 'REJECTED':
      case 'LAPORAN_DITOLAK':
      case 'LAPORAN_DIBATALKAN':
        return 'rejected';
      case 'STATUS_UPDATE':
      case 'INFO':
      case 'SYSTEM':
      case 'PEMBARUAN_STATUS':
        return 'status_update';
      default:
        return 'info';
    }
  }

  String _sectionFromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'TERBARU';
    if (day == today.subtract(const Duration(days: 1))) return 'KEMARIN';
    return 'SEBELUMNYA';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari yang lalu';
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  Future<void> markAsRead(NotificationItem item) async {
    final index = notifications.indexWhere((n) => n == item);
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

    if (item.id != null && item.id!.isNotEmpty) {
      await _authService.markNotificationRead(item.id!);
    }
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

    try {
      await _authService.markAllNotificationsRead();
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
    } catch (_) {}
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
}
