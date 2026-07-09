import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../../home/controllers/ob_home_controller.dart';
import '../controllers/ob_reports_controller.dart';

class ObReportsView extends GetView<ObReportsController> {
  const ObReportsView({super.key});

  static const _blue = Color(0xFF0F5B93);
  static const _pageBg = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _pageBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: controller.loadReports,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(child: _Header(isDark: isDark)),
                  SliverToBoxAdapter(child: _SearchAndFilters(isDark: isDark)),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final reports = controller.filteredReports;
                    if (reports.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyReports(),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 16, 118),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _IncomingReportCard(
                                report: reports[index],
                                onTap: () =>
                                    controller.openReport(reports[index]),
                              ),
                            );
                          },
                          childCount: reports.length,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const ObBottomNav(
              activeItem: ObBottomNavItem.profile,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : ObReportsView._blue,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              'Semua Laporan Masuk',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : ObReportsView._blue,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends GetView<ObReportsController> {
  const _SearchAndFilters({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFDDE5EF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 16, 8),
      child: Column(
        children: [
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              onChanged: controller.onSearchChanged,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cari pelaporan atau lokasi...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF9AA4B2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF718096),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: Obx(
              () => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final filter = const [
                    'Semua',
                    'Proses',
                    'Selesai',
                    'Tertolak',
                    'Pending',
                  ][index];
                  final active = controller.selectedFilter.value == filter;
                  return _FilterChip(
                    label: filter,
                    active: active,
                    onTap: () => controller.setFilter(filter),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = active
        ? ObReportsView._blue
        : isDark
            ? AppDarkColors.surfaceVariant
            : Colors.white;
    final fg = active
        ? Colors.white
        : isDark
            ? Colors.white70
            : const Color(0xFF5C6675);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? ObReportsView._blue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _IncomingReportCard extends StatelessWidget {
  const _IncomingReportCard({
    required this.report,
    required this.onTap,
  });

  final HomeReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD1D9E5);

    return Obx(() {
      final priority = _priorityStyle(report.priority);
      final status = _statusStyle(report.status.value);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                      color: Color(0xFF0F5B93),
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
                              _ReportPill(style: priority),
                              const Spacer(),
                              _ReportPill(style: status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
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
                                  report.location,
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
                            report.description,
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF1F2937),
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

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 118),
      child: Center(
        child: Text(
          'Belum ada laporan masuk',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF718096),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
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

class _ReportPill extends StatelessWidget {
  const _ReportPill({required this.style});

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
            style.label,
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
    return const _PillStyle(
      label: 'Selesai',
      icon: Icons.check_circle_outline,
      background: Color(0xFFDDF8E9),
      foreground: Color(0xFF2BAE66),
    );
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

  return const _PillStyle(
    label: 'Pending',
    icon: Icons.schedule_outlined,
    background: Color(0xFFFFF2C8),
    foreground: Color(0xFFFFA000),
  );
}
