import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/shared/theme/theme_controller.dart';

void main() {
  final themeController = Get.put(ThemeController());

  runApp(
    Obx(
      () => GetMaterialApp(
        title: "Lapor OB",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F4C81),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppDarkColors.accent,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppDarkColors.background,
          canvasColor: AppDarkColors.background,
          cardColor: AppDarkColors.card,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppDarkColors.header,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppDarkColors.surface,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppDarkColors.surface,
          ),
          useMaterial3: true,
        ),
        themeMode: themeController.themeMode.value,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    ),
  );
}
