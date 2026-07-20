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
        actions: [
          // Manual refresh button for owner
          Obx(() {
            if (controller.isOwner.value) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.loadCollaborators(),
                tooltip: 'Refresh'.tr,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadCollaborators();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      child: Obx(() {
        // Show different UI based on ownership
        if (controller.isOwner.value) {
          return _buildOwnerCollaborationView(isDark, titleColor, mutedColor, cardColor);
        } else {
          return _buildNonOwnerCollaborationView(isDark, titleColor, mutedColor, cardColor);
        }
      }),
    );
  }

  // Owner view: Catatan (editable) + Tim (with approve/reject/remove)
  Widget _buildOwnerCollaborationView(bool isDark, Color titleColor, Color mutedColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes section (editable)
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
            InkWell(
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
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showEditNotesDialog(controller),
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
            child: Obx(() => Text(
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
                )),
          ),
        ),

        const SizedBox(height: 20),

        // Team section with full list
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
                      fontSize: 13,
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.collaborators.map((collaborator) {
              return _buildCollaboratorItem(
                collaborator.name,
                collaborator.status == 'APPROVED' ? 'Anggota' : 'Menunggu',
                collaborator.status == 'PENDING',
                collaborator.id,
                isDark,
                titleColor,
                mutedColor,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // Non-owner view: Catatan (read-only) + Tim (owner + current status)
  Widget _buildNonOwnerCollaborationView(bool isDark, Color titleColor, Color mutedColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes section (read-only)
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
          ],
        ),
        const SizedBox(height: 8),
        Container(
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
          child: Obx(() => Text(
                controller.notes.value.isEmpty
                    ? 'Belum ada catatan.'.tr
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
              )),
        ),

        const SizedBox(height: 20),

        // Team section - show owner + self if joined
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

        // Owner info
        _buildTeamMemberCard(
          controller.ownerName.value,
          'Pemilik Laporan',
          isDark,
          titleColor,
          mutedColor,
        ),

        // Show current user if already joined
        Obx(() {
          final currentUserId = controller.currentUserId;
          final hasJoined = controller.collaborators.any(
            (c) => c.id == currentUserId,
          );

          if (hasJoined) {
            final currentUser = controller.collaborators.firstWhere(
              (c) => c.id == currentUserId,
            );
            return Column(
              children: [
                const SizedBox(height: 12),
                _buildTeamMemberCard(
                  currentUser.name,
                  'Anda',
                  isDark,
                  titleColor,
                  mutedColor,
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // Team member card (simple, no action buttons)
  Widget _buildTeamMemberCard(
    String name,
    String role,
    bool isDark,
    Color titleColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppDarkColors.surfaceVariant 
            : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
              ? AppDarkColors.border 
              : const Color(0xFFE5E9EE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: navyColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: navyColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorItem(
    String name, 
    String role, 
    bool isPending, 
    String collaborationId,
    bool isDark,
    Color titleColor,
    Color mutedColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppDarkColors.surfaceVariant 
            : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark 
              ? AppDarkColors.border 
              : const Color(0xFFE5E9EE),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: navyColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: navyColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons for owner
          Obx(() {
            if (controller.isOwner.value) {
              if (isPending) {
                // Pending - show approve/reject buttons
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Approve button
                    InkWell(
                      onTap: () => controller.approveCollaborator(collaborationId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BC36A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF2BC36A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Reject button
                    InkWell(
                      onTap: () => controller.rejectCollaborator(collaborationId),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: urgentRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: urgentRed,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Approved - show remove button (red icon)
                return InkWell(
                  onTap: () => controller.removeCollaborator(collaborationId),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: urgentRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_remove_outlined,
                      size: 16,
                      color: urgentRed,
                    ),
                  ),
                );
              }
            } else {
              // Non-owner - no action buttons
              return const SizedBox.shrink();
            }
          }),
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
        // Selesaikan Laporan button (biru)
        _buildSolidButton(
          'Selesaikan',
          const Color(0xFF1689D8), // Blue color
          () => controller.completeReportFromCollaboration(),
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 12),
        // Batalkan Kolaborasi button (merah)
        _buildSolidButton(
          'Batalkan Kolaborasi',
          urgentRed, // Red color
          () => controller.closeCollaboration(),
          icon: Icons.cancel_outlined,
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
      // User already joined - show "Keluar" button (red with exit icon)
      return _buildSolidButton(
        'Keluar',
        urgentRed,
        () => _showLeaveConfirmation(),
        icon: Icons.logout,
      );
    }

    // User not joined yet - show "Bergabung" button (navy with add icon)
    return _buildSolidButton(
      'Bergabung',
      navyColor,
      () => controller.joinCollaboration(),
      icon: Icons.group_add,
    );
  }

  // Show confirmation dialog before leaving collaboration
  Future<void> _showLeaveConfirmation() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Keluar dari Kolaborasi'.tr),
        content: Text('Apakah Anda yakin ingin keluar dari kolaborasi ini?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: urgentRed,
            ),
            child: Text('Keluar'.tr),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.leaveCollaboration();
    }
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
