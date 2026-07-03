import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

/// ================= MODEL =================
class ReportModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final ReportStatus status;

  ReportModel({
    required this.id,
    required this.title,
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
        return 'In Progress';
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.rejected:
        return 'Rejected';
      case ReportStatus.resolved:
        return 'Resolved';
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
        title: 'HVAC Leak in Sector 4',
        description: 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        date: DateTime(2023, 10, 24),
        status: ReportStatus.inProgress,
      ),
      ReportModel(
        id: '#REP-8490',
        title: 'Broken Entry Door Lock',
        description: 'The electronic strike on the north entrance is failing to engage. Security concern.',
        date: DateTime(2023, 10, 22),
        status: ReportStatus.pending,
      ),
      ReportModel(
        id: '#REP-8475',
        title: 'Flickering Lights in Breakroom',
        description: 'Fluorescent tubes in the main staff breakroom are flickering constantly causing headaches.',
        date: DateTime(2023, 10, 18),
        status: ReportStatus.rejected,
      ),
      ReportModel(
        id: '#REP-8412',
        title: 'Restroom Sink Clog',
        description: "Men's restroom sink on floor 2 is completely blocked and overflowing slightly.",
        date: DateTime(2023, 10, 10),
        status: ReportStatus.resolved,
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
    Get.offNamed(Routes.OB_HOME);
  }

  void createReport() {
    Get.snackbar('Action', 'Create Report');
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
            r.title.toLowerCase().contains(searchQuery) ||
            r.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    filteredReports.value = result;
  }
}