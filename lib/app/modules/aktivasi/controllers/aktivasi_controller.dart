import 'package:get/get.dart';

class AktivasiController extends GetxController {
  final isActivationFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    isActivationFailed.value = _hasFailedActivationState();
  }

  void showActivationFailed() {
    isActivationFailed.value = true;
  }

  bool _hasFailedActivationState() {
    final arguments = Get.arguments;
    if (arguments == true) {
      return true;
    }

    if (arguments is String) {
      final status = arguments.toLowerCase();
      return status == 'failed' || status == 'gagal';
    }

    if (arguments is Map) {
      final failed = arguments['failed'] == true;
      final status = arguments['status']?.toString().toLowerCase();
      if (failed || status == 'failed' || status == 'gagal') {
        return true;
      }
    }

    final status = Get.parameters['status']?.toLowerCase();
    final error = Get.parameters['error'];
    return status == 'failed' || status == 'gagal' || error != null;
  }
}
