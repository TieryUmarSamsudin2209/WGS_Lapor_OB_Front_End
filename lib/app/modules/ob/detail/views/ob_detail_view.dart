import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/ob_detail_controller.dart';
import '../../../../shared/theme/theme_controller.dart';

class ObDetailView extends GetView<ObDetailController> {
  const ObDetailView({super.key});

  final Color navyColor = const Color(0xFF0F4C81);
  final Color urgentRed = const Color(0xFFC62828);
  final Color lightPurple = const Color(0xFFF3F5FF);

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
          'Detail Laporan'.tr,
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
            // 1. CARD DETAIL UTAMA
            _buildMainDetailCard(),

            const SizedBox(height: 15),

            // 2. FORM AKSI (Hanya muncul jika state 'working' atau 'rejecting')
            Obx(() {
              if (controller.pageState.value == 'working') {
                return _buildActionForm(
                  titleText: 'Beri Catatan',
                  hintText: 'catatan_hint',  // Translation key
                  photoLabel: 'Bukti Foto Selesai',
                );
              } else if (controller.pageState.value == 'rejecting') {
                return _buildActionForm(
                  titleText: 'Beri Alasan Menolak',
                  hintText: 'Tidak bisa diperbaiki, alat rusak total',
                  photoLabel: 'Bukti Foto Pembatalan (Opsional)',
                );
              }
              return const SizedBox.shrink(); // Kosong jika state awal
            }),

            const SizedBox(height: 15),

