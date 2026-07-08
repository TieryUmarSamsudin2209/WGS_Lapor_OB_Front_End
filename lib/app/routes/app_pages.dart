import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/aktivasi/bindings/aktivasi_binding.dart';
import '../modules/aktivasi/views/aktivasi_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/ob/home/bindings/ob_home_binding.dart';
import '../modules/ob/home/views/ob_home_view.dart';
import '../modules/ob/detail/bindings/ob_detail_binding.dart';
import '../modules/ob/detail/views/ob_detail_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/privacy/views/privacy_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/terms/views/terms_view.dart';

import '../modules/ob/profil/bindings/ob_profil_binding.dart';
import '../modules/ob/profil/views/ob_profil_view.dart';
import '../modules/ob/checklist/bindings/ob_checklist_binding.dart';
import '../modules/ob/checklist/views/ob_checklist_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static Widget _lightOnly(Widget child) {
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: child,
    );
  }

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => _lightOnly(const LoginPage()),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => _lightOnly(const SplashScreenView()),
      binding: SplashScreenBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: _Paths.AKTIVASI,
      page: () => _lightOnly(const AktivasiView()),
      binding: AktivasiBinding(),
    ),
    GetPage(
      name: Routes.OB_DETAIL,
      page: () => const ObDetailView(),
      binding: ObDetailBinding(),
    ),
    GetPage(
      name: Routes.OB_HOME,
      page: () => const OBHomeView(),
      binding: ObHomeBinding(),
    ),
    GetPage(
      name: Routes.OB_PROFIL,
      page: () => const ObProfilView(),
      binding: ObProfilBinding(),
    ),
    GetPage(
      name: Routes.OB_CHECKLIST,
      page: () => const ObChecklistView(),
      binding: ObChecklistBinding(),
    ),
    GetPage(name: Routes.TERMS, page: () => _lightOnly(const TermsView())),
    GetPage(name: Routes.PRIVACY, page: () => _lightOnly(const PrivacyView())),
  ];
}
