import 'package:get/get.dart';

import '../controllers/ob_detail_tugas_controller.dart';

class ObDetailTugasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObDetailTugasController>(
      () => ObDetailTugasController(),
    );
  }
}
