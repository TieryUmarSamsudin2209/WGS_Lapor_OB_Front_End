import 'package:get/get.dart';
import '../controllers/ob_checklist_controller.dart';

class ObChecklistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObChecklistController>(
      () => ObChecklistController(),
    );
  }
}
