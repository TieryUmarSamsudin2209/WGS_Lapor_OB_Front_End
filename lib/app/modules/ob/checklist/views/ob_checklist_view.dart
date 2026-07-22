import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/custom_alert.dart';
import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../controllers/ob_checklist_controller.dart';

class ObChecklistView extends GetView<ObChecklistController> {
  const ObChecklistView({super.key, this.isNested = false});

  final bool isNested;

  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildSummaryCard(),
                              const SizedBox(height: 12),
                              _buildTabToggle(),
                              const SizedBox(height: 8),
                              _buildTugasContainer(),
                              const SizedBox(height: 110),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!isNested)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: const ObBottomNav(activeItem: ObBottomNavItem.checklist),
            ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final isDark = Get.isDarkMode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.header : const Color(0xFF0F4C81),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: isDark ? 10 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 24, 20),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () => Get.back(),
              ),
              const SizedBox(width: 8),
              Text(
                'Daftar Tugas'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Obx(() {
      final count = controller.completedCountToday;
      final location = controller.penugasanText.value;
      final isDark = Get.isDarkMode;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppDarkColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE2EAF8).withValues(alpha: isDark ? 0.2 : 0.8),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tugas Diselesaikan hari ini'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF0F2A5E),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isDark ? Colors.blueAccent : const Color(0xFF5A78FF),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Penugasan: $location'.tr,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : const Color(0xFF5A78FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F4C81),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Tab Toggle ────────────────────────────────────────────────────────
  Widget _buildTabToggle() {
    return Obx(() {
      final isDark = Get.isDarkMode;
      final currentTab = controller.activeTab.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppDarkColors.surfaceVariant : const Color(0xFFF6F8FD),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.activeTab.value = 'tugas',
                  child: AnimatedContainer(
                     duration: const Duration(milliseconds: 200),
                     alignment: Alignment.center,
                     decoration: BoxDecoration(
                       color: currentTab == 'tugas'
                           ? const Color(0xFF154B86)
                           : Colors.transparent,
                       borderRadius: BorderRadius.circular(25),
                     ),
                     child: Text(
                       'Tugas'.tr,
                       style: TextStyle(
                         color: currentTab == 'tugas'
                             ? Colors.white
                             : (isDark ? Colors.white60 : const Color(0xFF7A8B9B)),
                         fontWeight: FontWeight.bold,
                         fontSize: 14,
                       ),
                     ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.activeTab.value = 'tugas_harian',
                  child: AnimatedContainer(
                     duration: const Duration(milliseconds: 200),
                     alignment: Alignment.center,
                     decoration: BoxDecoration(
                       color: currentTab == 'tugas_harian'
                           ? const Color(0xFF154B86)
                           : Colors.transparent,
                       borderRadius: BorderRadius.circular(25),
                     ),
                     child: Text(
                       'Tugas Harian'.tr,
                       style: TextStyle(
                         color: currentTab == 'tugas_harian'
                             ? Colors.white
                             : (isDark ? Colors.white60 : const Color(0xFF7A8B9B)),
                         fontWeight: FontWeight.bold,
                         fontSize: 14,
                       ),
                     ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Tugas Container ────────────────────────────────────────────────────
  Widget _buildTugasContainer() {
    return Obx(() {
      final isDark = Get.isDarkMode;
      final currentTab = controller.activeTab.value;

      if (currentTab == 'tugas_harian') {
        return _buildSectionsList();
      }

      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final tasks = controller.adHocTasks;
      if (tasks.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const _ChecklistEmptyState(),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppDarkColors.surface : const Color(0xFF154B86),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildAdHocTaskCard(context, task);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Ad Hoc Task Card ──────────────────────────────────────────────────
  Widget _buildAdHocTaskCard(BuildContext context, Map<String, dynamic> task) {
    final isDark = Get.isDarkMode;
    final id = task['id']?.toString() ?? '';
    final title = task['nama_tugas']?.toString() ?? '';
    final description = task['catatan']?.toString() ?? task['deskripsi']?.toString() ?? '';
    final status = task['status']?.toString() ?? 'BELUM_DIKERJAKAN';
    final isCompleted = status == 'SELESAI';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF2E8B57),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F2A5E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF7A8B9B),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: isCompleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Color(0xFF2E8B57),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Selesai'.tr,
                                style: TextStyle(
                                  color: Color(0xFF2E8B57),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _showConfirmationDialog(context, id, status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Selesaikan Tugas'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Confirmation & Success Dialogs ─────────────────────────────────────
  void _showConfirmationDialog(BuildContext context, String tugasId, String currentStatus) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Get.isDarkMode;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E8B57),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selesaikan Tugas?'.tr,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F2A5E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Konfirmasi apakah anda sudah menyelesaikan tugas anda.'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF7A8B9B),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close confirmation dialog
                      final success = await controller.completeAdHocTask(tugasId, currentStatus);
                      if (success && context.mounted) {
                        _showSuccessDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF053E85),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Ya, Selesai'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF053E85),
                      side: const BorderSide(color: Color(0xFF053E85)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Batalkan'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final isDark = Get.isDarkMode;
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2E8B57),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tugas Selesai!'.tr,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F2A5E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kerja bagus! Tugas Anda telah tercatat.'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : const Color(0xFF7A8B9B),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white70 : const Color(0xFF0F2A5E),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Sections list ─────────────────────────────────────────────────────
  Widget _buildSectionsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.sections.isEmpty) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: const _ChecklistEmptyState(),
        );
      }
      final list = controller.sections.toList();
      return Column(
        children: [
          for (var i = 0; i < list.length; i++)
            _FadeInSlideUp(
              delay: Duration(milliseconds: i * 35),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: _buildSectionCard(list[i]),
              ),
            ),
        ],
      );
    });
  }

  // ─── Section card ──────────────────────────────────────────────────────
  Widget _buildSectionCard(ChecklistSection section) {
    return Container(
      decoration: BoxDecoration(
        color:
            Get.isDarkMode ? AppDarkColors.surface : const Color(0xFF0F4C81),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (Get.isDarkMode ? Colors.black : const Color(0xFF0F4C81))
                .withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 2),
              child: Text(
                section.title.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
            ...section.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildItemCard(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Item card ─────────────────────────────────────────────────────────
  Widget _buildItemCard(ChecklistItem item) {
    return Obx(() {
      final status = item.status.value;
      final style = _statusStyle(status);
      final isDark = Get.isDarkMode;
      final cardColor = isDark ? AppDarkColors.surface : Colors.white;
      final titleColor = isDark ? Colors.white : const Color(0xFF1B2559);
      final descColor = isDark ? Colors.white70 : Colors.grey.shade500;

      return Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _showItemDetailPopup(Get.context!, item),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: style.color, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.tr,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: status == 'resolved'
                              ? Colors.grey.shade400
                              : titleColor,
                          decoration: status == 'resolved'
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: status == 'resolved'
                              ? Colors.grey.shade300
                              : descColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: style.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(style.icon, size: 11, color: style.color),
                              const SizedBox(width: 4),
                              Text(
                                style.label.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: style.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── POPUP DETAIL ──────────────────────────────────────────────────────
  void _showItemDetailPopup(BuildContext context, ChecklistItem item) {
    controller.noteController.text = item.note.value;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss'.tr,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, _) {
        final curve = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: a1.value.clamp(0.0, 1.0),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _ChecklistDetailPopup(
                item: item,
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple empty state widget
class _ChecklistEmptyState extends StatelessWidget {
  const _ChecklistEmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppDarkColors.border : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belum ada checklist'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada item untuk ditampilkan saat ini.'.tr,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── POPUP WIDGET ─────────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _ChecklistDetailPopup extends StatelessWidget {
  final ChecklistItem item;
  final ObChecklistController controller;

  const _ChecklistDetailPopup({
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1B2559);
    final bodyColor = isDark ? Colors.white60 : Colors.grey.shade600;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final fieldBorderColor = isDark ? AppDarkColors.border : Colors.grey.shade300;
    final closeBg = isDark ? AppDarkColors.surfaceVariant : Colors.grey.shade100;
    final closeColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Title + Close ────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.tr,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: bodyColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    controller.saveNote(item);
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: closeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20, color: closeColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Status Buttons ───────────────────────────────────
            _buildStatusButton(item, 'resolved'),
            const SizedBox(height: 8),
            _buildStatusButton(item, 'pending'),
            const SizedBox(height: 8),
            _buildStatusButton(item, 'todo'),

            const SizedBox(height: 24),

            // ── Catatan Label ────────────────────────────────────
            RichText(
              text: TextSpan(
                text: 'Catatan'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                children: const [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Catatan TextField ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: fieldColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fieldBorderColor),
              ),
              child: TextField(
                controller: controller.noteController,
                maxLines: 3,
                style: TextStyle(color: titleColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan'.tr,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
                onChanged: (_) => controller.saveNote(item),
              ),
            ),

            const SizedBox(height: 20),

            // ── Bukti Foto Label ─────────────────────────────────
            Text(
              'Bukti Foto'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),

            // ── Photo Grid ───────────────────────────────────────
            Obx(() => _buildPhotoGrid(context, item)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _submitDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Kirim'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Status button ─────────────────────────────────────────────────────
  void _submitDetail() {
    try {
      final validationMessage = controller.validateItemDetail(item);
      if (validationMessage != null) {
        _showValidationError();
        return;
      }

      controller.submitItemDetail(item);
      final alertContext = Get.overlayContext ?? Get.context;
      Get.back();

      if (alertContext == null) return;

      Future.delayed(const Duration(milliseconds: 150), () {
        _showAutoDismissAlert(alertContext, isSuccess: true);
      });
    } catch (_) {
      _showAutoDismissAlert(
        Get.overlayContext ?? Get.context,
        isSuccess: false,
        description: 'Terjadi kesalahan. Silakan coba lagi'.tr,
      );
    }
  }

  void _showValidationError() {
    _showAutoDismissAlert(
      Get.overlayContext ?? Get.context,
      isSuccess: false,
      description: 'Mohon isi catatan dan bukti foto'.tr,
    );
  }

  void _showAutoDismissAlert(
    BuildContext? alertContext, {
    required bool isSuccess,
    String? description,
  }) {
    if (alertContext == null) return;

    var alertDismissed = false;
    CustomAlert.show(
      alertContext,
      isSuccess: isSuccess,
      description: description,
    ).whenComplete(() {
      alertDismissed = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!alertDismissed) {
        Get.back();
      }
    });
  }

  Widget _buildStatusButton(ChecklistItem item, String statusValue) {
    final style = _statusStyle(statusValue);

    return Obx(() {
      final isActive = item.status.value == statusValue;

      return GestureDetector(
        onTap: () => controller.setItemStatus(item, statusValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? style.bgColor : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? style.color.withValues(alpha: 0.4) : Colors.grey.shade200,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? style.icon : Icons.circle_outlined,
                size: 18,
                color: isActive ? style.color : Colors.grey.shade400,
              ),
              const SizedBox(width: 10),
              Text(
                style.label.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? style.color : Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              if (isActive)
                Icon(Icons.check_rounded, size: 18, color: style.color),
            ],
          ),
        ),
      );
    });
  }

  // ─── Photo grid ────────────────────────────────────────────────────────
  Widget _buildPhotoGrid(BuildContext context, ChecklistItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDAE2F5)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          // Existing photos
          ...item.photos.asMap().entries.map(
            (entry) => _buildPhotoThumb(item, entry.key, entry.value),
          ),
          // Add button (max 3)
          if (item.photos.length < 3) _buildAddPhotoButton(context, item),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb(ChecklistItem item, int index, String path) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0F4C81), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(path, fit: BoxFit.cover)
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => controller.removeItemPhoto(item, index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(BuildContext context, ChecklistItem item) {
    return GestureDetector(
      onTap: () => _showPhotoSourceSheet(item),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(Icons.add, size: 24, color: Colors.grey.shade500),
      ),
    );
  }

  void _showPhotoSourceSheet(ChecklistItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto'.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: Text('Kamera'.tr),
              onTap: () {
                Get.back();
                controller.pickItemPhoto(item, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.purple),
              ),
              title: Text('Galeri'.tr),
              onTap: () {
                Get.back();
                controller.pickItemPhoto(item, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Status style helper ──────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusStyle {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;
  const _StatusStyle(this.color, this.bgColor, this.icon, this.label);
}

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'resolved':
      return const _StatusStyle(
        Color(0xFF3FA76B),
        Color(0xFFE4F6EA),
        Icons.check_circle_outline_rounded,
        'Selesai',
      );
    case 'pending':
      return const _StatusStyle(
        Color(0xFFC98A1B),
        Color(0xFFFCF1DC),
        Icons.access_time_rounded,
        'Menunggu',
      );
    default:
      return const _StatusStyle(
        Color(0xFFD9534F),
        Color(0xFFFBE7E6),
        Icons.radio_button_unchecked_rounded,
        'Belum Dikerjakan',
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
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
