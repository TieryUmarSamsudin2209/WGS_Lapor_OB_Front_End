import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_alert.dart';

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
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final sections = <ChecklistSection>[].obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Temporary controller for note text field inside popup
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadChecklist();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  Future<void> loadChecklist() async {
    isLoading.value = true;

    final response = await _authService.getDailyChecklist();
    final checklistItems = _extractChecklistItems(response);

    if (checklistItems.isNotEmpty) {
      sections.value = _sectionsFromApi(checklistItems);
      isLoading.value = false;
      return;
    }

    _loadDummyData();
    isLoading.value = false;
  }

  void _loadDummyData() {
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

  String? validateItemDetail(ChecklistItem item) {
    final isNoteEmpty = noteController.text.trim().isEmpty;
    final isPhotoEmpty = item.photos.isEmpty;

    if (isNoteEmpty && isPhotoEmpty) {
      return 'Catatan dan bukti foto wajib diisi.';
    }
    if (isNoteEmpty) {
      return 'Catatan wajib diisi.';
    }
    if (isPhotoEmpty) {
      return 'Bukti foto wajib diisi.';
    }

    return null;
  }

  void submitItemDetail(ChecklistItem item) {
    saveNote(item);
  }

  List<dynamic> _extractChecklistItems(Map<String, dynamic>? response) {
    final data = _asMap(response?['data']);
    return _asList(data?['data']) ??
        _asList(data?['checklist']) ??
        _asList(data?['checklists']) ??
        _asList(data?['items']) ??
        _asList(response?['data']) ??
        _asList(response?['checklist']) ??
        _asList(response?['checklists']) ??
        _asList(response?['items']) ??
        const [];
  }

  List<ChecklistSection> _sectionsFromApi(List<dynamic> items) {
    final groupedItems = <String, List<ChecklistItem>>{};

    for (final rawItem in items.whereType<Map>()) {
      final item = _asMap(rawItem) ?? const {};
      final sectionTitle = _firstValue(item, [
            'section',
            'kategori',
            'area',
            'ruangan',
            'lokasi',
          ]) ??
          'Checklist Harian';

      groupedItems.putIfAbsent(sectionTitle, () => []).add(
            ChecklistItem(
              id: _firstValue(item, ['id', 'checklist_id', 'uuid']) ?? '',
              title: _firstValue(item, [
                    'title',
                    'judul',
                    'nama',
                    'nama_checklist',
                    'kegiatan',
                  ]) ??
                  'Checklist',
              description: _firstValue(item, [
                    'description',
                    'deskripsi',
                    'keterangan',
                    'catatan',
                  ]) ??
                  '-',
              status: _statusFromApi(_firstValue(item, ['status']) ?? 'todo'),
              note: _firstValue(item, ['catatan', 'note']) ?? '',
            ),
          );
    }

    return groupedItems.entries
        .map((entry) => ChecklistSection(title: entry.key, items: entry.value))
        .toList();
  }

  String _statusFromApi(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('selesai') ||
        normalized.contains('resolved') ||
        normalized.contains('done')) {
      return 'resolved';
    }
    if (normalized.contains('pending') ||
        normalized.contains('proses') ||
        normalized.contains('progress')) {
      return 'pending';
    }
    return 'todo';
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
          _showErrorAlert('Maksimal 3 foto per item.');
        }
      }
    } catch (_) {
      _showErrorAlert('Gagal mengambil foto. Silakan coba lagi.');
    }
  }

  /// Remove photo from item
  void removeItemPhoto(ChecklistItem item, int index) {
    try {
      item.photos.removeAt(index);
    } catch (_) {
      _showErrorAlert('Gagal menghapus foto. Silakan coba lagi.');
    }
  }

  void _showErrorAlert(String description) {
    final alertContext = Get.overlayContext ?? Get.context;
    if (alertContext == null) return;

    var alertDismissed = false;
    CustomAlert.show(
      alertContext,
      isSuccess: false,
      description: description,
    ).whenComplete(() {
      alertDismissed = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!alertDismissed) {
        Get.back();
      }
    });
  }

  /// Navigation
  void goHome() => Get.offAllNamed(Routes.OB_HOME);
  void goProfile() => Get.offAllNamed(Routes.OB_PROFIL);
}
