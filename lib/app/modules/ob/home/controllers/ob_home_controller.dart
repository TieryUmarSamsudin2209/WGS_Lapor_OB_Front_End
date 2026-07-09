import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';

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

  HomeReport({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.priority,
    required String status,
    bool hasCollaboration = false,
    this.photos = const [],
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

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadHomeData();
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

  Future<void> loadReports() async {
    isLoadingReports.value = true;

    try {
      final response = await _authService.getObReports();
      final items = _extractItems(
        response,
        keys: const ['laporan', 'reports', 'items', 'data'],
      );

      reports.value = items
          .whereType<Map>()
          .map((item) => _reportFromApi(_asMap(item) ?? const {}))
          .toList();
    } catch (_) {
      reports.clear();
    } finally {
      isLoadingReports.value = false;
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
      id: _stringValueFromSources([
            item,
            detail,
          ], [
            'id',
            'laporan_id',
            'report_id',
            'uuid',
          ]) ??
          '',
      title: _stringValueFromSources([item, detail], [
            'title',
            'judul',
            'nama_laporan',
            'kategori',
            'category',
          ]) ??
          'Laporan',
      location: _stringValueFromSources([item, detail], [
            'location',
            'lokasi',
            'ruangan',
            'area',
            'detail_lokasi',
            'alamat',
          ]) ??
          '-',
      description: _stringValueFromSources([item, detail], [
            'description',
            'deskripsi',
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
        normalized.contains('diproses')) {
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
      'bukti_foto',
      'gambar',
      'images',
    ]) {
      final value = source[key];
      final list = _asList(value);
      if (list != null) {
        return list.map((item) => item.toString()).where((item) {
          return item.trim().isNotEmpty;
        }).toList();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return [value.toString().trim()];
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
          'nama',
          'name',
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
}
