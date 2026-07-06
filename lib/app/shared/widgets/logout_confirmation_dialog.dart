import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  static const _danger = Color(0xFFC91C20);
  static const _dangerSoft = Color(0xFFF8E8EA);
  static const _textPrimary = Color(0xFF20242A);
  static const _textSecondary = Color(0xFF505565);
  static const _outline = Color(0xFF7B8190);

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Batal',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: LogoutConfirmationDialogContent(onConfirm: onConfirm),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LogoutConfirmationDialogContent();
  }
}

class LogoutConfirmationDialogContent extends StatelessWidget {
  const LogoutConfirmationDialogContent({
    super.key,
    this.onConfirm,
  });

  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 46),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD8DCE3), width: 1.4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 98,
                height: 98,
                decoration: const BoxDecoration(
                  color: LogoutConfirmationDialog._dangerSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: LogoutConfirmationDialog._danger,
                  size: 46,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Konfirmasi Keluar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LogoutConfirmationDialog._textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Apakah Anda yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LogoutConfirmationDialog._textSecondary,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 52),
              _DialogButton(
                text: 'Ya, Keluar',
                backgroundColor: LogoutConfirmationDialog._danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              ),
              const SizedBox(height: 24),
              _DialogButton(
                text: 'Batal',
                backgroundColor: Colors.white,
                foregroundColor: LogoutConfirmationDialog._textPrimary,
                borderColor: LogoutConfirmationDialog._outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 86,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: borderColor ?? backgroundColor,
              width: 1.6,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
