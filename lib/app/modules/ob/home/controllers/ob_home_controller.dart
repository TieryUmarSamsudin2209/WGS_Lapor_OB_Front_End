import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/checklist_translation_key.dart';
import '../../../../shared/utils/report_translation_key.dart';
import '../../../../shared/widgets/ob_assignment_alert.dart';

class DailyTask {
  final String title;
  final String location;
  final RxString status; // 'resolved' or 'pending'

  DailyTask({
    required this.title,
    required this.location,
    required String status,
  }) : status = status.obs;
}

class HomeReport {
  final String id;
  final String title;
  final String location;
  final String description;
  final String priority; // 'URGENT' or 'STANDARD'
  final RxString status; // 'Belum Diproses', 'Sedang Diproses', 'Selesai', 'Ditolak'
  final RxBool hasCollaboration;
  final List<String> photos;
  final String? reporterName;
  final String? categoryName;
  final Rx<String?> obId; // Made reactive for dynamic updates
  final Rx<String?> obName; // Made reactive for dynamic updates
  final RxList<String> collaborators; // List of collaborator names

  // Convenience getters for backward compatibility
  String? get assignedObId => obId.value;
  String? get assignedObName => obName.value;

  HomeReport({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.priority,
    required String status,
    bool hasCollaboration = false,
    this.photos = const [],
    this.reporterName,
    this.categoryName,
    String? assignedObId,
    String? assignedObName,
    List<String> collaborators = const [],
  }) : status = status.obs,
       hasCollaboration = hasCollaboration.obs,
       obId = Rx<String?>(assignedObId),
       obName = Rx<String?>(assignedObName),
       collaborators = RxList<String>(collaborators);
}

