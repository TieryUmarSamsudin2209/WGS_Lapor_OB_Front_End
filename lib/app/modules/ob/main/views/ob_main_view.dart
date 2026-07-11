import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../../checklist/views/ob_checklist_view.dart';
import '../../home/views/ob_home_view.dart';
import '../../profil/views/ob_profil_view.dart';
import '../controllers/ob_main_controller.dart';

class ObMainView extends StatelessWidget {
  const ObMainView({super.key, required this.initialTab});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ObMainController());

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
                OBHomeView(isNested: true),
                ObChecklistView(isNested: true),
                ObProfilView(isNested: true),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              return ObBottomNav(
                activeItem: _getItemFromIndex(controller.activeIndex.value),
                onTap: (item) {
                  controller.changePage(_getIndexFromItem(item));
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  ObBottomNavItem _getItemFromIndex(int index) {
    switch (index) {
      case 0:
        return ObBottomNavItem.home;
      case 1:
        return ObBottomNavItem.checklist;
      case 2:
        return ObBottomNavItem.profile;
      default:
        return ObBottomNavItem.home;
    }
  }

  int _getIndexFromItem(ObBottomNavItem item) {
    switch (item) {
      case ObBottomNavItem.home:
        return 0;
      case ObBottomNavItem.checklist:
        return 1;
      case ObBottomNavItem.profile:
        return 2;
    }
  }
}
