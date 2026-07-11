import 'package:get/get.dart';

import '../../../shared/controllers/auth_controller.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/translations/app_translations.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final name = 'Karyawan'.obs;
  final username = '@username'.obs;
  final avatarUrl =
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256'
          .obs;
  final reports = <Map<String, dynamic>>[].obs;
  final filteredReports = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'Semua'.obs;
  final selectedLanguage = 'Indonesia'.obs;

  String _searchQuery = '';
  String? _selectedStatus;

  List<Map<String, dynamic>> get recentReports => reports.take(2).toList();
  int get totalReports => reports.length;

  String get firstName {
    final parts = name.value.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Karyawan' : parts.first;
  }

  String get lastName {
    final parts = name.value.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.skip(1).join(' ');
  }

  @override
  void onInit() {
    super.onInit();
    selectedLanguage.value = AppTranslations.currentLanguageLabel();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await _authService.getUserProfile();
      final data = _asMap(response?['data']) ?? response;
      final profile = _asMap(data?['user']) ??
          _asMap(data?['profile']) ??
          _asMap(data?['data']) ??
          data;

      _setProfile(profile);

      var reportItems = _extractReportItems(
        response: response,
        data: data,
        profile: profile,
      );

      if (reportItems.isEmpty) {
        final reportsResponse = await _authService.getEmployeeReports(
          limit: 50,
        );
        final reportsData = _asMap(reportsResponse?['data']) ?? reportsResponse;
        reportItems = _extractReportItems(
          response: reportsResponse,
          data: reportsData,
          profile: null,
        );
      }

      final parsedReports = reportItems
          .whereType<Map>()
          .map((item) => _reportFromApi(_asMap(item) ?? const {}))
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
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(
    String firstName,
    String lastName,
    String? avatarPath,
  ) async {
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();
    if (sanitizedFirstName.isEmpty) return false;

    final fullName = [sanitizedFirstName, sanitizedLastName]
        .where((part) => part.isNotEmpty)
        .join(' ');

    final response = await _authService.updateUserProfile(
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
      avatarPath: avatarPath,
    );

    if (response == null) {
      Get.snackbar('Gagal', 'Profil belum berhasil disimpan');
      return false;
    }

    final profile = _profileFromResponse(response);
    if (profile != null) {
      _setProfile(profile);
    } else {
      name.value = fullName;
      if (avatarPath != null && avatarPath.trim().isNotEmpty) {
        avatarUrl.value = avatarPath.trim();
      }
    }

    Get.snackbar('Berhasil', 'Profil berhasil disimpan');
    return true;
  }

  void updateAvatar(String avatarPath) {
    final sanitizedAvatarPath = avatarPath.trim();
    if (sanitizedAvatarPath.isEmpty) return;

    avatarUrl.value = sanitizedAvatarPath;
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    selectedFilter.value = _filterLabelFromStatus(status);
    _applyFilter();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _selectedStatus = _statusFromFilter(filter);
    _applyFilter();
  }

  void onSearchChanged(String value) {
    _searchQuery = value.trim().toLowerCase();
    _applyFilter();
  }

  Future<void> logout() async {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController(), permanent: true);
    await authController.logout();
  }

  Future<void> openReport(Map<String, dynamic> report) async {
    final id = report['raw_id']?.toString() ?? report['id']?.toString();
    if (id == null || id.isEmpty) return;

    final detail = await _authService.getUserReportDetail(id);
    final message =
        _asMap(detail?['data'])?['description']?.toString() ??
        _asMap(detail?['data'])?['deskripsi']?.toString() ??
        'Detail laporan berhasil dimuat';
    Get.snackbar('Detail laporan', message);
  }

  void _setProfile(Map<String, dynamic>? profile) {
    if (profile == null) return;

    final displayName = _firstValue(profile, [
      'nama_lengkap',
      'nama',
      'name',
      'username',
      'email',
    ]);
    final userName = _firstValue(profile, ['username', 'email', 'nama']);
    final photo = _firstValue(profile, [
      'profile_picture',
      'profilePicture',
      'avatar',
      'foto',
    ]);

    if (displayName != null && displayName.isNotEmpty) {
      name.value = displayName;
    }
    if (userName != null && userName.isNotEmpty) {
      username.value = userName.startsWith('@') ? userName : '@$userName';
    }
    if (photo != null && photo.isNotEmpty) {
      avatarUrl.value = _profilePhotoUrl(photo);
    }
  }

  Map<String, dynamic>? _profileFromResponse(Map<String, dynamic> response) {
    final data = _asMap(response['data']) ?? response;
    final profile = _asMap(data['user']) ??
        _asMap(data['profile']) ??
        _asMap(data['data']) ??
        data;
    return _looksLikeProfile(profile) ? profile : null;
  }

  bool _looksLikeProfile(Map<String, dynamic> value) {
    return [
      'id',
      'username',
      'email',
      'nama',
      'nama_lengkap',
      'name',
      'role',
      'profile_picture',
      'profilePicture',
      'avatar',
      'foto',
    ].any(value.containsKey);
  }

  String _profilePhotoUrl(String photo) {
    if (photo.startsWith('http')) return photo;
    if (photo.startsWith('/uploads')) {
      return '${AuthService.baseUrl}$photo';
    }
    if (photo.startsWith('uploads/')) {
      return '${AuthService.baseUrl}/$photo';
    }
    if (photo.startsWith('/') || photo.contains('\\') || photo.contains(':')) {
      return photo;
    }
    return photo;
  }

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

  List<dynamic>? _listFromSource(
    Map<String, dynamic>? source,
    List<String> keys,
  ) {
    if (source == null) return null;

    for (final key in keys) {
      final list = _asList(source[key]);
      if (list != null) return list;

      final nested = _asMap(source[key]);
      if (nested == null) continue;

      for (final nestedKey in keys) {
        final nestedList = _asList(nested[nestedKey]);
        if (nestedList != null) return nestedList;
      }
    }

    return null;
  }

  void _applyFilter() {
    var result = reports.toList();

    if (_selectedStatus != null) {
      result = result
          .where((report) => report['status']?.toString() == _selectedStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((report) {
        return report.values.whereType<String>().any(
              (value) => value.toLowerCase().contains(_searchQuery),
            );
      }).toList();
    }

    filteredReports.value = result;
  }

  String _filterLabelFromStatus(String? status) {
    switch (status) {
      case 'Diproses':
        return 'Proses';
      case 'Selesai':
        return 'Selesai';
      case 'Ditolak':
        return 'Tertolak';
      case 'Pending':
        return 'Pending';
      default:
        return 'Semua';
    }
  }

  String? _statusFromFilter(String filter) {
    switch (filter) {
      case 'Proses':
        return 'Diproses';
      case 'Selesai':
        return 'Selesai';
      case 'Tertolak':
        return 'Ditolak';
      case 'Pending':
        return 'Pending';
      default:
        return null;
    }
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

  DateTime? _dateValue(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
