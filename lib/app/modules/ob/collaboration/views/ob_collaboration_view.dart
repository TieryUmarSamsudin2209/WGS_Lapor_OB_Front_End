import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme_controller.dart';
import '../controllers/ob_collaboration_controller.dart';

class ObCollaborationView extends GetView<ObCollaborationController> {
  const ObCollaborationView({super.key});

  final Color navyColor = const Color(0xFF0F4C81);
  final Color urgentRed = const Color(0xFFC62828);
  final Color lightPurple = const Color(0xFFF3F5FF);

  // Static method to show edit notes dialog
  static void _showEditNotesDialog(ObCollaborationController controller) {
    if (!controller.canEditNotes) {
      Get.snackbar('Error'.tr, 'Hanya pemilik laporan yang dapat mengubah catatan'.tr);
      return;
    }

    final notesController = TextEditingController(text: controller.currentNotes);
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.edit_note, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tambahkan Catatan'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      notesController.dispose();
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Text field
              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tolong bawakan sapu dan...'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      notesController.dispose();
                      Get.back();
                    },
                    child: Text(
                      'Batal'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final newNotes = notesController.text.trim();
                                notesController.dispose();
                                Get.back();
                                await controller.updateNotes(newNotes);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1689D8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, size: 18),
                                  const SizedBox(width: 6),
                                  Text('Simpan Catatan'.tr),
                                ],
                              ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : navyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kolaborasi'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Report Info Card
            _buildReportInfoCard(),

            const SizedBox(height: 15),

            // Collaborators Section
            _buildCollaboratorsSection(),

            const SizedBox(height: 15),

            // Action Buttons
            Obx(() => _buildActionButtons()),
          ],
        ),
      ),
    );
  }

  Widget _buildReportInfoCard() {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF102235) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white70 : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: urgentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: urgentRed),
                    const SizedBox(width: 4),
                    Obx(() => Text(
                          controller.reportPriority.value.tr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: urgentRed,
                          ),
                        )),
                  ],
                ),
              ),
              Text(
                controller.reportTimeAgo,
                style: TextStyle(fontSize: 11, color: mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Report Title
          Obx(() => Text(
                controller.reportTitle.value.tr,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              )),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: navyColor),
              const SizedBox(width: 4),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.reportLocation.value.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          ),

          // Owner Info
          _buildInfoRow(
            Icons.person_outline,
            'Dilaporkan Oleh',
            controller.reportReporter,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Lokasi',
            controller.reportLocation.value,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.edit_outlined,
            'Kategori',
            controller.reportCategory,
          ),

          const SizedBox(height: 25),

          // Description Section
          Text(
            'DESKRIPSI LAPORAN'.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.reportDescription,
            style: TextStyle(
              fontSize: 13,
              color: titleColor,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 25),

          // Bukti Foto Section
          Text(
            'BUKTI FOTO'.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildPhotoSection(isDark, mutedColor),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsSection() {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? const Color(0xFF102235) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white70 : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: 20, color: mutedColor),
              const SizedBox(width: 8),
              Text(
                'Catatan'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const Spacer(),
              // Show edit button if owner
              Obx(() {
                if (!controller.isOwner.value) return const SizedBox.shrink();
                return InkWell(
                  onTap: () => _showEditNotesDialog(controller),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppDarkColors.surfaceVariant
                          : const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: isDark ? Colors.white70 : mutedColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => GestureDetector(
                onTap: controller.isOwner.value
                    ? () => _showEditNotesDialog(controller)
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppDarkColors.surfaceVariant
                        : const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppDarkColors.border
                          : const Color(0xFFE5E9EE),
                    ),
                  ),
                  child: Text(
                    controller.notes.value.isEmpty
                        ? 'Belum ada catatan. Tap untuk menambahkan.'.tr
                        : controller.notes.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.notes.value.isEmpty
                          ? mutedColor.withValues(alpha: 0.6)
                          : mutedColor,
                      fontStyle: controller.notes.value.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // Team Section
          Row(
            children: [
              Icon(Icons.people_outline, size: 20, color: mutedColor),
              const SizedBox(width: 8),
              Text(
                'Tim'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Collaborators List
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.collaborators.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppDarkColors.surfaceVariant
                      : const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_alt_outlined, size: 40, color: mutedColor),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada OB yang bergabung'.tr,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: controller.collaborators
                  .map((collaborator) => _buildCollaboratorItem(
                        name: collaborator.name,
                        role: collaborator.role,
                        isOwner: controller.isOwner.value &&
                            collaborator.id == controller.currentUserId,
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCollaboratorItem({
    required String name,
    required String role,
    bool isOwner = false,
  }) {
    final isDark = Get.isDarkMode;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: isDark
            ? AppDarkColors.surfaceVariant
            : const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
        border: isOwner
            ? Border.all(color: urgentRed, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: navyColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: navyColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: urgentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 14, color: urgentRed),
                  const SizedBox(width: 4),
                  Text(
                    'Hapus'.tr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: urgentRed,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isDark = Get.isDarkMode;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : Colors.transparent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: controller.isOwner.value
          ? _buildOwnerButtons()
          : _buildCollaboratorButtons(),
    );
  }

  Widget _buildOwnerButtons() {
    return Column(
      children: [
        // Tutup Kolaborasi button
        _buildSolidButton(
          'Tutup Kolaborasi',
          const Color(0xFF1689D8), // Blue color
          () => controller.closeCollaboration(),
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 12),
        // Batalkan Kolaborasi button
        _buildSolidButton(
          'Batalkan Kolaborasi',
          urgentRed,
          () => controller.cancelCollaboration(),
          icon: Icons.close,
        ),
      ],
    );
  }

  Widget _buildCollaboratorButtons() {
    // Check if current user already joined
    final currentUserId = controller.currentUserId;
    final hasJoined = controller.collaborators.any(
      (c) => c.id == currentUserId,
    );

    if (hasJoined) {
      return Column(
        children: [
          Icon(Icons.check_circle_outline, color: navyColor, size: 34),
          const SizedBox(height: 10),
          Text(
            'Anda sudah bergabung ke kolaborasi ini'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Get.isDarkMode ? Colors.white : const Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    return _buildSolidButton(
      'Bergabung',
      navyColor,
      () => controller.joinCollaboration(),
      icon: Icons.add,
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    final isDark = Get.isDarkMode;
    final titleColor = isDark ? Colors.white60 : Colors.grey;
    final valueColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style: TextStyle(fontSize: 10, color: titleColor),
              ),
              const SizedBox(height: 2),
              Text(
                value.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSolidButton(
    String text,
    Color color,
    VoidCallback? onTap, {
    IconData? icon,
  }) {
    final isDark = Get.isDarkMode;
    final isBusy = controller.isSubmitting.value;
    final buttonColor = isDark && color == navyColor
        ? const Color(0xFF052C58)
        : color;
    final foregroundColor = isDark && color == navyColor
        ? AppDarkColors.accent
        : Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          elevation: isDark ? 0 : 4,
          shadowColor: isDark
              ? Colors.transparent
              : navyColor.withValues(alpha: 0.28),
        ),
        onPressed: isBusy ? null : onTap,
        child: isBusy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foregroundColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.tr,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPhotoSection(bool isDark, Color mutedColor) {
    // Get photos from activeReport
    final photos = controller.activeReport?.photos ?? [];
    
    if (photos.isEmpty) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: isDark
              ? AppDarkColors.surfaceVariant
              : const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppDarkColors.border
                : const Color(0xFFDDE4EE),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 34,
              color: mutedColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada foto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // Show photos in a horizontal scrollable list
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photoUrl = photos[index];
          return Container(
            width: 150,
            margin: EdgeInsets.only(right: index < photos.length - 1 ? 12 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppDarkColors.border
                    : const Color(0xFFDDE4EE),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark
                        ? AppDarkColors.surfaceVariant
                        : const Color(0xFFF4F6FA),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 34,
                          color: mutedColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gagal memuat foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: isDark
                        ? AppDarkColors.surfaceVariant
                        : const Color(0xFFF4F6FA),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
