import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/ob_detail_tugas_controller.dart';
import '../../../../shared/theme/theme_controller.dart';

class ObDetailTugasView extends GetView<ObDetailTugasController> {
  const ObDetailTugasView({super.key});

  final Color navyColor = const Color(0xFF0F4C81);
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
          'Detail Tugas'.tr,
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

            // 2. FORM AKSI
            _buildActionForm(
              titleText: 'Beri Catatan',
              hintText: 'Sudah saya perbaiki ya',
            ),

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
                    controller.baseLocation.value.tr,
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

          // Info List (Kategori, Lokasi, Waktu)
          Obx(() {
            return Column(
              children: [
                _buildInfoRow(
                  Icons.edit_outlined,
                  'Kategori',
                  controller.categoryName.value,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person_outline,
                  'Lokasi',
                  controller.location.value,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time_filled,
                  'Waktu',
                  'Hari Ini',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    final isDark = Get.isDarkMode;
    final titleColor = isDark ? Colors.white60 : Colors.grey;
    final valueColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F4C81),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
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

  Widget _buildActionForm({
    required String titleText,
    required String hintText,
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
          _buildPhotoUploadSection(
            label: 'Foto Kondisi Awal',
            photosList: controller.beforePhotos,
            onPick: controller.pickBeforeImage,
            onRemove: controller.removeBeforePhoto,
          ),
          const SizedBox(height: 20),
          _buildPhotoUploadSection(
            label: 'Foto Kondisi Akhir',
            photosList: controller.actionPhotos,
            onPick: controller.pickImage,
            onRemove: controller.removePhoto,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection({
    required String label,
    required RxList<String> photosList,
    required Function(ImageSource) onPick,
    required Function(int) onRemove,
  }) {
    final isDark = Get.isDarkMode;
    final titleColor = isDark ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Preview Foto Dinamis
        Obx(() {
          if (photosList.isEmpty) {
            return GestureDetector(
              onTap: () => _showPhotoSourceSheetFor(onPick),
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
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Color(0xFF0F4C81),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap untuk unggah foto'.tr,
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
                    photosList.first,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(photosList.first),
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
              ...photosList.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildPhotoThumbnailFor(
                    path: entry.value,
                    index: entry.key,
                    onRemove: onRemove,
                  ),
                ),
              ),
              if (photosList.length < 3) _buildEmptyPhotoAddFor(onPick),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPhotoThumbnailFor({
    required String path,
    required int index,
    required Function(int) onRemove,
  }) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: kIsWeb
                ? Image.network(path, fit: BoxFit.cover)
                : Image.file(File(path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => onRemove(index),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPhotoAddFor(Function(ImageSource) onPick) {
    return GestureDetector(
      onTap: () => _showPhotoSourceSheetFor(onPick),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Icon(
          Icons.add,
          size: 18,
          color: Colors.grey,
        ),
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
        return Column(
          children: [
            _buildSolidButton(
              'Selesaikan Tugas',
              navyColor,
              () => controller.completeReport(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSolidButton(
    String text,
    Color color,
    VoidCallback? onTap,
  ) {
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
            : Text(
                text.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showPhotoSourceSheetFor(Function(ImageSource) onPick) {
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
                  onPick(ImageSource.camera);
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
                  onPick(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
