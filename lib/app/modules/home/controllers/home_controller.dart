import 'package:get/get.dart';

import '../../../shared/services/auth_service.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final count = 0.obs;
  final name = 'Karyawan'.obs;
  final reports = <Map<String, dynamic>>[].obs;
  final isLoadingReports = false.obs;

  List<Map<String, dynamic>> get recentReports => reports.take(2).toList();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    loadReports();
  }

  void _loadUser() {
    final user = _authService.user.value;
    final displayName = user?['username'] ?? user?['name'] ?? user?['email'];
    if (displayName != null && displayName.toString().trim().isNotEmpty) {
      name.value = displayName.toString();
    }
  }

  Future<void> loadReports() async {
    if (!_authService.isLoggedIn) return;

    isLoadingReports.value = true;
    try {
      final profileResponse = await _authService.getUserProfile();
      final profileData = _asMap(profileResponse?['data']) ?? profileResponse;
      final profile = _asMap(profileData?['user']) ??
          _asMap(profileData?['profile']) ??
          _asMap(profileData?['data']) ??
          profileData;
      var items = _extractReportItems(
        response: profileResponse,
        data: profileData,
        profile: profile,
      );

      if (items.isEmpty) {
        final reportsResponse = await _authService.getEmployeeReports(
          limit: 10,
        );
        final reportsData = _asMap(reportsResponse?['data']) ?? reportsResponse;
        items = _extractReportItems(
          response: reportsResponse,
          data: reportsData,
          profile: null,
        );
      }

      final parsedReports = items
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(_reportFromApi)
          .toList();

      parsedReports.sort((a, b) {
        final aDate = _dateValue(a['created_at']);
        final bDate = _dateValue(b['created_at']);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      reports.value = parsedReports;
    } finally {
      isLoadingReports.value = false;
    }
  }

  Future<void> openReport(Map<String, dynamic> report) async {
    final id = report['raw_id']?.toString() ?? report['id']?.toString();
    if (id == null || id.isEmpty) return;

    final detail = await _authService.getUserReportDetail(id);
    final message =
        _asMap(detail?['data'])?['description']?.toString() ??
        _asMap(detail?['data'])?['deskripsi']?.toString() ??
        _asMap(detail?['data'])?['deskripsi_kendala']?.toString() ??
        'Detail laporan berhasil dimuat';
    Get.snackbar('Detail laporan', message);
  }

  void increment() => count.value++;

  Map<String, dynamic> _reportFromApi(Map<String, dynamic> item) {
    final detail = _asMap(item['laporan']) ?? _asMap(item['report']) ?? item;
    final sources = [item, detail];
    final rawId =
        _firstValueFromSources(sources, ['id', 'laporan_id', 'report_id']) ??
            '';
    final displayId = rawId.startsWith('#') ? rawId : '#$rawId';

    return {
      'raw_id': rawId,
      'id': displayId,
      'category': _firstValueFromSources(sources, [
            'category',
            'kategori',
            'nama_kategori',
          ]) ??
          '-',
      'priority': (_firstValueFromSources(sources, [
                'priority',
                'prioritas',
                'urgency',
                'urgensi',
              ]) ??
              'STANDARD')
          .toUpperCase(),
      'status': _statusLabel(
        _firstValueFromSources(sources, ['status', 'status_laporan']) ??
            'Pending',
      ),
      'title': _firstValueFromSources(sources, [
            'title',
            'judul',
            'nama_laporan',
            'nama_kategori',
            'kategori',
            'category',
          ]) ??
          'Laporan',
      'location': _firstValueFromSources(sources, [
            'location',
            'lokasi',
            'ruangan',
            'area',
            'detail_lokasi',
            'alamat',
            'lantai',
          ]) ??
          '-',
      'description': _firstValueFromSources(sources, [
            'description',
            'deskripsi',
            'deskripsi_kendala',
            'catatan',
            'keluhan',
            'keterangan',
          ]) ??
          '-',
      'created_at': _firstValueFromSources(sources, [
        'created_at',
        'createdAt',
        'tanggal',
        'date',
        'tanggal_laporan',
        'waktu_laporan',
      ]),
    };
  }

  List<dynamic> _extractReportItems({
    required Map<String, dynamic>? response,
    required Map<String, dynamic>? data,
    required Map<String, dynamic>? profile,
  }) {
    const keys = [
      'laporan',
      'laporan_karyawan',
      'laporanKaryawan',
      'reports',
      'riwayat_laporan',
      'riwayatLaporan',
      'history',
      'histori',
      'report_history',
      'reportHistory',
      'employee_reports',
      'employeeReports',
      'data',
      'items',
      'rows',
      'results',
    ];

    final nestedData = _asMap(data?['data']);
    for (final source in [nestedData, data, profile, response]) {
      final list = _listFromSource(source, keys);
      if (list != null) return list;
    }

    return const [];
  }

  List<dynamic>? _listFromSource(Object? source, List<String> keys) {
    if (source is List) return source;

    final map = _asMap(source);
    if (map == null) return null;

    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;

      final nested = _asMap(value);
      if (nested == null) continue;

      for (final nestedKey in keys) {
        final nestedValue = nested[nestedKey];
        if (nestedValue is List) return nestedValue;
      }
    }

    return null;
  }

  String _statusLabel(String status) {
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
      return 'Diproses';
    }
    return 'Pending';
  }

  String? _firstValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nestedValue = _firstValue(_asMap(value) ?? const {}, [
          'nama_lokasi',
          'nama_kategori',
          'nomor_lantai',
          'nama',
          'name',
          'title',
          'label',
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

  DateTime? _dateValue(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
