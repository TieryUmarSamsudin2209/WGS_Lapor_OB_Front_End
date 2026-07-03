import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ob_detail_controller.dart';

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
          onPressed: () => Get.offNamed('/home'),
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

  // ==========================================
  // WIDGET WIDGET BAGIAN
  // ==========================================

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
                        Text(
                          'URGENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: urgentRed,
                          ),
                        ),
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
          const Text(
            'Kebocoran Pipa Air',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
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
                  const Text(
                    'Pipa di bawah wastafel bocor parah, air meluap ke area lorong utama. Segera perbaiki sebelum licin dan membahayakan karyawan yang lewat. Pastikan membawa kunci pipa dan sealant cadangan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
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

          // Gambar Besar Preview
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://i.pinimg.com/736x/21/df/b2/21dfb25d0c75cc46927eb21516e45398.jpg', 
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Toilet Pria - Wastafel 02',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thumbnail Foto
          Row(
            children: [
              _buildPhotoThumbnail(isActive: true),
              const SizedBox(width: 10),
              _buildPhotoThumbnail(isActive: false, hasImage: true),
              const SizedBox(width: 10),
              _buildEmptyPhotoAdd(),
              const SizedBox(width: 10),
              _buildEmptyPhotoAdd(),
            ],
          ),
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

  Widget _buildPhotoThumbnail({bool isActive = false, bool hasImage = true}) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: hasImage
            ? Image.network(
                'https://i.pinimg.com/736x/21/df/b2/21dfb25d0c75cc46927eb21516e45398.jpg',
                fit: BoxFit.cover,
              )
            : Container(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildEmptyPhotoAdd() {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(child: Icon(Icons.add, size: 16, color: Colors.grey)),
    );
  }
}
