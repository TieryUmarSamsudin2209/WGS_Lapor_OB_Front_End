import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

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
      
      // First initialize basic data
      _initializeFromReport();
      
      // If obId is null, try to fetch complete report data from API
      if (activeReport!.obId.value == null || activeReport!.obId.value!.isEmpty) {
        debugPrint('⚠️ obId is null, fetching complete report data...');
        _fetchCompleteReportData().then((_) {
          // After fetching, re-determine ownership
          _determineOwnership();
          // Then load collaborators
          Future.microtask(() => _loadCollaborators());
        });
      } else {
        // Load collaborators after initialization
        Future.microtask(() => _loadCollaborators());
      }
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

  /// Fetch complete report data including owner info
  Future<void> _fetchCompleteReportData() async {
    final reportId = _activeReportId;
    if (reportId == null) return;

    debugPrint('🔄 Fetching complete report data for: $reportId');
    
    try {
      // Try to get collaboration requests - if successful, extract owner info
      final response = await _authService.getCollaborationRequests(reportId);
      
      if (response != null) {
        debugPrint('✅ Got response, checking for owner info...');
        
        // Try to extract owner info from response
        final data = response['data'];
        final laporan = response['laporan'];
        
        // Owner info might be in laporan object
        if (laporan is Map) {
          final obData = laporan['ob'];
          if (obData is Map) {
            final obId = obData['id']?.toString();
            final obName = obData['nama_lengkap']?.toString() ?? 
                          obData['nama']?.toString() ?? 
                          obData['name']?.toString();
            
            if (obId != null && obId.isNotEmpty) {
              debugPrint('✅ Found owner info from API: $obName (ID: $obId)');
              if (activeReport != null) {
                activeReport!.obId.value = obId;
                if (obName != null) {
                  activeReport!.obName.value = obName;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching complete report data: $e');
    }
  }

  /// Determine ownership based on current data
  void _determineOwnership() {
    final currentUser = _authService.user.value;
    final currentObId = currentUser?['id']?.toString();
    final reportObId = activeReport?.obId.value?.toString();

    debugPrint('🔍 Determining ownership:');
    debugPrint('   Current User ID: $currentObId');
    debugPrint('   Report OB ID: $reportObId');

    if (reportObId != null && reportObId.isNotEmpty && 
        currentObId != null && currentObId == reportObId) {
      isOwner.value = true;
      ownerName.value = activeReport!.obName.value ?? 
                       currentUser?['nama_lengkap']?.toString() ?? 
                       'OB';
      debugPrint('   ✅ Current user IS owner');
    } else {
      isOwner.value = false;
      ownerName.value = activeReport?.obName.value ?? 'Pemilik Laporan';
      debugPrint('   ℹ️ Current user is NOT owner');
    }
    
    debugPrint('   🎯 Final isOwner: ${isOwner.value}');
  }

  void _initializeFromReport() {
    if (activeReport == null) {
      debugPrint('⚠️ activeReport is null in collaboration view');
      return;
    }

    debugPrint('📋 Initializing collaboration view with report data:');
    debugPrint('   ID: ${activeReport!.id}');
    debugPrint('   Title: ${activeReport!.title}');
    debugPrint('   Has Collaboration: ${activeReport!.hasCollaboration.value}');

    // Set basic data from activeReport
    reportTitle.value = activeReport!.title;
    reportPriority.value = activeReport!.priority;
    reportLocation.value = activeReport!.location;
    
    // Determine ownership
    _determineOwnership();
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
    debugPrint('   isOwner: ${isOwner.value}');
    
    isLoading.value = true;
    
    final response = await _authService.getCollaborationRequests(reportId);
    
    isLoading.value = false;

    if (response == null) {
      debugPrint('❌ Failed to load collaborators');
      
      // If non-owner and got 403, it's expected - just clear list and continue
      if (!isOwner.value && _authService.lastRequestError?.contains('403') == true) {
        debugPrint('ℹ️ Non-owner got 403 as expected, clearing collaborators list');
        collaborators.clear();
        return;
      }
      
      final message = _authService.lastRequestError ??
          'Gagal memuat daftar permintaan kolaborasi'.tr;
      
      // Only show error if owner (owner needs to see collaboration requests)
      if (isOwner.value && _authService.lastRequestError != null) {
        final ctx = Get.context;
        if (ctx != null) {
          await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
        }
      }
      return;
    }

    debugPrint('✅ Got collaboration response: ${response.keys.join(", ")}');

    // Extract collaborators from response
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
      
      // CRITICAL FIX: If error is "already owner", update isOwner flag
      if (message.contains('OB utama') || message.contains('owner') || message.contains('pemilik')) {
        debugPrint('⚠️ User is actually the owner, updating isOwner flag');
        isOwner.value = true;
        
        // Update owner info
        final currentUser = _authService.user.value;
        final currentObId = currentUser?['id']?.toString();
        if (currentObId != null && activeReport != null) {
          activeReport!.obId.value = currentObId;
          activeReport!.obName.value = currentUser?['nama_lengkap']?.toString() ?? 'OB';
          ownerName.value = activeReport!.obName.value!;
        }
        
        // Reload collaborators as owner
        await _loadCollaborators();
        return;
      }
      
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - show success message
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Permintaan kolaborasi berhasil dikirim!'.tr,
      );
    }

    // Reload collaborators untuk update status
    await _loadCollaborators();
  }

  Future<void> leaveCollaboration() async {
    if (isSubmitting.value) return;
    if (isOwner.value) {
      Get.snackbar('Error'.tr, 'Pemilik laporan tidak bisa keluar dari kolaborasi'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    // Find current user's collaboration ID
    final currentUserId = _authService.user.value?['id']?.toString();
    final currentCollaboration = collaborators.firstWhereOrNull(
      (c) => c.id == currentUserId,
    );

    if (currentCollaboration == null) {
      Get.snackbar('Error'.tr, 'Anda belum bergabung ke kolaborasi ini'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.removeCollaborationMember(
      reportId: reportId,
      collaborationId: currentCollaboration.id,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal keluar dari kolaborasi'.tr;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - show success message and go back
    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Berhasil keluar dari kolaborasi'.tr,
      );
    }

    // Go back to previous page
    Get.back();
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
  Future<void> removeCollaborator(String collaborationId) async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat mengeluarkan anggota'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.removeCollaborationMember(
      reportId: reportId,
      collaborationId: collaborationId,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal mengeluarkan anggota'.tr;
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
        description: 'Anggota berhasil dikeluarkan'.tr,
      );
    }

    await _loadCollaborators();
  }

  Future<void> completeReportFromCollaboration() async {
    if (isSubmitting.value) return;
    if (!isOwner.value) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat menyelesaikan laporan'.tr);
      return;
    }

    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    // Redirect ke halaman detail untuk melengkapi catatan dan foto selesai
    // Karena complete report memerlukan catatan dan foto bukti selesai
    Get.back(); // Keluar dari collaboration page
    Get.toNamed('/ob-detail', arguments: activeReport);
  }

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
