import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lapor_ob/app/shared/services/login_services.dart';

class ObProfileController extends GetxController {
  final api = Get.find<LoginService>();
  final ImagePicker picker = ImagePicker();

  final isLoading = true.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> tempProfileImage = Rx<File?>(null);

  // User profile
  final namaLengkap = ''.obs;
  final username = ''.obs;
  final email = ''.obs;
  final role = ''.obs;
  final profilePicture = ''.obs;
  final totalLaporan = 0.obs;
  final tasksCompleted = 0.obs;
  final rejected = 0.obs;

  // Laporan items
  final laporanItems = <Map<String, dynamic>>[].obs;
  final isLoadingMore = false.obs;
  String? nextCursor;

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> pickCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  void deleteProfileImage() {
    profileImage.value = null;
  }

  void openEditProfile() {
    tempProfileImage.value = profileImage.value;
  }

  Future<void> pickTempImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      tempProfileImage.value = File(image.path);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;

    final result = await api.getUserProfile();
    if (result != null) {
      final data = result['data'] as Map?;
      final userData = data?['user'] as Map?;
      if (userData != null) {
        namaLengkap.value = userData['nama_lengkap']?.toString() ?? '';
        username.value = userData['username']?.toString() ?? '';
        email.value = userData['email']?.toString() ?? '';
        role.value = userData['role']?.toString() ?? '';
        profilePicture.value = userData['profile_picture']?.toString() ?? '';
        totalLaporan.value = userData['total_laporan'] as int? ?? 0;
        tasksCompleted.value = userData['tasksCompleted'] as int? ?? 0;
        rejected.value = userData['rejected'] as int? ?? 0;
      }

      final laporanData = data?['laporan'] as Map?;
      if (laporanData != null) {
        final items = laporanData['items'] as List?;
        if (items != null) {
          laporanItems.value = items.cast<Map<String, dynamic>>();
        }
        nextCursor = laporanData['next_cursor']?.toString();
      }
    }

    isLoading.value = false;
  }

  double get progressValue {
    if (totalLaporan.value == 0) return 0.0;
    return tasksCompleted.value / totalLaporan.value;
  }

  String get progressText {
    return '${tasksCompleted.value}/${totalLaporan.value} Tugas Selesai';
  }

  String get progressPercent {
    return '${(progressValue * 100).round()}%';
  }

  Color prioColor(String prioritas) {
    switch (prioritas.toUpperCase()) {
      case 'URGENT':
        return const Color(0xFFFFDAD6);
      case 'HIGH':
        return const Color(0xFFFFE5B4);
      default:
        return const Color(0xFFFFFDCC);
    }
  }

  Color prioTextColor(String prioritas) {
    switch (prioritas.toUpperCase()) {
      case 'URGENT':
        return const Color(0xFF93000A);
      case 'HIGH':
        return const Color(0xFFB25000);
      default:
        return const Color(0xFFFF8800);
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'BELUM_DIKERJAKAN':
        return 'Pending';
      case 'SEDANG_DIKERJAKAN':
        return 'Dikerjakan';
      case 'SELESAI':
        return 'Selesai';
      case 'DITOLAK':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'BELUM_DIKERJAKAN':
        return const Color(0xFFFFFDCC);
      case 'SEDANG_DIKERJAKAN':
        return const Color(0xFFD1E8FF);
      case 'SELESAI':
        return const Color(0xFFDCFCE7);
      case 'DITOLAK':
        return const Color(0xFFFFDAD6);
      default:
        return const Color(0xFFFFFDCC);
    }
  }

  Color statusTextColor(String status) {
    switch (status) {
      case 'BELUM_DIKERJAKAN':
        return const Color(0xFFFF8800);
      case 'SEDANG_DIKERJAKAN':
        return const Color(0xFF004BA0);
      case 'SELESAI':
        return const Color(0xFF166534);
      case 'DITOLAK':
        return const Color(0xFF93000A);
      default:
        return const Color(0xFFFF8800);
    }
  }
}
