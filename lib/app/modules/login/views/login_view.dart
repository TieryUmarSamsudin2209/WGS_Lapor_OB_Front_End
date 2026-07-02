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
      theme: ThemeData(
        fontFamily: 'sans-serif',
      ),
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
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEBF2FC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // --- LOGO WGS MENGGUNAKAN IMAGE ---
                Image.asset(
                  'assets/images/logo_wgs.png',
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
                  },
                ),

                const SizedBox(height: 40),

                // --- LOGIN CARD ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF003366).withValues(alpha: 0.06),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Halo!",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: navyTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            "Selamat datang di Lapor OB!",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: navyTextColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        _buildLabel("Username"),
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () => Get.offAllNamed(Routes.HOME),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4FA0FF),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: const Color(0xFF4FA0FF).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                "Masuk",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.REGISTER),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'sans-serif',
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Belum punya akun? ",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: "Daftar",
                                    style: TextStyle(
                                      color: navyTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          color: navyTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildInputField({required String hint, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2EAF8),
          width: 1.5,
        ),
      ),
      child: TextField(
        obscureText: isPassword,
        style: TextStyle(
          color: navyTextColor,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: InputBorder.none,
          isDense: true,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}