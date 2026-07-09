import 'package:get/get.dart';

import '../controllers/ob_notifications_controller.dart';

class ObNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObNotificationsController>(
      () => ObNotificationsController(),
    );
  }
}
