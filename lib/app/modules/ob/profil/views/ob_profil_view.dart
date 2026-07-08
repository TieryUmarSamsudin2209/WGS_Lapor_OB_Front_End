import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/edit_profile_dialog.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../controllers/ob_profil_controller.dart';

class ObProfilView extends GetView<ObProfilController> {
  const ObProfilView({super.key});

  static const _navy = Color(0xFF0F2A5E);
  static const _bg = Colors.white;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppDarkColors.background : _navy;
    final surface = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : _navy;
    final controlBg = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final controlBorder = isDark ? AppDarkColors.border : Colors.grey.shade300;
    final controlText = isDark ? Colors.white70 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: pageBg,
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
                      color: pageBg,
                      child: const SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: Text(
                              'Profil Saya',
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
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 75), // Spacing for the overlapping avatar

                          // Name
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    controller.name.value,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => EditProfileDialog.show(
                                    context,
                                    avatarUrl: controller.avatarUrl.value,
                                    firstName: controller.firstName,
                                    lastName: controller.lastName,
                                    onSave: controller.updateProfile,
                                    onAvatarChanged:
                                        controller.updateAvatar,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                              color: controlBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: controlBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    size: 22, color: Colors.grey.shade400),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onChanged: controller.onSearchChanged,
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
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
                                    color: controlBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: controlBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 16,
                                        color: controlText,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: controlText,
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
            child: const ObBottomNav(activeItem: ObBottomNavItem.profile),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E2A3A);
    final itemColor = isDark ? Colors.white70 : const Color(0xFF1E2A3A);

    Get.bottomSheet(
      Material(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Filter berdasarkan status',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              ListTile(
                tileColor: sheetColor,
                title: Text('All', style: TextStyle(color: itemColor)),
                onTap: () {
                  controller.setStatusFilter(null);
                  Get.back();
                },
              ),
              for (final status in const [
                ReportStatus.resolved,
                ReportStatus.pending,
                ReportStatus.rejected,
              ])
                ListTile(
                  tileColor: sheetColor,
                  title: Text(status.label, style: TextStyle(color: itemColor)),
                  onTap: () {
                    controller.setStatusFilter(status);
                    Get.back();
                  },
                ),
            ],
          ),
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
          if (!url.startsWith('http')) {
            return Image.file(File(url), fit: BoxFit.cover);
          }
          return Image.network(url, fit: BoxFit.cover);
        }),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});
  final ReportModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E2A3A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF3F4653);
    final borderColor = isDark ? AppDarkColors.accent : const Color(0xFFD6DCE8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: const Color(0xFF00518E),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _PriorityBadge(priority: report.priority),
                              const Spacer(),
                              _StatusBadge(status: report.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 15,
                                  color: Color(0xFF0057D9),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  report.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF0057D9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
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
                              color: bodyColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            height: 1,
                            color: const Color(0xFFE3E8F0),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                'Lihat Detail',
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
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
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final isUrgent = priority == 'URGENT';

    return _ReportBadge(
      text: priority,
      icon: Icons.error_outline,
      color: isUrgent ? const Color(0xFFD11C25) : const Color(0xFFFFB020),
      bgColor: isUrgent ? const Color(0xFFFFE4E7) : const Color(0xFFFFF2C8),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    IconData icon;

    switch (status) {
      case ReportStatus.inProgress:
      case ReportStatus.resolved:
        color = const Color(0xFF2B9A57);
        bgColor = const Color(0xFFDDF8E9);
        icon = Icons.check_circle_outline;
        break;
      case ReportStatus.pending:
        color = const Color(0xFFFFA000);
        bgColor = const Color(0xFFFFF2C8);
        icon = Icons.schedule_outlined;
        break;
      case ReportStatus.rejected:
        color = const Color(0xFFD11C25);
        bgColor = const Color(0xFFFFE4E7);
        icon = Icons.cancel_outlined;
        break;
    }

    return _ReportBadge(
      text: status.label,
      icon: icon,
      color: color,
      bgColor: bgColor,
    );
  }
}

class _ReportBadge extends StatelessWidget {
  const _ReportBadge({
    required this.text,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
