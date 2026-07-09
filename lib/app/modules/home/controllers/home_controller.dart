import 'package:get/get.dart';

import '../../../shared/services/auth_service.dart';

class HomeController extends GetxController {
  final count = 0.obs;
  final name = 'Karyawan'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    if (!Get.isRegistered<AuthService>()) return;

    final user = Get.find<AuthService>().user.value;
    final displayName = user?['username'] ?? user?['name'] ?? user?['email'];
    if (displayName != null && displayName.toString().trim().isNotEmpty) {
      name.value = displayName.toString();
    }
  }

  void increment() => count.value++;
}
