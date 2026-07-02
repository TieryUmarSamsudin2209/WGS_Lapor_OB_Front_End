import 'package:get/get.dart';
// import '../../../routes/app_pages.dart'; // Uncomment nanti

class SplashScreenController extends GetxController {
  var progressValue = 0.0.obs;
  var isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    startAnimation();
  }

  void startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    isLoaded.value = true;

    for (double i = 0; i <= 1.0; i += 0.015) {
      await Future.delayed(const Duration(milliseconds: 25));
      progressValue.value = i;
    }

    progressValue.value = 1.0;

    await Future.delayed(const Duration(milliseconds: 500));

    // If user is deep-linking to a route (e.g. /detail on web),
    // don't force redirect to Aktivasi.
    final String fragment =
        Uri.base.fragment; // e.g. "detail" when URL is /# /detail
    final String path = Uri.base.path; // e.g. "/detail" or "/ob/detail"

    final String current = Get
        .currentRoute; // e.g. "/ob/detail" or "/detail" depending on routing mode

    final bool isDetailDeepLink =
        fragment.contains('detail') ||
        path.contains('detail') ||
        current.contains('detail');

    if (!isDetailDeepLink) {
      Get.offNamed('/ob/detail');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
