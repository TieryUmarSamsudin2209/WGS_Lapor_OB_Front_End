import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../controllers/aktivasi_controller.dart';

class AktivasiView extends GetView<AktivasiController> {
  const AktivasiView({super.key});

  final Color navyTextColor = const Color(0xFF003366);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isActivationFailed.value) {
        return _buildActivationFailedView();
      }

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
    });
  }

  Widget _buildActivationFailedView() {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  'assets/images/logo_wgs.png',
                  width: 142,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.business_rounded,
                      size: 92,
                      color: Color(0xFF111827),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Lapor OB',
                  style: TextStyle(
                    color: navyTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD8D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link_off_rounded,
                    color: Color(0xFFD71920),
                    size: 29,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Aktivasi Gagal',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                _ActivationMessageBox(
                  backgroundColor: Color(0xFFFFF1F2),
                  borderColor: Color(0xFFFFB9C0),
                  title: 'Maaf, tautan tidak valid.',
                  message:
                      'Tautan aktivasi ini sudah tidak valid atau telah kedaluwarsa.\n'
                      'Tautan biasanya hanya berlaku selama kurun waktu yang\n'
                      'ditentukan atau hanya bisa digunakan satu kali.',
                ),
                const SizedBox(height: 20),
                const _ActivationMessageBox(
                  backgroundColor: Color(0xFFFFFCF5),
                  borderColor: Color(0xFFECDDB9),
                  title:
                      'Langkah selanjutnya: Silakan hubungi\nadministrator Anda untuk meminta tautan\naktivasi baru.',
                ),
                const SizedBox(height: 46),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.offAllNamed(Routes.LOGIN),
                    icon: const Icon(Icons.arrow_back_rounded, size: 13),
                    label: const Text('Kembali ke Beranda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5F9F),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(
                        0xFF0F5F9F,
                      ).withValues(alpha: 0.32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                const Text(
                  'POWERED BY WALDEN GLOBAL SERVICES',
                  style: TextStyle(
                    color: Color(0xFF7B879D),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
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
        _buildPolicyText(
          "Kebijakan Privasi",
          onTap: () => Get.toNamed(Routes.PRIVACY),
        ),
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

class _ActivationMessageBox extends StatelessWidget {
  const _ActivationMessageBox({
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    this.message,
  });

  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF40151A),
              fontSize: 11,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: const TextStyle(
                color: Color(0xFF40151A),
                fontSize: 10,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
