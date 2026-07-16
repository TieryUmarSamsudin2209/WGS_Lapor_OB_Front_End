import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/services/notification_socket.dart';
import '../../../../shared/utils/checklist_translation_key.dart';
import '../../../../shared/utils/report_translation_key.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObNotificationItem {
  const ObNotificationItem({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.section,
    required this.timeLabel,
    required this.createdAt,
    this.titleParams = const {},
    this.messageParams = const {},
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
  final Map<String, String> titleParams;
  final Map<String, String> messageParams;
  final bool isUnread;
  final String? reportId;
  final String? laporanId;
  final Map<String, dynamic>? data;
}

class ObNotificationsController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final notifications = <ObNotificationItem>[].obs;
  final isLoading = false.obs;

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
        final tipe = message['tipe']?.toString() ?? '';
        if (tipe.contains('TUGAS') || tipe.contains('LAPORAN') || tipe.contains('TASK') || tipe.contains('REPORT')) {
          loadNotifications();
        }
      });
    } catch (_) {}
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;

    try {
      final response = await _authService.getNotifications();

      if (response == null) {
        _showDummyNotifications();
        return;
      }

      final items = _parseNotificationsFromApi(response);

      if (items.isEmpty) {
        _showDummyNotifications();
        return;
      }

      notifications.value = items;
    } catch (_) {
      if (notifications.isEmpty) {
        _showDummyNotifications();
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<ObNotificationItem> _parseNotificationsFromApi(Map<String, dynamic> response) {
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

    return allNotifications.whereType<Map>().map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      final id = item['id']?.toString() ?? '';
      final type = item['tipe']?.toString() ?? item['type']?.toString() ?? 'system';
      final title = item['judul']?.toString() ?? item['title']?.toString() ?? 'Notifikasi';
      final message = item['pesan']?.toString() ?? item['message']?.toString() ?? '';
      final readAt = item['read_at'];
      final createdAt = _parseDate(item['created_at']?.toString());
      final isUnread = readAt == null || readAt.toString().isEmpty || readAt.toString() == 'null';
      final reportId = item['laporan_id']?.toString() ??
                       item['report_id']?.toString() ??
                       item['id_laporan']?.toString();
      final laporanId = item['laporan_id']?.toString();

      return ObNotificationItem(
        id: id.isNotEmpty ? id : null,
        type: type,
        title: title,
        message: message,
        section: _sectionFromDate(createdAt),
        timeLabel: _timeAgo(createdAt),
        createdAt: createdAt,
        isUnread: isUnread,
        reportId: reportId,
        laporanId: laporanId,
        data: item,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(ObNotificationItem item) async {
    final index = notifications.indexWhere((n) => n == item);
    if (index == -1 || !notifications[index].isUnread) return;

    notifications[index] = ObNotificationItem(
      id: item.id,
      type: item.type,
      title: item.title,
      message: item.message,
      section: item.section,
      timeLabel: item.timeLabel,
      createdAt: item.createdAt,
      titleParams: item.titleParams,
      messageParams: item.messageParams,
      isUnread: false,
      reportId: item.reportId,
      laporanId: item.laporanId,
      data: item.data,
    );
    notifications.refresh();

    if (item.id != null && item.id!.isNotEmpty) {
      await _authService.markNotificationRead(item.id!);
    }
  }

  Future<void> handleNotificationTap(ObNotificationItem item) async {
    await markAsRead(item);
    await _navigateBasedOnType(item);
  }

  Future<void> _navigateBasedOnType(ObNotificationItem item) async {
    final type = item.type.toUpperCase();

    if (type.contains('KOLABORASI') || type.contains('COLLABORATION')) {
      await _openCollaborationPage(item);
      return;
    }

    if (type.contains('LAPORAN') || type.contains('REPORT')) {
      await _openReportDetailPage(item);
      return;
    }

    if (type.contains('TUGAS') || type.contains('TASK') || type.contains('CHECKLIST')) {
      Get.back();
      return;
    }
  }

  Future<void> _openCollaborationPage(ObNotificationItem item) async {
    Get.back();

    Get.snackbar(
      'Kolaborasi Dibuka',
      'Silakan cek daftar laporan untuk melihat laporan dengan kolaborasi aktif',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1689D8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.people, color: Colors.white),
    );

    try {
      final homeController = Get.find<ObHomeController>();
      await homeController.loadReports();
    } catch (_) {}
  }

  Future<void> _openReportDetailPage(ObNotificationItem item) async {
    Get.back();
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    notifications.value = notifications.map((item) {
      return ObNotificationItem(
        id: item.id,
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        titleParams: item.titleParams,
        messageParams: item.messageParams,
        isUnread: false,
        reportId: item.reportId,
        laporanId: item.laporanId,
        data: item.data,
      );
    }).toList();

    try {
      final success = await _authService.markAllNotificationsRead();
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Semua notifikasi telah ditandai sudah dibaca',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2BC36A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (_) {}
  }

  void _showDummyNotifications() {
    final now = DateTime.now();
    notifications.value = [
      ObNotificationItem(
        id: 'ob_dummy_1',
        type: 'task',
        title: 'Tugas Baru: @title',
        titleParams: {
          'title': checklistTranslationKey('Bersihkan Ruang Meeting A'),
        },
        message: 'Admin baru saja menugaskan Anda.',
        section: 'HARI INI',
        timeLabel: '10 mnt',
        createdAt: now.subtract(const Duration(minutes: 10)),
        isUnread: true,
      ),
      ObNotificationItem(
        id: 'ob_dummy_2',
        type: 'report',
        title: 'Laporan Baru: @title',
        titleParams: {'title': reportTranslationKey('AC Bocor di Pantry')},
        message: '@reporter melaporkan masalah baru.',
        messageParams: const {'reporter': 'Karyawan (Asep)'},
        section: 'HARI INI',
        timeLabel: '1 jam',
        createdAt: now.subtract(const Duration(hours: 1)),
        isUnread: true,
      ),
      ObNotificationItem(
        id: 'ob_dummy_3',
        type: 'system',
        title: 'Pembaruan Sistem',
        message: 'Versi aplikasi @version tersedia.',
        messageParams: const {'version': '2.4.1'},
        section: 'HARI INI',
        timeLabel: '3 jam',
        createdAt: now.subtract(const Duration(hours: 3)),
        isUnread: false,
      ),
      ObNotificationItem(
        id: 'ob_dummy_4',
        type: 'task',
        title: 'Pengingat Tugas: @title',
        titleParams: {
          'title': checklistTranslationKey('Cek Toilet Lantai 2'),
        },
        message: 'Tugas ini harus selesai dalam @duration.',
        messageParams: const {'duration': '30 menit'},
        section: 'KEMARIN',
        timeLabel: 'Kemarin',
        createdAt: now.subtract(const Duration(days: 1)),
        isUnread: false,
      ),
    ];
  }

  Map<String, List<ObNotificationItem>> get groupedNotifications {
    final grouped = <String, List<ObNotificationItem>>{};
    for (final item in notifications) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }
    return grouped;
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
  }

  String _sectionFromDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'HARI INI';
    if (day == today.subtract(const Duration(days: 1))) return 'KEMARIN';
    return 'SEBELUMNYA';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt';
    if (diff.inHours < 24) return '${diff.inHours} jam';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari';
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
