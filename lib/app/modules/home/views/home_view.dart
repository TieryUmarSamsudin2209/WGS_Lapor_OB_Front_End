import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

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
  State<BottomNavigationLayout> createState() =>
      _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState extends State<BottomNavigationLayout> {
  final Color navyColor = const Color(0xFF0F4C81);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: navyColor,
        title: const Text('Beranda'),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(
              foregroundColor: navyColor,
              backgroundColor: Colors.white,
            ),
            onPressed: () {
              // Handle notification press
            },
          )
        ],
      ),
      body: const HomePage(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
              // --- Item 1: Home (already here) ---
              _buildNavItem(
                icon: Icons.home,
                outlineIcon: Icons.home_outlined,
                label: 'Home',
                isActive: true,
                onTap: () {
                  // Already on Home, no navigation needed.
                },
              ),

              // --- Item 2: Report ---
              _buildNavItem(
                icon: Icons.add,
                outlineIcon: Icons.add,
                label: 'Report',
                isActive: false,
                onTap: () => Get.toNamed(Routes.REPORT),
              ),

              // --- Item 3: Profile ---
              _buildNavItem(
                icon: Icons.person,
                outlineIcon: Icons.person_outline,
                label: 'Profile',
                isActive: false,
                onTap: () => Get.toNamed(Routes.PROFILE),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData outlineIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? navyColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : outlineIcon,
              color: isActive ? Colors.white : navyColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : navyColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final Color navyColor = const Color(0xFF0F4C81);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: navyColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Pagi,',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Alex Karyawan',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => Get.toNamed(Routes.REPORT),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20, color: navyColor),
                          const SizedBox(width: 2),
                          Text(
                            'Laporkan masalah baru',
                            style: TextStyle(color: navyColor, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        icon: Icons.plumbing_outlined,
                        label: 'Kebersihan',
                        onTap: () =>
                            Get.toNamed(Routes.REPORT, arguments: 'Plumbing'),
                      ),
                      _buildCategoryItem(
                        icon: Icons.chair_outlined,
                        label: 'Peralatan',
                        onTap: () =>
                            Get.toNamed(Routes.REPORT, arguments: 'Furniture'),
                      ),
                      _buildCategoryItem(
                        icon: Icons.air_outlined,
                        label: 'Maintenance',
                        onTap: () =>
                            Get.toNamed(Routes.REPORT, arguments: 'HVAC'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: navyColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktivitas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.PROFILE),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActivityCard(
                  icon: Icons.plumbing_outlined,
                  title: 'Leaking Pipe in Restroom B',
                  subtitle: 'Reported: Today, 09:30 AM • ID: #REP-2023-11A',
                  statusIcon: Icons.sync,
                  statusLabel: 'In Progress',
                ),
                const SizedBox(height: 8),
                _buildActivityCard(
                  icon: Icons.electric_bolt_outlined,
                  title: 'Flickering Lights in Meeting Room 4',
                  subtitle:
                      'Reported: Yesterday, 14:15 PM • ID: #REP-2023-10X',
                  statusIcon: Icons.check_circle_outline,
                  statusLabel: 'Resolved',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: Colors.white,
          ),
          child: Icon(icon, size: 30, color: navyColor),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required String statusLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC7C7C7), width: 1),
                ),
                child: Icon(icon, size: 30, color: const Color(0xFF9F9F9F)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: navyColor,
                      ),
                    ),
                    Text(subtitle),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDECFF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 18, color: navyColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}