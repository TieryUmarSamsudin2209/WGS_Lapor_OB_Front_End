import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:get/get.dart';
import 'package:lapor_ob/app/modules/report/controllers/report_controller.dart';
import 'package:lapor_ob/app/modules/profile/views/profile_view.dart';
import 'package:lapor_ob/app/modules/report/views/report_view.dart';

import '../controllers/home_controller.dart';

//Fetching API With Dio Package
final dio = Dio(BaseOptions(
  baseUrl: "https://stylar-nonseverable-denver.ngrok-free.dev/api",
  headers: {
    "Content-Type": "application/json",
  },
));

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return const BottomNavigationLayout();
  }
}

class BottomNavigationLayout extends StatefulWidget {
  const BottomNavigationLayout({super.key});

  @override
  State<BottomNavigationLayout> createState() => _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState extends State<BottomNavigationLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ReportView(),
    const ProfileView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned.fill(child: _pages[_selectedIndex]),
          // Floating bottom navigation bar
          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x660015B0),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.add,
                      label: 'Report',
                      index: 1,
                      isCircularIcon: true,
                    ),
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Profile',
                      index: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isCircularIcon = false,
  }) {
    final bool selected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex == 1 && index != 1) {
          try {
            Get.find<ReportController>().clearForm();
          } catch (_) {}
        }
        setState(() => _selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F4C81) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCircularIcon)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : const Color(0xFF0F4C81),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: selected ? const Color(0xFF0F4C81) : Colors.white,
                ),
              )
            else
              Icon(
                selected ? icon : _outlinedFor(icon),
                color: selected ? Colors.white : const Color(0xFF0F4C81),
                size: 24,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF0F4C81),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _outlinedFor(IconData icon) {
    if (icon == Icons.home) return Icons.home_outlined;
    if (icon == Icons.person) return Icons.person_outline;
    return icon;
  }

  // Exposed helper so child widgets (like HomePage) can switch tabs
  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}