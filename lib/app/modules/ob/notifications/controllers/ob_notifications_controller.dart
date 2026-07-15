import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';
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
  final Map<String, dynamic>? data; // Store raw notification data
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
      debugPrint('📬 [NOTIF] Loading notifications for OB...');
      
      // Call real notification API
      final response = await _authService.getNotifications();
      
      if (response == null) {
        debugPrint('⚠️ [NOTIF] No response from API, using dummy data');
        _showDummyNotifications();
        return;
      }
      
      debugPrint('✅ [NOTIF] Got notifications response');
      
      // Parse notifications from API response
      final items = _parseNotificationsFromApi(response);
      
      if (items.isEmpty) {
        debugPrint('ℹ️ [NOTIF] No notifications found');
      } else {
        debugPrint('📋 [NOTIF] Parsed ${items.length} notifications');
      }
      
      notifications.value = items;
    } catch (e) {
      debugPrint('❌ [NOTIF] Error loading notifications: $e');
      _showDummyNotifications();
    } finally {
      isLoading.value = false;
    }
  }

  List<ObNotificationItem> _parseNotificationsFromApi(Map<String, dynamic> response) {
    // Extract notifications list from response
    // Based on API doc: { success: true, data: { mari_list: [...] } }
    final data = _asMap(response['data']);
    
    debugPrint('📋 [NOTIF] Response structure: ${response.keys.toList()}');
    if (data != null) {
      debugPrint('📋 [NOTIF] Data keys: ${data.keys.toList()}');
    }
    
    // Collect all notifications from different time sections
    final List<dynamic> allNotifications = [];
    
    if (data != null) {
      // Extract from hari_ini
      final hariIni = data['hari_ini'];
      if (hariIni is List) {
        debugPrint('📋 [NOTIF] Found ${hariIni.length} notifications in hari_ini');
        allNotifications.addAll(hariIni);
      }
      
      // Extract from kemarin
      final kemarin = data['kemarin'];
      if (kemarin is List) {
        debugPrint('📋 [NOTIF] Found ${kemarin.length} notifications in kemarin');
        allNotifications.addAll(kemarin);
      }
      
      // Extract from sebelumnya if exists
      final sebelumnya = data['sebelumnya'];
      if (sebelumnya is List) {
        debugPrint('📋 [NOTIF] Found ${sebelumnya.length} notifications in sebelumnya');
        allNotifications.addAll(sebelumnya);
      }
    }
    
    debugPrint('📋 [NOTIF] Found ${allNotifications.length} raw notifications');
    
    return allNotifications.whereType<Map>().map((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      
      // Extract fields from notification API response
      final id = item['id']?.toString() ?? '';
      final type = item['tipe']?.toString() ?? item['type']?.toString() ?? 'system';
      final title = item['judul']?.toString() ?? item['title']?.toString() ?? 'Notifikasi';
      final message = item['pesan']?.toString() ?? item['message']?.toString() ?? 'Ada notifikasi baru';
      final senderName = item['nama_lengkap']?.toString() ?? 'System';
      final readAt = item['read_at'];
      final createdAt = _dateFromApi(item['created_at']?.toString());
      
      // Debug: Print all keys in notification item
      debugPrint('  📋 [NOTIF] Notification keys: ${item.keys.toList()}');
      
      // Extract report/laporan ID - try multiple possible keys
      final reportId = item['laporan_id']?.toString() ?? 
                      item['report_id']?.toString() ??
                      item['id_laporan']?.toString() ??
                      item['laporanId']?.toString() ??
                      item['reportId']?.toString();
      final laporanId = item['laporan_id']?.toString();
      
      // Check if unread: read_at is null or empty string
      final isUnread = readAt == null || readAt.toString().isEmpty || readAt.toString() == 'null';
      
      debugPrint('  - ID: $id, Type: $type, Title: $title, Message: $message, Read: ${!isUnread}, ReportID: $reportId');
      
      return ObNotificationItem(
        id: id,
        type: type,
        title: title,
        message: message,
        section: _sectionFromDate(createdAt),
        timeLabel: _timeAgo(createdAt),
        createdAt: createdAt,
        isUnread: isUnread,
        reportId: reportId,
        laporanId: laporanId,
        data: item, // Store raw data
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Mark single notification as read
  Future<void> markAsRead(ObNotificationItem item) async {
    final index = notifications.indexWhere((n) => n == item);
    if (index != -1 && notifications[index].isUnread) {
      // Optimistically update UI
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
      
      // Call API to mark as read
      if (item.id != null && item.id!.isNotEmpty) {
        debugPrint('📬 [NOTIF] Marking notification ${item.id} as read');
        try {
          await _authService.markNotificationRead(item.id!);
          debugPrint('✅ [NOTIF] Notification marked as read');
        } catch (e) {
          debugPrint('❌ [NOTIF] Failed to mark as read: $e');
        }
      }
    }
  }

  /// Handle notification tap - mark as read and navigate
  Future<void> handleNotificationTap(ObNotificationItem item) async {
    // Mark as read first
    await markAsRead(item);
    
    // Navigate based on notification type
    await _navigateBasedOnType(item);
  }

  Future<void> _navigateBasedOnType(ObNotificationItem item) async {
    debugPrint('📱 [NOTIF] Handling navigation for type: ${item.type}');
    
    final type = item.type.toUpperCase();
    
    // Collaboration-related notifications
    if (type.contains('KOLABORASI') || type.contains('COLLABORATION')) {
      debugPrint('📱 [NOTIF] Opening collaboration page');
      await _openCollaborationPage(item);
      return;
    }
    
    // Report-related notifications
    if (type.contains('LAPORAN') || type.contains('REPORT')) {
      debugPrint('📱 [NOTIF] Opening report detail page');
      await _openReportDetailPage(item);
      return;
    }
    
    // Task-related notifications
    if (type.contains('TUGAS') || type.contains('TASK') || type.contains('CHECKLIST')) {
      debugPrint('📱 [NOTIF] Opening tasks/checklist page');
      // Navigate to home/tasks tab
      Get.back(); // Close notification page
      return;
    }
    
    debugPrint('📱 [NOTIF] No specific navigation for type: ${item.type}');
  }

  Future<void> _openCollaborationPage(ObNotificationItem item) async {
    debugPrint('📱 [NOTIF] Opening collaboration - raw data: ${item.data}');
    debugPrint('   Available data keys: ${item.data?.keys.toList()}');
    
    // Since notification doesn't include laporan_id, we need to handle this differently
    // Options:
    // 1. Go back to home and let user see reports with collaboration badge
    // 2. Fetch all reports and find the one with open collaboration
    
    Get.back(); // Close notification page
    
    // Show info to user
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
    
    // Optionally refresh reports to show latest data
    try {
      final homeController = Get.find<ObHomeController>();
      await homeController.loadReports();
      debugPrint('✅ [NOTIF] Reports refreshed after collaboration notification');
    } catch (e) {
      debugPrint('⚠️ [NOTIF] Could not refresh reports: $e');
    }
  }

  Future<void> _openReportDetailPage(ObNotificationItem item) async {
    // Try to extract report ID from notification data
    Get.back(); // Go back to home
    
    // TODO: Extract reportId and navigate to detail page
    // Example: Get.toNamed(Routes.OB_DETAIL, arguments: reportData);
    
    debugPrint('ℹ️ [NOTIF] Report detail navigation - need report ID from notification data');
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    
    debugPrint('📬 [NOTIF] Marking all notifications as read');
    
    // Call API to mark all as read
    try {
      final success = await _authService.markAllNotificationsRead();
      
      if (success) {
        // Update all notifications to read
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
        
        debugPrint('✅ [NOTIF] All notifications marked as read');
        
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
      } else {
        throw Exception('API returned false');
      }
    } catch (e) {
      debugPrint('❌ [NOTIF] Failed to mark all as read: $e');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menandai semua notifikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
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
