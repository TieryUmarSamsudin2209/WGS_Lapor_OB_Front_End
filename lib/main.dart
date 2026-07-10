import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/shared/services/login_services.dart';
import 'app/data/providers/api_services.dart';

void main() {
  Get.put(ApiService(), permanent: true);
  Get.put(LoginService(), permanent: true);
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
