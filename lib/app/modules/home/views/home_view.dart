import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF3F6FA), // Warna latar belakang abu-abu sangat muda
      body: HomePage(),
      extendBody: true, // Agar konten bisa di-scroll sampai ke bawah navigasi
      bottomNavigationBar: BottomNavigationLayout(),
    );
  }
}

// --- WIDGET FLOATING NAVIGATION BAR ---
class BottomNavigationLayout extends StatelessWidget {
  const BottomNavigationLayout({super.key});

  final Color navyColor = const Color(0xFF0F4C81);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FA0FF).withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: BottomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: true,
                onTap: () {},
                navyColor: navyColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.add_circle,
                label: 'Report',
                isActive: false,
                onTap: () => Get.toNamed(Routes.REPORT),
                navyColor: navyColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: false,
                onTap: () => Get.toNamed(Routes.PROFILE),
                navyColor: navyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KONTEN UTAMA ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final Color navyColor = const Color(0xFF0F4C81);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120), // Ruang untuk Floating Nav
      child: Column(
        children: [
          // --- HEADER & KATEGORI (BACKGROUND BIRU) ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: navyColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Beranda',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Selamat Pagi,',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        const Text(
                          'Alex Karyawan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // TOMBOL LAPORKAN MASALAH
                    Hero(
                      tag: 'submit-report',
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: navyColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Get.toNamed(Routes.REPORT),
                          icon: Icon(Icons.add, size: 20, color: navyColor),
                          label: Text(
                            'Laporkan masalah baru',
                            style: TextStyle(
                              color: navyColor, 
                              fontSize: 15, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 35),
                    
                    const Text(
                      'Kategori',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // GRID KATEGORI (TATA LETAK PRESISI)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: 'category-Plumbing',
                          child: _buildCategoryItem(
                            icon: Icons.home_outlined,
                            label: 'Kebersihan',
                            onTap: () => Get.toNamed(Routes.REPORT, arguments: 'Plumbing'),
                          ),
                        ),
                        Hero(
                          tag: 'category-Furniture',
                          child: _buildCategoryItem(
                            icon: Icons.chair_outlined,
                            label: 'Peralatan',
                            onTap: () => Get.toNamed(Routes.REPORT, arguments: 'Furniture'),
                          ),
                        ),
                        Hero(
                          tag: 'category-HVAC',
                          child: _buildCategoryItem(
                            icon: Icons.local_laundry_service_outlined,
                            label: 'Maintenance',
                            onTap: () => Get.toNamed(Routes.REPORT, arguments: 'HVAC'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: 'category-Miscellaneous',
                          child: _buildCategoryItem(
                            icon: Icons.home_outlined,
                            label: 'Miscellaneous',
                            onTap: () => Get.toNamed(Routes.REPORT, arguments: 'Miscellaneous'),
                          ),
                        ),
                        _buildCategoryItem(
                          icon: Icons.chair_outlined,
                          label: 'Blum ada',
                          onTap: () {},
                        ),
                        _buildCategoryItem(
                          icon: Icons.local_laundry_service_outlined,
                          label: 'Blum ada',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20), // Celah putih
          
          // --- AKTIVITAS CARD (BACKGROUND BIRU) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: navyColor,
              borderRadius: BorderRadius.circular(25),
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
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.PROFILE),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // KARTU AKTIVITAS 1
                _buildActivityCard(
                  icon: Icons.home_outlined,
                  title: 'Leaking Pipe in\nRestroom B',
                  subtitle: 'Reported: Today, 09:30 AM • ID:\n#REP-2023-11A',
                  statusIcon: Icons.remove_circle_outline, // Ikon minus melingkar
                  statusLabel: 'In Progress',
                ),
                const SizedBox(height: 15),
                
                // KARTU AKTIVITAS 2
                _buildActivityCard(
                  icon: Icons.electric_bolt_outlined,
                  title: 'Flickering Lights in\nMeeting Room 4',
                  subtitle: 'Reported: Yesterday, 14:15 PM •\nID: #REP-2023-10X',
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

  // HELPER: KATEGORI ITEM
  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90, // Lebar kotak putih sesuai desain
        child: Column(
          children: [
            Container(
              height: 55,
              width: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: navyColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER: KARTU AKTIVITAS (PUTIH)
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
        borderRadius: BorderRadius.circular(15),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IKON KIRI DENGAN BORDER
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Icon(icon, size: 24, color: Colors.blueGrey),
              ),
              const SizedBox(width: 15),
              
              // TEKS UTAMA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: navyColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // BADGE STATUS (KANAN BAWAH)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FA), // Biru sangat muda (Light Blue)
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: navyColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}