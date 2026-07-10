import 'package:get/get.dart';
import 'package:lapor_ob/app/shared/services/login_services.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LoginService>()) {
      Get.put(LoginService(), permanent: true);
    }
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController(), permanent: true);
    }
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}