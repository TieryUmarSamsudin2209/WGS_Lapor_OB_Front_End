import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObCollaborationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  HomeReport? activeReport;

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  final collaborators = <CollaboratorModel>[].obs;

  // Owner info
  var ownerName = 'Alex'.obs;
  var reportTitle = 'Kebocoran Pipa Air'.obs;
  var reportPriority = 'URGENT'.obs;
  var reportLocation = 'HQ Tower A, Lantai 4 (Toilet Pria)'.obs;

  // Check if current user is the owner
  var isOwner = false.obs;

  // Public getter for current user ID
  String? get currentUserId => _authService.user.value?['id']?.toString();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HomeReport) {
      activeReport = Get.arguments as HomeReport;
      _initializeFromReport();
    }
    _loadCollaborators();
  }

  void _initializeFromReport() {
    if (activeReport == null) return;

    reportTitle.value = activeReport!.title;
    reportPriority.value = activeReport!.priority;
    reportLocation.value = activeReport!.location;
    ownerName.value = activeReport!.assignedObName ?? 'OB';

    // Check if current user is the owner
    final currentUser = _authService.user.value;
    final currentObId = currentUser?['id']?.toString();
    final reportObId = activeReport!.assignedObId?.toString();

    if (currentObId != null && reportObId != null && currentObId == reportObId) {
      isOwner.value = true;
    }
  }

  Future<void> _loadCollaborators() async {
    if (activeReport == null) return;

    final reportId = _activeReportId;
    if (reportId == null) return;

    isLoading.value = true;
    final response = await _authService.getCollaborationRequests(reportId);
    isLoading.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal memuat daftar permintaan kolaborasi'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      }
      return;
    }

    // Extract collaborators from response
    final data = response['data'];
    if (data is List) {
      collaborators.assignAll(
        data.map((item) => CollaboratorModel.fromJson(item)).toList(),
      );
    }
  }

  Future<void> joinCollaboration() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.sendCollaborationRequest(reportId);
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal mengirim permintaan kolaborasi'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - reload collaborators and show success message
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Permintaan kolaborasi berhasil dikirim!'.tr,
      );
    }

    // Refresh collaborators list
    await _loadCollaborators();
  }

  Future<void> approveCollaborator(String collaborationId) async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat menyetujui permintaan'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.approveCollaborationRequest(
      reportId: reportId,
      collaborationId: collaborationId,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal menyetujui permintaan'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - reload collaborators
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Permintaan disetujui'.tr,
      );
    }

    await _loadCollaborators();
  }

  Future<void> rejectCollaborator(String collaborationId) async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat menolak permintaan'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.rejectCollaborationRequest(
      reportId: reportId,
      collaborationId: collaborationId,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal menolak permintaan'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - reload collaborators
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Permintaan ditolak'.tr,
      );
    }

    await _loadCollaborators();
  }

  Future<void> cancelCollaboration() async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat membatalkan kolaborasi'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.cancelCollaboration(reportId);
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal membatalkan kolaborasi'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - go back to detail page
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Kolaborasi berhasil dibatalkan'.tr,
      );
    }

    Get.back();
  }

  String? get _activeReportId {
    final rawId = activeReport?.id.trim();
    if (rawId == null || rawId.isEmpty) return null;
    final normalized = rawId.startsWith('#') ? rawId.substring(1) : rawId;
    return normalized.trim().isEmpty ? null : normalized.trim();
  }
}

class CollaboratorModel {
  final String id;
  final String name;
  final String role;

  CollaboratorModel({
    required this.id,
    required this.name,
    this.role = 'Peminta Laporan',
  });

  factory CollaboratorModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ??
        json['ob_id']?.toString() ??
        json['user_id']?.toString() ??
        '';

    final name = json['nama']?.toString() ??
        json['nama_lengkap']?.toString() ??
        json['name']?.toString() ??
        json['username']?.toString() ??
        'OB';

    final role = json['role']?.toString() ?? 'Peminta Laporan';

    return CollaboratorModel(
      id: id,
      name: name,
      role: role,
    );
  }
}
