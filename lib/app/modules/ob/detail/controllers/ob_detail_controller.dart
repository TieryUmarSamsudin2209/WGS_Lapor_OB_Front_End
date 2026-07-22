import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/services/auth_service.dart';
import '../../../../shared/utils/report_translation_key.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../../../shared/widgets/ob_complete_report_dialog.dart';
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

  // Timer untuk elapsed time
  Timer? _elapsedTimer;
  var elapsedTime = ''.obs;
  DateTime? _createdAt;
  DateTime? _dikerjakanAt;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is HomeReport) {
      activeReport = Get.arguments as HomeReport;
      title.value = reportTranslationKey(activeReport!.title);
      description.value = reportTranslationKey(activeReport!.description);
      priority.value = activeReport!.priority;
      location.value = reportTranslationKey(activeReport!.location);
      reporterName.value = activeReport!.reporterName ?? '-';
      categoryName.value = reportTranslationKey(
        activeReport!.categoryName ?? activeReport!.title,
      );
      
      // Use reactive value for owner name
      takenByName.value = activeReport!.obName.value ?? activeReport!.assignedObName;
      debugPrint('📋 [DETAIL] Assigned OB: ${takenByName.value}');
      debugPrint('📋 [DETAIL] OB ID: ${activeReport!.obId.value}');
      
      reportPhotos.assignAll(activeReport!.photos);
      isNeedHelp.value = activeReport!.hasCollaboration.value;

      _createdAt = activeReport!.createdAt;
      _dikerjakanAt = activeReport!.dikerjakanAt;

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

      _updateElapsedTime();
      if (pageState.value == 'working') {
        _startElapsedTimer();
      }
    }
  }

  Future<void> setWorking() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    isSubmitting.value = true;
    final response = await _authService.takeObReport(reportId);
    isSubmitting.value = false;

    if (response == null) {
      final message =
          _authService.lastRequestError ?? 'Gagal mengambil laporan'.tr;
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
          description: message.tr,
        );
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - set to working state (not initial/pending)
    pageState.value = 'working';
    isDetailExpanded.value = false;
    activeReport?.status.value = 'Sedang Diproses'; // Always "Sedang Diproses", never "Belum Diproses"

    // Set dikerjakanAt to now when taken
    _dikerjakanAt = DateTime.now();
    activeReport?.dikerjakanAt = _dikerjakanAt;
    _startElapsedTimer();
    
    // Set owner info from response or current user
    final obNameFromResponse = _assignedObNameFromResponse(response);
    final currentUserId = _currentObIds.firstOrNull;
    final currentUserName = _currentObName;
    
    // Update assigned OB info in activeReport
    if (obNameFromResponse != null) {
      takenByName.value = obNameFromResponse;
      activeReport?.obName.value = obNameFromResponse;
    } else if (currentUserName != null) {
      takenByName.value = currentUserName;
      activeReport?.obName.value = currentUserName;
    } else {
      takenByName.value = 'Anda';
      activeReport?.obName.value = 'Anda';
    }
    
    // Set assignedObId if available
    if (currentUserId != null && activeReport != null) {
      activeReport?.obId.value = currentUserId;
      debugPrint('✅ Report taken by: $currentUserName (ID: $currentUserId)');
    }

    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description:
            _responseMessage(response)?.tr ?? 'Berhasil mengambil laporan.'.tr,
      );
    }
  }

  void setRejecting() {
    if (pageState.value == 'working') {
      pageState.value = 'rejecting';
      isDetailExpanded.value = false;
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsedTime();
    });
  }

  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  void _updateElapsedTime() {
    if (pageState.value == 'working') {
      final start = _dikerjakanAt;
      if (start != null) {
        final duration = DateTime.now().difference(start);
        elapsedTime.value = _formatDuration(duration);
        return;
      }
    }
    if (pageState.value == 'initial' || pageState.value == 'taken') {
      final created = _createdAt;
      if (created != null) {
        final diff = DateTime.now().difference(created);
        elapsedTime.value = _formatTimeAgo(diff);
        return;
      }
    }
    elapsedTime.value = '';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(Duration diff) {
    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit yang lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    final date = _createdAt?.toLocal();
    if (date != null) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  Future<void> toggleNeedHelp() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }

    // Toggle collaboration status using PATCH /kolaborasi endpoint
    // This will:
    // 1. Open/close collaboration on the report (owner only)
    // 2. Send WebSocket notification to all OB accounts if opening
    // 3. Update has_collaboration status
    
    debugPrint('🔄 [TOGGLE] Starting collaboration toggle for report: $reportId');
    debugPrint('🔄 [TOGGLE] Current state - isNeedHelp: ${isNeedHelp.value}, hasCollaboration: ${activeReport?.hasCollaboration.value}');
    
    // Determine current status and what to do
    final currentlyOpen = activeReport?.hasCollaboration.value == true;
    final shouldOpen = !currentlyOpen;
    
    debugPrint('🔄 [TOGGLE] Current collaboration status: $currentlyOpen, will set to: $shouldOpen');
    
    isSubmitting.value = true;
    final response = await _authService.toggleCollaboration(reportId, isOpen: shouldOpen);
    isSubmitting.value = false;

    debugPrint('🔄 [TOGGLE] Response received: ${response != null ? "SUCCESS" : "FAILED"}');
    if (response != null) {
      debugPrint('🔄 [TOGGLE] Response keys: ${response.keys.join(", ")}');
      debugPrint('🔄 [TOGGLE] Response data: $response');
    }

    if (response == null) {
      final ctx = Get.context;
      final message = _authService.lastRequestError ??
          'Gagal mengubah status kolaborasi'.tr;
      debugPrint('❌ [TOGGLE] Failed with error: $message');
      if (ctx != null) {
        await CustomAlert.show(
          ctx,
          isSuccess: false,
          description: message.tr,
        );
      } else {
        Get.snackbar('Gagal'.tr, message.tr);
      }
      return;
    }

    // Success - update state from response
    // Backend should return the new collaboration status
    final responseData = response['data'];
    debugPrint('🔍 [TOGGLE] Response data object: $responseData');
    
    final hasCollabFromResponse = responseData?['is_kolaborasi_open'] ??  // Backend field (priority)
                                  responseData?['kolaborasi'] ?? 
                                  responseData?['has_collaboration'] ??
                                  response['is_kolaborasi_open'] ??
                                  response['kolaborasi'] ??
                                  response['has_collaboration'];
    
    debugPrint('🔍 [TOGGLE] Extracted hasCollab from response: $hasCollabFromResponse (type: ${hasCollabFromResponse.runtimeType})');
    
    // Use backend status if available, otherwise toggle local
    final newStatus = hasCollabFromResponse ?? !isNeedHelp.value;
    
    debugPrint('✅ [TOGGLE] New collaboration status: $newStatus');
    debugPrint('📝 [TOGGLE] Updating local state...');
    
    isNeedHelp.value = newStatus;
    activeReport?.hasCollaboration.value = newStatus;
    
    debugPrint('✅ [TOGGLE] Local state updated - isNeedHelp: ${isNeedHelp.value}, hasCollaboration: ${activeReport?.hasCollaboration.value}');

    // Trigger home reports refresh to show badge
    debugPrint('🔄 [TOGGLE] Refreshing home reports...');
    try {
      final obHomeController = Get.find<ObHomeController>();
      await obHomeController.loadReports(silent: true);
      debugPrint('✅ [TOGGLE] Home reports refreshed successfully');
    } catch (e) {
      debugPrint('⚠️ [TOGGLE] Could not find ObHomeController: $e');
    }

    final ctx = Get.context;
    if (ctx != null) {
      await CustomAlert.show(
        ctx,
        isSuccess: true,
        description: newStatus
            ? 'Kolaborasi dibuka. Notifikasi terkirim ke semua OB.'.tr
            : 'Kolaborasi ditutup.'.tr,
      );
    }
    
    debugPrint('🎉 [TOGGLE] Collaboration toggle completed!');
  }

  Future<void> openCollaborationPage() async {
    if (activeReport == null) {
      Get.snackbar('Error'.tr, 'Data laporan tidak ditemukan'.tr);
      return;
    }

    final reportId = activeReport!.id;
    
    // Check if collaboration is already open
    final isCollabOpen = activeReport!.hasCollaboration.value;
    
    debugPrint('🚀 [COLLAB] Opening collaboration page');
    debugPrint('🚀 [COLLAB] Current collaboration status: $isCollabOpen');
    
    // If collaboration not open yet, open it first
    if (!isCollabOpen) {
      debugPrint('🚀 [COLLAB] Collaboration not open, opening now...');
      
      // Call openCollaboration API to open collaboration
      final response = await _authService.openCollaboration(reportId);
      
      if (response != null) {
        // Extract collaboration status from response
        final responseData = response['data'];
        final hasCollabFromResponse = responseData?['is_kolaborasi_open'] ??  // Backend field (priority)
                                      responseData?['kolaborasi'] ?? 
                                      responseData?['has_collaboration'] ??
                                      response['is_kolaborasi_open'] ??
                                      response['kolaborasi'] ??
                                      response['has_collaboration'];
        
        // Update local state
        final newStatus = hasCollabFromResponse ?? true; // Default to true if response doesn't specify
        activeReport!.hasCollaboration.value = newStatus;
        isNeedHelp.value = newStatus;
        
        debugPrint('✅ [COLLAB] Collaboration opened: $newStatus');
        
        // Refresh home to show badge
        try {
          final obHomeController = Get.find<ObHomeController>();
          await obHomeController.loadReports(silent: true);
        } catch (e) {
          debugPrint('⚠️ [COLLAB] Could not refresh home: $e');
        }
      } else {
        // Failed to open collaboration
        final error = _authService.lastRequestError ?? 'Gagal membuka kolaborasi';
        debugPrint('❌ [COLLAB] Failed to open collaboration: $error');
        Get.snackbar('Gagal'.tr, error.tr);
        return;
      }
    }

    // Navigate to collaboration page
    debugPrint('📱 [COLLAB] Navigating to collaboration page');
    Get.toNamed(
      '/ob/collaboration',
      arguments: activeReport,
    );
  }

  // ── Selesaikan → alert berhasil lalu kembali ke screen sebelumnya ────────
  Future<void> completeReport() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    final note = noteController.text.trim();

    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }
    if (note.isEmpty) {
      Get.snackbar('Catatan wajib diisi'.tr, 'Mohon isi catatan pekerjaan'.tr);
      return;
    }
    if (note.length < 5) {
      Get.snackbar('Catatan terlalu pendek'.tr, 'Keterangan minimal 5 karakter'.tr);
      return;
    }
    if (actionPhotos.isEmpty) {
      Get.snackbar('Foto wajib diisi'.tr, 'Mohon unggah bukti foto selesai'.tr);
      return;
    }

    final ctx = Get.context;
    if (ctx == null) return;

    // Tampilkan Popup Konfirmasi 1 ("Selesaikan Laporan?")
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
    final response = await _authService.submitObReportHistory(
      reportId: reportId,
      note: note,
      photoPaths: actionPhotos.toList(),
    );
    isSubmitting.value = false;

    if (response == null) {
      final message =
          _authService.lastRequestError ?? 'Gagal menyelesaikan laporan'.tr;
      await CustomAlert.show(context, isSuccess: false, description: message.tr);
      return;
    }

    activeReport?.status.value = 'Selesai';
    _stopElapsedTimer();

    try {
      final obHomeController = Get.find<ObHomeController>();
      await obHomeController.loadReports(silent: true);
    } catch (_) {}

    // Tampilkan Popup Berhasil 2 ("Laporan Selesai!")
    ObCompleteReportDialog.showSuccess(
      context,
      onClose: () {
        Get.back(); // Kembali ke OB Home
      },
    );

    // Auto navigate back setelah 2.2 detik jika tombol close tidak ditekan
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Tutup Dialog jika masih terbuka
        Get.back(); // Kembali ke OB Home
      }
    });
  }

  // ── Tolak → alert gagal lalu kembali ke screen sebelumnya ─────────────────
  Future<void> confirmReject() async {
    if (isSubmitting.value) return;
    final reportId = _activeReportId;
    final reason = noteController.text.trim();

    if (reportId == null) {
      Get.snackbar('Error'.tr, 'ID laporan tidak ditemukan'.tr);
      return;
    }
    if (reason.isEmpty) {
      Get.snackbar('Alasan wajib diisi'.tr, 'Mohon isi alasan menolak laporan'.tr);
      return;
    }
    if (reason.length < 3) {
      Get.snackbar('Alasan terlalu pendek'.tr, 'Catatan pembatalan minimal 3 karakter'.tr);
      return;
    }
    // Foto pembatalan OPSIONAL (tidak wajib)
    // User dapat menolak dengan atau tanpa foto

    isSubmitting.value = true;
    final response = await _authService.cancelObReport(
      reportId: reportId,
      catatan: reason,
      fotoSelesai: actionPhotos.isNotEmpty ? actionPhotos.toList() : null,
    );
    isSubmitting.value = false;

    if (response == null) {
      final ctx = Get.context;
      var message = _authService.lastRequestError ?? 'Gagal menolak laporan'.tr;
      
      // Jika backend masih memerlukan foto, berikan petunjuk yang jelas
      if (message.toLowerCase().contains('foto') && 
          message.toLowerCase().contains('wajib')) {
        message = 'Foto bukti pembatalan diperlukan oleh sistem. Mohon unggah minimal 1 foto.'.tr;
      }
      
      if (ctx != null) {
        await CustomAlert.show(ctx, isSuccess: false, description: message.tr);
      } else {
        Get.snackbar('Error'.tr, message.tr);
      }
      return;
    }

    activeReport?.status.value = 'Ditolak';
    _stopElapsedTimer();
    final ctx = Get.context;
    if (ctx != null) {
      CustomAlert.show(
        ctx,
        isSuccess: true,
        description: 'Berhasil batalkan laporan'.tr,
      );
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
    // Check if report has assigned OB ID
    final assignedId = report.assignedObId?.trim();
    if (assignedId != null && assignedId.isNotEmpty) {
      final currentIds = _currentObIds;
      if (currentIds.isEmpty) {
        // No current user ID available, assume not taken by this OB
        return true;
      }
      // Check if assigned ID matches any of current OB IDs
      final isTakenByMe = currentIds.contains(_normalizeIdentity(assignedId));
      debugPrint('🔍 Check by ID: assignedId=$assignedId, currentIds=$currentIds, isTakenByMe=$isTakenByMe');
      return !isTakenByMe; // Return true only if NOT taken by me
    }

    // Fallback: Check by OB name
    final assignedName = report.assignedObName?.trim();
    if (assignedName != null && assignedName.isNotEmpty) {
      final currentName = _currentObName;
      if (currentName == null || currentName.trim().isEmpty) {
        // No current user name available, assume not taken by this OB
        return true;
      }
      final isTakenByMe = _normalizeIdentity(assignedName) == _normalizeIdentity(currentName);
      debugPrint('🔍 Check by Name: assignedName=$assignedName, currentName=$currentName, isTakenByMe=$isTakenByMe');
      return !isTakenByMe; // Return true only if NOT taken by me
    }

    // No assigned OB info available
    // If status is "Sedang Diproses" but no OB assigned, assume it's available for this OB
    debugPrint('🔍 No assigned OB info, status=${report.status.value}');
    return false; // NOT locked - let current OB work on it
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
    _stopElapsedTimer();
    noteController.dispose();
    super.onClose();
  }
}