            // 3. CARD TOMBOL AKSI BAWAH
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  // 1. CARD INFORMASI UTAMA
  Widget _buildMainDetailCard() {
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
          // Header (Badge & Waktu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
                            controller.priority.value.tr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: urgentRed,
                            ),
                          )),
                        ],
                      ),
                    ),
                    Obx(() {
                      if (controller.isNeedHelp.value) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF57C00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.help,
                                size: 8,
                                color: Color(0xFFF57C00),
                              ),
                              
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final isWorking = controller.pageState.value == 'working';
                final elapsed = controller.elapsedTime.value;
                if (elapsed.isEmpty) return const SizedBox.shrink();
                return Text(
                  isWorking ? 'Dikerjakan: $elapsed' : elapsed,
                  style: TextStyle(fontSize: 11, color: mutedColor),
                );
              }),
            ],
          ),
          const SizedBox(height: 15),

          // Judul Laporan
          Obx(() => Text(
            controller.title.value.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: titleColor,
            ),
          )),
          const SizedBox(height: 8),

          // Lokasi Ringkas (Biru)
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: navyColor),
              const SizedBox(width: 4),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.location.value.tr,
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

          // Info List (Pelapor, Lokasi, Kategori)
          Obx(
            () => _buildInfoRow(
              Icons.person_outline,
              'Dilaporkan Oleh',
              controller.reporterName.value,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _buildInfoRow(
              Icons.location_on_outlined,
              'Lokasi',
              controller.location.value,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => _buildInfoRow(
              Icons.edit_outlined,
              'Kategori',
              controller.categoryName.value,
            ),
          ),

          // BAGIAN YANG BISA DI-EXPAND / COLLAPSE
          Obx(() {
            if (controller.isDetailExpanded.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Text(
                    'DESKRIPSI LAPORAN'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.description.value.tr,
                    style: TextStyle(
                      fontSize: 13,
                      color: titleColor,
                      height: 1.5,
                    ),
                  )),
                  const SizedBox(height: 25),
                  Text(
                    'BUKTI FOTO'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final hasPhoto = controller.reportPhotos.isNotEmpty;
                    if (!hasPhoto) {
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
                              'Foto belum ada'.tr,
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

                    final photoPath = controller.reportPhotos.first;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: photoPath.startsWith('http')
                              ? Image.network(
                                  photoPath,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(photoPath),
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  size: 14,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Klik untuk Perbesar'.tr,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () => controller.toggleDetailExpand(),
                  child: Text(
                    'LIHAT SELENGKAPNYA >'.tr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildActionForm({
    required String titleText,
    required String hintText,
    required String photoLabel,
  }) {
    final isDark = Get.isDarkMode;
    final surface = isDark ? const Color(0xFF102235) : lightPurple;
    final fieldColor = isDark ? const Color(0xFF172B40) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller.noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText.tr,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.all(15),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            photoLabel.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),

          // Preview Foto Dinamis
          Obx(() {
            if (controller.actionPhotos.isEmpty) {
              return GestureDetector(
                onTap: _showPhotoSourceSheet,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: Color(0xFF0F4C81),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ambil / Pilih Foto Bukti'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Image.network(
                      controller.actionPhotos.first,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(controller.actionPhotos.first),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
            );
          }),
          const SizedBox(height: 10),

          // Thumbnail Foto Dinamis
          Obx(() {
            return Row(
              children: [
                ...controller.actionPhotos.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildPhotoThumbnail(
                      path: entry.value,
                      index: entry.key,
                    ),
                  ),
                ),
                if (controller.actionPhotos.length < 3) _buildEmptyPhotoAdd(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
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
      child: Obx(() {
        if (controller.pageState.value == 'initial') {
          return Column(
            children: [
              _buildSolidButton(
                'Kerjakan Laporan',
                navyColor,
                () => controller.setWorking(),
              ),
              
            ],
          );
        }

        if (controller.pageState.value == 'working') {
          return Column(
            children: [
              _buildSolidButton(
                'Selesaikan Laporan',
                navyColor,
                () => controller.completeReport(),
              ),
              const SizedBox(height: 12),
              _buildSolidButton(
                'Tolak Laporan',
                urgentRed,
                () => controller.setRejecting(),
              ),
              const SizedBox(height: 12),
              _buildOutlineButton(
                'Kolaborasi',
                () => controller.openCollaborationPage(),
                icon: controller.isNeedHelp.value
                    ? Icons.people
                    : Icons.people_outline,
                isActive: controller.isNeedHelp.value,
              ),
            ],
          );
        }

        if (controller.pageState.value == 'rejecting') {
          return Column(
            children: [
              _buildSolidButton(
                'Konfirmasi Tolak',
                urgentRed,
                () => controller.confirmReject(),
                icon: Icons.block,
              ),
            ],
          );
        }

        if (controller.pageState.value == 'taken') {
          final name = controller.takenByName.value?.trim();
          return _buildLockedNotice(
            icon: Icons.lock_clock_rounded,
            title: 'Laporan sudah diambil',
            message: 'Laporan ini sudah diambil oleh @name.'.trParams({
              'name': name == null || name.isEmpty ? 'OB lain'.tr : name,
            }),
          );
        }

        if (controller.pageState.value == 'resolved') {
          final status = controller.activeReport?.status.value ?? 'selesai';
          return _buildLockedNotice(
            icon: Icons.verified_outlined,
            title: 'Laporan sudah @status'.trParams({
              'status': status.tr.toLowerCase(),
            }),
            message: 'Laporan ini sudah tidak dapat diambil lagi.',
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }

  void _showPhotoSourceSheet() {
    final isDark = Get.isDarkMode;
    final sheetColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;

    Get.bottomSheet(
      Material(
        color: sheetColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: sheetColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Foto'.tr,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                tileColor: sheetColor,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppDarkColors.accent.withValues(alpha: 0.16)
                        : Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: isDark ? AppDarkColors.accent : Colors.blue,
                  ),
                ),
                title: Text('Kamera'.tr, style: TextStyle(color: titleColor)),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                tileColor: sheetColor,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF9B5CFF).withValues(alpha: 0.16)
                        : Colors.purple[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: isDark ? const Color(0xFFB58CFF) : Colors.purple,
                  ),
                ),
                title: Text('Galeri'.tr, style: TextStyle(color: titleColor)),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- KUMPULAN WIDGET HELPER ---

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

  Widget _buildLockedNotice({
    required IconData icon,
    required String title,
    required String message,
  }) {
    final isDark = Get.isDarkMode;
    final iconColor = isDark ? AppDarkColors.accent : navyColor;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 34),
        const SizedBox(height: 10),
        Text(
          title.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: bodyColor,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlineButton(
    String text,
    VoidCallback onTap, {
    IconData? icon,
    bool isActive = false,
    Color activeColor = const Color(0xFFF57C00),
  }) {
    final isDark = Get.isDarkMode;
    final defaultColor = isDark ? AppDarkColors.accent : navyColor;
    final borderColor = isActive ? activeColor : defaultColor;
    final bgColor = isActive
        ? activeColor.withValues(alpha: 0.1)
        : isDark
            ? Colors.transparent
            : Colors.white;
    final fgColor = isActive ? activeColor : defaultColor;
    final usedIcon = icon ?? Icons.help_outline;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.4),
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(usedIcon, size: 22, color: fgColor),
            const SizedBox(width: 8),
            Text(
              text.tr,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail({required String path, required int index}) {
    return GestureDetector(
      onTap: () => controller.removePhoto(index),
      child: Stack(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: kIsWeb
                  ? Image.network(path, fit: BoxFit.cover)
                  : Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoAdd() {
    return GestureDetector(
      onTap: _showPhotoSourceSheet,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
