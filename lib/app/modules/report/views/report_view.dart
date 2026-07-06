import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/report_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/custom_alert.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  final Color navyColor = const Color(0xFF003366);
  final Color urgentRed = const Color(0xFFC62828);
  final Color lightPurpleBg = const Color(0xFFF3F5FF);

  static const Map<String, IconData> _categoryIconMap = {
    'Plumbing': Icons.home_outlined,
    'Furniture': Icons.chair_outlined,
    'HVAC': Icons.local_laundry_service_outlined,
    'Miscellaneous': Icons.home_outlined,
    'Electrical': Icons.electric_bolt_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    // Check if category was passed as argument
    final String? passedCategory = Get.arguments as String?;
    if (passedCategory != null && passedCategory.isNotEmpty) {
      controller.setCategory(passedCategory);
    }

    final categories = ['Plumbing', 'Electrical', 'HVAC', 'Furniture'];
    final buildings = [
      'Headquarters (Tower A)',
      'Headquarters (Tower B)',
      'Warehouse (Sector C)',
      'Office Wing (East)'
    ];

    // Local state untuk Dropdown Building
    final RxnString selectedBuilding = RxnString(null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: navyColor),
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
        ),
        title: Text(
          "Lapor OB",
          style: TextStyle(
            color: navyColor,
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
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER SECTION (LATAR PUTIH) ---
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kirim Laporan",
                                style: TextStyle(
                                  color: navyColor,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Jelaskan secara rinci masalah fasilitas di bawah ini. Menyertakan foto yang jelas dan lokasi yang akurat akan membantu tim kami merespons lebih cepat.",
                                style: TextStyle(
                                  color: Colors.grey[600],
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
                              color: navyColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            // Padding bawah 120 untuk memberikan ruang bagi Floating Nav Bar
                            padding: const EdgeInsets.only(top: 25, left: 20, right: 20, bottom: 120),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Kategori Masalah", isRequired: true, color: Colors.white),
                                const SizedBox(height: 8),
                                
                                // DROPDOWN KATEGORI
                                _buildModernDropdown(
                                  value: RxnString(controller.selectedCategory.value),
                                  hint: "Pilih Kategori",
                                  items: categories,
                                  onChanged: (val) => controller.setCategory(val),
                                ),
                                
                                const SizedBox(height: 12),

                                // HERO: Kategori terpilih
                                Obx(() {
                                  final cat = controller.selectedCategory.value;
                                  if (cat == null || cat.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Hero(
                                    tag: 'category-$cat',
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_categoryIconMap[cat] ?? Icons.help_outline, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            cat,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 12),

                                _buildLabel("Priority Level", color: Colors.white),
                                const SizedBox(height: 8),
                                
                                // TOGGLE BUTTON PRIORITAS
                                Obx(() => Row(
                                  children: [
                                    _buildPriorityButton(
                                      label: "Standard",
                                      isActive: controller.priorityLevel.value == "Standard",
                                      activeColor: Colors.white,
                                      activeTextColor: navyColor,
                                      onTap: () => controller.setPriority("Standard"),
                                    ),
                                    const SizedBox(width: 15),
                                    _buildPriorityButton(
                                      label: "Urgent",
                                      isActive: controller.priorityLevel.value == "Urgent",
                                      activeColor: urgentRed,
                                      activeTextColor: Colors.white,
                                      onTap: () => controller.setPriority("Urgent"),
                                    ),
                                  ],
                                )),

                                const SizedBox(height: 25),

                                // --- INNER CARD (FORM DETAIL - LIGHT PURPLE) ---
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: lightPurpleBg,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Lokasi", isRequired: true, color: navyColor),
                                      const SizedBox(height: 8),
                                      
                                      // DROPDOWN BUILDING
                                      _buildModernDropdown(
                                        value: selectedBuilding,
                                        hint: "Pilih lokasi gedung",
                                        items: buildings,
                                        onChanged: (val) => selectedBuilding.value = val,
                                      ),

                                      const SizedBox(height: 20),

                                      _buildLabel("Lantai / Nomor Ruangan *", color: navyColor),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        hint: "Keterangan Tempat",
                                        onChanged: (val) => controller.floorRoomController.value = val,
                                      ),

                                      const SizedBox(height: 20),

                                      _buildLabel("Deskripsi Masalah", isRequired: true, color: navyColor),
                                      const SizedBox(height: 8),
                                      _buildTextField(
                                        hint: "JJelaskan masalahnya secara rinci.",
                                        maxLines: 4,
                                        onChanged: (val) => controller.descriptionController.value = val,
                                      ),

                                      const SizedBox(height: 20),

                                      // --- PHOTO EVIDENCE ---
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildLabel("Bukti Foto", color: navyColor),
                                          Text(
                                            "Max 3 foto (1MB)",
                                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Upload Box dengan Modal Bottom Sheet
                                      GestureDetector(
                                        onTap: () {
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
                                              child: Wrap(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(bottom: 20),
                                                    child: Text(
                                                      "Pilih Sumber Foto",
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  ListTile(
                                                    leading: Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                                                      child: const Icon(Icons.camera_alt, color: Colors.blue),
                                                    ),
                                                    title: const Text("Kamera"),
                                                    onTap: () {
                                                      Get.back();
                                                      controller.pickImage(ImageSource.camera);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(color: Colors.purple[50], shape: BoxShape.circle),
                                                      child: const Icon(Icons.photo_library, color: Colors.purple),
                                                    ),
                                                    title: const Text("Galeri"),
                                                    onTap: () {
                                                      Get.back();
                                                      controller.pickImage(ImageSource.gallery);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.2), 
                                              width: 1.5
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 30),
                                              const SizedBox(height: 8),
                                              const Text(
                                                "Ketuk untuk mengunggah foto",
                                                style: TextStyle(
                                                  fontSize: 12, 
                                                  fontWeight: FontWeight.bold, 
                                                  color: Colors.black54
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      // Image Thumbnails Row (MENGGUNAKAN File LOKAL)
                                      Obx(() => controller.attachedPhotos.isEmpty
                                          ? const SizedBox.shrink()
                                          : SizedBox(
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
                                                          top: -2,
                                                          right: -2,
                                                          child: IconButton(
                                                            icon: Container(
                                                              padding: const EdgeInsets.all(2),
                                                              decoration: const BoxDecoration(
                                                                color: Colors.white,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: const Icon(Icons.close, color: Colors.black, size: 14),
                                                            ),
                                                            onPressed: () => controller.removePhoto(index),
                                                            constraints: const BoxConstraints(),
                                                            padding: EdgeInsets.zero,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            )),

                                      const SizedBox(height: 30),

                                      // --- SUBMIT BUTTON ---
                                      Hero(
                                        tag: 'submit-report',
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              if (controller.selectedCategory.value == null) {
                                                Get.snackbar(
                                                  "Peringatan",
                                                  "Harap pilih kategori masalah terlebih dahulu.",
                                                  backgroundColor: Colors.orangeAccent,
                                                  colorText: Colors.white,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(16),
                                                  borderRadius: 12,
                                                );
                                                return;
                                              }

                                              // ── Custom alert berhasil ──
                                              CustomAlert.show(context, isSuccess: true);

                                              Future.delayed(const Duration(milliseconds: 1800), () {
                                                controller.clearForm();
                                                Get.back();
                                              });
                                            },
                                            icon: const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                                            label: const Text(
                                              "Kirim Laporan",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: navyColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              elevation: 2,
                                            ),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // --- FLOATING NAVIGATION BAR ---
          Positioned(
            bottom: 25,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Sudut melengkung penuh (stadium)
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FA0FF).withOpacity(0.4), // Glow Biru
                    blurRadius: 20,
                    spreadRadius: 2,
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

  Widget _buildLabel(String text, {bool isRequired = false, required Color color}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        children: isRequired
            ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  // Widget Dropdown Modern
  Widget _buildModernDropdown({
    required RxnString value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => DropdownButtonFormField<String>(
        value: value.value,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        items: items.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: onChanged,
      )),
    );
  }

  // Widget TextField Modern
  Widget _buildTextField({required String hint, int maxLines = 1, required Function(String) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
      ),
      child: TextField(
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? Colors.transparent : Colors.white),
            boxShadow: isActive
                ? [BoxShadow(color: const Color.fromARGB(255, 233, 233, 233).withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
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