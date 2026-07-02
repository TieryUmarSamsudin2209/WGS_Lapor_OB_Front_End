import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/WGSLogoNoBG.png', width: 200, height: 200),
                  const Text(
                    'Lapor OB', 
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => LinearProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00355F)),
                        backgroundColor: const Color(0xFFD8D8D8),
                        value: controller.progressValue.value,
                        borderRadius: BorderRadius.circular(50),
                      )),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30, 
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'POWERED BY WALDEN GLOBAL SERVICES',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42474F),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}