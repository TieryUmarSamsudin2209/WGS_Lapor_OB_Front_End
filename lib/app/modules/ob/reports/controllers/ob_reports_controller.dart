import 'dart:async';

import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObReportsController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final reports = <HomeReport>[].obs;
  final filteredReports = <HomeReport>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;

  String _searchQuery = '';
  Timer? _reportPollingTimer;

  @override
  void onInit() {
    super.onInit();
    loadReports();
    _startReportPolling();
  }

  Future<void> loadReports({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
    }

    try {
      final response = await _authService.getObReports(limit: 100);
      final items = _extractItems(response);

      reports.value = items
          .whereType<Map>()
          .map((item) => _reportFromApi(_asMap(item) ?? const {}))
          .toList();
      _applyFilter();
    } catch (_) {
      if (!silent) {
        reports.clear();
        filteredReports.clear();
      }
    } finally {
      if (!silent) {
        isLoading.value = false;
      }
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void onSearchChanged(String value) {
    _searchQuery = value.trim().toLowerCase();
    _applyFilter();
  }

  void openReport(HomeReport report) {
    Get.toNamed(Routes.OB_DETAIL, arguments: report);
  }

  void _applyFilter() {
    final filter = selectedFilter.value;
    var result = reports.toList();

    if (filter != 'Semua') {
      result = result.where((report) {
        final status = report.status.value;
        if (filter == 'Proses') return status == 'Sedang Diproses';
        if (filter == 'Selesai') return status == 'Selesai';
        if (filter == 'Tertolak') return status == 'Ditolak';
        if (filter == 'Pending') return status == 'Belum Diproses';
        return true;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((report) {
        return [
          report.id,
          report.title,
          report.location,
          report.description,
          report.priority,
          report.status.value,
        ].any((value) => value.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    filteredReports.value = result;
  }

  HomeReport _reportFromApi(Map<String, dynamic> item) {
    final detail = _asMap(item['laporan']) ?? _asMap(item['report']) ?? item;
    final photos = _photosFromApi(item);

    return HomeReport(
      id:
          _stringValue(item, [
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
      title:
          _stringValueFromSources([item, detail], [
            'title',
            'judul',
            'nama_laporan',
            'kategori',
            'category',
            'nama_kategori',
          ]) ??
          'Laporan',
      location:
          _stringValueFromSources([item, detail], [
            'location',
            'lokasi',
            'ruangan',
            'area',
            'detail_lokasi',
            'alamat',
            'lantai',
          ]) ??
          '-',
      description:
          _stringValueFromSources([item, detail], [
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

  List<dynamic> _extractItems(Map<String, dynamic>? response) {
    final data = _asMap(response?['data']);
    final nestedData = _asMap(data?['data']);
    const keys = [
      'laporan',
      'reports',
      'items',
      'data',
      'rows',
      'results',
      'riwayat_laporan',
      'riwayatLaporan',
      'laporan_masuk',
      'laporanMasuk',
      'incoming_reports',
      'incomingReports',
      'report_history',
      'reportHistory',
      'history',
      'histori',
    ];

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
      if (value is List) {
        return value
            .map((item) => AuthService.resolveMediaUrl(item.toString()))
            .where((item) => item.isNotEmpty)
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
          'nama_lokasi',
          'nama_kategori',
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

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  void _startReportPolling() {
    _reportPollingTimer?.cancel();
    _reportPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadReports(silent: true);
    });
  }

  @override
  void onClose() {
    _reportPollingTimer?.cancel();
    super.onClose();
  }
}
