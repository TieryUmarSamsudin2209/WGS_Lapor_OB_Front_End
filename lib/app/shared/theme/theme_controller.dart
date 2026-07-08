import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDarkColors {
  static const background = Color(0xFF020407);
  static const header = Color(0xFF07172B);
  static const surface = Color(0xFF0B1118);
  static const surfaceVariant = Color(0xFF111923);
  static const card = Color(0xFF121B24);
  static const border = Color(0xFF223145);
  static const accent = Color(0xFF2D8EFF);
}

class ThemeController extends GetxController {
  final themeMode = ThemeMode.light.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme() {
    themeMode.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }
}
