import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../controllers/ob_home_controller.dart';

class OBHomeView extends GetView<ObHomeController> {
  const OBHomeView({super.key});

  static const _pageBg = Color(0xFFEEF4FC);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _pageBg,
      body: Stack(
        children: [
          const ObHomePage(),
          const _PinnedHeader(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const ObBottomNav(activeItem: ObBottomNavItem.home),
          ),
        ],
      ),
    );
  }
}

class ObHomePage extends GetView<ObHomeController> {
  const ObHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 128, 13, 104),
        child: Column(
          children: [
            _SectionCard(
              title: 'Tugas Harian',
              onSeeAll: () => Get.toNamed(Routes.OB_CHECKLIST),
              child: Obx(
                () => Column(
                  children: controller.dailyTasks
                      .map((task) => _TaskCard(task: task))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 13),
            _SectionCard(
              title: 'Laporan',
              onSeeAll: () {
                if (controller.reports.isNotEmpty) {
                  Get.toNamed(
                    Routes.OB_DETAIL,
                    arguments: controller.reports.first,
                  );
                }
              },
              child: Obx(
                () => Column(
                  children: controller.reports
                      .map((report) => _ReportCard(report: report))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedHeader extends GetView<ObHomeController> {
  const _PinnedHeader();

  static const _blue = Color(0xFF14558B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: 121,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.header : _blue,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Beranda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _ThemeToggleButton(),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Notifikasi',
                  child: InkWell(
                    onTap: () => Get.snackbar(
                      'Notifikasi',
                      'Belum ada notifikasi baru',
                      snackPosition: SnackPosition.TOP,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: const SizedBox(
                      width: 38,
                      height: 34,
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              'Selamat Pagi,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                controller.name.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => Tooltip(
        message: themeController.isDarkMode ? 'Mode terang' : 'Mode gelap',
        child: InkWell(
          onTap: themeController.toggleTheme,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 34,
            height: 34,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.onSeeAll,
    required this.child,
  });

  final String title;
  final VoidCallback onSeeAll;
  final Widget child;

  static const _blue = Color(0xFF14558B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : _blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final DailyTask task;

  static const _blue = Color(0xFF14558B);
  static const _muted = Color(0xFF676D75);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isResolved = task.status.value == 'resolved';
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(21, 13, 15, 10),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.card : Colors.white,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0x7A78B7FF),
              blurRadius: isDark ? 8 : 3,
              spreadRadius: isDark ? 0 : 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TinyIconBox(
              icon: isResolved
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: isResolved
                  ? const Color(0xFF16A05C)
                  : const Color(0xFFFF9B24),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : _blue,
                      fontSize: 14,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : _muted,
                      fontSize: 10.5,
                      height: 1.16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StatusPill(
                      label: isResolved ? 'Selesai' : 'Pending',
                      icon: isResolved
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      background: isResolved
                          ? const Color(0xFFDDF8E9)
                          : const Color(0xFFFFF5BF),
                      foreground: isResolved
                          ? const Color(0xFF16A05C)
                          : const Color(0xFFFF9B24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final HomeReport report;

  static const _blue = Color(0xFF14558B);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final priority = _priorityStyle(report.priority);
      final status = _statusStyle(report.status.value);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.OB_DETAIL, arguments: report),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              color: isDark ? AppDarkColors.card : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppDarkColors.border : Colors.white,
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF094976),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 8, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Badge(style: priority),
                              Obx(
                                () => report.hasCollaboration.value
                                    ? const Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: _Badge(
                                          style: _BadgeStyle(
                                            label: 'Kolaborasi',
                                            icon: Icons.groups_2_outlined,
                                            background: Color(0xFFE7F0FF),
                                            foreground: Color(0xFF2D8EFF),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const Spacer(),
                              _Badge(style: status),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 13,
                              height: 1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF1E32F5),
                                size: 13,
                              ),
                              Expanded(
                                child: Text(
                                  report.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF1E32F5),
                                    fontSize: 9,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF42474F),
                              fontSize: 8.6,
                              height: 1.18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE3E7ED),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF42474F),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 13,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF42474F),
                              ),
                            ],
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
    });
  }
}

class _TinyIconBox extends StatelessWidget {
  const _TinyIconBox({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x330015B0),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 11),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 10),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.foreground, size: 9),
          const SizedBox(width: 3),
          Text(
            style.label,
            style: TextStyle(
              color: style.foreground,
              fontSize: 8,
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
  if (priority == 'URGENT') {
    return const _BadgeStyle(
      label: 'URGENT',
      icon: Icons.error_rounded,
      background: Color(0xFFFFD8D8),
      foreground: Color(0xFFBF1D2D),
    );
  }

  return const _BadgeStyle(
    label: 'STANDARD',
    icon: Icons.error_rounded,
    background: Color(0xFFFFF0B9),
    foreground: Color(0xFFFFA01A),
  );
}

_BadgeStyle _statusStyle(String status) {
  if (status == 'Sedang Diproses') {
    return const _BadgeStyle(
      label: 'Diproses',
      icon: Icons.sync_rounded,
      background: Color(0xFFE7F0FF),
      foreground: Color(0xFF2D8EFF),
    );
  }
  if (status == 'Selesai' || status == 'Resolved') {
    return const _BadgeStyle(
      label: 'Selesai',
      icon: Icons.check_circle_outline_rounded,
      background: Color(0xFFDDF8E9),
      foreground: Color(0xFF16A05C),
    );
  }
  if (status == 'Ditolak') {
    return const _BadgeStyle(
      label: 'Ditolak',
      icon: Icons.error_outline_rounded,
      background: Color(0xFFFFD8D8),
      foreground: Color(0xFFBF1D2D),
    );
  }

  return const _BadgeStyle(
    label: 'Pending',
    icon: Icons.error_outline_rounded,
    background: Color(0xFFFFF0B9),
    foreground: Color(0xFFFFA01A),
  );
}
