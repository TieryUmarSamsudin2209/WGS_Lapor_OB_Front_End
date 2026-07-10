import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lapor_ob/app/shared/services/login_services.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final token = RxnString();
  final user = Rxn<Map<String, dynamic>>();

  late final LoginService _loginService;

  @override
  void onInit() {
    super.onInit();
    _loginService = Get.find<LoginService>();
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
      final success = await _loginService.login(
        identifier: identifierController.text.trim(),
        password: passwordController.text,
      );

      if (success) {
        token.value = _loginService.token.value;
        user.value = _loginService.user.value;

        Get.offAllNamed(
          _dashboardRouteFor(
            user.value,
            fallbackRole: _loginService.role.value,
            fallbackIdentifier: identifierController.text.trim(),
          ),
        );
      } else {
        _showError('Login gagal. Periksa email/username dan password Anda.');
      }
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

