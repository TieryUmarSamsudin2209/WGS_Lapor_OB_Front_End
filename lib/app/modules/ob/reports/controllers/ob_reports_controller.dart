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

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;

    try {
      final response = await _authService.getObReports(limit: 50);
      final items = _extractItems(response);

      reports.value = items
          .whereType<Map>()
          .map((item) => _reportFromApi(_asMap(item) ?? const {}))
          .toList();
      _applyFilter();
    } catch (_) {
      reports.clear();
      filteredReports.clear();
    } finally {
      isLoading.value = false;
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
          _stringValueFromSources([item, detail], [
            'id',
            'laporan_id',
            'report_id',
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
      'foto_masalah',
      'bukti_foto',
      'gambar',
      'images',
    ]) {
      final value = source[key];
      if (value is List) {
        return value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
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
          'nama_lokasi',
          'nama_kategori',
          'nomor_lantai',
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
}
