import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/widgets/contact_admin_dialog.dart';
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
                            color: const Color(
                              0xFF003366,
                            ).withValues(alpha: 0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "Aktivasi Akun",
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: navyTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                "Buat password pertama untuk masuk ke Lapor OB.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: navyTextColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            _buildLabel("Password"),
                            Obx(
                              () => _buildInputField(
                                controller: controller.passwordController,
                                hint: "Masukan Password",
                                obscureText: controller.obscurePassword.value,
                                onToggleVisibility:
                                    controller.togglePasswordVisibility,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Password wajib diisi';
                                  }
                                  if (text.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildLabel("Password Confirmation"),
                            Obx(
                              () => _buildInputField(
                                controller:
                                    controller.confirmPasswordController,
                                hint: "Konfirmasi Password",
                                obscureText:
                                    controller.obscureConfirmPassword.value,
                                onToggleVisibility:
                                    controller.toggleConfirmPasswordVisibility,
                                validator: (value) {
                                  final text = value ?? '';
                                  if (text.isEmpty) {
                                    return 'Konfirmasi password wajib diisi';
                                  }
                                  if (text !=
                                      controller.passwordController.text) {
                                    return 'Password tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            Center(
                              child: SizedBox(
                                width: 130,
                                height: 38,
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.activateAccount,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4FA0FF),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: const Color(
                                        0xFF9DCBFF,
                                      ),
                                      elevation: 0,
                                      shadowColor: const Color(
                                        0xFF4FA0FF,
                                      ).withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
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
                            ),

                            const SizedBox(height: 40),

                            _AdminContactPrompt(textColor: navyTextColor),
                          ],
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
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
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
          suffixIcon: IconButton(
            tooltip: obscureText
                ? 'Tampilkan password'
                : 'Sembunyikan password',
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF6B7280),
              size: 18,
            ),
          ),
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

class _AdminContactPrompt extends StatelessWidget {
  const _AdminContactPrompt({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Belum punya akun? ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          GestureDetector(
            onTap: () => ContactAdminDialog.show(context),
            child: Text(
              'Hubungi admin',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ],
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
