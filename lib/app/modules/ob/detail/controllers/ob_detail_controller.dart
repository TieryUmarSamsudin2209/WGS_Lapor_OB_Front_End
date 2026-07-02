import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ObDetailController extends GetxController {
  var pageState = 'initial'.obs;
  var isDetailExpanded = true.obs;
  var isNeedHelp = false.obs;

  final noteController = TextEditingController();
  final actionPhotos = <String>[].obs;

  void setWorking() {
    pageState.value = 'working';
    isDetailExpanded.value = false;
  }

  void setRejecting() {
    if (pageState.value == 'working') {
      pageState.value = 'rejecting';
      isDetailExpanded.value = false;
    }
  }

  void toggleNeedHelp() {
    isNeedHelp.value = !isNeedHelp.value;
  }

  void completeReport() {
    pageState.value = 'completed';
    isDetailExpanded.value = false;
  }

  void finishAndGoBack() {
    Get.snackbar('Sukses', 'Laporan berhasil diselesaikan',
        backgroundColor: Colors.green, colorText: Colors.white);
    Get.offNamed('/home');
  }

  void confirmReject() {
    Get.snackbar('Ditolak', 'Laporan berhasil ditolak',
        backgroundColor: Colors.red, colorText: Colors.white);
    Get.back();
  }

  void toggleDetailExpand() {
    isDetailExpanded.value = !isDetailExpanded.value;
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}