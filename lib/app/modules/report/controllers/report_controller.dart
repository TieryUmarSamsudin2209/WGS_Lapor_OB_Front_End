import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/controllers/profile_controllers.dart';
import '../../../shared/services/auth_service.dart';

class ReportOption {
  const ReportOption({required this.id, required this.label, this.parentId});

  final String id;
  final String label;
  final String? parentId;
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

  static const _fallbackLocations = [
    ReportOption(
      id: '033f0941-8378-42e3-af2c-29cf83ab8e11',
      label: 'Gedung A - Kantor Pusat',
    ),
    ReportOption(
      id: '6c58477b-a345-4175-893a-58472165b899',
      label: 'Gedung B - Kantor Cabang',
    ),
  ];

  static const _fallbackFloors = [
    ReportOption(
      id: '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      label: 'Gedung A - Kantor Pusat - Lantai 1',
      parentId: '033f0941-8378-42e3-af2c-29cf83ab8e11',
    ),
    ReportOption(
      id: '7249c72a-642d-4ceb-afbe-61396587e37e',
      label: 'Gedung A - Kantor Pusat - Lantai 2',
      parentId: '033f0941-8378-42e3-af2c-29cf83ab8e11',
    ),
    ReportOption(
      id: 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      label: 'Gedung A - Kantor Pusat - Lantai 3',
      parentId: '033f0941-8378-42e3-af2c-29cf83ab8e11',
    ),
    ReportOption(
      id: '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      label: 'Gedung B - Kantor Cabang - Lantai 1',
      parentId: '6c58477b-a345-4175-893a-58472165b899',
    ),
    ReportOption(
      id: 'a75e15c3-5990-4936-af85-2848d12d1901',
      label: 'Gedung B - Kantor Cabang - Lantai 2',
      parentId: '6c58477b-a345-4175-893a-58472165b899',
    ),
  ];

  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);
  final ImagePicker _picker = ImagePicker();

  final categories = <ReportOption>[].obs;
  final locations = <ReportOption>[].obs;
  final floors = <ReportOption>[].obs;
  final rooms = <ReportOption>[].obs;
  
  final selectedCategory = Rxn<ReportOption>();
  final selectedLocation = Rxn<ReportOption>();
  final selectedFloor = Rxn<ReportOption>();
  final selectedRoom = Rxn<ReportOption>();
  
  final priorityLevel = 'STANDARD'.obs;
  final descriptionController = ''.obs;
  final attachedPhotos = <String>[].obs;
  final isAnonymous = false.obs;
  
  final isLoadingOptions = false.obs;
  final isSubmitting = false.obs;
  final submitFailureMessage = RxnString();

  List<ReportOption> get categoryOptions =>
      categories.isNotEmpty
      ? categories
      : _authService.isOfflineMode
      ? _fallbackCategories
      : const [];

  List<ReportOption> get locationOptions =>
      locations.isNotEmpty
      ? locations
      : _authService.isOfflineMode
      ? _fallbackLocations
      : const [];

  List<ReportOption> get floorOptions {
    final location = selectedLocation.value;
    if (floors.isEmpty && !_authService.isOfflineMode) return const [];
    final activeFloors = floors.isNotEmpty ? floors : _fallbackFloors;
    if (location == null) return const [];

    final locationId = location.id;
    final locationLabel = location.label.toLowerCase();

    return activeFloors.where((option) {
      if (option.parentId == locationId) return true;
      if (option.parentId == null) {
        final floorLabel = option.label.toLowerCase();
        if (floorLabel.contains(locationLabel)) return true;
        if (locationLabel.contains('gedung a') && floorLabel.contains('gedung a')) return true;
        if (locationLabel.contains('gedung b') && floorLabel.contains('gedung b')) return true;
      }
      return false;
    }).toList();
  }

  List<ReportOption> get roomOptions {
    final floorId = selectedFloor.value?.id;
    if (rooms.isEmpty || floorId == null) return const [];

    final filtered = rooms
        .where((option) => option.parentId == null || option.parentId == floorId)
        .toList();
    return filtered;
  }

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
        _authService.getReportRooms(),
        _authService.getReportLocations(),
      ]);

      categories.assignAll(_optionsFromApi(results[0], isFloor: false));
      floors.assignAll(_optionsFromApi(results[1], isFloor: true));
      rooms.assignAll(_roomOptionsFromApi(results[2]));
      locations.assignAll(_optionsFromApi(results[3], isFloor: false));

      // FALLBACK: If locations list from API is empty but we have floors, extract unique locations from floors!
      if (locations.isEmpty && floors.isNotEmpty) {
        final Map<String, ReportOption> extracted = {};
        var fallbackIdCounter = 1;
        for (final floor in floors) {
          final locId = floor.parentId ?? 'loc-fallback-$fallbackIdCounter';
          if (floor.parentId == null) {
            fallbackIdCounter++;
          }
          
          // Floor label is like "Gedung A - Kantor Pusat - Lantai 1"
          final parts = floor.label.split(' - ');
          final locLabel = parts.length > 1
              ? parts.sublist(0, parts.length - 1).join(' - ')
              : parts[0];
              
          extracted.putIfAbsent(
            locLabel.toLowerCase(),
            () => ReportOption(id: locId, label: locLabel),
          );
        }
        if (extracted.isNotEmpty) {
          locations.assignAll(extracted.values);
        }
      }

      _replaceSelectionWithApiOption(selectedCategory, categoryOptions);
      _replaceSelectionWithApiOption(selectedLocation, locationOptions);
      _replaceSelectionWithApiOption(selectedFloor, floorOptions);
      _replaceSelectionWithApiOption(selectedRoom, roomOptions);
    } finally {
      isLoadingOptions.value = false;
    }
  }

  void setCategoryById(String? categoryId) {
    selectedCategory.value = _optionById(categoryOptions, categoryId);
  }

  void setLocationById(String? locationId) {
    selectedLocation.value = _optionById(locationOptions, locationId);
    
    final floor = selectedFloor.value;
    if (floor != null) {
      final matchesLocation = floor.parentId == locationId || 
          (floor.parentId == null && floor.label.toLowerCase().contains(selectedLocation.value?.label.toLowerCase() ?? ''));
      if (!matchesLocation) {
        selectedFloor.value = null;
        selectedRoom.value = null;
      }
    }
  }

  void setFloorById(String? floorId) {
    selectedFloor.value = _optionById(floors.isNotEmpty ? floors : _fallbackFloors, floorId);

    final room = selectedRoom.value;
    if (room?.parentId != null && room!.parentId != floorId) {
      selectedRoom.value = null;
    }
  }

  void setRoomById(String? roomId) {
    selectedRoom.value = _optionById(roomOptions, roomId);
  }

  void setPriority(String priority) {
    priorityLevel.value = priority;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 70);

      if (image != null) {
        if (attachedPhotos.length < 5) {
          attachedPhotos.add(image.path);
        } else {
          Get.snackbar(
            'Batas Maksimal'.tr,
            'Anda hanya dapat mengunggah maksimal 5 foto.'.tr,
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
    final location = selectedLocation.value;
    final floor = selectedFloor.value;
    final room = selectedRoom.value;
    final description = descriptionController.value.trim();

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

    if (location == null) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap pilih lokasi terlebih dahulu.'.tr,
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
        'Harap pilih lokasi lantai terlebih dahulu.'.tr,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }

    if (room == null) {
      Get.snackbar(
        'Peringatan'.tr,
        'Harap pilih ruangan terlebih dahulu.'.tr,
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
      final response = await _authService.createEmployeeReport(
        floorId: floor.id,
        roomId: room.id,
        categoryId: category.id,
        description: description,
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
          'Laporan belum terkirim. Periksa koneksi, sesi login, atau data kategori/lokasi/ruangan.'.tr;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    selectedCategory.value = null;
    selectedLocation.value = null;
    selectedFloor.value = null;
    selectedRoom.value = null;
    priorityLevel.value = 'STANDARD';
    descriptionController.value = '';
    attachedPhotos.clear();
    isAnonymous.value = false;
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

  String? _floorParentId(
    Map<String, dynamic> item,
    List<Map<String, dynamic>> sources,
  ) {
    return _firstTextFromSources(sources, const [
      'lokasi_id',
      'lokasiId',
      'location_id',
      'locationId',
      'gedung_id',
      'gedungId',
      'building_id',
      'buildingId',
    ]);
  }

  ReportOption? _optionFromApi(
    Map<String, dynamic> item, {
    required bool isFloor,
  }) {
    final sources = _optionSources(item, isFloor: isFloor);
    final id = _firstTextFromSources(
      sources,
      isFloor
          ? const [
              'id',
              'lantai_id',
              'lantaiId',
              'floor_id',
              'floorId',
              'id_lantai',
              'idLantai',
              'uuid',
              'value',
              'key',
            ]
          : const [
              'id',
              'kategori_id',
              'kategoriId',
              'category_id',
              'categoryId',
              'kategori_laporan_id',
              'kategoriLaporanId',
              'id_kategori',
              'idKategori',
              'uuid',
              'value',
              'key',
            ],
    );

    final label = _firstTextFromSources(
      sources,
      isFloor
          ? const [
              'nama_lantai',
              'namaLantai',
              'nomor_lantai',
              'nomorLantai',
              'lantai',
              'floor',
              'nama',
              'name',
              'label',
              'title',
              'lokasi',
              'location',
            ]
          : const [
              'nama_kategori_laporan',
              'namaKategoriLaporan',
              'nama_kategori',
              'namaKategori',
              'kategori_laporan',
              'kategoriLaporan',
              'kategori',
              'category',
              'nama',
              'name',
              'label',
              'title',
            ],
    );

    if (id == null || label == null) return null;

    final normalizedLabel = isFloor ? _floorLabel(label) : label;
    final building = isFloor ? _buildingLabel(sources) : null;
    final displayLabel =
        building != null && !normalizedLabel.contains(building)
        ? '$building - $normalizedLabel'
        : normalizedLabel;

    final parentId = isFloor ? _floorParentId(item, sources) : null;

    return ReportOption(id: id, label: displayLabel, parentId: parentId);
  }

  List<ReportOption> _optionsFromApi(
    Iterable<Map<String, dynamic>> items, {
    required bool isFloor,
  }) {
    final options = <ReportOption>[];
    final seenIds = <String>{};

    for (final item in items) {
      final option = _optionFromApi(item, isFloor: isFloor);
      if (option == null || !seenIds.add(option.id)) continue;
      options.add(option);
    }

    return options;
  }

  List<ReportOption> _roomOptionsFromApi(
    Iterable<Map<String, dynamic>> items,
  ) {
    final options = <ReportOption>[];
    final seenIds = <String>{};

    for (final item in items) {
      final option = _roomOptionFromApi(item);
      if (option == null || !seenIds.add(option.id)) continue;
      options.add(option);
    }

    return options;
  }

  ReportOption? _roomOptionFromApi(Map<String, dynamic> item) {
    final sources = _roomSources(item);
    final id = _firstTextFromSources(sources, const [
      'id',
      'ruangan_id',
      'ruanganId',
      'room_id',
      'roomId',
      'id_ruangan',
      'idRuangan',
      'uuid',
      'value',
      'key',
    ]);
    final label = _firstTextFromSources(sources, const [
      'nama_ruangan',
      'namaRuangan',
      'ruangan',
      'room',
      'lokasi',
      'location',
      'kode_ruangan',
      'kodeRuangan',
      'nama',
      'name',
      'label',
      'title',
    ]);

    if (id == null || label == null) return null;

    return ReportOption(
      id: id,
      label: label,
      parentId: _roomParentId(item, sources),
    );
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
    if (replacement == null && options.isNotEmpty) selected.value = null;
  }

  List<Map<String, dynamic>> _optionSources(
    Map<String, dynamic> item, {
    required bool isFloor,
  }) {
    final nestedKeys = isFloor
        ? const [
            'lantai',
            'floor',
            'lokasi',
            'location',
            'gedung_lantai',
            'gedungLantai',
          ]
        : const [
            'kategori',
            'category',
            'kategori_laporan',
            'kategoriLaporan',
          ];

    return [
      item,
      for (final key in nestedKeys)
        if (_asMap(item[key]) != null) _asMap(item[key])!,
    ];
  }

  List<Map<String, dynamic>> _roomSources(Map<String, dynamic> item) {
    return [
      item,
      for (final key in const ['ruangan', 'room', 'lokasi', 'location'])
        if (_asMap(item[key]) != null) _asMap(item[key])!,
    ];
  }

  String? _roomParentId(
    Map<String, dynamic> item,
    List<Map<String, dynamic>> sources,
  ) {
    final directParent = _firstTextFromSources(sources, const [
      'lantai_id',
      'lantaiId',
      'floor_id',
      'floorId',
      'id_lantai',
      'idLantai',
    ]);
    if (directParent != null) return directParent;

    for (final source in [item, ...sources]) {
      for (final key in const ['lantai', 'floor']) {
        final nested = _asMap(source[key]);
        if (nested == null) continue;

        final nestedId = _firstText(nested, const [
          'id',
          'uuid',
          'lantai_id',
          'lantaiId',
          'floor_id',
          'floorId',
        ]);
        if (nestedId != null) return nestedId;
      }
    }

    return null;
  }

  String? _firstTextFromSources(
    List<Map<String, dynamic>> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _firstText(source, keys);
      if (value != null) return value;
    }
    return null;
  }

  String? _firstText(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;

      if (value is Map) {
        final nestedValue = _firstText(_asMap(value) ?? const {}, const [
          'nama_kategori_laporan',
          'nama_kategori',
          'nama_lantai',
          'nomor_lantai',
          'nama_gedung',
          'nama',
          'name',
          'label',
          'title',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? _buildingLabel(List<Map<String, dynamic>> sources) {
    return _firstTextFromSources(sources, const [
      'nama_gedung',
      'namaGedung',
      'gedung',
      'building',
      'building_name',
      'buildingName',
      'nama_bangunan',
      'namaBangunan',
    ]);
  }

  String _floorLabel(String label) {
    final value = label.trim();
    if (RegExp(r'^\d+$').hasMatch(value)) return 'Lantai $value';
    return value;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}
