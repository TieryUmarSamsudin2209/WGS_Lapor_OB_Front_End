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
  const ObChecklistView({super.key});

  static const _navy = Color(0xFF0F2A5E);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSectionsList(),
                const SizedBox(height: 110),
              ],
            ),
          ),
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
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: const Text(
            'Daftar List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sections list ─────────────────────────────────────────────────────
  Widget _buildSectionsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: controller.sections
            .map((section) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _buildSectionCard(section),
                ))
            .toList(),
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
                section.title,
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
                        item.title,
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
                        item.description,
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
                                style.label,
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
    // Pre-populate note text field
    controller.noteController.text = item.note.value;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
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
                        item.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
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
                text: 'Catatan',
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
                  hintText: 'Tambahkan catatan',
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
              'Bukti Foto',
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
                child: const Text(
                  'Kirim',
                  style: TextStyle(
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
        description: 'Terjadi kesalahan. Silakan coba lagi',
      );
    }
  }

  void _showValidationError() {
    _showAutoDismissAlert(
      Get.overlayContext ?? Get.context,
      isSuccess: false,
      description: 'Mohon isi catatan dan bukti foto',
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
                style.label,
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
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              title: const Text('Kamera'),
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
              title: const Text('Galeri'),
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
        'Resolved',
      );
    case 'pending':
      return const _StatusStyle(
        Color(0xFFC98A1B),
        Color(0xFFFCF1DC),
        Icons.access_time_rounded,
        'Pending',
      );
    default:
      return const _StatusStyle(
        Color(0xFFD9534F),
        Color(0xFFFBE7E6),
        Icons.radio_button_unchecked_rounded,
        'To-Do',
      );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
