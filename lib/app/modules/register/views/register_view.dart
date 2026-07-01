import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F5FF),
              Color(0xFFFFFFFF),
              Color(0xFFF0F5FF),
            ],
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
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
                  },
                ),

                const SizedBox(height: 50),

                // --- REGISTER CARD ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ciptakan Akun",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: navyTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Lapor OB-Mu!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: navyTextColor,
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildLabel("Username"),
                        _buildInputField(hint: ""),

                        const SizedBox(height: 20),

                        _buildLabel("Password"),
                        _buildInputField(hint: "", isPassword: true),

                        const SizedBox(height: 20),

                        _buildLabel("Confirm Password"),
                        _buildInputField(hint: "", isPassword: true),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => Get.offAllNamed(Routes.HOME),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Buat akun",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Center(
                          child: GestureDetector(
                            onTap: () => Get.offNamed(Routes.LOGIN),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                children: [
                                  const TextSpan(text: "Sudah memiliki akun? "),
                                  TextSpan(
                                    text: "Masuk",
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
      padding: const EdgeInsets.only(left: 5, bottom: 8),
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
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }
}
