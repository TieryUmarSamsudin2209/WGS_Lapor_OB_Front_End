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
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: Column(
              children: [
                _PinnedHeader(),
                Expanded(child: ObHomePage()),
              ],
            ),
          ),
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
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: controller.loadHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Tugas Harian',
                      onSeeAll: () => Get.toNamed(Routes.OB_CHECKLIST),
                      child: Obx(
                        () {
                          if (controller.isLoadingTasks.value) {
                            return const _SectionLoading();
                          }
                          if (controller.dailyTasks.isEmpty) {
                            return const _SectionEmpty(
                              message: 'Belum ada tugas harian',
                            );
                          }
                          return Column(
                            children: controller.dailyTasks
                                .map((task) => _TaskCard(task: task))
                                .toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        () {
                          if (controller.isLoadingReports.value) {
                            return const _SectionLoading();
                          }
                          if (controller.reports.isEmpty) {
                            return const _SectionEmpty(
                              message: 'Belum ada laporan',
                            );
                          }
                          return Column(
                            children: controller.reports
                                .map((report) => _ReportCard(report: report))
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppDarkColors.card
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : const Color(0xFF676D75),
          fontSize: 12,
          fontWeight: FontWeight.w700,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;
        final horizontalPadding = isCompact ? 12.0 : 16.0;
        final titleSize = isCompact ? 22.0 : 27.0;
        final iconBoxSize = isCompact ? 30.0 : 38.0;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppDarkColors.header : _blue,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Beranda',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleSize,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _ThemeToggleButton(size: iconBoxSize),
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
                          child: SizedBox(
                            width: iconBoxSize,
                            height: iconBoxSize,
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: isCompact ? 21 : 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 18 : 21,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton({required this.size});

  final double size;

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
            width: size,
            height: size,
            child: Icon(
              themeController.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white,
              size: size <= 30 ? 19 : 21,
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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : _blue,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : _blue).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
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
                    horizontal: 4,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.card : Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            const SizedBox(width: 12),
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
                      fontSize: 14.5,
                      height: 1.2,
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
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppDarkColors.card : Colors.white,
              borderRadius: BorderRadius.circular(14),
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
                    width: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF094976),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _Badge(style: priority),
                              _Badge(style: status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14.5,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF1E32F5),
                                size: 15,
                              ),
                              Expanded(
                                child: Text(
                                  report.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF1E32F5),
                                    fontSize: 11,
                                    height: 1.2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF42474F),
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? Colors.white12
                                : const Color(0xFFE3E7ED),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Obx(
                                () => report.hasCollaboration.value
                                    ? const _Badge(
                                        style: _BadgeStyle(
                                          label: 'Kolaborasi',
                                          icon: Icons.groups_2_outlined,
                                          background: Color(0xFFFFF2C8),
                                          foreground: Color(0xFFFF9B24),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const Spacer(),
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF42474F),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark
            ? AppDarkColors.surfaceVariant
            : color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 19),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.foreground, size: 11),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              color: style.foreground,
              fontSize: 11,
              height: 1,
              fontWeight: FontWeight.w700,
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
