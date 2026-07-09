import 'package:get/get.dart';

import '../controllers/ob_reports_controller.dart';

class ObReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObReportsController>(
      () => ObReportsController(),
    );
  }
}
