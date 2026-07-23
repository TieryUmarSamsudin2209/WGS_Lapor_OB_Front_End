import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_pages.dart';
import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/checklist_translation_key.dart';
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
  final adHocTasks = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Tab state
  final activeTab = 'tugas_harian'.obs; // 'tugas' or 'tugas_harian'
  final penugasanText = ''.obs;

  // Filter state
  final searchQuery = ''.obs;
  final selectedLokasiId = RxnString();
  final selectedLantaiId = RxnString();
  final selectedStatus = RxnString();

  // Temporary controller for note text field inside popup
  final noteController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _fetchUserProfile();
    loadAllTasks();
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  int get completedCountToday {
    final adHocCompleted = adHocTasks.where((t) => t['status'] == 'SELESAI').length;
    final dailyCompleted = sections.expand((s) => s.items).where((item) => item.status.value == 'resolved').length;
    return adHocCompleted + dailyCompleted;
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      if (profile != null && profile['success'] == true) {
        final userData = profile['data']?['user'];
        if (userData != null) {
          penugasanText.value = userData['penugasan']?.toString() ?? 'Gedung A - Lantai 1 & 2';
        }
      }
    } catch (_) {
      penugasanText.value = 'Gedung A - Lantai 1 & 2';
    }
  }

  Future<void> loadAdHocTasks() async {
    await loadAllTasks();
  }

  Future<void> loadChecklist() async {
    await loadAllTasks();
  }

  bool _isRoutineTask(Map<String, dynamic> task) {
    final type = (task['jenis_tugas'] ??
            task['tipe_tugas'] ??
            task['tipe'] ??
            task['jenis'] ??
            task['type'] ??
            task['kategori'] ??
            task['category'] ??
            '')
        .toString()
        .toLowerCase()
        .trim();

    final routineVal = task['is_routine'] ?? task['isRoutine'];
    if (routineVal is bool) {
      if (routineVal) return true;
    } else if (routineVal is num) {
      if (routineVal == 1) return true;
    } else if (routineVal is String) {
      final v = routineVal.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'ya') return true;
    }

    if (type.contains('tidak rutin') ||
        type.contains('tidak_rutin') ||
        type == 'non_rutin' ||
        type == 'non-rutin' ||
        type == 'non rutin' ||
        type == 'tidak') {
      return false;
    }
    if (type.contains('rutin') || type.contains('routine') || type == 'harian') {
      return true;
    }

    final name = (task['nama_tugas'] ?? task['title'] ?? '').toString().toLowerCase();
    if (name.contains('rutin') && !name.contains('tidak rutin')) {
      return true;
    }

    return false;
  }

  Future<void> loadAllTasks() async {
    isLoading.value = true;
    
    try {
      // 1. Fetch Daily Checklist (Rutin)
      final checklistRes = await _authService.getDailyChecklist(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        lokasiId: selectedLokasiId.value,
        lantaiId: selectedLantaiId.value,
        status: selectedStatus.value,
      );
      final checklistItems = _extractChecklistItems(checklistRes);
      final routineSections = _sectionsFromApi(checklistItems);
      
      // 2. Fetch Tasks from /api/ob/tugas
      final tasksRes = await _authService.getObTugas();
      final List<ChecklistSection> apiRoutineSections = [];
      final List<Map<String, dynamic>> nonRoutineTasks = [];
      
      if (tasksRes != null && tasksRes['success'] == true) {
        final list = tasksRes['data'] as List?;
        if (list != null) {
          final allTasks = list.map((e) => Map<String, dynamic>.from(e)).toList();
          
          for (final task in allTasks) {
            if (_isRoutineTask(task)) {
              final item = ChecklistItem(
                id: task['id']?.toString() ?? '',
                title: task['nama_tugas']?.toString() ?? task['title']?.toString() ?? 'Tugas Rutin',
                description: task['catatan']?.toString() ?? task['deskripsi']?.toString() ?? '-',
                status: _statusFromApi(task['status']?.toString() ?? 'todo'),
                note: task['catatan']?.toString() ?? '',
              );
              
              final sectionTitle = task['lokasi']?.toString() ?? 'Tugas Rutin';
              
              var existingSection = apiRoutineSections.firstWhereOrNull((s) => s.title == sectionTitle);
              if (existingSection == null) {
                existingSection = ChecklistSection(title: sectionTitle, items: []);
                apiRoutineSections.add(existingSection);
              }
              existingSection.items.add(item);
            } else {
              nonRoutineTasks.add(task);
            }
          }
        }
      }
      
      sections.value = [...routineSections, ...apiRoutineSections];
      adHocTasks.value = nonRoutineTasks;
      
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> completeAdHocTask(String tugasId, String currentStatus) async {
    try {
      isLoading.value = true;
      if (currentStatus == 'BELUM_DIKERJAKAN') {
        final claimRes = await _authService.claimObTugas(tugasId);
        if (claimRes == null || claimRes['success'] != true) {
          _showErrorAlert('Gagal mengklaim tugas.'.tr);
          return false;
        }
      }

      final selesaiRes = await _authService.selesaiObTugas(tugasId);
      if (selesaiRes != null && selesaiRes['success'] == true) {
        await loadAllTasks();
        return true;
      } else {
        _showErrorAlert('Gagal menyelesaikan tugas.'.tr);
        return false;
      }
    } catch (e) {
      debugPrint('Error completing ad-hoc task: $e');
      _showErrorAlert('Terjadi kesalahan.'.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filters and reload checklist from API
  void filterChecklist({
    String? search,
    String? lokasiId,
    String? lantaiId,
    String? status,
  }) {
    if (search != null) searchQuery.value = search;
    if (lokasiId != null) selectedLokasiId.value = lokasiId.isEmpty ? null : lokasiId;
    if (lantaiId != null) selectedLantaiId.value = lantaiId.isEmpty ? null : lantaiId;
    if (status != null) selectedStatus.value = status.isEmpty ? null : status;
    loadChecklist();
  }

  /// Reset all filters
  void resetFilters() {
    searchQuery.value = '';
    selectedLokasiId.value = null;
    selectedLantaiId.value = null;
    selectedStatus.value = null;
    loadChecklist();
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
      return 'Catatan dan bukti foto wajib diisi.'.tr;
    }
    if (isNoteEmpty) {
      return 'Catatan wajib diisi.'.tr;
    }
    if (isPhotoEmpty) {
      return 'Bukti foto wajib diisi.'.tr;
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
      final sectionTitle = checklistTranslationKey(
        _firstValueFromSources([item, detail], [
              'section',
              'section_name',
              'kategori',
              'category',
              'area',
              'ruangan',
              'lokasi',
              'location',
            ]) ??
            'Checklist Harian',
      );

      groupedItems.putIfAbsent(sectionTitle, () => []).add(
            ChecklistItem(
              id: _firstValueFromSources([item, detail], [
                    'id',
                    'checklist_id',
                    'checklist_harian_id',
                    'uuid',
                  ]) ??
                  '',
              title: checklistTranslationKey(
                _firstValueFromSources([item, detail], [
                      'title',
                      'judul',
                      'nama',
                      'nama_checklist',
                      'nama_tugas',
                      'kegiatan',
                      'task',
                    ]) ??
                    'Checklist',
              ),
              description: checklistTranslationKey(
                _firstValueFromSources([item, detail], [
                      'description',
                      'deskripsi',
                      'keterangan',
                      'catatan',
                      'detail',
                    ]) ??
                    '-',
              ),
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
          _showErrorAlert('Maksimal 3 foto per item.'.tr);
        }
      }
    } catch (_) {
      _showErrorAlert('Gagal mengambil foto. Silakan coba lagi.'.tr);
    }
  }

  /// Remove photo from item
  void removeItemPhoto(ChecklistItem item, int index) {
    try {
      item.photos.removeAt(index);
    } catch (_) {
      _showErrorAlert('Gagal menghapus foto. Silakan coba lagi.'.tr);
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
