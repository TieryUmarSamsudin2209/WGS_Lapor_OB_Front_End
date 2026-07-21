import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/controllers/auth_controller.dart';
import '../../../shared/services/auth_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final errorMessage = ''.obs;
  final token = RxnString();
  final user = Rxn<Map<String, dynamic>>();

  late final AuthService _authService;
  late final AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : Get.put(AuthService(), permanent: true);
    _authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController(), permanent: true);
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void clearErrorMessage() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;
    errorMessage.value = '';

    if (!(formKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {
      final success = await _authController.login(
        identifierController.text.trim(),
        passwordController.text,
        showError: false,
      );

      if (success) {
        token.value = _authService.token.value;
        user.value = _authService.user.value;
        Get.offAllNamed(
          _dashboardRouteFor(
            user.value,
            fallbackRole: _authService.role.value,
            fallbackIdentifier: identifierController.text.trim(),
          ),
        );
        return;
      }

      final errorMsg = _authService.lastRequestError;
      if (errorMsg != null && errorMsg.isNotEmpty) {
        errorMessage.value = errorMsg;
      } else {
        errorMessage.value =
            'Password atau konfirmasi passowrd salah. Silakan coba lagi.';
      }
    } catch (_) {
      errorMessage.value =
          'Tidak dapat terhubung ke server. Coba lagi sebentar.';
    } finally {
      isLoading.value = false;
    }
  }

  String _dashboardRouteFor(
    Map<String, dynamic>? userData, {
    Object? fallbackRole,
    String? fallbackIdentifier,
  }) {
    final role = (userData?['role'] ?? fallbackRole)
            ?.toString()
            .trim()
            .toLowerCase()
            .replaceAll(' ', '_') ??
        '';
    final identifier = (userData?['username'] ??
            userData?['email'] ??
            fallbackIdentifier ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    if (role == 'ob' ||
        role == 'office_boy' ||
        role.contains('ob') ||
        identifier.split('@').first.startsWith('ob')) {
      return Routes.OB_HOME;
    }

    if (role == 'admin' ||
        role == 'karyawan' ||
        role == 'employee' ||
        role == 'hr') {
      return Routes.HOME;
    }

    return Routes.HOME;
  }
}
