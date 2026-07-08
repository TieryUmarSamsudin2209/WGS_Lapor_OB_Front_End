import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/theme/theme_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppDarkColors.background
          : const Color(0xFFF3F6FA), // Warna latar belakang abu-abu sangat muda
      body: const HomePage(),
      extendBody: true, // Agar konten bisa di-scroll sampai ke bawah navigasi
      bottomNavigationBar: const BottomNavigationLayout(),
    );
  }
}

// --- WIDGET FLOATING NAVIGATION BAR ---
class BottomNavigationLayout extends StatelessWidget {
  const BottomNavigationLayout({super.key});

  final Color navyColor = const Color(0xFF0F4C81);
  static const _darkNav = Color(0xFF101418);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
      child: Container(
        height: 70,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? _darkNav : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: isDark
              ? Border.all(
                  color: AppDarkColors.border.withValues(alpha: 0.75),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : const Color(0xFF4FA0FF).withValues(alpha: 0.3),
              blurRadius: isDark ? 10 : 25,
              spreadRadius: isDark ? 0 : 2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? AppDarkColors.surface : navyColor;
    final sectionBorderColor =
        isDark ? AppDarkColors.border : Colors.transparent;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(top: 320),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: sectionBorderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            onTap: () => Get.toNamed(Routes.REPORT,
                                arguments: 'Plumbing'),
                          ),
                        ),
                        Hero(
                          tag: 'category-Furniture',
                          child: _buildCategoryItem(
                            icon: Icons.chair_outlined,
                            label: 'Peralatan',
                            onTap: () => Get.toNamed(Routes.REPORT,
                                arguments: 'Furniture'),
                          ),
                        ),
                        Hero(
                          tag: 'category-HVAC',
                          child: _buildCategoryItem(
                            icon: Icons.local_laundry_service_outlined,
                            label: 'Maintenance',
                            onTap: () =>
                                Get.toNamed(Routes.REPORT, arguments: 'HVAC'),
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
                            onTap: () => Get.toNamed(Routes.REPORT,
                                arguments: 'Miscellaneous'),
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

              const SizedBox(height: 20), // Celah putih
          
          // --- AKTIVITAS CARD (BACKGROUND BIRU) ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sectionColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: sectionBorderColor),
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
                      child: Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppDarkColors.accent : Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // KARTU AKTIVITAS 1
                _buildActivityCard(
                  context: context,
                  icon: Icons.home_outlined,
                  title: 'Leaking Pipe in\nRestroom B',
                  subtitle: 'Reported: Today, 09:30 AM • ID:\n#REP-2023-11A',
                  statusIcon: Icons.remove_circle_outline, // Ikon minus melingkar
                  statusLabel: 'In Progress',
                ),
                const SizedBox(height: 15),
                
                // KARTU AKTIVITAS 2
                _buildActivityCard(
                  context: context,
                  icon: Icons.electric_bolt_outlined,
                  title: 'Flickering Lights in\nMeeting Room 4',
                  subtitle: 'Reported: Yesterday, 14:15 PM •\nID: #REP-2023-10X',
                  statusIcon: Icons.check_circle_outline,
                  statusLabel: 'Resolved',
                ),
              ],
            ),
          ),
              const SizedBox(height: 140),
            ],
          ),
        ),
        _buildPinnedHeader(context),
      ],
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportButtonBg = isDark ? Colors.transparent : Colors.white;
    final reportButtonFg = isDark ? AppDarkColors.accent : navyColor;
    final reportButtonBorder =
        isDark ? AppDarkColors.accent : Colors.transparent;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.header : navyColor,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Beranda',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      _buildThemeButton(),
                      const SizedBox(width: 8),
                      _buildNotificationButton(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'Selamat Pagi,',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 2),
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'Alex Karyawan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                      backgroundColor: reportButtonBg,
                      foregroundColor: reportButtonFg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: reportButtonBorder, width: 1.4),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Get.toNamed(Routes.REPORT),
                    icon: Icon(Icons.add, size: 20, color: reportButtonFg),
                    label: Text(
                      'Laporkan masalah baru',
                      style: TextStyle(
                        color: reportButtonFg,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER: KATEGORI ITEM
  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    final itemColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : Colors.transparent;
    final iconColor = isDark ? AppDarkColors.accent : navyColor;
    final labelColor = isDark ? Colors.white70 : Colors.white;

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
                color: itemColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton() {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Tooltip(
        message: themeController.isDarkMode ? 'Mode terang' : 'Mode gelap',
        child: Material(
          color: themeController.isDarkMode
              ? AppDarkColors.surfaceVariant
              : const Color(0xFF0D3A62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: themeController.isDarkMode
                ? const BorderSide(color: AppDarkColors.border)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: themeController.toggleTheme,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Tooltip(
      message: 'Notifikasi',
      child: Material(
        color: Get.isDarkMode
            ? AppDarkColors.surfaceVariant
            : const Color(0xFF0D3A62),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: Get.isDarkMode
              ? const BorderSide(color: AppDarkColors.border)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => Get.snackbar(
            'Notifikasi',
            'Belum ada notifikasi baru',
            snackPosition: SnackPosition.TOP,
          ),
          borderRadius: BorderRadius.circular(8),
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  // HELPER: KARTU AKTIVITAS (PUTIH)
  Widget _buildActivityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required String statusLabel,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final titleColor = isDark ? Colors.white : navyColor;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey;
    final iconBorderColor =
        isDark ? AppDarkColors.border : Colors.grey.shade300;
    final iconColor = isDark ? AppDarkColors.accent : Colors.blueGrey;
    final badgeColor =
        isDark ? const Color(0xFF052C58) : const Color(0xFFE6F0FA);
    final badgeTextColor = isDark ? AppDarkColors.accent : navyColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: isDark ? Border.all(color: AppDarkColors.border) : null,
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
                  border: Border.all(color: iconBorderColor, width: 1.5),
                ),
                child: Icon(icon, size: 24, color: iconColor),
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
                        color: titleColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor,
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
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: badgeTextColor),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
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
