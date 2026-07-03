import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

/// ==================== MODELS ====================

// status: 'resolved' | 'pending' | 'todo'
class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final RxString status;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required String status,
  }) : status = status.obs;
}

class ChecklistSection {
  final String title;
  final List<ChecklistItem> items;

  ChecklistSection({required this.title, required this.items});
}

/// ==================== CONTROLLER ====================

class ObChecklistController extends GetxController {
  final sections = <ChecklistSection>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    isLoading.value = true;

    sections.value = [
      ChecklistSection(
        title: 'Area kerja utama & Koridor',
        items: [
          ChecklistItem(
            id: 'CK-01',
            title: 'Mengepel & Menyapu',
            description: 'Membersihkan seluruh lantai area kerja dan koridor.',
            status: 'resolved',
          ),
          ChecklistItem(
            id: 'CK-02',
            title: 'Dusting (Mengelap Debu)',
            description:
                'Mengelap meja kerja, meja meeting, kursi, rak buku, dan ambang jendela.',
            status: 'pending',
          ),
          ChecklistItem(
            id: 'CK-03',
            title: 'Restocking (Isi Ulang)',
            description:
                'Memastikan sabun cuci tangan, tisu toilet, dan tisu wastafel selalu terisi penuh.',
            status: 'todo',
          ),
        ],
      ),
      ChecklistSection(
        title: 'Area Toilet (Krusial & Harus Dicek Berkala)',
        items: [
          ChecklistItem(
            id: 'CK-04',
            title: 'Pembersihan Area Basah',
            description: 'Lantai, kloset/urinal, dan wastafel.',
            status: 'resolved',
          ),
          ChecklistItem(
            id: 'CK-05',
            title: 'Cek Drainase',
            description:
                'Memastikan tidak ada sumbatan pada saluran air dan air mengalir dengan lancar.',
            status: 'resolved',
          ),
        ],
      ),
      ChecklistSection(
        title: 'Manajemen Sampah & Utilitas (Fasilitas)',
        items: [
          ChecklistItem(
            id: 'CK-06',
            title: 'Pengosongan Tempat Sampah',
            description: 'Mengosongkan seluruh tempat sampah.',
            status: 'resolved',
          ),
          ChecklistItem(
            id: 'CK-07',
            title: 'Pengecekan Lampu & AC',
            description: 'Matikan saat pulang.',
            status: 'resolved',
          ),
          ChecklistItem(
            id: 'CK-08',
            title: 'Menyiram Tanaman',
            description:
                'Menyiram tanaman hias yang ada di dalam maupun di depan kantor.',
            status: 'resolved',
          ),
        ],
      ),
    ];

    isLoading.value = false;
  }

  /// Cycle: resolved → pending → todo → resolved
  void toggleItem(ChecklistItem item) {
    switch (item.status.value) {
      case 'resolved':
        item.status.value = 'pending';
        break;
      case 'pending':
        item.status.value = 'todo';
        break;
      default:
        item.status.value = 'resolved';
    }
    sections.refresh();
  }

  /// Navigation
  void goHome() => Get.offAllNamed(Routes.OB_HOME);
  void goProfile() => Get.offAllNamed(Routes.OB_PROFIL);
}
