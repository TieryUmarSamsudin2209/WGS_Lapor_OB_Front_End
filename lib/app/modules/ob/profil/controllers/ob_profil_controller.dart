import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

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
    _loadDummyData();
  }

  /// ---- Dummy data (biar langsung muncul di UI) ----
  void _loadDummyData() {
    isLoading.value = true;

    reports.value = [
      ReportModel(
        id: '#REP-8492',
        priority: 'URGENT',
        title: 'Kebocoran Pipa Air',
        location: 'HQ Tower A, Lantai 4 (Toilet Pria)',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 24),
        status: ReportStatus.resolved,
      ),
      ReportModel(
        id: '#REP-8490',
        priority: 'URGENT',
        title: 'Kebocoran Pipa Air',
        location: 'HQ Tower A, Lantai 4 (Toilet Pria)',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 22),
        status: ReportStatus.rejected,
      ),
      ReportModel(
        id: '#REP-8475',
        priority: 'STANDARD',
        title: 'Kebocoran Pipa Air',
        location: 'HQ Tower A, Lantai 4 (Toilet Pria)',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 18),
        status: ReportStatus.pending,
      ),
      ReportModel(
        id: '#REP-8412',
        priority: 'URGENT',
        title: 'Kebocoran Pipa Air',
        location: 'HQ Tower A, Lantai 4 (Toilet Pria)',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 10),
        status: ReportStatus.resolved,
      ),
      ReportModel(
        id: '#REP-8408',
        priority: 'URGENT',
        title: 'Kebocoran Pipa Air',
        location: 'HQ Tower A, Lantai 4 (Toilet Pria)',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 8),
        status: ReportStatus.rejected,
      ),
    ];

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

  void logout() {
    Get.offAllNamed(Routes.LOGIN);
  }

  void openReport(ReportModel report) {
    Get.snackbar('Detail', 'Open ${report.id}');
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
}
