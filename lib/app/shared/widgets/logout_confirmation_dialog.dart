import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD8DCE3);
    final titleColor = isDark ? Colors.white : LogoutConfirmationDialog._textPrimary;
    final messageColor =
        isDark ? Colors.white70 : LogoutConfirmationDialog._textSecondary;
    final cancelBackground =
        isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final cancelBorder =
        isDark ? AppDarkColors.border : LogoutConfirmationDialog._outline;
    final cancelText =
        isDark ? Colors.white : LogoutConfirmationDialog._textPrimary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? LogoutConfirmationDialog._danger.withValues(alpha: 0.16)
                      : LogoutConfirmationDialog._dangerSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: LogoutConfirmationDialog._danger,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Keluar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Apakah Anda yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: messageColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 28),
              _DialogButton(
                text: 'Ya, Keluar',
                backgroundColor: LogoutConfirmationDialog._danger,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              ),
              const SizedBox(height: 12),
              _DialogButton(
                text: 'Batal',
                backgroundColor: cancelBackground,
                foregroundColor: cancelText,
                borderColor: cancelBorder,
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
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor ?? backgroundColor,
              width: 1.3,
            ),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}
