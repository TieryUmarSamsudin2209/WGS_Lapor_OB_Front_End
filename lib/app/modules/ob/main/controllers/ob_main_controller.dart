import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ObMainController extends GetxController {
  final pageController = PageController();
  final activeIndex = 0.obs;

  void changePage(int index) {
    activeIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
