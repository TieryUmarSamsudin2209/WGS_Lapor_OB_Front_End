import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObCollaborationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Cache of approved collaborators keyed by report id. Persists across
  // controller disposal so re-opening the page keeps the member list even
  // when the server doesn't return an approved-members list.
  static final Map<String, List<CollaboratorModel>> _approvedCache = {};

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
          Future.microtask(() {
            _loadCollaborators();
            // Start periodic refresh if owner
            if (isOwner.value) {
              _startPeriodicRefresh();
            }
          });
        });
      } else {
        // Determine ownership first
        _determineOwnership();
        // Load collaborators after initialization
        Future.microtask(() {
          _loadCollaborators();
          // Start periodic refresh if owner
          if (isOwner.value) {
            _startPeriodicRefresh();
          }
        });
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

  @override
  void onClose() {
    _stopPeriodicRefresh();
    super.onClose();
  }

  Timer? _refreshTimer;

  /// Start periodic refresh for owner to auto-load new collaboration requests
  void _startPeriodicRefresh() {
    if (!isOwner.value) return;
    
    debugPrint('🔄 Starting periodic refresh for collaboration requests');
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isOwner.value) {
        debugPrint('⏰ Auto-refreshing collaboration requests...');
        _loadCollaborators();
      } else {
        _stopPeriodicRefresh();
      }
    });
  }

  /// Stop periodic refresh
  void _stopPeriodicRefresh() {
    if (_refreshTimer != null) {
      debugPrint('⏹️ Stopping periodic refresh');
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }

  /// Fetch complete report data including owner info
  Future<void> _fetchCompleteReportData() async {
    final reportId = _activeReportId;
    if (reportId == null) return;

    debugPrint('🔄 Fetching complete report data for: $reportId');

    try {
      // Fetch the single report detail which contains the owner (ob_id) info
      final response = await _authService.getObReportById(reportId);

      if (response != null) {
        debugPrint('✅ Got report detail, checking for owner info...');
        debugPrint('📦 Report detail top-level keys: ${response.keys.join(", ")}');
        final laporanObj = response['laporan'];
        if (laporanObj is Map) {
          debugPrint('📦 laporan keys: ${(laporanObj as Map).keys.join(", ")}');
        }
        final dataObj = response['data'];
        if (dataObj is Map) {
          debugPrint('📦 data keys: ${(dataObj as Map).keys.join(", ")}');
        }

        // The detail response may wrap the report in 'data' or 'laporan'
        final candidates = <dynamic>[
          response['laporan'],
          response['data'],
          response,
        ];

        String? obId;
        String? obName;

        for (final candidate in candidates) {
          if (candidate is Map) {
            final foundId = candidate['ob_id']?.toString() ??
                candidate['assigned_ob_id']?.toString() ??
                candidate['petugas_id']?.toString() ??
                candidate['user_id']?.toString() ??
                candidate['created_by']?.toString() ??
                candidate['ob']?['id']?.toString();
            final foundName = candidate['ob_name']?.toString() ??
                candidate['nama_ob']?.toString() ??
                candidate['ob']?['nama_lengkap']?.toString() ??
                candidate['ob']?['nama']?.toString() ??
                candidate['ob']?['name']?.toString();

            if (foundId != null && foundId.isNotEmpty) {
              obId = foundId;
              if (foundName != null) obName = foundName;
              break;
            }
          }
        }

        if (obId != null && obId.isNotEmpty) {
          debugPrint('✅ Found owner info from API: $obName (ID: $obId)');
          if (activeReport != null) {
            activeReport!.obId.value = obId;
            if (obName != null) {
              activeReport!.obName.value = obName;
            }
          }
        } else {
          debugPrint('⚠️ Owner info (ob_id) not found in report detail response, trying collaboration endpoint...');
          // Fallback: the collaboration requests endpoint returns the laporan
          // object (with ob_id) for the owner, and an "OB utama" error confirms
          // the current user is the owner.
          final collabResponse = await _authService.getCollaborationRequests(reportId);
          if (collabResponse != null) {
            // The collaboration requests endpoint returns 200 ONLY for the
            // report owner (non-owners who haven't joined get an error). So a
            // successful response here confirms the current user is the owner.
            debugPrint('✅ Collaboration requests returned 200 — current user is the owner');
            final currentUser = _authService.user.value;
            final currentObId = currentUser?['id']?.toString();
            if (currentObId != null && activeReport != null) {
              activeReport!.obId.value = currentObId;
              activeReport!.obName.value = currentUser?['nama_lengkap']?.toString() ?? 'OB';
            }
          } else {
            // If the request failed with an "OB utama"/owner error, the current
            // user IS the owner of this report.
            final err = _authService.lastRequestError ?? '';
            if (err.contains('OB utama') || err.contains('owner') || err.contains('pemilik')) {
              debugPrint('⚠️ Collaboration endpoint confirms current user is the owner');
              final currentUser = _authService.user.value;
              final currentObId = currentUser?['id']?.toString();
              if (currentObId != null && activeReport != null) {
                activeReport!.obId.value = currentObId;
                activeReport!.obName.value = currentUser?['nama_lengkap']?.toString() ?? 'OB';
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
      ownerName.value = activeReport?.obName.value ?? 'Pemilik Laporan'.tr;
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
    
    List<CollaboratorModel> combinedList = [];
    String? requestError;

    // 0. Preserve locally-approved collaborators so a reload (or re-opening the
    //    page) doesn't drop them when the server doesn't return an
    //    approved-members list. We read from both the live Rx list and the
    //    per-report cache (which survives controller disposal).
    final cached = _approvedCache[reportId];
    if (cached != null) combinedList.addAll(cached);
    for (final local in List<CollaboratorModel>.from(collaborators)) {
      if (local.status == 'APPROVED') {
        if (!combinedList.any((c) => c.id == local.id || (c.obId != null && c.obId == local.obId))) {
          combinedList.add(local);
        }
      }
    }

    // 1. Sync dashboard reports list first to get latest collaborators on activeReport
    try {
      if (Get.isRegistered<ObHomeController>()) {
        debugPrint('🔄 Syncing reports list from dashboard...');
        await Get.find<ObHomeController>().loadReports(silent: true);
      }
    } catch (e) {
      debugPrint('⚠️ Error syncing reports: $e');
    }

    // 2. Fetch requests from /gabung (only for owner) to get pending requests and any approved ones in laporan
    Map? requestsResponse;
    if (isOwner.value) {
      debugPrint('📋 Fetching collaboration requests...');
      requestsResponse = await _authService.getCollaborationRequests(reportId);
      if (requestsResponse == null) {
        requestError = _authService.lastRequestError;
      }
    }

    // 3. Collect all APPROVED collaborators first
    // Source A: Extract approved collaborators from the laporan object inside requestsResponse (if available)
    if (requestsResponse != null) {
      final laporan = requestsResponse['laporan'];
      if (laporan is Map) {
        for (final key in [
          'kolaborator',
          'kolaborators',
          'collaborators',
          'team',
          'tim',
          'ob_list',
          'obList',
          'ob_kolaborator',
          'obKolaborator',
        ]) {
          final list = laporan[key];
          if (list is List) {
            debugPrint('📋 Found ${list.length} active collaborators in response.laporan.$key');
            for (var item in list) {
              if (item is Map<String, dynamic>) {
                final updatedItem = Map<String, dynamic>.from(item);
                updatedItem['status'] = 'APPROVED';
                final model = CollaboratorModel.fromJson(updatedItem);
                if (!combinedList.any((c) => c.id == model.id || (c.obId != null && c.obId == model.obId))) {
                  combinedList.add(model);
                }
              }
            }
            break;
          }
        }
      }
    }

    // Source B: Add approved collaborators from activeReport.collaborators
    final currentUser = _authService.user.value;
    final currentUserId = currentUser?['id']?.toString();
    final currentUserName = currentUser?['nama_lengkap']?.toString() ?? 
                            currentUser?['nama']?.toString() ?? 
                            currentUser?['name']?.toString() ?? 
                            '';

    debugPrint('👥 Adding approved collaborators from activeReport (count: ${activeReport!.collaborators.length})');
    for (final name in activeReport!.collaborators) {
      if (name.isEmpty) continue;
      
      // Skip if it's the owner (owner is already displayed separately in UI)
      if (name == ownerName.value) continue;

      final isMe = name == currentUserName;
      
      // Deduplicate: check if this collaborator is already in combinedList
      final exists = combinedList.any((c) => c.name == name || (isMe && c.obId == currentUserId));
      if (!exists) {
        combinedList.add(CollaboratorModel(
          id: isMe ? (currentUserId ?? '') : name, // Use user ID if it's current user
          obId: isMe ? currentUserId : null,
          name: name,
          status: 'APPROVED',
          role: 'Anggota'.tr,
        ));
      }
    }

    // 4. Collect all PENDING requests (only for owner), avoiding any who are already APPROVED
    if (requestsResponse != null) {
      final data = requestsResponse['data'];
      List<dynamic> items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        final hariIni = data['hari_ini'];
        final kemarin = data['kemarin'];
        if (hariIni is List) items.addAll(hariIni);
        if (kemarin is List) items.addAll(kemarin);
      }

      for (var item in items) {
        if (item is Map<String, dynamic>) {
          final model = CollaboratorModel.fromJson(item);
          
          // Check if already approved/present in list
          final exists = combinedList.any((c) => c.id == model.id || (c.obId != null && c.obId == model.obId));
          if (!exists) {
            combinedList.add(model);
          }
        }
      }

      // Extract notes if available
      if (requestsResponse['notes'] != null) {
        notes.value = requestsResponse['notes'].toString();
      } else if (requestsResponse['catatan'] != null) {
        notes.value = requestsResponse['catatan'].toString();
      }
    }

    isLoading.value = false;

    // Assign all loaded collaborators
    collaborators.assignAll(combinedList);
    debugPrint('✅ Loaded ${collaborators.length} collaborators');
    
    // Debug print each collaborator
    for (var collab in collaborators) {
      debugPrint('   - ${collab.name} (${collab.role}) [${collab.status}]');
    }

    // Only show error if owner and requests failed to load
    if (isOwner.value && requestError != null) {
      final ctx = Get.context;
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: requestError.tr);
      }
    }
  }

  /// Public method to reload collaborators (can be called from UI)
  Future<void> loadCollaborators() async {
    await _loadCollaborators();
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
      (c) => c.obId == currentUserId || c.id == currentUserId,
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

    // Success - update collaborator status locally so the name appears immediately
    final idx = collaborators.indexWhere((c) => c.id == collaborationId);
    if (idx != -1) {
      final updated = CollaboratorModel(
        id: collaborators[idx].id,
        obId: collaborators[idx].obId,
        name: collaborators[idx].name,
        role: 'Anggota'.tr,
        status: 'APPROVED',
      );
      collaborators[idx] = updated;
      // Persist into the per-report cache so re-opening keeps the member.
      _cacheApproved(reportId, updated);
    }

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

  void _cacheApproved(String reportId, CollaboratorModel member) {
    final list = _approvedCache.putIfAbsent(reportId, () => <CollaboratorModel>[]);
    if (!list.any((c) => c.id == member.id || (c.obId != null && c.obId == member.obId))) {
      list.add(member);
    }
  }

  void _uncacheApproved(String reportId, String collaborationId) {
    final list = _approvedCache[reportId];
    if (list != null) {
      list.removeWhere((c) => c.id == collaborationId);
    }
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

    // Success - remove collaborator from local list
    collaborators.removeWhere((c) => c.id == collaborationId);
    _uncacheApproved(reportId, collaborationId);

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

    // Success - remove collaborator from local list
    collaborators.removeWhere((c) => c.id == collaborationId);
    _uncacheApproved(reportId, collaborationId);

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
  final String? obId;
  final String name;
  final String role;
  final String status; // PENDING, APPROVED, REJECTED

  CollaboratorModel({
    required this.id,
    this.obId,
    required this.name,
    this.role = 'Anggota',
    this.status = 'PENDING',
  });

  String get translatedRole => role.tr;

  factory CollaboratorModel.fromJson(Map<String, dynamic> json) {
    // Extract ID from various possible keys
    final id = json['id']?.toString() ??
        json['collaboration_id']?.toString() ??
        json['kolaborasi_id']?.toString() ??
        json['ob_id']?.toString() ??
        json['user_id']?.toString() ??
        '';

    final obId = json['ob_id']?.toString() ??
        json['user_id']?.toString() ??
        json['ob']?['id']?.toString();

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
        (status == 'APPROVED' ? 'Anggota'.tr : 'Menunggu Persetujuan'.tr);

    return CollaboratorModel(
      id: id,
      obId: obId,
      name: name,
      role: role,
      status: status,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
}
