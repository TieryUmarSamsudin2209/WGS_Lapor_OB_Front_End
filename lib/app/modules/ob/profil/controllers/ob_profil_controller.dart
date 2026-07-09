import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/controllers/auth_controller.dart';
import '../../../../shared/services/auth_service.dart';

/// ================= MODEL =================
class ReportModel {
  final String id;
  final String priority;
  final String title;
  final String location;
  final String description;
  final DateTime date;
  final ReportStatus status;

  ReportModel({
    required this.id,
    required this.priority,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.status,
  });
}

/// ================= ENUM =================
enum ReportStatus { inProgress, pending, rejected, resolved }

extension ReportStatusExt on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.inProgress:
        return 'Selesai';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.rejected:
        return 'Ditolak';
      case ReportStatus.resolved:
        return 'Selesai';
    }
  }

  bool get isClosed {
    return this == ReportStatus.rejected || this == ReportStatus.resolved;
  }
}

/// ================= CONTROLLER =================
class ObProfilController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  /// ---- Profile ----
  var name = 'Rahman OB'.obs;
  var username = '@username'.obs;
  var avatarUrl = 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400'.obs;

  String get firstName => name.value.trim().split(RegExp(r'\s+')).first;

  String get lastName {
    final parts = name.value.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.skip(1).join(' ');
  }

  /// ---- State ----
  var isLoading = false.obs;

  /// ---- Data ----
  var reports = <ReportModel>[].obs;
  var filteredReports = <ReportModel>[].obs;

  ReportStatus? currentFilter;
  String searchQuery = '';

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

    filteredReports.value = reports;
    isLoading.value = false;
  }

  /// ================= ACTION =================

  void goToReportHistory() {
    Get.snackbar('Info', 'Go to report history');
  }

  void goHome() {
    Get.offAllNamed(Routes.OB_HOME);
  }

  void createReport() {
    Get.toNamed(Routes.OB_CHECKLIST);
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

  Future<void> logout() async {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController(), permanent: true);
    await authController.logout();
  }

  Future<void> openReport(ReportModel report) async {
    final reportId = report.id.startsWith('#') ? report.id.substring(1) : report.id;
    final detail = await _authService.getUserReportDetail(reportId);
    final data = _asMap(detail?['data']);
    final message = data?['description']?.toString() ??
        data?['deskripsi']?.toString() ??
        'Detail laporan berhasil dimuat';
    Get.snackbar('Detail laporan', message);
  }

  /// ================= FILTER =================

  void setStatusFilter(ReportStatus? status) {
    currentFilter = status;
    _applyFilter();
  }

  void onSearchChanged(String value) {
    searchQuery = value.toLowerCase();
    _applyFilter();
  }

  void _applyFilter() {
    List<ReportModel> result = reports;

    /// Filter by status
    if (currentFilter != null) {
      result = result.where((r) => r.status == currentFilter).toList();
    }

    /// Filter by search
    if (searchQuery.isNotEmpty) {
      result = result.where((r) {
        return r.id.toLowerCase().contains(searchQuery) ||
            r.priority.toLowerCase().contains(searchQuery) ||
            r.title.toLowerCase().contains(searchQuery) ||
            r.location.toLowerCase().contains(searchQuery) ||
            r.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    filteredReports.value = result;
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

  ReportModel _reportFromApi(Map<String, dynamic> item) {
    final rawId = _firstValue(item, ['id', 'laporan_id', 'report_id']) ?? '';
    final displayId = rawId.startsWith('#') ? rawId : '#$rawId';

    return ReportModel(
      id: displayId,
      priority:
          (_firstValue(item, ['priority', 'prioritas']) ?? 'STANDARD')
              .toUpperCase(),
      title:
          _firstValue(item, ['title', 'judul', 'nama_laporan']) ?? 'Laporan',
      location: _firstValue(item, ['location', 'lokasi', 'ruangan']) ?? '-',
      description:
          _firstValue(item, ['description', 'deskripsi', 'catatan']) ?? '-',
      date: _dateFromApi(_firstValue(item, ['created_at', 'tanggal', 'date'])),
      status: _statusFromApi(_firstValue(item, ['status']) ?? 'Pending'),
    );
  }

  ReportStatus _statusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('tolak') || normalized.contains('reject')) {
      return ReportStatus.rejected;
    }
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done')) {
      return ReportStatus.resolved;
    }
    if (normalized.contains('proses') || normalized.contains('progress')) {
      return ReportStatus.inProgress;
    }
    return ReportStatus.pending;
  }

  DateTime _dateFromApi(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
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
