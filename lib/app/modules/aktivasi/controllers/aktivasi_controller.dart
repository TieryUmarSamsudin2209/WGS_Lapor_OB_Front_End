import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/services/auth_service.dart';

class AktivasiController extends GetxController {
  final AuthService _authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isActivationFailed = false.obs;
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final token = RxnString();

  @override
  void onInit() {
    super.onInit();
    token.value = _activationToken();
    isActivationFailed.value =
        _hasFailedActivationState() || (token.value?.isEmpty ?? true);
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void showActivationFailed() {
    isActivationFailed.value = true;
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  Future<void> activateAccount() async {
    if (isLoading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final activationToken = token.value?.trim();
    if (activationToken == null || activationToken.isEmpty) {
      showActivationFailed();
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authService.activateAccount(
        activationToken: activationToken,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (response == null) {
        Get.snackbar(
          'Aktivasi gagal',
          _authService.lastRequestError ??
              'Token tidak valid atau password tidak cocok.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
        return;
      }

      Get.snackbar(
        'Aktivasi berhasil',
        _messageFromResponse(response) ??
            'Akun berhasil diaktivasi, silakan login.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
      );
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  bool _hasFailedActivationState() {
    final arguments = Get.arguments;
    if (arguments == true) {
      return true;
    }

    if (arguments is String) {
      final status = arguments.toLowerCase();
      return status == 'failed' || status == 'gagal';
    }

    if (arguments is Map) {
      final failed = arguments['failed'] == true;
      final status = arguments['status']?.toString().toLowerCase();
      if (failed || status == 'failed' || status == 'gagal') {
        return true;
      }
    }

    final status = Get.parameters['status']?.toLowerCase();
    final error = Get.parameters['error'];
    return status == 'failed' || status == 'gagal' || error != null;
  }

  String? _activationToken() {
    final parameterToken = Get.parameters['token']?.trim();
    if (parameterToken != null && parameterToken.isNotEmpty) {
      return parameterToken;
    }

    final arguments = Get.arguments;
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }

    if (arguments is Map) {
      final value =
          arguments['token'] ??
          arguments['activationToken'] ??
          arguments['activation_token'];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }

    return null;
  }

  String? _messageFromResponse(Map<String, dynamic> response) {
    for (final key in ['message', 'pesan']) {
      final value = response[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final data = response['data'];
    if (data is Map) {
      for (final key in ['message', 'pesan']) {
        final value = data[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }

    return null;
  }
}
