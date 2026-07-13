import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../controllers/ob_home_controller.dart';

class OBHomeView extends GetView<ObHomeController> {
  const OBHomeView({super.key, this.isNested = false});

  final bool isNested;

  static const _blue = Color(0xFF14558B);
  static const _pageBg = Color(0xFFF4F4F8);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerHeight = MediaQuery.viewPaddingOf(context).top + 170;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            top: headerHeight,
            child: RefreshIndicator(
              onRefresh: controller.loadHomeData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 116),
                children: [
                  _FadeInSlideUp(
                    delay: Duration.zero,
                    child: _ProgressCard(controller: controller),
                  ),
                  const SizedBox(height: 24),
                  _FadeInSlideUp(
                    delay: const Duration(milliseconds: 25),
                    child: _TaskPreview(controller: controller),
                  ),
                  const SizedBox(height: 20),
                  _FadeInSlideUp(
                    delay: const Duration(milliseconds: 50),
                    child: _LatestReports(controller: controller),
                  ),
                ],
              ),
            ),
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
              child: ObBottomNav(activeItem: ObBottomNavItem.home),
            ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.controller});

  final ObHomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? AppDarkColors.header : OBHomeView._blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
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
                      'Halo, @name'.trParams({
                        'name': _firstName(controller.name.value),
                      }),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Ubah tema'.tr,
                  onPressed: Get.find<ThemeController>().toggleTheme,
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                IconButton(
                  tooltip: 'Notifikasi'.tr,
                  onPressed: () => Get.toNamed(Routes.OB_NOTIFICATIONS),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tetap semangat menjaga kebersihan hari ini!'.tr,
              style: const TextStyle(
                color: Color(0xFFD8E9F6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _translatedAssignmentLabel(controller.assignmentLabel),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.controller});

  final ObHomeController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFE2E8F0);

    return Obx(() {
      final total = controller.totalTaskCount;
      final done = controller.completedTaskCount;
      final progress = total == 0 ? 0.0 : done / total;

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: progress),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, _) {
          final percent = (animValue * 100).round();
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.09),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Kerja Hari Ini'.tr,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1D2A3A),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$done/$total',
                              style: const TextStyle(
                                color: Color(0xFF0071B9),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: ' ${'Tugas Selesai'.tr}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0071B9),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: animValue,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppDarkColors.surfaceVariant
                                    : const Color(0xFFE8E6FA),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF0071B9),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: animValue,
                        strokeWidth: 6,
                        backgroundColor: isDark
                            ? AppDarkColors.surfaceVariant
                            : const Color(0xFFE6ECF5),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF0071B9),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Color(0xFF0071B9),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({required this.controller});

  final ObHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Daftar Tugas',
          trailing: Icons.sort_rounded,
          onTap: () => Get.toNamed(Routes.OB_CHECKLIST),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingTasks.value) {
            return const _LoadingCard();
          }
          if (controller.dailyTasks.isEmpty) {
            return const _EmptyCard(message: 'Belum ada tugas harian');
          }
          return Column(
            children: controller.dailyTasks
                .take(3)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TaskCard(task: task),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

class _LatestReports extends StatelessWidget {
  const _LatestReports({required this.controller});

  final ObHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Laporan Masuk',
          onTap: () => Get.toNamed(Routes.OB_REPORTS),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingReports.value) {
            return const _LoadingCard();
          }
          if (controller.latestReports.isEmpty) {
            return const _EmptyCard(message: 'Belum ada laporan masuk');
          }

          return Column(
            children: controller.latestReports
                .map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HomeReportCard(
                      controller: controller,
                      report: report,
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
    this.onTap,
  });

  final String title;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            title.tr,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF253044),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onTap,
            icon: Icon(
              trailing,
              color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            ),
          ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final DailyTask task;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFE6EDF5);

    return Obx(() {
      final done = task.status.value == 'resolved';
      final status = done ? _donePill : _pendingPill;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: const Color(0xFF8FC5FF).withValues(alpha: 0.48),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _SmallStatusIcon(style: status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : OBHomeView._blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        decoration: null,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    task.location.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _Pill(style: status),
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

class _HomeReportCard extends StatelessWidget {
  const _HomeReportCard({
    required this.controller,
    required this.report,
  });

  final ObHomeController controller;
  final HomeReport report;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD0D8E4);

    return Obx(() {
      final priority = _priorityStyle(report.priority);
      final status = _statusStyle(report.status.value);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.OB_DETAIL, arguments: report),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: OBHomeView._blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _Pill(style: priority),
                              const Spacer(),
                              _Pill(style: status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            report.title.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF064BFF),
                                size: 15,
                              ),
                              Expanded(
                                child: Text(
                                  report.location.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF064BFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            report.description.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF465160),
                              fontSize: 11,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Divider(
                            height: 1,
                            color: isDark
                                ? AppDarkColors.border
                                : const Color(0xFFE7ECF3),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (report.hasCollaboration.value)
                                const _TinyLabel(text: 'Kolaborasi'),
                              if (report.assignedObName != null &&
                                  report.assignedObName!.trim().isNotEmpty)
                                _TinyLabel(text: report.assignedObName!.trim()),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: report.status.value ==
                                          'Belum Diproses'
                                      ? _TakeReportButton(
                                          isLoading:
                                              controller.isTakingReport(report),
                                          onPressed: () =>
                                              controller.takeReport(report),
                                        )
                                      : _DetailLink(isDark: isDark),
                                ),
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

class _TakeReportButton extends StatelessWidget {
  const _TakeReportButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.assignment_turned_in_outlined, size: 14),
        label: Text((isLoading ? 'Mengambil' : 'Ambil').tr),
        style: ElevatedButton.styleFrom(
          backgroundColor: OBHomeView._blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF7AA7CE),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _DetailLink extends StatelessWidget {
  const _DetailLink({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lihat Detail'.tr,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF1F2937),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white60 : Colors.grey,
          size: 16,
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE6EDF5),
        ),
      ),
      child: Text(
        message.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA000),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SmallStatusIcon extends StatelessWidget {
  const _SmallStatusIcon({required this.style});

  final _PillStyle style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE6EDF5),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF8FC5FF).withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Icon(style.icon, color: style.foreground, size: 15),
      ),
    );
  }
}

