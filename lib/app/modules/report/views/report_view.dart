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
    final pageBg = isDark ? AppDarkColors.background : Colors.white;
    final formPanelColor = isDark ? AppDarkColors.header : navyColor;
    final surface = isDark ? AppDarkColors.card : lightPurpleBg;
    final titleColor = isDark ? Colors.white : navyColor;
    final bodyColor = isDark ? Colors.white70 : Colors.grey[600];
    final mutedTextColor = isDark ? Colors.white60 : Colors.grey[500];
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
        : Colors.blue.withValues(alpha: 0.2);
    final uploadIconColor = isDark ? AppDarkColors.accent : Colors.grey[400];
    final uploadTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: isNested
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back, color: titleColor),
                onPressed: () {
                  controller.clearForm();
                  Get.back();
                },
              ),
        title: Text(
          'Lapor OB',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      // MENGGUNAKAN STACK AGAR NAVIGATION BAR BISA MELAYANG DI ATAS KONTEN
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
                        // --- HEADER SECTION (LATAR PUTIH) ---
                        Container(
                          color: pageBg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kirim Laporan'.tr,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jelaskan secara rinci masalah fasilitas di bawah ini. Menyertakan foto yang jelas dan lokasi yang akurat akan membantu tim kami merespons lebih cepat.'.tr,
                                style: TextStyle(
                                  color: bodyColor,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        ),

                        // --- FORM SECTION (CARD BIRU TUA YANG IKUT SCROLL) ---
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: formPanelColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            // Padding bawah 120 untuk memberikan ruang bagi Floating Nav Bar
                            padding: const EdgeInsets.only(
                              top: 25,
                              left: 20,
                              right: 20,
                              bottom: 120,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(
                                  'Kategori Masalah',
                                  isRequired: true,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),

                                // DROPDOWN KATEGORI
                                Obx(
                                  () => _buildModernDropdown(
                                    value:
                                        controller.selectedCategory.value?.id,
                                    hint: 'Pilih Kategori',
                                    items: controller.categoryOptions,
                                    onChanged: controller.setCategoryById,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // HERO: Kategori terpilih
                                Obx(() {
                                  final cat = controller.selectedCategory.value;
                                  if (cat == null || cat.label.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Hero(
                                    tag: 'category-${cat.label}',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _categoryIconMap[cat.label] ??
                                                Icons.help_outline,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cat.label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 12),

                                _buildLabel(
                                  'Prioritas',
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),

                                // TOGGLE BUTTON PRIORITAS
                                Obx(
                                  () => Row(
                                    children: [
                                      _buildPriorityButton(
                                        label: 'Standard',
                                        isActive:
                                            controller.priorityLevel.value ==
                                            "STANDARD",
                                        activeColor: isDark
                                            ? AppDarkColors.surfaceVariant
                                            : Colors.white,
                                        activeTextColor: isDark
                                            ? AppDarkColors.accent
                                            : navyColor,
                                        onTap: () =>
                                            controller.setPriority("STANDARD"),
                                      ),
                                      const SizedBox(width: 15),
                                      _buildPriorityButton(
                                        label: 'Urgent',
                                        isActive:
                                            controller.priorityLevel.value ==
                                            "URGENT",
                                        activeColor: urgentRed,
                                        activeTextColor: Colors.white,
                                        onTap: () =>
                                            controller.setPriority("URGENT"),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // --- INNER CARD (FORM DETAIL - LIGHT PURPLE) ---
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: surface,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel(
                                        'Lokasi',
                                        isRequired: true,
                                        color: titleColor,
                                      ),
                                      const SizedBox(height: 8),

                                      // DROPDOWN BUILDING
                                      Obx(
                                        () => _buildModernDropdown(
                                          value: controller
                                              .selectedFloor
                                              .value
                                              ?.id,
                                          hint: 'Pilih lokasi gedung',
                                          items: controller.floorOptions,
                                          onChanged: controller.setFloorById,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      _buildLabel(
                                        'Ruangan',
                                        isRequired: true,
                                        color: titleColor,
                                      ),
                                      const SizedBox(height: 8),

                                      Obx(
                                        () => _buildModernDropdown(
                                          value: controller
                                              .selectedRoom
                                              .value
                                              ?.id,
                                          hint: 'Pilih ruangan',
                                          items: controller.roomOptions,
                                          onChanged: controller.setRoomById,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      _buildLabel(
                                        'Deskripsi Masalah',
                                        isRequired: true,
                                        color: titleColor,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        hint:
                                            'Jelaskan masalahnya secara rinci.',
                                        maxLines: 4,
                                        onChanged: (val) =>
                                            controller
                                                    .descriptionController
                                                    .value =
                                                val,
                                      ),

                                      const SizedBox(height: 20),

                                      // --- PHOTO EVIDENCE ---
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildLabel(
                                            'Bukti Foto',
                                            color: titleColor,
                                          ),
                                          Text(
                                            'Max 5 foto (1MB)'.tr,
                                            style: TextStyle(
                                              color: mutedTextColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Upload Box dengan Modal Bottom Sheet
                                      GestureDetector(
                                        onTap: () {
                                          Get.bottomSheet(
                                            Material(
                                              color: uploadBackground,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      20,
                                                    ),
                                                    topRight: Radius.circular(
                                                      20,
                                                    ),
                                                  ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: uploadBackground,
                                                ),
                                                child: Wrap(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 20,
                                                          ),
                                                      child: Text(
                                                        'Pilih Sumber Foto'.tr,
                                                        style: TextStyle(
                                                          color: titleColor,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      tileColor:
                                                          uploadBackground,
                                                      leading: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isDark
                                                              ? AppDarkColors
                                                                    .accent
                                                                    .withValues(
                                                                      alpha:
                                                                          0.16,
                                                                    )
                                                              : Colors.blue[50],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.camera_alt,
                                                          color: isDark
                                                              ? AppDarkColors
                                                                    .accent
                                                              : Colors.blue,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        'Kamera'.tr,
                                                        style: TextStyle(
                                                          color: titleColor,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Get.back();
                                                        controller.pickImage(
                                                          ImageSource.camera,
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      tileColor:
                                                          uploadBackground,
                                                      leading: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9B5CFF,
                                                                ).withValues(
                                                                  alpha: 0.16,
                                                                )
                                                              : Colors
                                                                    .purple[50],
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.photo_library,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFFB58CFF,
                                                                )
                                                              : Colors.purple,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        'Galeri'.tr,
                                                        style: TextStyle(
                                                          color: titleColor,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Get.back();
                                                        controller.pickImage(
                                                          ImageSource.gallery,
                                                        );
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
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: uploadBackground,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color: uploadBorder,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.camera_alt_outlined,
                                                color: uploadIconColor,
                                                size: 30,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Ketuk untuk mengunggah foto'.tr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: uploadTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      // Image Thumbnails Row (MENGGUNAKAN File LOKAL)
                                      Obx(
                                        () => controller.attachedPhotos.isEmpty
                                            ? const SizedBox.shrink()
                                            : SizedBox(
                                                height: 90,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: controller
                                                      .attachedPhotos
                                                      .length,
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 12,
                                                          ),
                                                      child: Stack(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            child: kIsWeb
                                                                ? Image.network(
                                                                    controller
                                                                        .attachedPhotos[index],
                                                                    width: 80,
                                                                    height: 80,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Image.file(
                                                                    File(
                                                                      controller
                                                                          .attachedPhotos[index],
                                                                    ),
                                                                    width: 80,
                                                                    height: 80,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                          ),
                                                          Positioned(
                                                            top: -2,
                                                            right: -2,
                                                            child: IconButton(
                                                              icon: Container(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      2,
                                                                    ),
                                                                decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 14,
                                                                ),
                                                              ),
                                                              onPressed: () =>
                                                                  controller
                                                                      .removePhoto(
                                                                        index,
                                                                      ),
                                                              constraints:
                                                                  const BoxConstraints(),
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),

                                      const SizedBox(height: 30),

                                      // --- SUBMIT BUTTON ---
                                      Hero(
                                        tag: 'submit-report',
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: Obx(() {
                                            final isSubmitting =
                                                controller.isSubmitting.value;
                                            return ElevatedButton.icon(
                                              onPressed: isSubmitting
                                                  ? null
                                                  : () async {
                                                      final success =
                                                          await controller
                                                              .submitReport();
                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      if (success) {
                                                        await CustomAlert.show(
                                                          context,
                                                          isSuccess: true,
                                                          description:
                                                              'Laporan berhasil dikirim.'.tr,
                                                        );
                                                        controller.clearForm();
                                                        Get.back();
                                                        return;
                                                      }

                                                      final failureMessage =
                                                          controller
                                                              .submitFailureMessage
                                                              .value;
                                                      if (failureMessage !=
                                                          null) {
                                                        await CustomAlert.show(
                                                          context,
                                                          isSuccess: false,
                                                          description:
                                                              failureMessage,
                                                        );
                                                      }
                                                    },
                                              icon: isSubmitting
                                                  ? SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: isDark
                                                                ? AppDarkColors
                                                                      .accent
                                                                : Colors.white,
                                                          ),
                                                    )
                                                  : Icon(
                                                      Icons.send_outlined,
                                                      color: isDark
                                                          ? AppDarkColors.accent
                                                          : Colors.white,
                                                      size: 18,
                                                    ),
                                              label: Text(
                                                isSubmitting
                                                    ? 'Mengirim...'.tr
                                                    : 'Kirim Laporan'.tr,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark
                                                      ? AppDarkColors.accent
                                                      : Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark
                                                    ? const Color(0xFF052C58)
                                                    : navyColor,
                                                disabledBackgroundColor: isDark
                                                    ? const Color(0xFF052C58)
                                                    : navyColor.withValues(
                                                        alpha: 0.72,
                                                      ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
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
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // Sudut melengkung penuh (stadium)
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

  // Widget Dropdown Modern
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

    final selectedValue = items.any((option) => option.id == value)
        ? value
        : null;

    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedValue,
        icon: Icon(Icons.keyboard_arrow_down, color: textColor),
        dropdownColor: fieldColor,
        borderRadius: BorderRadius.circular(14),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint.tr,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: items.map((ReportOption option) {
          return DropdownMenuItem<String>(
            value: option.id,
            child: Text(option.label.tr),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Widget TextField Modern
  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    final isDark = Get.isDarkMode;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? AppDarkColors.border : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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

  // Toggle Prioritas
  Widget _buildPriorityButton({
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color activeTextColor,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    final inactiveBorderColor = isDark ? AppDarkColors.border : Colors.white;
    final activeShadowColor = isDark
        ? Colors.black
        : const Color.fromARGB(255, 233, 233, 233);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.transparent : inactiveBorderColor,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeShadowColor.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label.tr,
            style: TextStyle(
              color: isActive ? activeTextColor : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
