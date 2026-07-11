import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/controllers/profile_controllers.dart';
import '../../../shared/services/auth_service.dart';

class ReportOption {
  const ReportOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ReportController extends GetxController {
  static const _fallbackCategories = [
    ReportOption(
      id: 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      label: 'Kebersihan',
    ),
    ReportOption(
      id: 'd2597de5-120f-47b0-878a-83a46c47db34',
      label: 'Pengecekan',
    ),
    ReportOption(
      id: '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      label: 'Peralatan',
    ),
  ];

  static const _fallbackFloors = [
    ReportOption(
      id: '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      label: 'Gedung A - Kantor Pusat - Lantai 1',
    ),
    ReportOption(
      id: '7249c72a-642d-4ceb-afbe-61396587e37e',
      label: 'Gedung A - Kantor Pusat - Lantai 2',
    ),
    ReportOption(
      id: 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      label: 'Gedung A - Kantor Pusat - Lantai 3',
    ),
    ReportOption(
      id: '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      label: 'Gedung B - Kantor Cabang - Lantai 1',
    ),
    ReportOption(
      id: 'a75e15c3-5990-4936-af85-2848d12d1901',
      label: 'Gedung B - Kantor Cabang - Lantai 2',
    ),
  ];

  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);
  final ImagePicker _picker = ImagePicker();

  final categories = <ReportOption>[].obs;
  final floors = <ReportOption>[].obs;
  final selectedCategory = Rxn<ReportOption>();
  final selectedFloor = Rxn<ReportOption>();
  final priorityLevel = 'STANDARD'.obs;
  final floorRoomController = ''.obs;
  final descriptionController = ''.obs;
  final attachedPhotos = <String>[].obs;
  final isLoadingOptions = false.obs;
  final isSubmitting = false.obs;
  final submitFailureMessage = RxnString();

  List<ReportOption> get categoryOptions =>
      categories.isNotEmpty ? categories : _fallbackCategories;
  List<ReportOption> get floorOptions =>
      floors.isNotEmpty ? floors : _fallbackFloors;

  @override
  void onInit() {
    super.onInit();
    _applyInitialCategory(Get.arguments);
    loadReportOptions();
  }

  Future<void> loadReportOptions() async {
    if (!_authService.isLoggedIn) return;

    isLoadingOptions.value = true;
    try {
      final results = await Future.wait([
        _authService.getReportCategories(),
        _authService.getReportFloors(),
      ]);

      categories.assignAll(
        results[0]
            .map((item) => _optionFromApi(item, isFloor: false))
            .whereType<ReportOption>(),
      );
      floors.assignAll(
        results[1]
            .map((item) => _optionFromApi(item, isFloor: true))
            .whereType<ReportOption>(),
      );

      _replaceSelectionWithApiOption(selectedCategory, categoryOptions);
      _replaceSelectionWithApiOption(selectedFloor, floorOptions);
    } finally {
      isLoadingOptions.value = false;
    }
  }

  void setCategoryById(String? categoryId) {
    selectedCategory.value = _optionById(categoryOptions, categoryId);
  }

  void setFloorById(String? floorId) {
    selectedFloor.value = _optionById(floorOptions, floorId);
  }

  void setPriority(String priority) {
    priorityLevel.value = priority;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 70);

      if (image != null) {
        if (attachedPhotos.length < 3) {
          attachedPhotos.add(image.path);
        } else {
          Get.snackbar(
            'Batas Maksimal'.tr,
            'Anda hanya dapat mengunggah maksimal 3 foto.'.tr,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil foto: @error'.trParams({'error': '$e'}));
    }
  }

  void removePhoto(int index) {
    attachedPhotos.removeAt(index);
  }

  Future<bool> submitReport() async {
    submitFailureMessage.value = null;

    final category = selectedCategory.value;
    final floor = selectedFloor.value;
    final description = descriptionController.value.trim();
    final locationDetail = floorRoomController.value.trim();

    if (!_authService.isLoggedIn) {
      Get.snackbar(
        'Sesi tidak ditemukan'.tr,
        'Silakan login kembali sebelum mengirim laporan.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (category == null) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap pilih kategori masalah terlebih dahulu.'.tr,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    if (floor == null) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap pilih lokasi gedung terlebih dahulu.'.tr,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    if (description.isEmpty) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap isi deskripsi masalah terlebih dahulu.'.tr,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    if (attachedPhotos.isEmpty) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap unggah minimal 1 foto bukti.'.tr,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final completeDescription = [
        description,
        if (locationDetail.isNotEmpty)
          'Lokasi detail: @location'.trParams({'location': locationDetail}),
      ].join('\n\n');

      final response = await _authService.createEmployeeReport(
        floorId: floor.id,
        categoryId: category.id,
        description: completeDescription,
        priority: priorityLevel.value,
        photoPaths: attachedPhotos.toList(),
      );

      if (response != null) {
        if (Get.isRegistered<ProfileController>()) {
          await Get.find<ProfileController>().loadProfile();
        }
        return true;
      }

      submitFailureMessage.value =
          _authService.lastRequestError ??
          'Laporan belum terkirim. Periksa koneksi, sesi login, atau data kategori/lokasi.'.tr;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    selectedCategory.value = null;
    selectedFloor.value = null;
    priorityLevel.value = 'STANDARD';
    floorRoomController.value = '';
    descriptionController.value = '';
    attachedPhotos.clear();
  }

  void _applyInitialCategory(Object? arguments) {
    if (arguments is! String || arguments.trim().isEmpty) return;

    final category = arguments.trim();
    selectedCategory.value =
        _fallbackCategories.firstWhereOrNull(
          (option) => option.label.toLowerCase() == category.toLowerCase(),
        ) ??
        ReportOption(id: category, label: category);
  }

  ReportOption? _optionFromApi(
    Map<String, dynamic> item, {
    required bool isFloor,
  }) {
    final id = _firstText(
      item,
      isFloor
          ? const ['id', 'lantai_id', 'floor_id', 'uuid', 'value']
          : const ['id', 'kategori_id', 'category_id', 'uuid', 'value'],
    );

    final label = _firstText(
      item,
      isFloor
          ? const ['nama_lantai', 'lantai', 'nama', 'name', 'label', 'title']
          : const [
              'nama_kategori',
              'kategori',
              'nama',
              'name',
              'label',
              'title',
            ],
    );

    if (id == null || label == null) return null;

    final building = isFloor
        ? _firstText(item, const ['gedung', 'nama_gedung', 'building'])
        : null;
    final displayLabel = building != null && !label.contains(building)
        ? '$building - $label'
        : label;

    return ReportOption(id: id, label: displayLabel);
  }

  ReportOption? _optionById(List<ReportOption> options, String? id) {
    if (id == null) return null;
    return options.firstWhereOrNull((option) => option.id == id);
  }

  void _replaceSelectionWithApiOption(
    Rxn<ReportOption> selected,
    List<ReportOption> options,
  ) {
    final current = selected.value;
    if (current == null) return;

    final replacement = options.firstWhereOrNull(
      (option) =>
          option.id == current.id ||
          option.label.toLowerCase() == current.label.toLowerCase(),
    );

    if (replacement != null) selected.value = replacement;
  }

  String? _firstText(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