class _PillStyle {
  const _PillStyle({
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

class _Pill extends StatelessWidget {
  const _Pill({required this.style});

  final _PillStyle style;

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
          Icon(style.icon, size: 10, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label.tr,
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

const _donePill = _PillStyle(
  label: 'Selesai',
  icon: Icons.check_circle_outline,
  background: Color(0xFFDDF8E9),
  foreground: Color(0xFF2BAE66),
);

const _pendingPill = _PillStyle(
  label: 'Pending',
  icon: Icons.error_outline,
  background: Color(0xFFFFF2C8),
  foreground: Color(0xFFFFA000),
);

_PillStyle _priorityStyle(String priority) {
  if (priority == 'URGENT') {
    return const _PillStyle(
      label: 'URGENT',
      icon: Icons.error_outline,
      background: Color(0xFFFFE2E5),
      foreground: Color(0xFFC72535),
    );
  }

  return const _PillStyle(
    label: 'STANDARD',
    icon: Icons.error_outline,
    background: Color(0xFFFFF2C8),
    foreground: Color(0xFFFFA000),
  );
}

_PillStyle _statusStyle(String status) {
  if (status == 'Selesai') {
    return _donePill;
  }
  if (status == 'Ditolak') {
    return const _PillStyle(
      label: 'Ditolak',
      icon: Icons.cancel_outlined,
      background: Color(0xFFFFE2E5),
      foreground: Color(0xFFC72535),
    );
  }
  if (status == 'Sedang Diproses') {
    return const _PillStyle(
      label: 'Proses',
      icon: Icons.sync_rounded,
      background: Color(0xFFE3F0FF),
      foreground: Color(0xFF1976D2),
    );
  }

  return _pendingPill;
}

String _firstName(String value) {
  final text = value.trim();
  if (text.isEmpty) return 'OB';
  return text.split(RegExp(r'\s+')).first;
}

String _translatedAssignmentLabel(String value) {
  const prefix = 'Penugasan: ';
  if (value.startsWith(prefix)) {
    return 'Penugasan: @assignment'.trParams({
      'assignment': value.substring(prefix.length),
    });
  }
  return value.tr;
}

class _FadeInSlideUp extends StatefulWidget {
  const _FadeInSlideUp({
    required this.child,
    this.delay = Duration.zero,
  }) : duration = const Duration(milliseconds: 180);

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<_FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<_FadeInSlideUp> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: widget.duration);
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _offsetAnim = Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _animController.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _animController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: FractionalTranslation(
            translation: _offsetAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
