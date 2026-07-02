import 'package:get/get.dart';

import '../controllers/ob_detail_controller.dart';

class ObDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObDetailController>(
      () => ObDetailController(),
    );
  }
}