class ObHomeController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final name = 'OB'.obs;
  final isLoadingTasks = false.obs;
  final isLoadingReports = false.obs;
  final unreadNotificationCount = 0.obs;

  // List of Daily Tasks
  final dailyTasks = <DailyTask>[].obs;

  // List of Reports
  final reports = <HomeReport>[].obs;
  final takingReportIds = <String>{}.obs;
  final _knownReportIds = <String>{};

  Timer? _reportPollingTimer;
  Timer? _notificationPollingTimer;
  bool _hasLoadedReportsOnce = false;

  String get assignmentLabel {
    final user = _authService.user.value ?? const <String, dynamic>{};
    final value =
        user['penugasan'] ??
        user['assignment'] ??
        user['lokasi'] ??
        user['location'];
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return 'Penugasan: $text';
    return 'Penugasan: Gedung A - Lantai 1 & 2';
  }

  int get completedTaskCount =>
      dailyTasks.where((task) => task.status.value == 'resolved').length;

  List<HomeReport> get latestReports => reports.toList();

  int get taskProgressPercent {
    if (totalTaskCount == 0) return 0;
    return ((completedTaskCount / totalTaskCount) * 100).round();
  }

  int get totalTaskCount => dailyTasks.length;

  String? get _currentObId {
    final user = _authService.user.value ?? const <String, dynamic>{};
    return _stringValue(user, const [
      'id',
      'user_id',
      'userId',
      'ob_id',
      'obId',
      'uuid',
    ]);
  }

  String? get _currentObName {
    final user = _authService.user.value ?? const <String, dynamic>{};
    return _stringValue(user, const [
      'nama_lengkap',
      'nama',
      'name',
      'username',
      'email',
    ]);
  }

  void createReport() {
    Get.toNamed(Routes.OB_CHECKLIST);
  }

  // Navigation functions
  void goHome() {
    // Already on home
  }

  void goProfile() {
    Get.offAllNamed(Routes.OB_PROFIL);
  }

  bool isTakingReport(HomeReport report) {
    final reportId = _normalizedReportId(report);
    return reportId != null && takingReportIds.contains(reportId);
  }

  Future<void> loadDailyTasks() async {
    isLoadingTasks.value = true;

    try {
      final response = await _authService.getDailyChecklist();
      if (response == null) {
        debugPrint('Daily checklist response is null');
        dailyTasks.clear();
        return;
      }

      final items = _extractItems(
        response,
        keys: const ['checklist', 'checklists', 'items', 'tugas', 'tasks'],
      );

      debugPrint('Extracted ${items.length} raw checklist items');

      final nextTasks = <DailyTask>[];
      var validCount = 0;
      var invalidCount = 0;

      for (final item in items) {
        final map = _asMap(item);
        if (map == null) {
          debugPrint('Skipping non-map checklist item: ${item.runtimeType}');
          invalidCount++;
          continue;
        }

        try {
          final task = _dailyTaskFromApi(map);
          nextTasks.add(task);
          validCount++;
        } catch (e) {
          debugPrint('Failed to parse checklist item: $e');
          invalidCount++;
        }
      }

      debugPrint('Successfully parsed $validCount checklist items, skipped $invalidCount invalid items');
      dailyTasks.value = nextTasks;
    } catch (e, stackTrace) {
      debugPrint('Error loading daily tasks: $e');
      debugPrint('Stack trace: $stackTrace');
      dailyTasks.clear();
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> loadHomeData() async {
    await Future.wait([
      loadDailyTasks(),
      loadReports(),
    ]);
  }

  Future<void> loadReports({
    bool showNewReportAlert = false,
    bool silent = false,
  }) async {
    if (!silent) {
      isLoadingReports.value = true;
    }

    try {
      final response = await _authService.getObReports(limit: 100);
      if (response == null) {
        if (!_authService.isOfflineMode) {
          reports.clear();
        }
        if (!silent) {
          Get.snackbar(
            'Gagal memuat laporan'.tr,
            _authService.lastRequestError ??
                'Laporan masuk belum bisa dimuat dari server.'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }

      final items = _extractItems(
        response,
        keys: const [
          'laporan',
          'reports',
          'items',
          'data',
          'rows',
          'results',
          'laporan_karyawan',
          'laporanKaryawan',
          'employee_reports',
          'employeeReports',
          'laporan_masuk',
          'laporanMasuk',
          'incoming_reports',
          'incomingReports',
          'riwayat_laporan',
          'riwayatLaporan',
          'report_history',
          'reportHistory',
          'history',
          'histori',
        ],
      );

      debugPrint('Extracted ${items.length} raw items from API response');

      final nextReports = <HomeReport>[];
      var validCount = 0;
      var invalidCount = 0;

      for (final item in items) {
        final map = _asMap(item);
        if (map == null) {
          debugPrint('Skipping non-map item: ${item.runtimeType}');
          invalidCount++;
          continue;
        }

        final report = _reportFromApi(map);
        if (report == null) {
          debugPrint('Failed to parse report from: ${map.keys.join(", ")}');
          invalidCount++;
          continue;
        }

        nextReports.add(report);
        validCount++;
      }

      debugPrint('Successfully parsed $validCount reports, skipped $invalidCount invalid items');

      if (nextReports.isEmpty && items.isNotEmpty) {
        if (!silent) {
          Get.snackbar(
            'Format data tidak valid'.tr,
            'Data laporan dari server tidak dapat diproses. Hubungi administrator.'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }

      _showNewReportAlert(nextReports, showNewReportAlert);
      reports.value = nextReports;
    } catch (e, stackTrace) {
      debugPrint('Error loading reports: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!silent) {
        reports.clear();
        Get.snackbar(
          'Kesalahan memuat laporan'.tr,
          'Terjadi kesalahan saat memproses data laporan.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (!silent) {
        isLoadingReports.value = false;
      }
    }
  }

  @override
  void onClose() {
    _reportPollingTimer?.cancel();
    _notificationPollingTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadHomeData();
    _startReportPolling();
    _loadUnreadNotificationCount();
    _startNotificationPolling();
  }

  void openReportDetail(HomeReport report) {
    Get.toNamed(Routes.OB_DETAIL, arguments: report);
  }

  Future<void> takeReport(HomeReport report) async {
    final reportId = _normalizedReportId(report);
    if (reportId == null) {
      Get.snackbar('Gagal'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    if (takingReportIds.contains(reportId)) return;

    takingReportIds.add(reportId);
    try {
      final response = await _authService.takeObReport(reportId);
      if (response == null) {
        Get.snackbar(
          'Gagal mengambil laporan'.tr,
          _authService.lastRequestError ??
              'Laporan belum bisa diambil. Coba muat ulang daftar laporan.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Success - update report status to "Sedang Diproses" (IN_PROGRESS)
      report.obName.value =
          _assignedObNameFromResponse(response) ?? _currentObName ?? 'Anda';
      report.obId.value = _assignedObIdFromResponse(response) ?? _currentObId;
      report.status.value = 'Sedang Diproses'; // Always "Sedang Diproses", never "Belum Diproses"

      Get.snackbar(
        'Laporan diambil'.tr,
        'Laporan sudah masuk daftar pekerjaan Anda.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadReports(silent: true);
      Get.toNamed(Routes.OB_DETAIL, arguments: report);
    } finally {
      takingReportIds.remove(reportId);
    }
  }

  // Toggle status tugas harian sebagai interaksi mikro
  void toggleTaskStatus(DailyTask task) {
    if (task.status.value == 'resolved') {
      task.status.value = 'pending';
    } else {
      task.status.value = 'resolved';
    }
  }

  List<dynamic>? _asList(Object? value) {
    if (value is List) return value;
    return null;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  String? _assignedObIdFromResponse(Map<String, dynamic> response) {
    return _stringValueFromSources([
      response,
      _asMap(response['data']) ?? const <String, dynamic>{},
      _asMap(response['laporan']) ?? const <String, dynamic>{},
      _asMap(response['report']) ?? const <String, dynamic>{},
    ], const [
      'ob_id',
      'id_ob',
      'petugas_id',
      'assigned_ob_id',
      'assignedObId',
      'taken_by_id',
      'takenById',
    ]);
  }

  String? _assignedObNameFromResponse(Map<String, dynamic> response) {
    return _stringValueFromSources([
      response,
      _asMap(response['data']) ?? const <String, dynamic>{},
      _asMap(response['laporan']) ?? const <String, dynamic>{},
      _asMap(response['report']) ?? const <String, dynamic>{},
    ], const [
      'nama_ob',
      'namaOb',
      'ob_name',
      'obName',
      'assigned_ob_name',
      'assignedObName',
      'taken_by_name',
      'takenByName',
      'diambil_oleh',
      'diambilOleh',
      'assigned_to',
      'assignedTo',
      'taken_by',
      'takenBy',
      'petugas',
      'petugas_ob',
      'ob',
    ]);
  }

  bool _boolValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      final text = value?.toString().trim().toLowerCase();
      if (text == null || text.isEmpty) continue;
      if (['true', '1', 'yes', 'ya', 'y'].contains(text)) return true;
      if (['false', '0', 'no', 'tidak', 'n'].contains(text)) return false;
    }
    return false;
  }

  bool _boolValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      if (_boolValue(source, keys)) return true;
    }
    return false;
  }

  DailyTask _dailyTaskFromApi(Map<String, dynamic> item) {
    final detail = _asMap(item['checklist']) ??
        _asMap(item['checklist_harian']) ??
        _asMap(item['tugas']) ??
        item;

    return DailyTask(
      title: checklistTranslationKey(
        _stringValueFromSources([item, detail], [
              'title',
              'judul',
              'nama',
              'nama_checklist',
              'nama_tugas',
              'kegiatan',
              'task',
            ]) ??
            'Checklist',
      ),
      location: checklistTranslationKey(
        _stringValueFromSources([item, detail], [
              'location',
              'lokasi',
              'ruangan',
              'area',
              'description',
              'deskripsi',
              'keterangan',
            ]) ??
            '-',
      ),
      status: _taskStatusFromApi(
        _stringValueFromSources(
              [item, detail],
              ['status', 'status_checklist', 'status_tugas'],
            ) ??
            'pending',
      ),
    );
  }

  List<dynamic> _extractItems(
    Map<String, dynamic>? response, {
    required List<String> keys,
  }) {
    if (response == null) {
      debugPrint('Response is null, returning empty list');
      return const [];
    }

    final data = _asMap(response['data']);
    final nestedData = _asMap(data?['data']);

    debugPrint('Response structure: top-level keys=${response.keys.join(", ")}');
    if (data != null) {
      debugPrint('data keys=${data.keys.join(", ")}');
    }

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      
      for (final key in keys) {
        final value = source[key];
        final list = _asList(value);
        if (list != null) {
          debugPrint('Found list at key "$key" with ${list.length} items');
          return list;
        }

        final nested = _asMap(value);
        if (nested == null) continue;
        
        for (final nestedKey in keys) {
          final nestedList = _asList(nested[nestedKey]);
          if (nestedList != null) {
            debugPrint('Found nested list at "$key.$nestedKey" with ${nestedList.length} items');
            return nestedList;
          }
        }
      }
      
      final directData = _asList(source['data']);
      if (directData != null) {
        debugPrint('Found list at direct "data" key with ${directData.length} items');
        return directData;
      }
    }

    debugPrint('No list found in response, tried keys: ${keys.join(", ")}');
    return const [];
  }

  void _loadUser() {
    final user = _authService.user.value;
    final displayName = user?['username'] ?? user?['name'] ?? user?['email'];
    if (displayName != null && displayName.toString().trim().isNotEmpty) {
      name.value = displayName.toString();
    }
  }

  String? _normalizedReportId(HomeReport report) {
    final rawId = report.id.trim();
    if (rawId.isEmpty) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    final text = normalized.trim();
    return text.isEmpty ? null : text;
  }

  List<String> _photosFromApi(Map<String, dynamic> source) {
    for (final key in [
      'photos',
      'foto',
      'foto_laporan',
      'foto_masalah',
      'bukti_foto',
      'gambar',
      'images',
    ]) {
      final value = source[key];
      final list = _asList(value);
      if (list != null) {
        return list
            .map((item) => AuthService.resolveMediaUrl(item.toString()))
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return [AuthService.resolveMediaUrl(value.toString())];
      }
    }
    return const [];
  }

  List<String> _collaboratorsFromApi(
    Map<String, dynamic> item,
    Map<String, dynamic> detail,
  ) {
    // Extract collaborators list
    for (final source in [item, detail]) {
      for (final key in [
        'kolaborator',
        'kolaborators',
        'collaborators',
        'team',
        'tim',
        'ob_list',
        'obList',
        'ob_kolaborator',
        'obKolaborator',
      ]) {
        final value = source[key];
        final list = _asList(value);
        if (list != null && list.isNotEmpty) {
          // Extract names from collaborator objects
          return list.map((collab) {
            final collabMap = _asMap(collab);
            if (collabMap == null) return collab.toString();
            
            return _stringValue(collabMap, [
              'nama',
              'nama_lengkap',
              'name',
              'username',
              'ob_name',
              'obName',
            ]) ?? 'OB';
          }).where((name) => name.isNotEmpty).toList();
        }
      }
    }
    return const [];
  }

  String _priorityFromApi(String priority) {
    final normalized = priority.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'STANDARD';
    }
    if (normalized.contains('urgent') ||
        normalized.contains('tinggi') ||
        normalized.contains('high')) {
      return 'URGENT';
    }
    return 'STANDARD';
  }

  Map<String, dynamic> _reportDetailFromApi(Map<String, dynamic> item) {
    return _asMap(item['laporan']) ??
        _asMap(item['report']) ??
        _asMap(item['laporan_karyawan']) ??
        _asMap(item['laporanKaryawan']) ??
        _asMap(item['employee_report']) ??
        _asMap(item['employeeReport']) ??
        _asMap(item['employee_reports']) ??
        _asMap(item['employeeReports']) ??
        item;
  }

  HomeReport? _reportFromApi(Map<String, dynamic> item) {
    try {
      final detail = _reportDetailFromApi(item);
      final photos = _photosFromApi(item);

      // Extract required fields
      final id = _stringValue(item, [
            'laporan_id',
            'report_id',
          ]) ??
          _stringValue(detail, [
            'id',
            'laporan_id',
            'report_id',
            'uuid',
          ]) ??
          _stringValue(item, [
            'id',
            'uuid',
          ]);

      final title = _stringValueFromSources([item, detail], [
        'title',
        'judul',
        'nama_laporan',
        'kategori',
        'category',
        'nama_kategori',
      ]);

      final location = _stringValueFromSources([item, detail], [
        'location',
        'lokasi',
        'ruangan',
        'area',
        'detail_lokasi',
        'alamat',
        'lantai',
      ]);

      final description = _stringValueFromSources([item, detail], [
        'description',
        'deskripsi',
        'deskripsi_kendala',
        'catatan',
        'keluhan',
        'keterangan',
      ]);

      // Validate required fields
      if (id == null || id.trim().isEmpty) {
        debugPrint('Report missing required field: id. Available keys: ${item.keys.join(", ")}');
        return null;
      }

      if (title == null || title.trim().isEmpty) {
        debugPrint('Report $id missing required field: title');
        return null;
      }

      // Debug reporter extraction
      final reporterName = _stringValueFromSources([item, detail], [
        'nama_pelapor',
        'pelapor', 
        'reporter',
        'reported_by',
        'reportedBy',
        'created_by',
        'createdBy',
        'submitted_by',
        'submittedBy',
        'karyawan',
        'pegawai',
        'user',
        'karyawan_name',
        'pegawai_name',
        'user_name',
      ]) ?? _extractReporterFromNestedObjects([item, detail]);
      
      debugPrint('📋 [REPORT-$id] Reporter: ${reporterName ?? "NOT FOUND"}');
      debugPrint('📋 [REPORT-$id] Available keys: ${item.keys.join(", ")}');
      if (detail != item) {
        debugPrint('📋 [REPORT-$id] Detail keys: ${detail.keys.join(", ")}');
      }

      return HomeReport(
        id: id,
        title: reportTranslationKey(title),
        location: reportTranslationKey(location ?? '-'),
        description: reportTranslationKey(description ?? '-'),
        priority: _priorityFromApi(
          _stringValueFromSources([item, detail], [
                'priority',
                'prioritas',
                'urgency',
                'urgensi',
              ]) ??
              'STANDARD',
        ),
        status: _reportStatusFromApi(
          _stringValueFromSources([item, detail], ['status', 'status_laporan']) ??
              'pending',
        ),
        hasCollaboration: _boolValueFromSources([item, detail], [
          'is_kolaborasi_open',  // Backend field (priority)
          'kolaborasi',
          'has_collaboration',
          'hasCollaboration',
          'butuh_bantuan',
          'need_help',
        ]),
        reporterName: reporterName,
        categoryName: _translatedValueOrNull(
          _stringValueFromSources([item, detail], [
            'nama_kategori',
            'kategori',
            'category',
            'category_name',
            'categoryName',
          ]),
        ),
        assignedObId: _stringValueFromSources([item, detail], [
          'ob_id',
          'id_ob',
          'petugas_id',
          'assigned_ob_id',
          'assignedObId',
          'taken_by_id',
          'takenById',
        ]),
        assignedObName: _stringValueFromSources([item, detail], [
          'nama_ob',
          'namaOb',
          'ob_name',
          'obName',
          'assigned_ob_name',
          'assignedObName',
          'taken_by_name',
          'takenByName',
          'diambil_oleh',
          'diambilOleh',
          'assigned_to',
          'assignedTo',
          'taken_by',
          'takenBy',
          'petugas',
          'petugas_ob',
          'ob',
        ]),
        photos: photos.isNotEmpty ? photos : _photosFromApi(detail),
        collaborators: _collaboratorsFromApi(item, detail),
      );
    } catch (e, stackTrace) {
      debugPrint('Exception parsing report: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  String _reportStatusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
    
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done') ||
        normalized.contains('completed') ||
        normalized.contains('complete')) {
      return 'Selesai';
    }
    
    if (normalized.contains('tolak') || 
        normalized.contains('reject') ||
        normalized.contains('ditolak') ||
        normalized.contains('declined')) {
      return 'Ditolak';
    }
    
    // IN_PROGRESS, PENDING (after taken), PROSES, etc should all be "Sedang Diproses"
    if (normalized.contains('proses') ||
        normalized.contains('progress') ||
        normalized.contains('in progress') ||
        normalized.contains('diproses') ||
        normalized.contains('ambil') ||
        normalized.contains('taken') ||
        normalized.contains('assigned') ||
        normalized.contains('working') ||
        normalized == 'pending') { // PENDING after taking = in progress
      return 'Sedang Diproses';
    }
    
    // Only truly unassigned reports are "Belum Diproses"
    return 'Belum Diproses';
  }

  void _showNewReportAlert(List<HomeReport> nextReports, bool enabled) {
    final previousIds = Set<String>.of(_knownReportIds);
    final nextIds = nextReports
        .map((report) => report.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (_hasLoadedReportsOnce && enabled) {
      final newReports = nextReports.where((report) {
        final id = report.id.trim();
        return id.isNotEmpty &&
            !previousIds.contains(id) &&
            report.status.value == 'Belum Diproses';
      }).toList();

      if (newReports.isNotEmpty) {
        final report = newReports.first;
        final location = report.location == '-' ? 'lokasi terkait' : report.location;
        ObAssignmentAlert.show(
          title: 'Penugasan Baru'.tr,
          message:
              'Ada tugas perbaikan @title di @location. Harap segera menuju lokasi.'
                  .trParams({
                    'title': report.title,
                    'location': location,
                  }),
        );
      }
    }

    _knownReportIds
      ..clear()
      ..addAll(nextIds);
    _hasLoadedReportsOnce = true;
  }

  void _startReportPolling() {
    _reportPollingTimer?.cancel();
    _reportPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadReports(showNewReportAlert: true, silent: true);
    });
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _authService.getUnreadNotificationCount();
      unreadNotificationCount.value = count;
      debugPrint('📬 [NOTIF-BADGE] Unread count: $count');
    } catch (e) {
      debugPrint('❌ [NOTIF-BADGE] Failed to load unread count: $e');
    }
  }

  void _startNotificationPolling() {
    _notificationPollingTimer?.cancel();
    // Poll every 15 seconds for new notifications
    _notificationPollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadUnreadNotificationCount();
    });
  }

  String? _stringValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nested = _asMap(value);
        final nestedValue = _stringValue(nested ?? const {}, [
          'nama_lengkap',
          'nama_lokasi',
          'nama_kategori',
          'nama_ruangan',
          'nomor_lantai',
          'nama',
          'name',
          'username',
          'email',
          'label',
          'title',
          'judul',
          'alamat',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _stringValueFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _stringValue(source, keys);
      if (value != null) return value;
    }
    return null;
  }

  String _taskStatusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done')) {
      return 'resolved';
    }
    return 'pending';
  }

  String? _extractReporterFromNestedObjects(List<Map<String, dynamic>> sources) {
    for (final source in sources) {
      // Try to extract from nested karyawan object
      final karyawan = _asMap(source['karyawan']);
      if (karyawan != null) {
        final name = _stringValue(karyawan, [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
        ]);
        if (name != null) {
          debugPrint('📋 [REPORTER] Found reporter in karyawan object: $name');
          return name;
        }
      }
      
      // Try to extract from nested user object
      final user = _asMap(source['user']);
      if (user != null) {
        final name = _stringValue(user, [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
        ]);
        if (name != null) {
          debugPrint('📋 [REPORTER] Found reporter in user object: $name');
          return name;
        }
      }
      
      // Try to extract from nested pelapor object
      final pelapor = _asMap(source['pelapor']);
      if (pelapor != null) {
        final name = _stringValue(pelapor, [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
        ]);
        if (name != null) {
          debugPrint('📋 [REPORTER] Found reporter in pelapor object: $name');
          return name;
        }
      }
      
      // Try to extract from nested reported_by object
      final reportedBy = _asMap(source['reported_by']);
      if (reportedBy != null) {
        final name = _stringValue(reportedBy, [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
        ]);
        if (name != null) {
          debugPrint('📋 [REPORTER] Found reporter in reported_by object: $name');
          return name;
        }
      }
    }
    
    debugPrint('📋 [REPORTER] No reporter found in nested objects');
    return null;
  }

  String? _translatedValueOrNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return reportTranslationKey(value);
  }
}
