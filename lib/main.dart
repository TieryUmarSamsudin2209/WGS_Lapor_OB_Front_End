import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/shared/controllers/auth_controller.dart';
import 'app/shared/services/auth_service.dart';
import 'app/shared/theme/theme_controller.dart';
import 'app/shared/translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTranslations.init();

  final authService = Get.put(AuthService(), permanent: true);
  await authService.loadSession();
  Get.put(AuthController(), permanent: true);

  final themeController = Get.put(ThemeController());

  runApp(
    Obx(
      () => GetMaterialApp(
        title: "Lapor OB",
        translations: AppTranslations(),
        locale: const Locale('id'),
        fallbackLocale: const Locale('id'),
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
