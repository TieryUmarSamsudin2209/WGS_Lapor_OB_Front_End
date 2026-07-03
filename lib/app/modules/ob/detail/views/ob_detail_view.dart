import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/ob_detail_controller.dart';
import '../../../../routes/app_pages.dart';

class ObDetailView extends GetView<ObDetailController> {
  const ObDetailView({super.key});

  final Color navyColor = const Color(0xFF0F4C81);
  final Color urgentRed = const Color(0xFFC62828);
  final Color lightPurple = const Color(0xFFF3F5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail Laporan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  hintText: 'Sudah saya perbaiki ya',
                  photoLabel: 'Bukti Foto Selesai',
                );
              } else if (controller.pageState.value == 'rejecting') {
                return _buildActionForm(
                  titleText: 'Beri Alasan Menolak',
                  hintText: 'Tidak bisa diperbaiki, alat rusak total',
                  photoLabel: 'Bukti Foto',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Badge & Waktu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgentRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: urgentRed),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          controller.priority.value,
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
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF57C00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.help,
                                size: 8,
                                color: const Color(0xFFF57C00),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'BUTUH BANTUAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const Text(
                '10 menit yang lalu',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Judul Laporan
          Obx(() => Text(
            controller.title.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          )),
          const SizedBox(height: 8),

          // Lokasi Ringkas (Biru)
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: navyColor),
              const SizedBox(width: 4),
              Text(
                'HQ Tower A, Lantai 4 (Toilet Pria)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: navyColor,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          ),

          // Info List (Pelapor, Lokasi, Kategori)
          _buildInfoRow(Icons.person_outline, 'Dilaporkan Oleh', 'Alex'),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Lokasi',
            'HQ Tower A, Lantai 3, Toilet Pria',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.edit_outlined, 'Kategori', 'Plumbing (Pipa)'),

          // BAGIAN YANG BISA DI-EXPAND / COLLAPSE
          Obx(() {
            if (controller.isDetailExpanded.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    'DESKRIPSI LAPORAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.description.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  )),
                  const SizedBox(height: 25),
                  const Text(
                    'BUKTI FOTO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bukti Foto dari User (Gambar dummy app)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://i.pinimg.com/736x/87/49/71/874971df30fa58b8f36a536ba95701a2.jpg', // Placeholder foto masalah
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
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 14,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Klik untuk Perbesar',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () => controller.toggleDetailExpand(),
                  child: const Text(
                    'LIHAT SELENGKAPNYA >',
                    style: TextStyle(
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.1)),
            ),
            child: TextField(
              controller: controller.noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.all(15),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            photoLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                        'Ambil / Pilih Foto Bukti',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              const SizedBox(height: 10),
              _buildOutlineButton(
                'Butuh Bantuan',
                () => controller.toggleNeedHelp(),
                icon: controller.isNeedHelp.value
                    ? Icons.help
                    : Icons.help_outline,
                isActive: controller.isNeedHelp.value,
              ),
            ],
          );
        } else if (controller.pageState.value == 'working') {
          return Column(
            children: [
              _buildSolidButton(
                'Selesaikan Laporan',
                navyColor,
                () => controller.completeReport(),
              ),
              const SizedBox(height: 10),
              _buildSolidButton(
                'Tolak Laporan',
                urgentRed,
                () => controller.setRejecting(),
              ),
              const SizedBox(height: 10),
              _buildOutlineButton(
                'Butuh Bantuan',
                () => controller.toggleNeedHelp(),
                icon: controller.isNeedHelp.value
                    ? Icons.help
                    : Icons.help_outline,
                isActive: controller.isNeedHelp.value,
              ),
            ],
          );
        } else if (controller.pageState.value == 'rejecting') {
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
        return const SizedBox.shrink();
      }),
    );
  }

  void _showPhotoSourceSheet() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.blue),
              ),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: Colors.purple),
              ),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- KUMPULAN WIDGET HELPER ---

  Widget _buildInfoRow(IconData icon, String title, String value) {
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
                title,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
    String text,
    VoidCallback onTap, {
    IconData? icon,
    bool isActive = false,
    Color activeColor = const Color(0xFFF57C00),
  }) {
    final borderColor = isActive ? activeColor : Colors.grey.shade300;
    final bgColor = isActive
        ? activeColor.withOpacity(0.1)
        : Colors.transparent;
    final fgColor = isActive ? activeColor : Colors.black87;
    final usedIcon = icon ?? Icons.help_outline;
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(usedIcon, size: 16, color: fgColor),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
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