import 'package:get/get.dart';

import '../controllers/ob_home_controller.dart';

class ObHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObHomeController>(
      () => ObHomeController(),
    );
  }
}
