import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAdminDialog extends StatelessWidget {
  const ContactAdminDialog({super.key});

  static const email = 'support@laporob.com';
  static const whatsappDisplay = '+62 812-3456-7890';
  static const _whatsappNumber = '6281234567890';
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF4B5563);
  static const _emailBlue = Color(0xFF0B74B6);
  static const _whatsappGreen = Color(0xFF24C765);

  static Future<void> show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup'.tr,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: const ContactAdminDialog(),
          ),
        );
      },
    );
  }

  static Future<void> _openEmail(BuildContext context) {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const {'subject': 'Bantuan Lapor OB'},
    );

    return _launch(context, uri, 'Tidak dapat membuka aplikasi email.');
  }

  static Future<void> _openWhatsApp(BuildContext context) {
    final uri = Uri.https('wa.me', '/$_whatsappNumber', {
      'text': 'Halo Admin Lapor OB, saya membutuhkan bantuan.',
    });

    return _launch(context, uri, 'Tidak dapat membuka WhatsApp.');
  }

  static Future<void> _launch(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) return;
    } catch (_) {
      // Fall through to the same user-facing error state.
    }

    messenger?.showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE4E8F0)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hubungi Admin'.tr,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Punya pertanyaan atau kendala? Tim kami siap membantu.'.tr,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _ContactOptionCard(
                  icon: Icons.mail_outline_rounded,
                  iconColor: _emailBlue,
                  iconBackground: Color(0xFFD6ECFF),
                  title: 'Email',
                  value: email,
                  buttonText: 'Kirim Email',
                  buttonIcon: Icons.send_rounded,
                  buttonColor: _emailBlue,
                  onPressed: () => _openEmail(context),
                ),
                const SizedBox(height: 16),
                _ContactOptionCard(
                  icon: Icons.chat_outlined,
                  iconColor: _whatsappGreen,
                  iconBackground: Color(0xFFD4F8E4),
                  title: 'WhatsApp',
                  value: whatsappDisplay,
                  buttonText: 'Chat WhatsApp',
                  buttonIcon: Icons.chat_bubble_outline_rounded,
                  buttonColor: _whatsappGreen,
                  onPressed: () => _openWhatsApp(context),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _emailBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: Text('Tutup'.tr),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactOptionCard extends StatelessWidget {
  const _ContactOptionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.value,
    required this.buttonText,
    required this.buttonIcon,
    required this.buttonColor,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String value;
  final String buttonText;
  final IconData buttonIcon;
  final Color buttonColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E4F1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: const TextStyle(
                        color: ContactAdminDialog._textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: ContactAdminDialog._textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(buttonIcon, size: 16),
              label: Text(buttonText.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
