import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/aktivasi_controller.dart';

class AktivasiView extends GetView<AktivasiController> {
  const AktivasiView({super.key});

  final Color navyTextColor = const Color(0xFF003366);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFEBF2FC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                Image.asset(
                  'assets/images/logo_wgs.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      size: 120,
                      color: Colors.grey,
                    );
                  },
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 40,
                      bottom: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF003366).withValues(alpha: 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Halo,Usn!",
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: navyTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Selamat datang di Lapor OB!",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: navyTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildLabel("Password"),
                        _buildInputField(
                          hint: "Masukan Password",
                          isPassword: true,
                        ),

                        const SizedBox(height: 20),

                        _buildLabel("Password Confirmation"),
                        _buildInputField(
                          hint: "Konfirmasi Password",
                          isPassword: true,
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: SizedBox(
                            width: 130,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () => Get.offAllNamed(Routes.LOGIN),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FA0FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: const Color(
                                  0xFF4FA0FF,
                                ).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "Aktivasi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Belum punya akun? ",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                              children: [
                                TextSpan(
                                  text: "Hubungi admin",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: navyTextColor,
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

                const SizedBox(height: 28),
                _buildPolicyLinks(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: navyTextColor,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInputField({required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBE7F5).withValues(alpha: 0.8),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        style: TextStyle(color: navyTextColor, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPolicyLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPolicyText("Kebijakan Privasi"),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            "•",
            style: TextStyle(
              color: Color(0xFF7B879D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _buildPolicyText(
          "Syarat & Ketentuan",
          onTap: () => Get.toNamed(Routes.TERMS),
        ),
      ],
    );
  }

  Widget _buildPolicyText(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF7B879D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
