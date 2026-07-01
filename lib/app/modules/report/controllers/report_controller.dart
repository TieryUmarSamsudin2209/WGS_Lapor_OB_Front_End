import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ReportController extends GetxController {
  final selectedCategory = Rxn<String>();
  final priorityLevel = 'Standard'.obs; // Standard or Urgent
  final selectedBuilding = 'Headquarters (Tower A)'.obs;
  final floorRoomController = ''.obs;
  final descriptionController = ''.obs;
  final attachedPhotos = <String>[].obs; // URL list of mock images

  void setCategory(String? category) {
    selectedCategory.value = category;
  }

  void setPriority(String priority) {
    priorityLevel.value = priority;
  }

  void setBuilding(String building) {
    selectedBuilding.value = building;
  }

  void addMockPhoto() {
    if (attachedPhotos.length < 3) {
      // Mock photo of a leak or maintenance issue
      const mockPhotos = [
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=300', // Ceiling water stain
        'https://images.unsplash.com/photo-1542013936693-8848e574047e?auto=format&fit=crop&q=80&w=300', // Pipes leaking
        'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&q=80&w=300', // Electrical cabinet
      ];
      attachedPhotos.add(mockPhotos[attachedPhotos.length]);
    } else {
      Get.snackbar(
        "Limit Tercapai",
        "Anda hanya dapat menambahkan maksimal 3 foto.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFCC3333),
        colorText: Colors.white,
      );
    }
  }

  void removePhoto(int index) {
    attachedPhotos.removeAt(index);
  }

  void clearForm() {
    selectedCategory.value = null;
    priorityLevel.value = 'Standard';
    selectedBuilding.value = 'Headquarters (Tower A)';
    floorRoomController.value = '';
    descriptionController.value = '';
    attachedPhotos.clear();
  }
}
