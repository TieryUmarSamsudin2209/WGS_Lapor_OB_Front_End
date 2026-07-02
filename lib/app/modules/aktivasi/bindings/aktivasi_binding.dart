import 'package:get/get.dart';

import '../controllers/aktivasi_controller.dart';

class AktivasiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AktivasiController>(
      () => AktivasiController(),
    );
  }
}