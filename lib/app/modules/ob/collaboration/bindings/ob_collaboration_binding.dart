import 'package:get/get.dart';

import '../controllers/ob_collaboration_controller.dart';

class ObCollaborationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObCollaborationController>(
      () => ObCollaborationController(),
    );
  }
}
