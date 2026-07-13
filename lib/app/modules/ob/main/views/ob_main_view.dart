import 'package:flutter/material.dart';

import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../../checklist/views/ob_checklist_view.dart';
import '../../home/views/ob_home_view.dart';
import '../../profil/views/ob_profil_view.dart';

class ObMainView extends StatefulWidget {
  const ObMainView({super.key, required this.initialTab});

  final int initialTab;

  @override
  State<ObMainView> createState() => _ObMainViewState();
}

class _ObMainViewState extends State<ObMainView> {
  late final PageController _pageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = _safeTab(widget.initialTab);
    _pageController = PageController(initialPage: _activeIndex);
  }

  @override
  void didUpdateWidget(covariant ObMainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextTab = _safeTab(widget.initialTab);
    if (nextTab == _activeIndex) return;
    _activeIndex = nextTab;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextTab);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : const Color(0xFFF4F4F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _activeIndex = index);
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
            child: ObBottomNav(
              activeItem: _getItemFromIndex(_activeIndex),
              onTap: (item) => _changePage(_getIndexFromItem(item)),
            ),
          ),
        ],
      ),
    );
  }

  void _changePage(int index) {
    final nextIndex = _safeTab(index);
    setState(() => _activeIndex = nextIndex);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
  }

  int _safeTab(int index) => index.clamp(0, 2);

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
