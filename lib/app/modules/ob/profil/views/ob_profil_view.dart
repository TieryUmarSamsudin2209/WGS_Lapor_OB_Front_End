import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../controllers/ob_profil_controller.dart';

class ObProfilView extends GetView<ObProfilController> {
  const ObProfilView({super.key});

  static const _navy = Color(0xFF0F2A5E);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navy,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background & Content Column
                Column(
                  children: [
                    // Blue header background with title
                    Container(
                      width: double.infinity,
                      height: 190,
                      color: _navy,
                      child: const SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: Text(
                              'My Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Body container
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 75), // Spacing for the overlapping avatar

                          // Name
                          Obx(() => Text(
                                controller.name.value,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: _navy,
                                ),
                              )),
                          const SizedBox(height: 4),
                          // Username
                          Obx(() => Text(
                                controller.username.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F57C3),
                                ),
                              )),
                          const SizedBox(height: 16),
                          // Button Reports History
                          ElevatedButton(
                            onPressed: controller.goToReportHistory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Reports History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ---- Search bar -----------------------------
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    size: 22, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: controller.onSearchChanged,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search reports by ID or category...',
                                      hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade400),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ---- Filter button ---------------------------
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => _showFilterSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune_rounded, size: 16, color: Colors.grey.shade700),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ---- Reports list -----------------------------
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final reports = controller.filteredReports;
                            if (reports.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No reports found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: reports.map((report) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ReportCard(
                                    report: report,
                                    onTap: () => controller.openReport(report),
                                  ),
                                );
                              }).toList(),
                            );
                          }),

                          const SizedBox(height: 4),
                          _LogoutButton(
                            onPressed: () => LogoutConfirmationDialog.show(
                              context,
                              onConfirm: controller.logout,
                            ),
                          ),

                          const SizedBox(height: 110), // Bottom spacer for floating bar
                        ],
                      ),
                    ),
                  ],
                ),

                // Positioned Avatar
                Positioned(
                  top: 130, // 190 (header height) - 60 (avatar radius) = 130
                  child: _Avatar(controller: controller),
                ),
              ],
            ),
          ),

          // Floating Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(controller: controller),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Filter by status',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            ListTile(
              title: const Text('All'),
              onTap: () {
                controller.setStatusFilter(null);
                Get.back();
              },
            ),
            for (final status in ReportStatus.values)
              ListTile(
                title: Text(status.label),
                onTap: () {
                  controller.setStatusFilter(status);
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 28),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFA11E1E),
          side: const BorderSide(color: Color(0xFFA11E1E), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});
  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Obx(() {
          final url = controller.avatarUrl.value;
          if (url.isEmpty) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            );
          }
          return Image.network(url, fit: BoxFit.cover);
        }),
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusStyle(this.color, this.bg, this.icon);
}

_StatusStyle _statusStyle(ReportStatus status) {
  switch (status) {
    case ReportStatus.inProgress:
      return const _StatusStyle(
        Color(0xFF2F6FE0),
        Color(0xFFE7EFFD),
        Icons.access_time_rounded,
      );
    case ReportStatus.pending:
      return const _StatusStyle(
        Color(0xFFC98A1B),
        Color(0xFFFCF1DC),
        Icons.access_time_rounded,
      );
    case ReportStatus.rejected:
      return const _StatusStyle(
        Color(0xFFD9534F),
        Color(0xFFFBE7E6),
        Icons.error_outline_rounded,
      );
    case ReportStatus.resolved:
      return const _StatusStyle(
        Color(0xFF3FA76B),
        Color(0xFFE4F6EA),
        Icons.check_circle_outline_rounded,
      );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});
  final ReportModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(report.status);
    final closed = report.status.isClosed;
    final dateStr =
        '${_month(report.date.month)} ${report.date.day}, ${report.date.year}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Left accent status line
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(color: style.color),
                ),
                // Card contents
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: ID and Status badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.id,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: style.bg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  style.icon,
                                  size: 12,
                                  color: style.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  report.status.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: style.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        report.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: closed ? Colors.grey.shade400 : const Color(0xFF1F2937),
                          decoration: closed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: closed ? Colors.grey.shade400 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: closed ? Colors.grey.shade400 : Colors.grey.shade600,
                          decoration: closed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: closed ? Colors.grey.shade400 : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Thin divider line
                      Container(
                        height: 1,
                        color: Colors.grey.shade100,
                      ),
                      const SizedBox(height: 10),
                      // Footer: Date and Chevron
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.grey.shade400),
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m - 1];
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC3C9FA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F6FE0).withValues(alpha: 1),
              blurRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home item
            InkWell(
              onTap: controller.goHome,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: ObProfilView._navy, size: 22),
                    const SizedBox(width: 6),
                    const Text(
                      'Home',
                      style: TextStyle(
                        color: ObProfilView._navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Checklist item
            InkWell(
              onTap: controller.createReport,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.checklist_rounded, color: ObProfilView._navy, size: 22),
                    const SizedBox(width: 6),
                    const Text(
                      'Checklist',
                      style: TextStyle(
                        color: ObProfilView._navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Active Profile item
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ObProfilView._navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
