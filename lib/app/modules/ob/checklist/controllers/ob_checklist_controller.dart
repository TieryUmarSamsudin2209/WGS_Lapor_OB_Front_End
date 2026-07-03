import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_pages.dart';

/// ==================== MODELS ====================

// status: 'resolved' | 'pending' | 'todo'
class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final RxString status;
  final RxString note;
  final RxList<String> photos;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required String status,
    String note = '',
  })  : status = status.obs,
        note = note.obs,
        photos = <String>[].obs;
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
  final ImagePicker _picker = ImagePicker();

  // Temporary controller for note text field inside popup
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
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

  /// Set status directly from popup
  void setItemStatus(ChecklistItem item, String newStatus) {
    item.status.value = newStatus;
    sections.refresh();
  }

  /// Save note from popup
  void saveNote(ChecklistItem item) {
    item.note.value = noteController.text;
  }

  /// Pick photo for a checklist item
  Future<void> pickItemPhoto(ChecklistItem item, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        if (item.photos.length < 3) {
          item.photos.add(image.path);
        } else {
          Get.snackbar('Batas Maksimal', 'Maksimal 3 foto per item.');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil foto: $e');
    }
  }

  /// Remove photo from item
  void removeItemPhoto(ChecklistItem item, int index) {
    item.photos.removeAt(index);
  }

  /// Navigation
  void goHome() => Get.offAllNamed(Routes.OB_HOME);
  void goProfile() => Get.offAllNamed(Routes.OB_PROFIL);
}
