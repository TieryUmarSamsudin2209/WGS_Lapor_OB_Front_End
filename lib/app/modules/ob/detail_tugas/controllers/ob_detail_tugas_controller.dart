import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collection/collection.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/report_translation_key.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../../../shared/widgets/ob_complete_report_dialog.dart';
import '../../home/controllers/ob_home_controller.dart';
import '../../checklist/controllers/ob_checklist_controller.dart';

class ObDetailTugasController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  HomeReport? activeReport;

  var pageState = 'working'.obs; // Go directly to working (form) state
  var isDetailExpanded = true.obs;
  var isSubmitting = false.obs;

  // Rx variables to make view dynamically change according to report
  var title = 'Tugas'.obs;
  var description = ''.obs;
  var priority = 'STANDARD'.obs;
  var location = '-'.obs;
  var baseLocation = '-'.obs;
  var reporterName = '-'.obs;
  var categoryName = '-'.obs;
  final reportPhotos = <String>[].obs;

  final noteController = TextEditingController();
  final beforePhotos = <String>[].obs;
  final actionPhotos = <String>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HomeReport) {
      activeReport = Get.arguments as HomeReport;
      title.value = reportTranslationKey(activeReport!.title);
      description.value = reportTranslationKey(activeReport!.description);
      priority.value = activeReport!.priority;
      reporterName.value = activeReport!.reporterName ?? '-';
      categoryName.value = reportTranslationKey(
        activeReport!.categoryName ?? activeReport!.title,
      );
      reportPhotos.assignAll(activeReport!.photos);

      final loc = activeReport!.location;
      if (loc.contains('|')) {
        final parts = loc.split('|');
        location.value = reportTranslationKey(parts[1]);
        baseLocation.value = reportTranslationKey(parts[0]);
      } else {
        location.value = reportTranslationKey(loc);
        baseLocation.value = reportTranslationKey(loc);
      }
      
      // Always start with 'working' state for form
      pageState.value = 'working';
    }
  }

  String? get _activeReportId {
    final rawId = activeReport?.id.trim();
    if (rawId == null || rawId.isEmpty) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    return normalized.trim().isEmpty ? null : normalized.trim();
  }

  // --- Image Pickers ---
  Future<void> pickImage(ImageSource source) async {
    await _pickPhotoTo(actionPhotos, source);
  }

  Future<void> pickBeforeImage(ImageSource source) async {
    await _pickPhotoTo(beforePhotos, source);
  }

  Future<void> _pickPhotoTo(RxList<String> list, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (file != null) {
        if (list.length < 3) {
          list.add(file.path);
        } else {
          Get.snackbar(
            'Batas Maksimal'.tr,
            'Anda hanya dapat mengunggah maksimal 3 foto.'.tr,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Gagal mengambil foto: @error'.trParams({
        'error': e.toString(),
      }));
    }
  }

  void removePhoto(int index) {
    actionPhotos.removeAt(index);
  }

  void removeBeforePhoto(int index) {
    beforePhotos.removeAt(index);
  }

  // --- Complete Report/Task Form Submission ---
  Future<void> completeReport() async {
    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID tugas tidak ditemukan'.tr);
      return;
    }

    final note = noteController.text.trim();
    if (note.isEmpty) {
      Get.snackbar('Catatan wajib diisi'.tr, 'Mohon isi catatan penyelesaian tugas'.tr);
      return;
    }
    if (beforePhotos.isEmpty) {
      Get.snackbar('Foto wajib diisi'.tr, 'Mohon unggah bukti foto kondisi awal'.tr);
      return;
    }
    if (actionPhotos.isEmpty) {
      Get.snackbar('Foto wajib diisi'.tr, 'Mohon unggah bukti foto kondisi akhir'.tr);
      return;
    }

    final ctx = Get.context;
    if (ctx == null) return;

    // Show Confirmation dialog
    await ObCompleteReportDialog.showConfirmation(
      ctx,
      onConfirm: () async {
        await _processCompleteReport(ctx, reportId, note);
      },
    );
  }

  Future<void> _processCompleteReport(
    BuildContext context,
    String reportId,
    String note,
  ) async {
    isSubmitting.value = true;
    final category = activeReport?.categoryName;

    if (category == 'Rutin') {
      try {
        final checklistController = Get.find<ObChecklistController>();
        final item = checklistController.sections
            .expand((s) => s.items)
            .firstWhereOrNull((i) => i.id == reportId);
        if (item != null) {
          checklistController.setItemStatus(item, 'resolved');
          item.note.value = note;
          item.photos.assignAll(actionPhotos);
          checklistController.submitItemDetail(item);
        }
      } catch (e) {
        debugPrint('Error completing checklist item: $e');
      }
      isSubmitting.value = false;
    } else if (category == 'Tidak Rutin') {
      // Ad-hoc task completion API call
      String currentStatus = 'BELUM_DIKERJAKAN';
      try {
        final checklistController = Get.find<ObChecklistController>();
        final task = checklistController.adHocTasks.firstWhereOrNull((t) => t['id']?.toString() == reportId);
        if (task != null) {
          currentStatus = task['status']?.toString() ?? 'BELUM_DIKERJAKAN';
        }
      } catch (_) {}

      if (currentStatus == 'BELUM_DIKERJAKAN') {
        final claimRes = await _authService.claimObTugas(reportId);
        if (claimRes == null || claimRes['success'] != true) {
          isSubmitting.value = false;
          final message = _authService.lastRequestError ?? 'Gagal mengklaim tugas.'.tr;
          await CustomAlert.show(context, isSuccess: false, description: message.tr);
          return;
        }
      }

      final response = await _authService.selesaiObTugas(reportId);
      isSubmitting.value = false;

      if (response == null || response['success'] != true) {
        final message = _authService.lastRequestError ?? 'Gagal menyelesaikan tugas'.tr;
        await CustomAlert.show(context, isSuccess: false, description: message.tr);
        return;
      }

      try {
        final checklistController = Get.find<ObChecklistController>();
        await checklistController.loadAdHocTasks();
      } catch (_) {}
    } else {
      final response = await _authService.submitObReportHistory(
        reportId: reportId,
        note: note,
        photoPaths: actionPhotos.toList(),
        beforePhotoPaths: beforePhotos.toList(),
      );
      isSubmitting.value = false;

      if (response == null) {
        final message = _authService.lastRequestError ?? 'Gagal menyelesaikan laporan'.tr;
        await CustomAlert.show(context, isSuccess: false, description: message.tr);
        return;
      }

      activeReport?.status.value = 'Selesai';

      try {
        final obHomeController = Get.find<ObHomeController>();
        await obHomeController.loadReports(silent: true);
      } catch (_) {}
    }

    // Show success dialog
    ObCompleteReportDialog.showSuccess(
      context,
      onClose: () {
        Get.back(); // Close Dialog
        Get.back(); // Back to checklist view
      },
    );

    // Auto navigate back after 2.2 seconds if close button not pressed
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Close Dialog
        Get.back(); // Back to checklist view
      }
    });
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
