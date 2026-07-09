import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';

class ObNotificationItem {
  const ObNotificationItem({
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

class ObNotificationsController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final notifications = <ObNotificationItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;

    try {
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
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
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
      final title =
          _firstValueFromSources([item, detail], [
            'title',
            'judul',
            'nama',
            'nama_checklist',
            'nama_tugas',
            'kegiatan',
          ]) ??
          'Tugas Harian';

      return ObNotificationItem(
        type: 'task',
        title: 'Tugas Baru: $title',
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
      final title =
          _firstValueFromSources([item, detail], [
            'title',
            'judul',
            'nama_laporan',
            'kategori',
            'category',
            'nama_kategori',
          ]) ??
          'Laporan Baru';
      final reporter =
          _firstValueFromSources([item, detail], [
            'pelapor',
            'nama_pelapor',
            'karyawan',
            'reported_by',
          ]) ??
          'Karyawan';

      return ObNotificationItem(
        type: 'report',
        title: 'Laporan Baru: $title',
        message: '$reporter melaporkan masalah baru.',
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
