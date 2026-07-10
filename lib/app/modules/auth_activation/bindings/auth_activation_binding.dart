import 'package:get/get.dart';

import '../controllers/auth_activation_controller.dart';
import '../../../data/providers/api_services.dart';

class AuthActivationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.lazyPut<AuthActivationController>(
      () => AuthActivationController(),
    );
  }
}
