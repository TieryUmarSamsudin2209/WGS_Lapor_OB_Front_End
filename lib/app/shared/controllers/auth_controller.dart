import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService authService = Get.isRegistered<AuthService>()
      ? Get.find<AuthService>()
      : Get.put(AuthService(), permanent: true);

  final isLoading = false.obs;

  Future<bool> login(
    String identifier,
    String password, {
    bool showError = true,
  }) async {
    if (isLoading.value) return false;

    isLoading.value = true;
    final success = await authService.login(
      identifier: identifier,
      password: password,
    );
    isLoading.value = false;

    if (!success && showError) {
      Get.snackbar('Error', 'Login gagal');
    }

    return success;
  }

  Future<void> logout() async {
    await authService.clearSession();
    Get.offAllNamed(Routes.LOGIN);
  }
}
