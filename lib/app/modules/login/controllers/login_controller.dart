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

  Future<void> login() async {
    if (isLoading.value) return;
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
          _dashboardRouteFor(user.value, fallbackRole: _authService.role.value),
        );
        return;
      }

      _showError('Login gagal. Periksa email dan password Anda.');
    } catch (_) {
      _showError('Tidak dapat terhubung ke server. Coba lagi sebentar.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Login gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
    );
  }

  String _dashboardRouteFor(
    Map<String, dynamic>? userData, {
    Object? fallbackRole,
  }) {
    final role = (userData?['role'] ?? fallbackRole)
            ?.toString()
            .trim()
            .toLowerCase()
            .replaceAll(' ', '_') ??
        '';

    if (role == 'ob' ||
        role == 'office_boy' ||
        role.contains('ob')) {
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
