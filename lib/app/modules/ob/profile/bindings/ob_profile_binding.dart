import 'package:get/get.dart';

import '../controllers/ob_profile_controller.dart';
import '../../home/controllers/ob_home_controller.dart';

class ObProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ObHomeController());
    Get.lazyPut(
      () => ObProfileController(),
      fenix: true,
    );
  }
}
