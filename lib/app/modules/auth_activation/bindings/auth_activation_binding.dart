import 'package:get/get.dart';

import '../controllers/auth_activation_controller.dart';

class AuthActivationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthActivationController>(
      () => AuthActivationController(),
    );
  }
}
