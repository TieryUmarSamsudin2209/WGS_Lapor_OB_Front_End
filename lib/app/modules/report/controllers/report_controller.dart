import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan package ini sudah di-install
import 'package:flutter/material.dart';

class ReportController extends GetxController {
  // --- STATE VARIABEL ---
  final selectedCategory = RxnString(null);
  final priorityLevel = "Standard".obs;
  final floorRoomController = "".obs;
  final descriptionController = "".obs;
  
  final attachedPhotos = <String>[].obs; 
  
  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // --- FUNGSI-FUNGSI ---

  void setCategory(String? category) {
    selectedCategory.value = category;
  }

  void setPriority(String priority) {
    priorityLevel.value = priority;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, 
      );
      
      if (image != null) {
        if (attachedPhotos.length < 3) {
          attachedPhotos.add(image.path); 
        } else {
          Get.snackbar(
            "Batas Maksimal", 
            "Anda hanya dapat mengunggah maksimal 3 foto.",
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil foto: $e");
    }
  }

  // Fungsi untuk menghapus foto dari list
  void removePhoto(int index) {
    attachedPhotos.removeAt(index);
  }

  void clearForm() {
    selectedCategory.value = null;
    priorityLevel.value = "Standard";
    floorRoomController.value = "";
    descriptionController.value = "";
    attachedPhotos.clear();
  }
}