import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../../routes/app_pages.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  final Color navyColor = const Color(0xFF003366);
  final Color lightPurpleBg = const Color(0xFFF3F5FF);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Submit a Report",
              style: TextStyle(
                color: navyColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Detail the facility issue below. Providing clear photos and accurate locations helps our team respond faster.",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),

            // --- ISSUE CATEGORY DROPDOWN ---
            _buildLabel("Issue Category *"),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  decoration: _buildInputDecoration("Select a category"),
                  icon: Icon(Icons.keyboard_arrow_down, color: navyColor),
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => controller.setCategory(val),
                )),
            const SizedBox(height: 20),

            // --- PRIORITY LEVEL ---
            _buildLabel("Priority Level"),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    _buildPriorityButton(
                      label: "Standard",
                      isSelected: controller.priorityLevel.value == "Standard",
                      onTap: () => controller.setPriority("Standard"),
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityButton(
                      label: "Urgent",
                      isSelected: controller.priorityLevel.value == "Urgent",
                      onTap: () => controller.setPriority("Urgent"),
                    ),
                  ],
                )),
            const SizedBox(height: 25),

            // --- LOCATION CONTAINER (PURPLE CARD) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightPurpleBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Building *"),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedBuilding.value,
                        decoration: _buildInputDecoration("Select building"),
                        icon: Icon(Icons.keyboard_arrow_down, color: navyColor),
                        items: buildings.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.setBuilding(val);
                        },
                      )),
                  const SizedBox(height: 16),
                  _buildLabel("Floor / Room Number"),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => controller.floorRoomController.value = val,
                    decoration: _buildInputDecoration("e.g., Floor 4, Meeting Room B"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- PROBLEM DESCRIPTION ---
            _buildLabel("Problem Description *"),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              onChanged: (val) => controller.descriptionController.value = val,
              decoration: _buildInputDecoration(
                "Describe the issue in detail. What is broken? Is it causing immediate disruption?",
              ),
            ),
            const SizedBox(height: 25),

            // --- PHOTO EVIDENCE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Photo Evidence"),
                Text(
                  "Max 3 files (5MB each)",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Photo Upload Trigger Box
            GestureDetector(
              onTap: () => controller.addMockPhoto(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "Tap to upload photos",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Uploaded Photo Thumbnails Row
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
                                child: Image.network(
                                  controller.attachedPhotos[index],
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
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )),
            const SizedBox(height: 35),

            // --- SUBMIT BUTTON ---
            SizedBox(
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
                  
                  Get.snackbar(
                    "Laporan Terkirim!",
                    "Laporan Anda telah berhasil terkirim.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF003366),
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 2),
                  );
                  
                  Future.delayed(const Duration(seconds: 2), () {
                    controller.clearForm();
                    Get.back();
                  });
                },
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                label: const Text(
                  "Submit Report",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: navyColor,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: navyColor, width: 2),
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildPriorityButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF003366) : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF003366) : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
