import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/controllers/auth_controller.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/report_translation_key.dart';
import '../../home/controllers/ob_home_controller.dart';

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

class ActiveLocation {
  final String id;
  final String name;
  final RxBool isActive;

  ActiveLocation({
    required this.id,
    required this.name,
    bool isActive = false,
  }) : isActive = isActive.obs;
}

/// ================= ENUM =================
enum ReportStatus { inProgress, pending, rejected, resolved }

extension ReportStatusExt on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.inProgress:
        return 'Diproses';
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
  var isEditingLocation = false.obs;
  var isSavingLocation = false.obs;

  /// ---- Data ----
  var reports = <ReportModel>[].obs;
  var filteredReports = <ReportModel>[].obs;
  final completedTaskTotal = 0.obs;
  var activeLocations = <ActiveLocation>[].obs;

  ReportStatus? currentFilter;
  String searchQuery = '';

  List<ReportModel> get recentReports => reports.take(2).toList();
  int get handledReportTotal =>
      reports.where((report) => report.status != ReportStatus.pending).length;
  String get averageResponseLabel => reports.isEmpty ? '-' : '15m';

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadActiveLocations();
  }

  Future<void> loadProfile() async {
    debugPrint('🔄 Loading profile...');
    isLoading.value = true;

    final results = await Future.wait([
      _authService.getUserProfile(),
      _authService.getObReports(limit: 50),
      _authService.getDailyChecklist(limit: 50),
    ]);

    final response = results[0];
    debugPrint('📦 Profile response: ${response.toString().substring(0, response.toString().length > 300 ? 300 : response.toString().length)}');
    
    final reportsResponse = results[1];
    final checklistResponse = results[2];
    final data = _asMap(response?['data']) ?? response;
    final profile = _asMap(data?['user']) ??
        _asMap(data?['profile']) ??
        _asMap(data?['data']) ??
        data;

    debugPrint('📝 Extracted profile: ${profile.toString().substring(0, profile.toString().length > 300 ? 300 : profile.toString().length)}');

    _setProfile(profile);

    var reportItems = _extractReportItems(reportsResponse);
    if (reportItems.isEmpty) {
      reportItems = _extractReportItems(response);
    }

    reports.value = reportItems
        .whereType<Map>()
        .map((item) => _reportFromApi(_asMap(item) ?? const {}))
        .toList();

    completedTaskTotal.value = _completedTaskCount(checklistResponse);
    filteredReports.value = reports;
    isLoading.value = false;
    
    debugPrint('✅ Profile loaded: name=${name.value}, username=${username.value}');
  }

  /// ================= ACTION =================

  void goToReportHistory() {
    Get.toNamed(Routes.OB_REPORTS);
  }

  void goHome() {
    Get.offAllNamed(Routes.OB_HOME);
  }

  void createReport() {
    Get.toNamed(Routes.OB_CHECKLIST);
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

    debugPrint('🔄 Updating profile: firstName=$sanitizedFirstName, lastName=$sanitizedLastName, avatarPath=$avatarPath');

    final response = await _authService.updateUserProfile(
      firstName: sanitizedFirstName,
      lastName: sanitizedLastName,
      avatarPath: avatarPath,
    );

    if (response == null) {
      final errorMsg = _authService.lastRequestError ?? 'Profil belum berhasil disimpan';
      debugPrint('❌ Update profile failed: $errorMsg');
      Get.snackbar('Gagal'.tr, errorMsg.tr);
      return false;
    }

    debugPrint('✅ Profile update API success: ${response.toString().substring(0, response.toString().length > 200 ? 200 : response.toString().length)}');

    final profile = _profileFromResponse(response);
    if (profile != null) {
      debugPrint('📦 Setting profile from response');
      _setProfile(profile);
    } else {
      debugPrint('📝 Setting profile manually: name=$fullName');
      name.value = fullName;
      if (avatarPath != null && avatarPath.trim().isNotEmpty) {
        avatarUrl.value = avatarPath.trim();
      }
    }

    // Force refresh UI
    name.refresh();
    avatarUrl.refresh();
    
    debugPrint('✅ Profile updated successfully: name=${name.value}, avatar=${avatarUrl.value}');
    Get.snackbar('Berhasil'.tr, 'Profil berhasil disimpan'.tr);
    return true;
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

  /// ================= ACTIVE LOCATION =================

  Future<void> loadActiveLocations() async {
    try {
      final response = await _authService.getObActiveLocations();
      if (response == null) return;

      final items = _extractLocationItems(response);
      activeLocations.value = items
          .whereType<Map>()
          .map((item) => _locationFromApi(_asMap(item) ?? const {}))
          .toList();
    } catch (e) {
      debugPrint('Error loading active locations: $e');
    }
  }

  void toggleEditLocation() {
    isEditingLocation.value = !isEditingLocation.value;
  }

  void toggleLocation(ActiveLocation location) {
    location.isActive.value = !location.isActive.value;
  }

  Future<void> saveActiveLocations() async {
    isSavingLocation.value = true;

    try {
      final activeLocationIds = activeLocations
          .where((loc) => loc.isActive.value)
          .map((loc) => loc.id)
          .toList();

      final response = await _authService.updateObActiveLocations(activeLocationIds);
      
      if (response == null) {
        Get.snackbar(
          'Gagal'.tr,
          'Lokasi aktif belum berhasil disimpan'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.snackbar(
        'Berhasil'.tr,
        'Lokasi aktif berhasil disimpan'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      isEditingLocation.value = false;
    } catch (e) {
      debugPrint('Error saving active locations: $e');
      Get.snackbar(
        'Gagal'.tr,
        'Terjadi kesalahan saat menyimpan lokasi'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingLocation.value = false;
    }
  }

  ActiveLocation _locationFromApi(Map<String, dynamic> item) {
    final id = _firstValue(item, [
          'id',
          'gedung_id',
          'lokasi_id',
          'location_id',
          'uuid',
        ]) ??
        '';
    
    final name = _firstValue(item, [
          'nama',
          'name',
          'nama_gedung',
          'nama_lokasi',
          'lokasi',
          'location',
        ]) ??
        'Lokasi';

    final isActive = _boolValue(item, [
      'is_active',
      'isActive',
      'active',
      'aktif',
    ]);

    return ActiveLocation(
      id: id,
      name: name,
      isActive: isActive,
    );
  }

  List<dynamic> _extractLocationItems(Map<String, dynamic>? response) {
    final data = _asMap(response?['data']);
    final nestedData = _asMap(data?['data']);
    const keys = [
      'lokasi',
      'locations',
      'gedung',
      'buildings',
      'lantai',
      'floors',
      'items',
      'data',
      'rows',
      'results',
    ];

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      for (final key in keys) {
        final value = source[key];
        if (value is List) return value;
      }
    }

    return const [];
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

  Future<void> openReport(ReportModel report) async {
    final reportId = report.id.startsWith('#') ? report.id.substring(1) : report.id;
    Get.toNamed(
      Routes.OB_DETAIL,
      arguments: HomeReport(
        id: reportId,
        title: report.title,
        location: report.location,
        description: report.description,
        priority: report.priority,
        status: _homeStatusFromProfileStatus(report.status),
        assignedObName: name.value,
      ),
    );
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

    debugPrint('🎯 _setProfile called with: ${profile.toString().substring(0, profile.toString().length > 300 ? 300 : profile.toString().length)}');

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

    debugPrint('  displayName: $displayName');
    debugPrint('  userName: $userName');
    debugPrint('  photo: $photo');

    if (displayName != null && displayName.isNotEmpty) {
      name.value = displayName;
    }
    if (userName != null && userName.isNotEmpty) {
      username.value = userName.startsWith('@') ? userName : '@$userName';
    }
    if (photo != null && photo.isNotEmpty) {
      avatarUrl.value = _profilePhotoUrl(photo);
    }
    
    debugPrint('✅ Profile set: name=${name.value}, username=${username.value}');
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
    return '${AuthService.baseUrl}/$photo';
  }

  ReportModel _reportFromApi(Map<String, dynamic> item) {
    final detail = _asMap(item['laporan']) ?? _asMap(item['report']) ?? item;
    final sources = [item, detail];
    final rawId = _firstValueFromSources(
      sources,
      ['id', 'laporan_id', 'report_id', 'uuid'],
    ) ?? '';
    final displayId = rawId.startsWith('#') ? rawId : '#$rawId';

    return ReportModel(
      id: displayId,
      priority: (_firstValueFromSources(sources, [
                'priority',
                'prioritas',
                'urgency',
                'urgensi',
              ]) ??
              'STANDARD')
          .toUpperCase(),
      title: reportTranslationKey(
        _firstValueFromSources(sources, [
              'title',
              'judul',
              'nama_laporan',
              'kategori',
              'category',
              'nama_kategori',
            ]) ??
            'Laporan',
      ),
      location: reportTranslationKey(
        _firstValueFromSources(sources, [
              'location',
              'lokasi',
              'ruangan',
              'area',
              'detail_lokasi',
              'alamat',
              'lantai',
            ]) ??
            '-',
      ),
      description: reportTranslationKey(
        _firstValueFromSources(sources, [
              'description',
              'deskripsi',
              'deskripsi_kendala',
              'catatan',
              'keluhan',
              'keterangan',
            ]) ??
            '-',
      ),
      date: _dateFromApi(
        _firstValueFromSources(sources, ['created_at', 'tanggal', 'date']),
      ),
      status: _statusFromApi(
        _firstValueFromSources(sources, ['status', 'status_laporan']) ??
            'Pending',
      ),
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
    if (normalized.contains('proses') ||
        normalized.contains('progress') ||
        normalized.contains('diproses')) {
      return ReportStatus.inProgress;
    }
    return ReportStatus.pending;
  }

  String _homeStatusFromProfileStatus(ReportStatus status) {
    switch (status) {
      case ReportStatus.inProgress:
        return 'Sedang Diproses';
      case ReportStatus.pending:
        return 'Belum Diproses';
      case ReportStatus.rejected:
        return 'Ditolak';
      case ReportStatus.resolved:
        return 'Selesai';
    }
  }

  List<dynamic> _extractReportItems(Map<String, dynamic>? response) {
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

  int _completedTaskCount(Map<String, dynamic>? response) {
    final items = _extractChecklistItems(response);
    return items.whereType<Map>().where((rawItem) {
      final item = _asMap(rawItem) ?? const {};
      final status = _firstValue(item, [
            'status',
            'status_checklist',
            'status_tugas',
          ]) ??
          '';
      final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
      return normalized.contains('selesai') ||
          normalized.contains('resolved') ||
          normalized.contains('done');
    }).length;
  }

  List<dynamic> _extractChecklistItems(Map<String, dynamic>? response) {
    final data = _asMap(response?['data']);
    final nestedData = _asMap(data?['data']);
    const keys = [
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
    ];

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      for (final key in keys) {
        final value = source[key];
        if (value is List) return value;
      }
    }

    return const [];
  }

  DateTime _dateFromApi(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  String? _firstValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final nested = _asMap(value);
        final nestedValue = _firstValue(nested ?? const {}, [
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
