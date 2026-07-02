import 'package:get/get.dart';

import '../controllers/ob_profil_controller.dart';

class ObProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObProfilController>(
      () => ObProfilController(),
    );
  }
}
