import 'package:get/get.dart';

import '../controllers/ob_profile_controller.dart';

class ObProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObProfileController>(
      () => ObProfileController(),
    );
  }
}
