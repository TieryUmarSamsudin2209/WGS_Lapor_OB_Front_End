import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/widgets/contact_admin_dialog.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  static const _navy = Color(0xFF111827);
  static const _primaryBlue = Color(0xFF0077B6);
  static const _softBlue = Color(0xFFD8ECFF);
  static const _pageBg = Color(0xFFF7F9FC);
  static const _bodyText = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
    final canNavigateBack = Navigator.of(context).canPop();

    return PopScope(
      canPop: canNavigateBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _openPreviousRoute();
        }
      },
      child: Scaffold(
        backgroundColor: _pageBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 30, 22, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _TrText(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: _navy,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _TrText(
                              text: 'Terakhir diperbarui: 7 Juli 2026',
                              style: TextStyle(
                                color: _bodyText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 17),
                            Container(
                              width: 58,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(0xFF23A7FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            _SectionCard(
                              icon: Icons.gavel_rounded,
                              title: '1. Pendahuluan',
                              child: const _TrText(
                                text:
                                    'Selamat datang di Lapor-OB. Dengan mengakses dan menggunakan platform kami, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Layanan ini disediakan untuk memfasilitasi pelaporan dan manajemen fasilitas gedung.\n\nJika Anda tidak menyetujui bagian mana pun dari ketentuan ini, Anda disarankan untuk berhenti menggunakan layanan kami segera.',
                                style: _TermsTextStyles.body,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _SectionCard(
                              icon: Icons.person_outline_rounded,
                              title: '2. Akun Pengguna',
                              child: Column(
                                children: const [
                                  _CheckItem(
                                    text:
                                        'Anda bertanggung jawab menjaga kerahasiaan kata sandi akun Anda.',
                                  ),
                                  _CheckItem(
                                    text:
                                        'Informasi yang diberikan saat pendaftaran harus akurat dan valid.',
                                  ),
                                  _CheckItem(
                                    text:
                                        'Satu akun hanya boleh digunakan oleh satu individu yang berwenang.',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            _ServiceBanner(),
                            const SizedBox(height: 15),
                            _SectionCard(
                              icon: Icons.report_problem_outlined,
                              title: '3. Penggunaan Layanan',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: const [
                                  _TrText(
                                    text:
                                        'Lapor-OB digunakan untuk melaporkan kebutuhan kebersihan atau perbaikan di area kerja. Pengguna dilarang:',
                                    style: _TermsTextStyles.body,
                                  ),
                                  SizedBox(height: 14),
                                  _RuleBox(
                                    text:
                                        'Mengirim laporan palsu atau menyesatkan.',
                                  ),
                                  _RuleBox(
                                    text:
                                        'Menggunakan bahasa yang kasar atau tidak pantas dalam deskripsi.',
                                  ),
                                  _RuleBox(
                                    text:
                                        'Melakukan spamming sistem dengan permintaan berulang tanpa alasan.',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            _SectionCard(
                              icon: Icons.shield_outlined,
                              title: '4. Privasi & Data',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _TrText(
                                    text:
                                        'Pengumpulan dan penggunaan data pribadi Anda diatur oleh Kebijakan Privasi kami. Dengan menyetujui Syarat & Ketentuan ini, Anda juga dianggap telah memahami Kebijakan Privasi.',
                                    style: _TermsTextStyles.body,
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => Get.toNamed(Routes.PRIVACY),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        _TrText(
                                          text: 'Lihat Kebijakan Privasi',
                                          style: TextStyle(
                                            color: _primaryBlue,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.open_in_new_rounded,
                                          color: _primaryBlue,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            _SectionCard(
                              icon: Icons.update_rounded,
                              title: '5. Perubahan Ketentuan',
                              child: const _TrText(
                                text:
                                    'Kami berhak memperbarui Syarat & Ketentuan ini sewaktu-waktu. Perubahan akan segera efektif setelah dipublikasikan di halaman ini. Penggunaan berkelanjutan atas layanan setelah perubahan menandakan persetujuan Anda.',
                                style: _TermsTextStyles.body,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _ContactCard(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    _openPreviousRoute();
  }

  void _openPreviousRoute() {
    final previousRoute = Get.previousRoute;
    if (previousRoute.isNotEmpty && previousRoute != Routes.TERMS) {
      Get.offNamed(previousRoute);
      return;
    }

    Get.offNamed(Routes.LOGIN);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
              onTap: () => _goBack(context),
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
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/logo_wgs.png',
            width: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          const _TrText(
            text: 'Lapor OB',
            style: TextStyle(
              color: Color(0xFF003366),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const Icon(Icons.info_outline_rounded, color: Color(0xFF4B5563)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 28),
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
              const _TrText(
                text: 'Lapor OB',
                style: TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _TrText(
            text: '© 2026 Lapor-OB. Hak Cipta Dilindungi Undang-Undang.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.toNamed(Routes.PRIVACY),
                child: const _TrText(
                  text: 'Kebijakan Privasi',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const _TrText(
                text: 'Syarat & Ketentuan',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE4E9F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 38,
                decoration: BoxDecoration(
                  color: TermsView._softBlue,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: TermsView._primaryBlue, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title.tr,
                  style: const TextStyle(
                    color: TermsView._navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF22C55E),
            size: 16,
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(text.tr, style: _TermsTextStyles.body)),
        ],
      ),
    );
  }
}

class _RuleBox extends StatelessWidget {
  const _RuleBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E5F5)),
      ),
      child: Text(
        text.tr,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          height: 1.35,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ServiceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 145,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB9C6D7), Color(0xFF243142)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _OfficeLinePainter())),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 16,
              bottom: 17,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrText(
                    text: 'Standar Pelayanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  _TrText(
                    text: 'Komitmen Kebersihan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficeLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.2;
    final floorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final x = size.width * (0.28 + i * 0.12);
      canvas.drawLine(Offset(x, 0), Offset(x - 24, size.height), wallPaint);
    }

    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.25 + i * 0.18);
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), floorPaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.63, 18, size.width * 0.22, 82),
      glassPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.29, size.height * 0.57),
      6,
      Paint()..color = const Color(0xFF5DAA74).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF91D5FF)),
      ),
      child: Column(
        children: [
          const _TrText(
            text: 'Punya Pertanyaan?',
            style: TextStyle(
              color: TermsView._primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const _TrText(
            text: 'Tim admin kami siap membantu Anda memahami ketentuan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: () => ContactAdminDialog.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: TermsView._primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Text(
                'Hubungi Admin'.tr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrText extends StatelessWidget {
  const _TrText({required this.text, required this.style, this.textAlign});

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(text.tr, textAlign: textAlign, style: style);
  }
}

class _TermsTextStyles {
  static const body = TextStyle(
    color: TermsView._bodyText,
    fontSize: 13.5,
    height: 1.55,
    fontWeight: FontWeight.w500,
  );
}
