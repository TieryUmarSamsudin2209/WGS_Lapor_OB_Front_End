import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/checklist_translation_key.dart';
import '../../../../shared/utils/report_translation_key.dart';

class ObNotificationItem {
  const ObNotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.section,
    required this.timeLabel,
    required this.createdAt,
    this.titleParams = const {},
    this.messageParams = const {},
    this.isUnread = true,
  });

  final String type;
  final String title;
  final String message;
  final String section;
  final String timeLabel;
  final DateTime createdAt;
  final Map<String, String> titleParams;
  final Map<String, String> messageParams;
  final bool isUnread;
}

class ObNotificationsController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final notifications = <ObNotificationItem>[].obs;
  final isLoading = false.obs;

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;

    try {
      if (_authService.isOfflineMode) {
        _showDummyNotifications();
        return;
      }

      final results = await Future.wait([
        _authService.getDailyChecklist(limit: 20),
        _authService.getObReports(limit: 20),
      ]);

      final items = <ObNotificationItem>[
        ..._taskNotifications(results[0]),
        ..._reportNotifications(results[1]),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifications.value = items;
    } catch (_) {
      _showDummyNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark single notification as read
  void markAsRead(ObNotificationItem item) {
    final index = notifications.indexWhere((n) => n == item);
    if (index != -1 && notifications[index].isUnread) {
      notifications[index] = ObNotificationItem(
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        titleParams: item.titleParams,
        messageParams: item.messageParams,
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
      return ObNotificationItem(
        type: item.type,
        title: item.title,
        message: item.message,
        section: item.section,
        timeLabel: item.timeLabel,
        createdAt: item.createdAt,
        titleParams: item.titleParams,
        messageParams: item.messageParams,
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
      ObNotificationItem(
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

  List<ObNotificationItem> _taskNotifications(Map<String, dynamic>? response) {
    final items = _extractItems(response, const [
      'data',
      'checklist',
      'checklists',
      'checklist_harian',
      'daily_checklists',
      'items',
      'tasks',
      'tugas',
      'rows',
      'results',
    ]);

    return items.whereType<Map>().take(8).map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      final detail =
          _asMap(item['checklist']) ??
          _asMap(item['checklist_harian']) ??
          _asMap(item['tugas']) ??
          item;
      final createdAt = _dateFromApi(
        _firstValueFromSources([item, detail], [
          'created_at',
          'assigned_at',
          'tanggal',
          'date',
        ]),
      );
      final title = checklistTranslationKey(
        _firstValueFromSources([item, detail], [
              'title',
              'judul',
              'nama',
              'nama_checklist',
              'nama_tugas',
              'kegiatan',
            ]) ??
            'Tugas Harian',
      );

      return ObNotificationItem(
        type: 'task',
        title: 'Tugas Baru: @title',
        titleParams: {'title': title},
        message: 'Admin baru saja menugaskan Anda.',
        section: _sectionFromDate(createdAt),
        timeLabel: _timeAgo(createdAt),
        createdAt: createdAt,
      );
    }).toList();
  }

  List<ObNotificationItem> _reportNotifications(Map<String, dynamic>? response) {
    final items = _extractItems(response, const [
      'laporan',
      'reports',
      'items',
      'data',
      'rows',
      'results',
    ]);

    return items.whereType<Map>().take(8).map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      final detail = _asMap(item['laporan']) ?? _asMap(item['report']) ?? item;
      final createdAt = _dateFromApi(
        _firstValueFromSources([item, detail], [
          'created_at',
          'tanggal',
          'date',
          'reported_at',
        ]),
      );
      final title = reportTranslationKey(
        _firstValueFromSources([item, detail], [
              'title',
              'judul',
              'nama_laporan',
              'kategori',
              'category',
              'nama_kategori',
            ]) ??
            'Laporan Baru',
      );
      final reporter =
          _firstValueFromSources([item, detail], [
            'pelapor',
            'nama_pelapor',
            'karyawan',
            'reported_by',
          ]) ??
          'Karyawan';
      final location = reportTranslationKey(
        _firstValueFromSources([item, detail], [
              'location',
              'lokasi',
              'ruangan',
              'area',
              'detail_lokasi',
              'alamat',
              'lantai',
            ]) ??
            'lokasi terkait',
      );

      return ObNotificationItem(
        type: 'report',
        title: 'Penugasan Baru',
        message:
            'Ada tugas perbaikan @title di @location. Dilaporkan oleh @reporter.',
        messageParams: {
          'title': title,
          'location': location,
          'reporter': reporter,
        },
        section: _sectionFromDate(createdAt),
        timeLabel: _timeAgo(createdAt),
        createdAt: createdAt,
      );
    }).toList();
  }

  List<dynamic> _extractItems(
    Map<String, dynamic>? response,
    List<String> keys,
  ) {
    final data = _asMap(response?['data']);
    final nestedData = _asMap(data?['data']);

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      for (final key in keys) {
        final value = source[key];
        if (value is List) return value;

        final nested = _asMap(value);
        if (nested == null) continue;
        for (final nestedKey in keys) {
          final nestedValue = nested[nestedKey];
          if (nestedValue is List) return nestedValue;
        }
      }
    }

    return const [];
  }

  DateTime _dateFromApi(String? value) {
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

  String? _firstValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nestedValue = _firstValue(_asMap(value) ?? const {}, [
          'nama',
          'name',
          'title',
          'judul',
          'label',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _firstValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _firstValue(source, keys);
      if (value != null) return value;
    }
    return null;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
