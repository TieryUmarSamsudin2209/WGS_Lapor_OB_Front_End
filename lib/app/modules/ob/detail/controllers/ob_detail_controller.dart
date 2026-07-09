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
      reportPhotos.assignAll(activeReport!.photos);
      isNeedHelp.value = activeReport!.hasCollaboration.value;

      // Map status values to appropriate page state
      final currentStatus = activeReport!.status.value;
      if (currentStatus == 'Sedang Diproses') {
        pageState.value = 'working';
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
      Get.snackbar('Error', 'Gagal mengambil laporan');
      return;
    }

    pageState.value = 'working';
    isDetailExpanded.value = false;
    activeReport?.status.value = 'Sedang Diproses';
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
      Get.snackbar('Error', 'Gagal menyelesaikan laporan');
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
      Get.snackbar('Error', 'Gagal menolak laporan');
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

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
