import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../routes/app_pages.dart';

class AuthActivationController extends GetxController {
  final Dio api = Dio(BaseOptions(
    baseUrl: 'https://stylar-nonseverable-denver.ngrok-free.dev',
    headers: {'Content-Type': 'application/json'},
  ));

  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  var obscurePassword = true.obs;
  var isLoading = false.obs;
  var passwordError = false.obs;
  var confirmPasswordError = false.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> activation(String token) async {
    if (passwordController.text.trim().isEmpty) {
      passwordError.value = true;
      confirmPasswordError.value = false;
      Get.showSnackbar(
        const GetSnackBar(
          backgroundColor: Color(0xFFFF0000),
          icon: Icon(Icons.dangerous_outlined, size: 45, color: Color(0xFFFFFFFF),),
          title: "Peringatan",
          message: "Password tidak boleh kosong.",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: const EdgeInsets.only(
            left: 15,
            right: 15
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          borderRadius: 10,
        ),
      );
      return;
    }

    if (passwordConfirmationController.text.trim().isEmpty) {
      passwordError.value = false;
      confirmPasswordError.value = true;
      Get.showSnackbar(
        const GetSnackBar(
          backgroundColor: Color(0xFFFF0000),
          icon: Icon(Icons.dangerous_outlined, size: 45, color: Color(0xFFFFFFFF),),
          title: "Peringatan",
          message: "Password tidak boleh kosong.",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: const EdgeInsets.only(
            left: 15,
            right: 15
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          borderRadius: 10,
        ),
      );
      return;
    }

    if (passwordController.text.trim() != passwordConfirmationController.text.trim()) {
      passwordError.value = true;
      confirmPasswordError.value = true;
      Get.showSnackbar(
        const GetSnackBar(
          backgroundColor: Color(0xFFFF0000),
          icon: Icon(Icons.dangerous_outlined, size: 45, color: Color(0xFFFFFFFF),),
          title: "Peringatan",
          message: "Password tidak sama.",
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
          margin: const EdgeInsets.only(
            left: 15,
            right: 15
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          borderRadius: 10,
        ),
      );
      return;
    }

    passwordError.value = false;
    confirmPasswordError.value = false;

    try {
      isLoading.value = true;

      final response = await api.post(
        "/auth/activate-account?token=$token",
        data: {
          "password": passwordController.text.trim(),
          "confirmPassword":
              passwordConfirmationController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        Get.showSnackbar(
          GetSnackBar(
            title: "Berhasil",
            message: response.data["message"],
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          ),
        );

        Get.offAllNamed(Routes.LOGIN);
      }
    } on DioException catch (e) {
      Get.showSnackbar(
        GetSnackBar(
          title: "Gagal",
          message: e.response?.data["message"] ??
              "Terjadi kesalahan.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  //TODO: Implement AuthActivationController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.onClose();
  }

  void increment() => count.value++;
}
