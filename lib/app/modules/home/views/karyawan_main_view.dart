import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/theme_controller.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../profile/views/profile_view.dart';
import '../../report/views/report_view.dart';
import '../controllers/karyawan_main_controller.dart';
import 'home_view.dart';

class KaryawanMainView extends StatelessWidget {
  const KaryawanMainView({super.key, required this.initialTab});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KaryawanMainController());

    // Sync initial index safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.pageController.hasClients) {
        controller.pageController.jumpToPage(initialTab);
      }
      controller.activeIndex.value = initialTab;
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : const Color(0xFFF4F4F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (index) {
                controller.activeIndex.value = index;
              },
              children: const [
                HomeView(isNested: true),
                ReportPage(isNested: true),
                ProfilePage(isNested: true),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              return KaryawanBottomNav(
                activeIndex: controller.activeIndex.value,
                onTap: (index) {
                  controller.changePage(index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class KaryawanBottomNav extends StatelessWidget {
  const KaryawanBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const navyTextColor = Color(0xFF003366);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FA0FF).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: BottomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: activeIndex == 0,
                onTap: () => onTap(0),
                navyColor: navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.add_circle_outline,
                label: 'Report',
                isActive: activeIndex == 1,
                onTap: () => onTap(1),
                navyColor: navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: activeIndex == 2,
                onTap: () => onTap(2),
                navyColor: navyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
