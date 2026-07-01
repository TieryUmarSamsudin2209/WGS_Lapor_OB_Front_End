import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  //TODO: Implement SplashScreenController

  var progressValue = 0.0.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    loadingSection();
  }

  void loadingSection() async {
    await Future.delayed(Duration(seconds: 2));
    progressValue.value = 0.3;
    await Future.delayed(Duration(seconds: 2));
    progressValue.value = 0.6;
    await Future.delayed(Duration(seconds: 2));
    progressValue.value = 1.0;
    await Future.delayed(Duration(milliseconds: 500));
    Get.offNamed('/home');
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
