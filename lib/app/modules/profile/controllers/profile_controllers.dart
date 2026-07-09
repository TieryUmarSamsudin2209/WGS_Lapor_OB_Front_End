import 'package:get/get.dart';

import '../../../shared/controllers/auth_controller.dart';
import '../../../shared/services/auth_service.dart';

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

  String _searchQuery = '';
  String? _selectedStatus;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;

    final response = await _authService.getUserProfile();
    final data = _asMap(response?['data']) ?? response;
    final profile = _asMap(data?['user']) ??
        _asMap(data?['profile']) ??
        _asMap(data?['data']) ??
        data;

    _setProfile(profile);

    final reportItems = _asList(data?['laporan']) ??
        _asList(data?['reports']) ??
        _asList(data?['riwayat_laporan']) ??
        _asList(data?['history']) ??
        _asList(response?['laporan']);

    reports.value = (reportItems ?? const [])
        .whereType<Map>()
        .map((item) => _reportFromApi(_asMap(item) ?? const {}))
        .toList();
    _applyFilter();

    isLoading.value = false;
  }

  void updateProfile(String firstName, String lastName) {
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();
    if (sanitizedFirstName.isEmpty) return;

    name.value = [sanitizedFirstName, sanitizedLastName]
        .where((part) => part.isNotEmpty)
        .join(' ');
  }

  void updateAvatar(String avatarPath) {
    final sanitizedAvatarPath = avatarPath.trim();
    if (sanitizedAvatarPath.isEmpty) return;

    avatarUrl.value = sanitizedAvatarPath;
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
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
      avatarUrl.value = photo;
    }
  }

  Map<String, dynamic> _reportFromApi(Map<String, dynamic> item) {
    final rawId = _firstValue(item, ['id', 'laporan_id', 'report_id']) ?? '';
    final displayId = rawId.startsWith('#') ? rawId : '#$rawId';

    return {
      'raw_id': rawId,
      'id': displayId,
      'category': _firstValue(item, ['category', 'kategori']) ?? '-',
      'priority':
          (_firstValue(item, ['priority', 'prioritas']) ?? 'STANDARD')
              .toUpperCase(),
      'status': _statusLabel(_firstValue(item, ['status']) ?? 'Pending'),
      'title': _firstValue(item, ['title', 'judul', 'nama_laporan']) ??
          'Laporan',
      'location': _firstValue(item, ['location', 'lokasi', 'ruangan']) ?? '-',
      'description':
          _firstValue(item, ['description', 'deskripsi', 'catatan']) ?? '-',
    };
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
    if (normalized.contains('proses') || normalized.contains('progress')) {
      return 'Diproses';
    }
    return 'Pending';
  }

  String? _firstValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
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
