import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

void main() {
  runApp(const LoginPages());
}

class LoginPages extends StatelessWidget {
  const LoginPages({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'sans-serif'),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  final Color navyTextColor = const Color(0xFF003366);
  final Color primaryBlue = const Color(0xFF5B9FFF);

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

                // --- LOGO WGS ---
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

                // --- LOGIN CARD ---
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
                          color: Colors.grey.withValues(alpha: 0.3),
                          // Spread radius negatif dan Offset ke bawah (Y positif)
                          // Memastikan shadow/bayangan HANYA muncul di bagian bawah card
                          spreadRadius: -10,
                          blurRadius: 20,
                          offset: const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Halo!",
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

                        _buildLabel("Username"),
                        // Memanggil input field lama dengan hint kosong agar mirip difoto
                        _buildInputField(hint: "Masukan Username"),

                        const SizedBox(height: 20),

                        _buildLabel("Password"),
                        _buildInputField(hint: "Masukan Password", isPassword: true),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, right: 8),
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Lupa Password?",
                                style: TextStyle(
                                  color: navyTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: SizedBox(
                            width: 130,
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () => Get.offAllNamed(Routes.HOME),
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
                                "Masuk",
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
                const SizedBox(height: 50),
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

  // --- MENGGUNAKAN SOURCE INPUT FIELD LAMA ANDA ---
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
}