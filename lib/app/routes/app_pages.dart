import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../modules/aktivasi/bindings/aktivasi_binding.dart';
import '../modules/aktivasi/views/aktivasi_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/karyawan_main_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/ob/checklist/bindings/ob_checklist_binding.dart';
import '../modules/ob/collaboration/bindings/ob_collaboration_binding.dart';
import '../modules/ob/collaboration/views/ob_collaboration_view.dart';
import '../modules/ob/detail/bindings/ob_detail_binding.dart';
import '../modules/ob/detail/views/ob_detail_view.dart';
import '../modules/ob/detail_tugas/bindings/ob_detail_tugas_binding.dart';
import '../modules/ob/detail_tugas/views/ob_detail_tugas_view.dart';
import '../modules/ob/home/bindings/ob_home_binding.dart';
import '../modules/ob/notifications/bindings/ob_notifications_binding.dart';
import '../modules/ob/notifications/views/ob_notifications_view.dart';
import '../modules/ob/profil/bindings/ob_profil_binding.dart';
import '../modules/ob/reports/bindings/ob_reports_binding.dart';
import '../modules/ob/reports/views/ob_reports_view.dart';
import '../modules/ob/main/views/ob_main_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/privacy/views/privacy_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/employee_report_detail_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';
import '../modules/terms/views/terms_view.dart';

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
      page: () => const KaryawanMainView(initialTab: 0),
      bindings: [
        HomeBinding(),
        ReportBinding(),
        ProfileBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const KaryawanMainView(initialTab: 2),
      bindings: [
        HomeBinding(),
        ReportBinding(),
        ProfileBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.REPORT_DETAIL,
      page: () => const EmployeeReportDetailView(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const KaryawanMainView(initialTab: 1),
      bindings: [
        HomeBinding(),
        ReportBinding(),
        ProfileBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),
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
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.OB_DETAIL_TUGAS,
      page: () => const ObDetailTugasView(),
      binding: ObDetailTugasBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.OB_HOME,
      page: () => const ObMainView(initialTab: 0),
      bindings: [
        ObHomeBinding(),
        ObChecklistBinding(),
        ObProfilBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 1),
    ),
    GetPage(
      name: Routes.OB_PROFIL,
      page: () => const ObMainView(initialTab: 2),
      bindings: [
        ObHomeBinding(),
        ObChecklistBinding(),
        ObProfilBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 1),
    ),
    GetPage(
      name: Routes.OB_CHECKLIST,
      page: () => const ObMainView(initialTab: 1),
      bindings: [
        ObHomeBinding(),
        ObChecklistBinding(),
        ObProfilBinding(),
      ],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 1),
    ),
    GetPage(
      name: Routes.OB_NOTIFICATIONS,
      page: () => const ObNotificationsView(),
      binding: ObNotificationsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.OB_REPORTS,
      page: () => const ObReportsView(),
      binding: ObReportsBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: Routes.OB_COLLABORATION,
      page: () => const ObCollaborationView(),
      binding: ObCollaborationBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(name: Routes.TERMS, page: () => _lightOnly(const TermsView())),
    GetPage(name: Routes.PRIVACY, page: () => _lightOnly(const PrivacyView())),
  ];
}
