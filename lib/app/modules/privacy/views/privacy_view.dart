import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  static const _navy = Color(0xFF111827);
  static const _primaryBlue = Color(0xFF0077B6);
  static const _softBlue = Color(0xFFD8ECFF);
  static const _pageBg = Color(0xFFF7F9FC);
  static const _bodyText = Color(0xFF4B5563);
  static const _green = Color(0xFF22C55E);
  static const _orange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 38, 28, 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Terakhir diperbarui: 7 Juli 2026',
                            style: TextStyle(
                              color: _bodyText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 21),
                          Container(
                            width: 74,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFF23A7FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 58),
                          const Text(
                            'Melindungi Data Anda di\nLapor-OB',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 29,
                              height: 1.28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Privasi Anda adalah prioritas kami. Dokumen ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat menggunakan platform manajemen Office Boy kami.',
                            style: TextStyle(
                              color: _bodyText,
                              fontSize: 16,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 38),
                          _buildImportantCard(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PrivacySection(
                            icon: Icons.manage_accounts_outlined,
                            title: '1. Informasi yang Kami\nKumpulkan',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Kami mengumpulkan informasi untuk memberikan layanan yang lebih baik kepada semua pengguna kami. Hal ini mencakup:',
                                  style: _PrivacyTextStyles.body,
                                ),
                                SizedBox(height: 14),
                                _BoldParagraph(
                                  text:
                                      'Informasi Akun: Nama, email dan peran (Karyawan atau Office Boy).',
                                ),
                                _BoldParagraph(
                                  text:
                                      'Data Laporan: Deskripsi tugas, foto bukti pekerjaan, dan waktu penyelesaian.',
                                ),
                                _BoldParagraph(
                                  text:
                                      'Lokasi: Data lokasi saat melakukan pelaporan untuk validasi kehadiran tugas (hanya jika diizinkan).',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _PrivacySection(
                            icon: Icons.settings_suggest_outlined,
                            title: '2. Penggunaan Informasi',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Informasi yang kami kumpulkan digunakan untuk mengoperasikan, memelihara, dan menyediakan fitur layanan Lapor-OB, termasuk:',
                                  style: _PrivacyTextStyles.body,
                                ),
                                SizedBox(height: 15),
                                _QuoteBox(
                                  text:
                                      '"Memantau kinerja operasional harian secara real-time untuk memastikan kebersihan gedung terjaga."',
                                ),
                                SizedBox(height: 11),
                                Text(
                                  'Kami juga menggunakan data untuk mengirimkan notifikasi tugas baru atau pembaruan status laporan langsung ke perangkat Anda.',
                                  style: _PrivacyTextStyles.body,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _PrivacySection(
                            icon: Icons.security_outlined,
                            title: '3. Keamanan Data',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Kami bekerja keras untuk melindungi Lapor-OB dan pengguna kami dari akses tanpa izin atau pengubahan, pengungkapan, maupun penghancuran informasi yang kami pegang secara tidak sah.',
                                  style: _PrivacyTextStyles.body,
                                ),
                                SizedBox(height: 14),
                                _SecurityBanner(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _PrivacySection(
                            icon: Icons.help_outline_rounded,
                            title: '4. Hak Anda',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Anda dapat meminta akses, koreksi, atau penghapusan data pribadi Anda kapan saja dengan menghubungi',
                                  style: _PrivacyTextStyles.body,
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 51,
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.mail_outline_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Hubungi Tim Privasi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  height: 51,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.download_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Unduh Salinan Data'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _primaryBlue,
                                      side: const BorderSide(
                                        color: _primaryBlue,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          _HelpCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'assets/images/logo_wgs.png',
            width: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          const Text(
            'Lapor OB',
            style: TextStyle(
              color: Color(0xFF003366),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E6EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Poin Penting:',
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 18),
          _ImportantItem(
            icon: Icons.shield_rounded,
            iconColor: _green,
            text: 'Data Anda dienkripsi dengan standar industri.',
          ),
          _ImportantItem(
            icon: Icons.visibility_off_outlined,
            iconColor: _primaryBlue,
            text:
                'Kami tidak pernah menjual data pribadi Anda kepada pihak ketiga.',
          ),
          _ImportantItem(
            icon: Icons.info_outline_rounded,
            iconColor: _orange,
            text: 'Anda memiliki kendali penuh atas informasi profil Anda.',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 38, 24, 29),
      color: const Color(0xFFE9EDFF),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_wgs.png',
                width: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              const Text(
                'Lapor OB',
                style: TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '© 2026 Lapor-OB. Hak Cipta Dilindungi Undang-Undang.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kebijakan Privasi',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.TERMS),
                child: const Text(
                  'Syarat & Ketentuan',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImportantItem extends StatelessWidget {
  const _ImportantItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: PrivacyView._navy,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: PrivacyView._softBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: PrivacyView._primaryBlue, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: PrivacyView._navy,
                  fontSize: 26,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _BoldParagraph extends StatelessWidget {
  const _BoldParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF374151),
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QuoteBox extends StatelessWidget {
  const _QuoteBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE0E4F4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: PrivacyView._navy,
          fontSize: 16,
          height: 1.35,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 222,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6F7FF), Color(0xFFBEDFFF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SecurityPainter())),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 20,
              top: 42,
              child: Text(
                'KEBIJAKAN PRIVASI\nDATA TERLINDUNG\nSECARA DIGITAL',
                style: TextStyle(
                  color: PrivacyView._primaryBlue,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Center(
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PrivacyView._primaryBlue.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: PrivacyView._primaryBlue,
                  size: 42,
                ),
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 18,
              child: Text(
                'KEAMANAN\nTINGKAT LANJUT',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: PrivacyView._primaryBlue,
                  fontSize: 9,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = PrivacyView._primaryBlue.withValues(alpha: 0.26)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.08 + i * 0.16);
      canvas.drawLine(Offset(x, 0), Offset(x + 64, size.height), linePaint);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.46,
        size.height * 0.85,
        size.width,
        size.height * 0.38,
      );
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, 28, 72, 144),
        const Radius.circular(15),
      ),
      glassPaint,
    );

    for (final point in [
      Offset(size.width * 0.26, size.height * 0.58),
      Offset(size.width * 0.42, size.height * 0.43),
      Offset(size.width * 0.72, size.height * 0.62),
      Offset(size.width * 0.87, size.height * 0.38),
    ]) {
      canvas.drawCircle(point, 8, glassPaint);
      canvas.drawCircle(point, 4, linePaint..style = PaintingStyle.fill);
      linePaint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 19, 19, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4CBEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Punya Pertanyaan Lain?',
            style: TextStyle(
              color: PrivacyView._navy,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Silakan baca Syarat & Ketentuan kami atau hubungi pusat bantuan untuk klarifikasi lebih lanjut.',
            style: TextStyle(
              color: PrivacyView._bodyText,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Buka Pusat Bantuan',
              style: TextStyle(
                color: PrivacyView._primaryBlue,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: PrivacyView._primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyTextStyles {
  static const body = TextStyle(
    color: PrivacyView._bodyText,
    fontSize: 16,
    height: 1.55,
    fontWeight: FontWeight.w500,
  );
}
