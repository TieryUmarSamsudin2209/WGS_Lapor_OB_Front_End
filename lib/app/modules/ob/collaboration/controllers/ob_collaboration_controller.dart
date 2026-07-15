import 'package:flutter/material.dart';
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
  final notes = ''.obs; // Catatan kolaborasi

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
      _loadCollaborators();
    } else {
      // No valid report data passed
      Get.snackbar(
        'Error'.tr,
        'Data laporan tidak ditemukan'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      // Go back after delay
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }

  void _initializeFromReport() {
    if (activeReport == null) {
      debugPrint('⚠️ activeReport is null in collaboration view');
      return;
    }

    debugPrint('📋 Initializing collaboration view with real report data:');
    debugPrint('   ID: ${activeReport!.id}');
    debugPrint('   Title: ${activeReport!.title}');
    debugPrint('   Priority: ${activeReport!.priority}');
    debugPrint('   Location: ${activeReport!.location}');
    
    // Check reactive values
    debugPrint('   Owner (reactive): ${activeReport!.obName.value}');
    debugPrint('   Owner ID (reactive): ${activeReport!.obId.value}');
    debugPrint('   Owner (getter): ${activeReport!.assignedObName}');
    debugPrint('   Owner ID (getter): ${activeReport!.assignedObId}');
    debugPrint('   Has Collaboration: ${activeReport!.hasCollaboration.value}');

    // Set data dari activeReport (REAL DATA, bukan dummy)
    reportTitle.value = activeReport!.title;
    reportPriority.value = activeReport!.priority;
    reportLocation.value = activeReport!.location;
    
    // Determine owner name - use reactive value directly
    if (activeReport!.obName.value != null && activeReport!.obName.value!.isNotEmpty) {
      ownerName.value = activeReport!.obName.value!;
      debugPrint('   ✅ Owner name set from report: ${ownerName.value}');
    } else {
      // Fallback to current user name if OB took this report
      final currentUserName = _authService.user.value?['nama_lengkap']?.toString() ??
          _authService.user.value?['name']?.toString() ??
          _authService.user.value?['username']?.toString() ??
          'OB';
      ownerName.value = currentUserName;
      debugPrint('   ℹ️ Owner name set from current user: ${ownerName.value}');
    }

    // Check ownership - Multiple ways to determine:
    // 1. Check if obId (reactive) matches current user ID
    // 2. If obId is null, check if current user took the report (status = in_progress)
    final currentUser = _authService.user.value;
    final currentObId = currentUser?['id']?.toString();
    final reportObId = activeReport!.obId.value?.toString(); // Use reactive value

    debugPrint('   Current User ID: $currentObId');
    debugPrint('   Report OB ID (reactive): $reportObId');
    debugPrint('   Report Status: ${activeReport!.status.value}');

    if (reportObId != null && reportObId.isNotEmpty && 
        currentObId != null && currentObId == reportObId) {
      // Clear owner match
      isOwner.value = true;
      debugPrint('   ✅ Current user is OWNER (ID match)');
    } else if ((reportObId == null || reportObId.isEmpty) && 
               activeReport!.status.value == 'Sedang Diproses') {
      // If no OB ID but status is in progress, assume current user is owner
      isOwner.value = true;
      debugPrint('   ✅ Current user is OWNER (status check - just took report)');
      
      // Set owner info AFTER build completes to avoid setState during build
      if (currentObId != null) {
        Future.microtask(() {
          activeReport!.obId.value = currentObId;
          activeReport!.obName.value = ownerName.value;
          debugPrint('   📝 Set owner info locally: ${ownerName.value} (ID: $currentObId)');
        });
      }
    } else {
      isOwner.value = false;
      debugPrint('   ℹ️ Current user is NOT owner');
    }
  }

  Future<void> _loadCollaborators() async {
    if (activeReport == null) {
      debugPrint('⚠️ Cannot load collaborators: activeReport is null');
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      debugPrint('⚠️ Cannot load collaborators: reportId is null');
      return;
    }

    debugPrint('🔄 Loading collaborators for report: $reportId');
    isLoading.value = true;
    
    final response = await _authService.getCollaborationRequests(reportId);
    
    isLoading.value = false;

    if (response == null) {
      debugPrint('❌ Failed to load collaborators');
      final message = _authService.lastRequestError ??
          'Gagal memuat daftar permintaan kolaborasi'.tr;
      
      // Only show error if not just empty list
      if (_authService.lastRequestError != null) {
        final ctx = Get.context;
        if (ctx != null) {
          await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
        }
      }
      return;
    }

    debugPrint('✅ Got collaboration response: ${response.keys.join(", ")}');

    // Extract collaborators from response
    // Response format bisa:
    // 1. { data: [...] }
    // 2. { data: { hari_ini: [...], kemarin: [...] } }
    final data = response['data'];
    
    if (data == null) {
      debugPrint('ℹ️ No collaborators data in response');
      collaborators.clear();
      return;
    }

    List<dynamic> items = [];
    
    if (data is List) {
      items = data;
      debugPrint('📋 Found ${items.length} collaborators (direct list)');
    } else if (data is Map) {
      // Combine hari_ini and kemarin if available
      final hariIni = data['hari_ini'];
      final kemarin = data['kemarin'];
      
      if (hariIni is List) {
        items.addAll(hariIni);
      }
      if (kemarin is List) {
        items.addAll(kemarin);
      }
      
      debugPrint('📋 Found ${items.length} collaborators (from grouped data)');
    }

    // Parse items to CollaboratorModel
    final parsedCollaborators = items.map((item) {
      if (item is Map<String, dynamic>) {
        return CollaboratorModel.fromJson(item);
      }
      return null;
    }).whereType<CollaboratorModel>().toList();

    collaborators.assignAll(parsedCollaborators);
    debugPrint('✅ Loaded ${collaborators.length} collaborators');
    
    // Extract notes if available
    if (response['notes'] != null) {
      notes.value = response['notes'].toString();
      debugPrint('📝 Notes: ${notes.value}');
    } else if (response['catatan'] != null) {
      notes.value = response['catatan'].toString();
      debugPrint('📝 Notes: ${notes.value}');
    }
    
    // Debug print each collaborator
    for (var collab in collaborators) {
      debugPrint('   - ${collab.name} (${collab.role}) [${collab.status}]');
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

  /// Close collaboration (menutup kolaborasi)
  /// Different from cancel - this closes an open collaboration
  Future<void> closeCollaboration() async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat menutup kolaborasi'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    // Confirm before closing
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Tutup Kolaborasi'.tr),
        content: Text('Apakah Anda yakin ingin menutup kolaborasi? Permintaan gabung akan ditolak.'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            child: Text('Tutup'.tr),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    isSubmitting.value = true;
    final response = await _authService.closeCollaboration(reportId);
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal menutup kolaborasi'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - update local state
    if (activeReport != null) {
      activeReport!.hasCollaboration.value = false;
    }

    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Kolaborasi berhasil ditutup'.tr,
      );
    }

    // Go back to detail page
    Get.back();
  }

  Future<void> updateNotes(String newNotes) async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat mengubah catatan'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    debugPrint('📝 Updating notes for report: $reportId');
    debugPrint('   New notes: $newNotes');

    isSubmitting.value = true;
    
    // Call API to update collaboration notes
    final response = await _authService.updateCollaborationNotes(
      reportId: reportId,
      notes: newNotes,
    );
    
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal memperbarui catatan'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - update local notes
    notes.value = newNotes;
    debugPrint('✅ Notes updated successfully');

    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Catatan berhasil diperbarui'.tr,
      );
    } else {
      Get.snackbar('Berhasil'.tr, 'Catatan berhasil diperbarui'.tr);
    }
  }

  // Getters for notes editing
  String get currentNotes => notes.value;
  bool get canEditNotes => isOwner.value;

  // Getters for report data
  String get reportDescription => activeReport?.description ?? 'Tidak ada deskripsi';
  
  String get reportCategory => activeReport?.categoryName ?? 'Tidak ada kategori';
  
  String get reportReporter => activeReport?.reporterName ?? ownerName.value;
  
  List<String> get reportPhotos => activeReport?.photos ?? [];
  
  String get reportTimeAgo {
    // Since HomeReport doesn't have createdAt, return default
    return 'Baru saja';
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
  final String status; // PENDING, APPROVED, REJECTED

  CollaboratorModel({
    required this.id,
    required this.name,
    this.role = 'Anggota',
    this.status = 'PENDING',
  });

  factory CollaboratorModel.fromJson(Map<String, dynamic> json) {
    // Extract ID from various possible keys
    final id = json['id']?.toString() ??
        json['collaboration_id']?.toString() ??
        json['kolaborasi_id']?.toString() ??
        json['ob_id']?.toString() ??
        json['user_id']?.toString() ??
        '';

    // Extract name from nested ob object or direct fields
    String name = 'OB';
    
    // Try ob object first
    final obData = json['ob'];
    if (obData is Map) {
      name = obData['nama_lengkap']?.toString() ??
          obData['nama']?.toString() ??
          obData['name']?.toString() ??
          obData['username']?.toString() ??
          name;
    }
    
    // Fallback to direct fields
    if (name == 'OB') {
      name = json['nama_lengkap']?.toString() ??
          json['nama_ob']?.toString() ??
          json['nama']?.toString() ??
          json['name']?.toString() ??
          json['username']?.toString() ??
          'OB';
    }

    // Extract status
    final status = (json['status']?.toString() ?? 'PENDING').toUpperCase();

    // Extract role (if available)
    final role = json['role']?.toString() ?? 
        (status == 'APPROVED' ? 'Anggota' : 'Menunggu Persetujuan');

    return CollaboratorModel(
      id: id,
      name: name,
      role: role,
      status: status,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}
