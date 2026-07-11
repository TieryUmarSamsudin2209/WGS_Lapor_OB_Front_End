import 'dart:async';

import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';
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
  String? assignedObId;
  String? assignedObName;

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
    this.assignedObId,
    this.assignedObName,
  }) : status = status.obs,
       hasCollaboration = hasCollaboration.obs;
}

class ObHomeController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final name = 'OB'.obs;
  final isLoadingTasks = false.obs;
  final isLoadingReports = false.obs;

  // List of Daily Tasks
  final dailyTasks = <DailyTask>[].obs;

  // List of Reports
  final reports = <HomeReport>[].obs;
  final takingReportIds = <String>{}.obs;
  final _knownReportIds = <String>{};

  Timer? _reportPollingTimer;
  bool _hasLoadedReportsOnce = false;

  int get completedTaskCount =>
      dailyTasks.where((task) => task.status.value == 'resolved').length;

  int get totalTaskCount => dailyTasks.length;

  int get taskProgressPercent {
    if (totalTaskCount == 0) return 0;
    return ((completedTaskCount / totalTaskCount) * 100).round();
  }

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

  List<HomeReport> get latestReports => reports.toList();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadHomeData();
    _startReportPolling();
  }

  void _loadUser() {
    final user = _authService.user.value;
    final displayName = user?['username'] ?? user?['name'] ?? user?['email'];
    if (displayName != null && displayName.toString().trim().isNotEmpty) {
      name.value = displayName.toString();
    }
  }

  Future<void> loadHomeData() async {
    await Future.wait([
      loadDailyTasks(),
      loadReports(),
    ]);
  }

  Future<void> loadDailyTasks() async {
    isLoadingTasks.value = true;

    try {
      final response = await _authService.getDailyChecklist();
      final items = _extractItems(
        response,
        keys: const ['checklist', 'checklists', 'items', 'tugas', 'tasks'],
      );

      dailyTasks.value = items
          .whereType<Map>()
          .map((item) => _dailyTaskFromApi(_asMap(item) ?? const {}))
          .toList();
    } catch (_) {
      dailyTasks.clear();
    } finally {
      isLoadingTasks.value = false;
    }
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
      final items = _extractItems(
        response,
        keys: const ['laporan', 'reports', 'items', 'data'],
      );

      final nextReports = items
          .whereType<Map>()
          .map((item) => _reportFromApi(_asMap(item) ?? const {}))
          .toList();

      _showNewReportAlert(nextReports, showNewReportAlert);
      reports.value = nextReports;
    } catch (_) {
      if (!silent) {
        reports.clear();
      }
    } finally {
      if (!silent) {
        isLoadingReports.value = false;
      }
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

  // Navigation functions
  void goHome() {
    // Already on home
  }

  void createReport() {
    Get.toNamed(Routes.OB_CHECKLIST);
  }

  void goProfile() {
    Get.offAllNamed(Routes.OB_PROFIL);
  }

  void openReportDetail(HomeReport report) {
    Get.toNamed(Routes.OB_DETAIL, arguments: report);
  }

  bool isTakingReport(HomeReport report) {
    final reportId = _normalizedReportId(report);
    return reportId != null && takingReportIds.contains(reportId);
  }

  Future<void> takeReport(HomeReport report) async {
    final reportId = _normalizedReportId(report);
    if (reportId == null) {
      Get.snackbar('Gagal', 'ID laporan tidak ditemukan');
      return;
    }

    if (takingReportIds.contains(reportId)) return;

    takingReportIds.add(reportId);
    try {
      final response = await _authService.takeObReport(reportId);
      if (response == null) {
        Get.snackbar(
          'Gagal mengambil laporan',
          _authService.lastRequestError ??
              'Laporan belum bisa diambil. Coba muat ulang daftar laporan.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      report.assignedObName =
          _assignedObNameFromResponse(response) ?? _currentObName ?? 'Anda';
      report.assignedObId = _assignedObIdFromResponse(response) ?? _currentObId;
      report.status.value = 'Sedang Diproses';

      Get.snackbar(
        'Laporan diambil',
        'Laporan sudah masuk daftar pekerjaan Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadReports(silent: true);
    } finally {
      takingReportIds.remove(reportId);
    }
  }

  DailyTask _dailyTaskFromApi(Map<String, dynamic> item) {
    return DailyTask(
      title: _stringValue(item, [
            'title',
            'judul',
            'nama',
            'nama_checklist',
            'kegiatan',
          ]) ??
          'Checklist',
      location: _stringValue(item, [
            'location',
            'lokasi',
            'ruangan',
            'area',
            'description',
            'deskripsi',
            'keterangan',
          ]) ??
          '-',
      status: _taskStatusFromApi(_stringValue(item, ['status']) ?? 'pending'),
    );
  }

  HomeReport _reportFromApi(Map<String, dynamic> item) {
    final detail = _asMap(item['laporan']) ?? _asMap(item['report']) ?? item;
    final photos = _photosFromApi(item);

    return HomeReport(
      id: _stringValue(item, [
            'laporan_id',
            'report_id',
          ]) ??
          _stringValue(detail, [
            'id',
            'uuid',
          ]) ??
          _stringValue(item, [
            'id',
            'uuid',
          ]) ??
          '',
      title: _stringValueFromSources([item, detail], [
            'title',
            'judul',
            'nama_laporan',
            'kategori',
            'category',
            'nama_kategori',
          ]) ??
          'Laporan',
      location: _stringValueFromSources([item, detail], [
            'location',
            'lokasi',
            'ruangan',
            'area',
            'detail_lokasi',
            'alamat',
            'lantai',
          ]) ??
          '-',
      description: _stringValueFromSources([item, detail], [
            'description',
            'deskripsi',
            'deskripsi_kendala',
            'catatan',
            'keluhan',
            'keterangan',
          ]) ??
          '-',
      priority: _priorityFromApi(
        _stringValueFromSources([item, detail], [
              'priority',
              'prioritas',
              'urgency',
              'urgensi',
            ]) ??
            '',
      ),
      status: _reportStatusFromApi(
        _stringValueFromSources([item, detail], ['status', 'status_laporan']) ??
            'pending',
      ),
      hasCollaboration: _boolValueFromSources([item, detail], [
        'has_collaboration',
        'hasCollaboration',
        'kolaborasi',
        'butuh_bantuan',
        'need_help',
      ]),
      reporterName: _stringValueFromSources([item, detail], [
        'nama_pelapor',
        'pelapor',
        'reporter',
        'reported_by',
        'reportedBy',
        'karyawan',
        'pegawai',
        'user',
      ]),
      categoryName: _stringValueFromSources([item, detail], [
        'nama_kategori',
        'kategori',
        'category',
        'category_name',
        'categoryName',
      ]),
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
    );
  }

  List<dynamic> _extractItems(
    Map<String, dynamic>? response, {
    required List<String> keys,
  }) {
    final data = _asMap(response?['data']);
    final nestedData = _asMap(data?['data']);

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      for (final key in keys) {
        final list = _asList(source[key]);
        if (list != null) return list;
      }
      final directData = _asList(source['data']);
      if (directData != null) return directData;
    }

    return const [];
  }

  String? _normalizedReportId(HomeReport report) {
    final rawId = report.id.trim();
    if (rawId.isEmpty) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    final text = normalized.trim();
    return text.isEmpty ? null : text;
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

  String _taskStatusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done')) {
      return 'resolved';
    }
    return 'pending';
  }

  String _reportStatusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done')) {
      return 'Selesai';
    }
    if (normalized.contains('tolak') || normalized.contains('reject')) {
      return 'Ditolak';
    }
    if (normalized.contains('proses') ||
        normalized.contains('progress') ||
        normalized.contains('diproses') ||
        normalized.contains('ambil') ||
        normalized.contains('taken') ||
        normalized.contains('assigned')) {
      return 'Sedang Diproses';
    }
    return 'Belum Diproses';
  }

  String _priorityFromApi(String priority) {
    final normalized = priority.trim().toLowerCase();
    if (normalized.contains('urgent') ||
        normalized.contains('tinggi') ||
        normalized.contains('high')) {
      return 'URGENT';
    }
    return 'STANDARD';
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

  String? _stringValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nested = _asMap(value);
        final nestedValue = _stringValue(nested ?? const {}, [
          'nama_lengkap',
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

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<dynamic>? _asList(Object? value) {
    if (value is List) return value;
    return null;
  }

  void _startReportPolling() {
    _reportPollingTimer?.cancel();
    _reportPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadReports(showNewReportAlert: true, silent: true);
    });
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
          title: 'Penugasan Baru',
          message:
              'Ada tugas perbaikan ${report.title} di $location. Harap segera menuju lokasi.',
        );
      }
    }

    _knownReportIds
      ..clear()
      ..addAll(nextIds);
    _hasLoadedReportsOnce = true;
  }

  @override
  void onClose() {
    _reportPollingTimer?.cancel();
    super.onClose();
  }
}
