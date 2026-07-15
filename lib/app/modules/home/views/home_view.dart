import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../controllers/home_controller.dart';
import '../controllers/karyawan_main_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key, this.isNested = false});

  final bool isNested;

  static const _blue = Color(0xFF0F4C81);
  static const _buttonBlue = Color(0xFF16A9F5);
  static const _pageBg = Color(0xFFF4F4F8);
  static const _lightText = Color(0xFF202536);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    final headerHeight = topPadding + 208;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            top: headerHeight,
            child: _HomeContent(controller: controller),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: _HomeHeader(controller: controller),
          ),
          if (!isNested)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigationLayout(),
            ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? AppDarkColors.header : HomeView._blue;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final cardBorderColor =
        isDark ? AppDarkColors.border : Colors.transparent;
    final headlineColor = isDark ? Colors.white : HomeView._blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.28),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      'Halo, @name'.trParams({'name': controller.name.value}),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                _ThemeButton(isDark: isDark),
                IconButton(
                  tooltip: 'Notifikasi'.tr,
                  onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      // Unread badge
                      Obx(() {
                        final unreadCount = controller.unreadNotificationCount.value;
                        if (unreadCount <= 0) return const SizedBox.shrink();
                        
                        return Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF1A73E8),
                                width: 1.5,
                              ),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 15),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cardBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada Fasilitas\nBermasalah?'.tr,
                    style: TextStyle(
                      color: headlineColor,
                      fontSize: 24,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(Routes.REPORT),
                      icon: const Icon(Icons.add_circle_outline, size: 13),
                      label: Text('Buat Laporan Baru'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HomeView._buttonBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Tooltip(
        message: themeController.isDarkMode ? 'Mode terang'.tr : 'Mode gelap'.tr,
        child: Material(
          color: Colors.white.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.12),
            ),
          ),
          child: InkWell(
            onTap: themeController.toggleTheme,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 40, 22, 122),
      children: [
        _SectionHeader(
          title: 'Kategori'.tr,
          titleColor: isDark ? Colors.white : HomeView._lightText,
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: const [
            _CategoryCard(
              icon: Icons.cleaning_services_outlined,
              label: 'Kebersihan',
              argument: 'Kebersihan',
            ),
            _CategoryCard(
              icon: Icons.air_rounded,
              label: 'AC & Udara',
              argument: 'AC & Udara',
            ),
            _CategoryCard(
              icon: Icons.water_drop_outlined,
              label: 'Air & Galon',
              argument: 'Air & Galon',
            ),
            _CategoryCard(
              icon: Icons.bolt_rounded,
              label: 'Kelistrikan',
              argument: 'Kelistrikan',
            ),
            _CategoryCard(
              icon: Icons.chair_outlined,
              label: 'Meja & Kursi',
              argument: 'Meja & Kursi',
            ),
            _CategoryCard(
              icon: Icons.more_horiz_rounded,
              label: 'Lainnya',
              argument: 'Lainnya',
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionHeader(
          title: 'Aktivitas'.tr,
          titleColor: isDark ? Colors.white : HomeView._lightText,
          trailing: 'Lihat semua'.tr,
          onTap: () {
            if (Get.isRegistered<KaryawanMainController>()) {
              Get.find<KaryawanMainController>().changePage(2);
            } else {
              Get.toNamed(Routes.PROFILE);
            }
          },
        ),
        const SizedBox(height: 10),
        Obx(
          () {
            if (controller.isLoadingReports.value) {
              return const _ActivityStateCard(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            }

            final reports = controller.recentReports;
            if (reports.isEmpty) {
              return _ActivityStateCard(
                child: Text(
                  'Belum ada aktivitas laporan'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (var i = 0; i < reports.length; i++) ...[
                  _ActivityCard(
                    report: reports[i],
                    onTap: () => controller.openReport(reports[i]),
                  ),
                  if (i != reports.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.titleColor,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Color titleColor;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                trailing!,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.argument,
  });

  final IconData icon;
  final String label;
  final String argument;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : Colors.transparent;
    final labelColor = isDark ? Colors.white : const Color(0xFF253044);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.REPORT, arguments: argument),
        borderRadius: BorderRadius.circular(7),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.17),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppDarkColors.surfaceVariant
                      : const Color(0xFFEFF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppDarkColors.accent : HomeView._buttonBlue,
                  size: 23,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.report,
    required this.onTap,
  });

  final Map<String, dynamic> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFCCD3DD);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF3E4653);
    final priority = report['priority']?.toString() ?? 'STANDARD';
    final status = report['status']?.toString() ?? 'Pending';
    final title = report['title']?.toString() ?? 'Laporan';
    final location = report['location']?.toString() ?? '-';
    final description = report['description']?.toString() ?? '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: borderColor),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: HomeView._blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(7),
                      bottomLeft: Radius.circular(7),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Badge(style: _priorityStyle(priority)),
                            const Spacer(),
                            _Badge(style: _statusStyle(status)),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Text(
                          title.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF064BFF),
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                location.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF064BFF),
                                  fontSize: 11,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: bodyColor,
                            fontSize: 11,
                            height: 1.18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityStateCard extends StatelessWidget {
  const _ActivityStateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 86,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFCCD3DD),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF3E4653),
        ),
        child: child,
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.text,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String text;
  final IconData icon;
  final Color background;
  final Color foreground;
}

class _Badge extends StatelessWidget {
  const _Badge({required this.style});

  final _BadgeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.foreground, size: 12),
          const SizedBox(width: 4),
          Text(
            style.text.tr,
            style: TextStyle(
              color: style.foreground,
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

_BadgeStyle _priorityStyle(String priority) {
  final normalized = priority.trim().toUpperCase();
  switch (normalized) {
    case 'URGENT':
    case 'HIGH':
    case 'TINGGI':
      return _BadgeStyle(
        text: normalized == 'HIGH' || normalized == 'TINGGI'
            ? 'URGENT'
            : normalized,
        icon: Icons.error_outline,
        background: const Color(0xFFFFE2E5),
        foreground: const Color(0xFFC72535),
      );
    default:
      return const _BadgeStyle(
        text: 'STANDARD',
        icon: Icons.error_outline,
        background: Color(0xFFFFF2C8),
        foreground: Color(0xFFFFA000),
      );
  }
}

_BadgeStyle _statusStyle(String status) {
  switch (status) {
    case 'Selesai':
      return const _BadgeStyle(
        text: 'Selesai',
        icon: Icons.check_circle_outline,
        background: Color(0xFFDDF8E9),
        foreground: Color(0xFF2BAE66),
      );
    case 'Ditolak':
      return const _BadgeStyle(
        text: 'Ditolak',
        icon: Icons.cancel_outlined,
        background: Color(0xFFFFE2E5),
        foreground: Color(0xFFC72535),
      );
    case 'Diproses':
      return const _BadgeStyle(
        text: 'Proses',
        icon: Icons.sync_rounded,
        background: Color(0xFFE3F0FF),
        foreground: Color(0xFF1976D2),
      );
    default:
      return const _BadgeStyle(
        text: 'Pending',
        icon: Icons.schedule_outlined,
        background: Color(0xFFFFF2C8),
        foreground: Color(0xFFFFA000),
      );
  }
}

class BottomNavigationLayout extends StatelessWidget {
  const BottomNavigationLayout({super.key});

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
                isActive: true,
                onTap: () {},
                navyColor: navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.add_circle_outline,
                label: 'Report',
                isActive: false,
                onTap: () => Get.toNamed(Routes.REPORT),
                navyColor: navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.person,
                label: 'Profile',
                isActive: false,
                onTap: () => Get.toNamed(Routes.PROFILE),
                navyColor: navyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
