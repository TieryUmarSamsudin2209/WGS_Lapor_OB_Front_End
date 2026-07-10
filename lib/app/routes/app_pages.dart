import 'package:get/get.dart';

import '../modules/application_policy/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/application_policy/privacy_policy/views/privacy_policy_view.dart';
import '../modules/application_policy/terms_conditions/bindings/terms_conditions_binding.dart';
import '../modules/application_policy/terms_conditions/views/terms_conditions_view.dart';
import '../modules/auth_activation/bindings/auth_activation_binding.dart';
import '../modules/auth_activation/views/auth_activation_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/ob/home/bindings/ob_home_binding.dart';
import '../modules/ob/home/views/ob_home_view.dart';
import '../modules/ob/profile/bindings/ob_profile_binding.dart';
import '../modules/ob/profile/views/ob_profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.OB_HOME,
      page: () => const OBHomeView(),
      binding: ObHomeBinding(),
    ),
    GetPage(
      name: _Paths.OB_PROFILE,
      page: () => const ObProfileView(),
      binding: ObProfileBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(showAppBar: true),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportView(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: _Paths.TERMS_CONDITIONS,
      page: () => const TermsConditionsView(),
      binding: TermsConditionsBinding(),
    ),
    GetPage(
      name: _Paths.AUTH_ACTIVATION,
      page: () => const AuthActivationView(),
      binding: AuthActivationBinding(),
    ),
  ];
}
