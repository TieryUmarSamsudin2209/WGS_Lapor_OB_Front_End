import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/report_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/custom_alert.dart';
import '../../../shared/theme/theme_controller.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, this.isNested = false});

  final bool isNested;

  final Color navyColor = const Color(0xFF003366);
  final Color urgentRed = const Color(0xFFC62828);
  final Color lightPurpleBg = const Color(0xFFF3F5FF);

  static const Map<String, IconData> _categoryIconMap = {
    'Kebersihan': Icons.cleaning_services_outlined,
    'Pengecekan': Icons.fact_check_outlined,
    'Peralatan': Icons.inventory_2_outlined,
    'Plumbing': Icons.home_outlined,
    'Furniture': Icons.chair_outlined,
    'HVAC': Icons.local_laundry_service_outlined,
    'Miscellaneous': Icons.home_outlined,
    'Electrical': Icons.electric_bolt_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final pageBg = isDark ? AppDarkColors.background : navyColor;
    final formBg = isDark ? AppDarkColors.card : lightPurpleBg;
    final titleColor = isDark ? Colors.white : navyColor;
    final bodyColor = isDark ? Colors.white70 : (Colors.grey[600] ?? Colors.grey);
    final Color mutedTextColor = isDark ? Colors.white60 : (Colors.grey[500] ?? Colors.grey);
    
    final navBarColor = isDark ? const Color(0xFF101418) : Colors.white;
    final navBorderColor = isDark
        ? AppDarkColors.border.withValues(alpha: 0.75)
        : Colors.transparent;
    final navShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.55)
        : const Color(0xFF4FA0FF).withValues(alpha: 0.4);
        
    final uploadBackground = isDark
        ? AppDarkColors.surfaceVariant
        : Colors.white;
    final uploadBorder = isDark
        ? AppDarkColors.border
        : const Color(0xFFD1E2FF);
    final Color uploadIconColor = isDark ? AppDarkColors.accent : (Colors.grey[400] ?? Colors.grey);
    final uploadTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isNested
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  controller.clearForm();
                  Get.back();
                },
              ),
        title: Text(
          'Kirim Laporan'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER TITLE SECTION ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 10,
                            bottom: 25,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kirim Laporan'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jelaskan secara rinci masalah fasilitas di bawah ini. Menyertakan foto yang jelas dan lokasi yang akurat akan membantu tim kami merespons lebih cepat.'.tr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- FORM CONTAINER ---
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: formBg,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              top: 30,
                              left: 20,
                              right: 20,
                              bottom: 120, // Space for floating bottom nav
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                  'Kategori Masalah',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),

                                // DROPDOWN KATEGORI
                                Obx(
                                  () => _buildModernDropdown(
                                    value: controller.selectedCategory.value?.id,
                                    hint: 'Pilih Kategori',
                                    items: controller.categoryOptions,
                                    onChanged: controller.setCategoryById,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Selected category tag
                                Obx(() {
                                  final cat = controller.selectedCategory.value;
                                  if (cat == null || cat.label.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppDarkColors.accent : navyColor).withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _categoryIconMap[cat.label] ?? Icons.help_outline,
                                          color: isDark ? AppDarkColors.accent : navyColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat.label,
                                          style: TextStyle(
                                            color: isDark ? AppDarkColors.accent : navyColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                _buildLabel(
                                  'Level Prioritas',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),

                                // PRIORITAS TOGGLE
                                Obx(
                                  () => Row(
                                    children: [
                                      _buildPriorityButton(
                                        label: 'Standard',
                                        isActive: controller.priorityLevel.value == "STANDARD",
                                        activeColor: Colors.white,
                                        activeTextColor: navyColor,
                                        icon: Icons.info_outline,
                                        onTap: () => controller.setPriority("STANDARD"),
                                      ),
                                      const SizedBox(width: 15),
                                      _buildPriorityButton(
                                        label: 'Urgent',
                                        isActive: controller.priorityLevel.value == "URGENT",
                                        activeColor: urgentRed,
                                        activeTextColor: Colors.white,
                                        icon: Icons.error_outline,
                                        onTap: () => controller.setPriority("URGENT"),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // LOKASI DROPDOWN
                                _buildLabel(
                                  'Lokasi',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => _buildModernDropdown(
                                    value: controller.selectedLocation.value?.id,
                                    hint: 'Pilih Lokasi',
                                    items: controller.locationOptions,
                                    onChanged: controller.setLocationById,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // LANTAI DROPDOWN
                                _buildLabel(
                                  'Lantai',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => _buildModernDropdown(
                                    value: controller.selectedFloor.value?.id,
                                    hint: 'Pilih Lantai',
                                    items: controller.floorOptions.map((opt) {
                                      final locationLabel = controller.selectedLocation.value?.label ?? '';
                                      var cleanLabel = opt.label;
                                      if (locationLabel.isNotEmpty && cleanLabel.startsWith(locationLabel)) {
                                        cleanLabel = cleanLabel.substring(locationLabel.length);
                                        if (cleanLabel.startsWith(' - ')) {
                                          cleanLabel = cleanLabel.substring(3);
                                        }
                                      }
                                      return ReportOption(id: opt.id, label: cleanLabel, parentId: opt.parentId);
                                    }).toList(),
                                    onChanged: controller.setFloorById,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // RUANGAN DROPDOWN
                                _buildLabel(
                                  'Nama/Nomor Ruangan',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),
                                Obx(
                                  () => _buildModernDropdown(
                                    value: controller.selectedRoom.value?.id,
                                    hint: 'Pilih Ruangan',
                                    items: controller.roomOptions,
                                    onChanged: controller.setRoomById,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // DESKRIPSI MASALAH
                                _buildLabel(
                                  'Deskripsi Masalah',
                                  isRequired: true,
                                  color: titleColor,
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  hint: 'Jelaskan secara singkat detail masalah yang ditemukan...',
                                  maxLines: 4,
                                  onChanged: (val) => controller.descriptionController.value = val,
                                ),

                                const SizedBox(height: 20),

                                // SWITCH ANONYMOUS
                                _buildAnonymousToggle(controller),

                                const SizedBox(height: 25),

                                // BUKTI FOTO SECTION
                                _buildPhotoUploadSection(context, controller, isDark, titleColor, mutedTextColor, uploadBackground, uploadBorder, uploadIconColor, uploadTextColor),

                                const SizedBox(height: 15),

                                // Image Thumbnails Row (MENGGUNAKAN File LOKAL)
                                Obx(
                                  () => controller.attachedPhotos.isEmpty
                                      ? const SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.only(bottom: 20),
                                          child: SizedBox(
                                            height: 90,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller.attachedPhotos.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 12),
                                                  child: Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: kIsWeb
                                                            ? Image.network(
                                                                controller.attachedPhotos[index],
                                                                width: 80,
                                                                height: 80,
                                                                fit: BoxFit.cover,
                                                              )
                                                            : Image.file(
                                                                File(controller.attachedPhotos[index]),
                                                                width: 80,
                                                                height: 80,
                                                                fit: BoxFit.cover,
                                                              ),
                                                      ),
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap: () => controller.removePhoto(index),
                                                          child: Container(
                                                            padding: const EdgeInsets.all(4),
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.black26,
                                                                  blurRadius: 4,
                                                                  offset: Offset(0, 1),
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color: Colors.black54,
                                                              size: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 20),

                                // SUBMIT BUTTON
                                Hero(
                                  tag: 'submit-report',
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: Obx(() {
                                      final isSubmitting = controller.isSubmitting.value;
                                      return ElevatedButton.icon(
                                        onPressed: isSubmitting
                                            ? null
                                            : () async {
                                                final success = await controller.submitReport();
                                                if (!context.mounted) {
                                                  return;
                                                }

                                                if (success) {
                                                  await CustomAlert.show(
                                                    context,
                                                    isSuccess: true,
                                                    description: 'Laporan berhasil dikirim.'.tr,
                                                  );
                                                  controller.clearForm();
                                                  Get.back();
                                                  return;
                                                }

                                                final failureMessage = controller.submitFailureMessage.value;
                                                if (failureMessage != null) {
                                                  await CustomAlert.show(
                                                    context,
                                                    isSuccess: false,
                                                    description: failureMessage,
                                                  );
                                                }
                                              },
                                        icon: isSubmitting
                                            ? SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: isDark ? AppDarkColors.accent : Colors.white,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.send_outlined,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                        label: Text(
                                          isSubmitting ? 'Mengirim...'.tr : 'Kirim Laporan'.tr,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark ? const Color(0xFF052C58) : navyColor,
                                          disabledBackgroundColor: isDark
                                              ? const Color(0xFF052C58)
                                              : navyColor.withValues(alpha: 0.72),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          elevation: 2,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // --- FLOATING NAVIGATION BAR ---
          if (!isNested)
            Positioned(
              bottom: 25,
              left: 20,
              right: 20,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: navBarColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: navBorderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: navShadowColor,
                      blurRadius: isDark ? 10 : 20,
                      spreadRadius: isDark ? 0 : 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: BottomNavItem(
                        icon: Icons.home_outlined,
                        label: "Home",
                        isActive: false,
                        onTap: () => Get.offAllNamed(Routes.HOME),
                        navyColor: navyColor,
                      ),
                    ),
                    Expanded(
                      child: BottomNavItem(
                        icon: Icons.add_circle,
                        label: "Report",
                        isActive: true,
                        onTap: () {},
                        navyColor: navyColor,
                      ),
                    ),
                    Expanded(
                      child: BottomNavItem(
                        icon: Icons.person_outline,
                        label: "Profile",
                        isActive: false,
                        onTap: () => Get.offAllNamed(Routes.PROFILE),
                        navyColor: navyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    bool isRequired = false,
    required Color color,
  }) {
    return RichText(
      text: TextSpan(
        text: text.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        children: isRequired
            ? [
                const TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String hint,
    required List<ReportOption> items,
    required Function(String?) onChanged,
  }) {
    final isDark = Get.isDarkMode;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? AppDarkColors.border : Colors.transparent;

    return _CustomDropdown(
      value: value,
      hint: hint,
      items: items,
      onChanged: onChanged,
      fieldColor: fieldColor,
      textColor: textColor,
      borderColor: borderColor,
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    final isDark = Get.isDarkMode;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD1E2FF);

    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: hint.tr,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildPriorityButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color activeTextColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    final inactiveBgColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final Color inactiveTextColor = isDark ? Colors.white60 : (Colors.grey[600] ?? Colors.grey);
    final inactiveBorderColor = isDark ? AppDarkColors.border : (Colors.grey[200] ?? Colors.grey);

    final border = isActive
        ? Border.all(color: activeColor == Colors.white ? const Color(0xFF003366) : activeColor, width: 2)
        : Border.all(color: inactiveBorderColor, width: 1);

    final bg = isActive ? activeColor : inactiveBgColor;
    final textCol = isActive ? activeTextColor : inactiveTextColor;
    final iconCol = isActive ? activeTextColor : inactiveTextColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconCol,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label.tr,
                style: TextStyle(
                  color: textCol,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle(ReportController controller) {
    final isDark = Get.isDarkMode;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF003366);
    final subtitleColor = isDark ? Colors.white60 : Colors.grey[500];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
                  'Kirim sebagai Anonim'.tr,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Identitas Anda tidak akan ditampilkan'.tr,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.isAnonymous.value,
              onChanged: (val) => controller.isAnonymous.value = val,
              activeColor: const Color(0xFF003366),
              activeTrackColor: const Color(0xFF003366).withValues(alpha: 0.2),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection(
    BuildContext context,
    ReportController controller,
    bool isDark,
    Color titleColor,
    Color mutedTextColor,
    Color uploadBackground,
    Color uploadBorder,
    Color uploadIconColor,
    Color uploadTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel(
              'Bukti Foto',
              color: titleColor,
            ),
            Text(
              'Max 3 foto (1MB)'.tr,
              style: TextStyle(
                color: mutedTextColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(
              Material(
                color: uploadBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Pilih Sumber Foto'.tr,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppDarkColors.accent.withValues(alpha: 0.16) : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: isDark ? AppDarkColors.accent : Colors.blue),
                        ),
                        title: Text('Kamera'.tr, style: TextStyle(color: titleColor)),
                        onTap: () {
                          Get.back();
                          controller.pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF9B5CFF).withValues(alpha: 0.16) : Colors.purple[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.photo_library, color: isDark ? const Color(0xFFB58CFF) : Colors.purple),
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
          },
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: uploadBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: uploadBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: isDark ? AppDarkColors.accent : const Color(0xFF003366).withValues(alpha: 0.4),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ketuk untuk mengunggah foto'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF003366).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomDropdown extends StatefulWidget {
  final String? value;
  final String hint;
  final List<ReportOption> items;
  final ValueChanged<String?> onChanged;
  final Color fieldColor;
  final Color textColor;
  final Color borderColor;

  const _CustomDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.fieldColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  State<_CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<_CustomDropdown> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    final idx = widget.items.indexWhere((option) => option.id == widget.value);
    final selectedLabel = idx != -1 ? widget.items[idx].label.tr : null;

    return Container(
      decoration: BoxDecoration(
        color: widget.fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        key: _key,
        onTap: _showMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedLabel ?? widget.hint.tr,
                  style: TextStyle(
                    color:
                        selectedLabel != null ? widget.textColor : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, color: widget.textColor),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu() async {
    final renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      color: widget.fieldColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 8,
      items: widget.items.map((option) {
        final isSelected = option.id == widget.value;
        return PopupMenuItem<String>(
          value: option.id,
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                option.label.tr,
                style: TextStyle(
                  color: isSelected
                      ? (Get.isDarkMode
                          ? Colors.white
                          : const Color(0xFF003366))
                      : (Get.isDarkMode ? Colors.white70 : Colors.black87),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    if (result != null && mounted) {
      widget.onChanged(result);
    }
  }
}
