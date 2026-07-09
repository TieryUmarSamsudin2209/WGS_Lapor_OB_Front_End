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
    List<String> photos = const [],
  })  : status = status.obs,
        note = note.obs,
        photos = photos.obs;
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

    try {
      final response = await _authService.getDailyChecklist();
      final checklistItems = _extractChecklistItems(response);
      sections.value = _sectionsFromApi(checklistItems);
    } catch (_) {
      sections.clear();
    } finally {
      isLoading.value = false;
    }
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
    final nestedData = _asMap(data?['data']);

    for (final source in [nestedData, data, response]) {
      if (source == null) continue;
      for (final key in [
        'data',
        'checklist',
        'checklists',
        'checklist_harian',
        'daily_checklists',
        'items',
        'tasks',
        'tugas',
        'rows',
        'records',
        'results',
      ]) {
        final list = _asList(source[key]);
        if (list != null) return list;
      }
    }

    return const [];
  }

  List<ChecklistSection> _sectionsFromApi(List<dynamic> items) {
    final groupedItems = <String, List<ChecklistItem>>{};

    for (final rawItem in items.whereType<Map>()) {
      final item = _asMap(rawItem) ?? const {};
      final detail = _asMap(item['checklist']) ??
          _asMap(item['checklist_harian']) ??
          _asMap(item['tugas']) ??
          item;
      final photos = _photosFromApi(item);
      final sectionTitle = _firstValueFromSources([item, detail], [
            'section',
            'section_name',
            'kategori',
            'category',
            'area',
            'ruangan',
            'lokasi',
            'location',
          ]) ??
          'Checklist Harian';

      groupedItems.putIfAbsent(sectionTitle, () => []).add(
            ChecklistItem(
              id: _firstValueFromSources([item, detail], [
                    'id',
                    'checklist_id',
                    'checklist_harian_id',
                    'uuid',
                  ]) ??
                  '',
              title: _firstValueFromSources([item, detail], [
                    'title',
                    'judul',
                    'nama',
                    'nama_checklist',
                    'nama_tugas',
                    'kegiatan',
                    'task',
                  ]) ??
                  'Checklist',
              description: _firstValueFromSources([item, detail], [
                    'description',
                    'deskripsi',
                    'keterangan',
                    'catatan',
                    'detail',
                  ]) ??
                  '-',
              status: _statusFromApi(
                _firstValueFromSources([item, detail], [
                      'status',
                      'status_checklist',
                      'status_tugas',
                    ]) ??
                    'todo',
              ),
              note: _firstValueFromSources([item, detail], [
                    'catatan',
                    'note',
                    'notes',
                  ]) ??
                  '',
              photos: photos.isNotEmpty ? photos : _photosFromApi(detail),
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
      if (value is Map) {
        final nested = _asMap(value);
        final nestedValue = _firstValue(nested ?? const {}, [
          'nama',
          'name',
          'title',
          'judul',
          'label',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
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

  List<String> _photosFromApi(Map<String, dynamic> source) {
    for (final key in [
      'photos',
      'foto',
      'foto_checklist',
      'foto_selesai',
      'bukti_foto',
      'gambar',
      'images',
    ]) {
      final value = source[key];
      final list = _asList(value);
      if (list != null) {
        return list.map((item) => item.toString()).where((item) {
          return item.trim().isNotEmpty;
        }).toList();
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return [value.toString().trim()];
      }
    }
    return const [];
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
