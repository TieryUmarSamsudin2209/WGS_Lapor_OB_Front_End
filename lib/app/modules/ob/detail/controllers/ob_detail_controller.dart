import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObDetailController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  HomeReport? activeReport;

  var pageState = 'initial'.obs;
  var isDetailExpanded = true.obs;
  var isNeedHelp = false.obs;
  var isSubmitting = false.obs;

  // Rx variables to make view dynamically change according to report
  var title = 'Kebocoran Pipa Air'.obs;
  var description = 'Pipa di bawah wastafel bocor parah...'.obs;
  var priority = 'URGENT'.obs;
  var location = '-'.obs;
  var reporterName = '-'.obs;
  var categoryName = '-'.obs;
  final takenByName = RxnString();
  final reportPhotos = <String>[].obs;

  final noteController = TextEditingController();
  final actionPhotos = <String>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HomeReport) {
      activeReport = Get.arguments as HomeReport;
      title.value = activeReport!.title;
      description.value = activeReport!.description;
      priority.value = activeReport!.priority;
      location.value = activeReport!.location;
      reporterName.value = activeReport!.reporterName ?? '-';
      categoryName.value = activeReport!.categoryName ?? activeReport!.title;
      takenByName.value = activeReport!.assignedObName;
      reportPhotos.assignAll(activeReport!.photos);
      isNeedHelp.value = activeReport!.hasCollaboration.value;

      // Map status values to appropriate page state
      final currentStatus = activeReport!.status.value;
      if (currentStatus == 'Sedang Diproses') {
        pageState.value = _isTakenByAnotherOb(activeReport!)
            ? 'taken'
            : 'working';
      } else if (currentStatus == 'Selesai' || currentStatus == 'Ditolak') {
        pageState.value = 'resolved'; // non-modifiable final states if needed
      } else {
        pageState.value = 'initial';
      }
    }
  }

  Future<void> setWorking() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error', 'ID laporan tidak ditemukan');
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.takeObReport(reportId);
    isSubmitting.value = false;

    if (response == null) {
      final message =
          _authService.lastRequestError ?? 'Gagal mengambil laporan';
      if (_looksLikeAlreadyTaken(message)) {
        pageState.value = 'taken';
        activeReport?.status.value = 'Sedang Diproses';
        takenByName.value =
            _takenByNameFromMessage(message) ?? takenByName.value ?? 'OB lain';
      }
      final ctx = Get.context;
      if (ctx != null) {
        await CustomAlert.show(
          ctx,
          isSuccess: false,
          description: message,
        );
      } else {
        Get.snackbar('Gagal', message);
      }
      return;
    }

    pageState.value = 'working';
    isDetailExpanded.value = false;
    activeReport?.status.value = 'Sedang Diproses';
    takenByName.value =
        _assignedObNameFromResponse(response) ?? _currentObName ?? 'Anda';

    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: _responseMessage(response) ?? 'Berhasil mengambil laporan.',
      );
    }
  }

  void setRejecting() {
    if (pageState.value == 'working') {
      pageState.value = 'rejecting';
      isDetailExpanded.value = false;
    }
  }

  void toggleNeedHelp() {
    isNeedHelp.value = !isNeedHelp.value;
    activeReport?.hasCollaboration.value = isNeedHelp.value;
  }

  // ── Selesaikan → alert berhasil lalu kembali ke screen sebelumnya ────────
  Future<void> completeReport() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    final note = noteController.text.trim();

    if (reportId == null) {
      Get.snackbar('Error', 'ID laporan tidak ditemukan');
      return;
    }
    if (note.isEmpty) {
      Get.snackbar('Catatan wajib diisi', 'Mohon isi catatan pekerjaan');
      return;
    }
    if (actionPhotos.isEmpty) {
      Get.snackbar('Foto wajib diisi', 'Mohon unggah bukti foto selesai');
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.submitObReportHistory(
      reportId: reportId,
      note: note,
      photoPaths: actionPhotos.toList(),
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message =
          _authService.lastRequestError ?? 'Gagal menyelesaikan laporan';
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message);
      } else {
        Get.snackbar('Error', message);
      }
      return;
    }

    activeReport?.status.value = 'Selesai';
    final ctx = Get.context;
    if (ctx != null) {
      CustomAlert.show(ctx, isSuccess: true);
    }
    Future.delayed(const Duration(milliseconds: 1800), () {
      Get.back(); // Tutup Dialog Alert
      Get.back(); // Kembali ke halaman sebelumnya (Home OB)
    });
  }

  // ── Tolak → alert gagal lalu kembali ke screen sebelumnya ─────────────────
  Future<void> confirmReject() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    final reason = noteController.text.trim();

    if (reportId == null) {
      Get.snackbar('Error', 'ID laporan tidak ditemukan');
      return;
    }
    if (reason.isEmpty) {
      Get.snackbar('Alasan wajib diisi', 'Mohon isi alasan menolak laporan');
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.rejectObReport(
      reportId: reportId,
      reason: reason,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ?? 'Gagal menolak laporan';
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message);
      } else {
        Get.snackbar('Error', message);
      }
      return;
    }

    activeReport?.status.value = 'Ditolak';
    final ctx = Get.context;
    if (ctx != null) {
      CustomAlert.show(ctx, isSuccess: false);
    }
    Future.delayed(const Duration(milliseconds: 1800), () {
      Get.back(); // Tutup Dialog Alert
      Get.back(); // Kembali ke halaman sebelumnya (Home OB)
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        if (actionPhotos.length < 3) {
          actionPhotos.add(image.path);
        } else {
          Get.snackbar('Batas Maksimal',
              'Anda hanya dapat mengunggah maksimal 3 foto.');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil foto: $e');
    }
  }

  void removePhoto(int index) {
    actionPhotos.removeAt(index);
  }

  void toggleDetailExpand() {
    isDetailExpanded.value = !isDetailExpanded.value;
  }

  String? get _activeReportId {
    final rawId = activeReport?.id.trim();
    if (rawId == null || rawId.isEmpty) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    return normalized.trim().isEmpty ? null : normalized.trim();
  }

  bool _isTakenByAnotherOb(HomeReport report) {
    final assignedId = report.assignedObId?.trim();
    if (assignedId != null && assignedId.isNotEmpty) {
      final currentIds = _currentObIds;
      return currentIds.isEmpty ||
          !currentIds.contains(_normalizeIdentity(assignedId));
    }

    final assignedName = report.assignedObName?.trim();
    if (assignedName != null && assignedName.isNotEmpty) {
      final currentName = _currentObName;
      if (currentName == null || currentName.trim().isEmpty) return true;
      return _normalizeIdentity(assignedName) != _normalizeIdentity(currentName);
    }

    return report.status.value == 'Sedang Diproses';
  }

  Set<String> get _currentObIds {
    final user = _authService.user.value ?? const <String, dynamic>{};
    return [
      'id',
      'user_id',
      'userId',
      'ob_id',
      'obId',
      'uuid',
    ].map((key) {
      return user[key]?.toString().trim();
    }).whereType<String>().where((value) {
      return value.isNotEmpty;
    }).map(_normalizeIdentity).toSet();
  }

  String? get _currentObName {
    final user = _authService.user.value ?? const <String, dynamic>{};
    return _firstText(user, const [
      'nama_lengkap',
      'nama',
      'name',
      'username',
      'email',
    ]);
  }

  String? _assignedObNameFromResponse(Map<String, dynamic> response) {
    return _firstTextFromSources([
      response,
      _asMap(response['data']),
      _asMap(response['laporan']),
      _asMap(response['report']),
    ], const [
      'nama_ob',
      'namaOb',
      'ob_name',
      'obName',
      'assigned_ob_name',
      'assignedObName',
      'taken_by_name',
      'takenByName',
      'diambil_oleh',
      'diambilOleh',
      'assigned_to',
      'assignedTo',
      'taken_by',
      'takenBy',
      'petugas',
      'petugas_ob',
      'ob',
    ]);
  }

  String? _responseMessage(Map<String, dynamic> response) {
    return _firstTextFromSources([
      response,
      _asMap(response['data']),
    ], const [
      'message',
      'pesan',
      'status',
      'detail',
    ]);
  }

  String? _firstTextFromSources(
    List<Map<String, dynamic>?> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _firstText(source, keys);
      if (value != null) return value;
    }
    return null;
  }

  String? _firstText(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;

    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;

      if (value is Map) {
        final nestedValue = _firstText(_asMap(value), const [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
          'label',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return null;
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  bool _looksLikeAlreadyTaken(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('sudah') &&
        (normalized.contains('ambil') || normalized.contains('taken'));
  }

  String? _takenByNameFromMessage(String message) {
    final match = RegExp(
      r'oleh\s+(.+?)(?:[.!?]|$)',
      caseSensitive: false,
    ).firstMatch(message);
    final name = match?.group(1)?.trim();
    return name == null || name.isEmpty ? null : name;
  }

  String _normalizeIdentity(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
