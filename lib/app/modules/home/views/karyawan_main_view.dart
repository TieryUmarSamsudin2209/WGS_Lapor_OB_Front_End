import 'package:flutter/material.dart';

import '../../../shared/theme/theme_controller.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../profile/views/profile_view.dart';
import '../../report/views/report_view.dart';
import 'home_view.dart';

class KaryawanMainView extends StatefulWidget {
  const KaryawanMainView({super.key, required this.initialTab});

  final int initialTab;

  @override
  State<KaryawanMainView> createState() => _KaryawanMainViewState();
}

class _KaryawanMainViewState extends State<KaryawanMainView> {
  late final PageController _pageController;
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = _safeTab(widget.initialTab);
    _pageController = PageController(initialPage: _activeIndex);
  }

  @override
  void didUpdateWidget(covariant KaryawanMainView oldWidget) {
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
            child: KaryawanBottomNav(
              activeIndex: _activeIndex,
              onTap: _changePage,
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
