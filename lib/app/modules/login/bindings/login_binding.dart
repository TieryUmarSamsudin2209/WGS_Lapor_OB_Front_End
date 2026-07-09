import 'package:get/get.dart';

import '../../../shared/controllers/auth_controller.dart';
import '../../../shared/services/auth_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
