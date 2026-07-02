import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      // Gunakan Stack murni agar Center content dan Footer terpisah posisinya
      body: Stack(
        children: [
          // --- BAGIAN TENGAH (LOGO & LOADING) ---
          Center(
            child: Obx(() => AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: controller.isLoaded.value ? 1.0 : 0.0,
                  curve: Curves.easeIn,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    // Efek melayang naik (slide up) halus
                    padding: EdgeInsets.only(top: controller.isLoaded.value ? 0 : 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LOGO
                        Image.asset(
                          'assets/images/logo_wgs.png', 
                          width: 180, // Disesuaikan agar proporsional
                          height: 180,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // TEKS APLIKASI
                        const Text(
                          'Lapor OB', 
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: 26,
                            color: Color(0xFF003366), // Sesuai warna navy Anda sebelumnya
                            letterSpacing: 1.2,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // CUSTOM LOADING BAR (LEBIH MODERN & SMOOTH)
                        Container(
                          width: 200, // Lebar total loading bar
                          height: 6,  // Ketebalan loading bar
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EAF8), // Background bar (biru sangat pudar)
                            borderRadius: BorderRadius.circular(10), // Ujung membulat
                          ),
                          child: Stack(
                            children: [
                              // Baris yang mengisi loading
                              Obx(() => AnimatedContainer(
                                    duration: const Duration(milliseconds: 100), // Muluskan lompatan value
                                    width: 200 * controller.progressValue.value,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF003366), // Warna bar yang terisi
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF003366).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
          
          // --- BAGIAN BAWAH (FOOTER) ---
          Positioned(
            bottom: 40, 
            left: 0,
            right: 0,
            child: Obx(() => AnimatedOpacity(
                  // Footer hanya fade in, tidak ikut bergeser (slide)
                  duration: const Duration(milliseconds: 1200),
                  opacity: controller.isLoaded.value ? 1.0 : 0.0,
                  child: const Column(
                    children: [
                      Text(
                        'POWERED BY',
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'WALDEN GLOBAL SERVICES',
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF003366),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}