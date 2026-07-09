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

  HomeReport({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.priority,
    required String status,
    bool hasCollaboration = false,
  }) : status = status.obs,
       hasCollaboration = hasCollaboration.obs;
}

class ObHomeController extends GetxController {
  final name = 'OB'.obs;

  // List of Daily Tasks
  final dailyTasks = <DailyTask>[].obs;

  // List of Reports
  final reports = <HomeReport>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _loadDummyData();
  }

  void _loadUser() {
    if (!Get.isRegistered<AuthService>()) return;

    final user = Get.find<AuthService>().user.value;
    final displayName = user?['username'] ?? user?['name'] ?? user?['email'];
    if (displayName != null && displayName.toString().trim().isNotEmpty) {
      name.value = displayName.toString();
    }
  }

  void _loadDummyData() {
    dailyTasks.value = [
      DailyTask(
        title: 'Mengepel & Menyapu',
        location: 'Membersihkan seluruh lantai area kerja dan koridor',
        status: 'resolved',
      ),
      DailyTask(
        title: 'Dusting (Mengelap Debu)',
        location: 'Mengelap meja kerja, meja meeting, kursi, rak buku, dan ambang jendela.',
        status: 'pending',
      ),
    ];

    reports.value = [
      HomeReport(
        id: '#REP-01',
        title: 'Kebocoran Pipa Air',
        location: 'HO Tower A, Lantai 4 (Toilet Pria)',
        description:
            'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        priority: 'URGENT',
        status: 'Selesai',
      ),
      HomeReport(
        id: '#REP-02',
        title: 'Kebocoran Pipa Air',
        location: 'HO Tower A, Lantai 4 (Toilet Pria)',
        description:
            'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        priority: 'URGENT',
        status: 'Ditolak',
      ),
      HomeReport(
        id: '#REP-03',
        title: 'Kebocoran Pipa Air',
        location: 'HO Tower A, Lantai 4 (Toilet Pria)',
        description:
            'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage',
        priority: 'STANDARD',
        status: 'Belum Diproses',
      ),
    ];
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
}
