import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/theme_controller.dart';

class ObCompleteReportDialog {
  static const _navy = Color(0xFF003366);
  static const _navyDark = Color(0xFF002244);
  static const _greenSoft = Color(0xFFE8F5E9);
  static const _greenIcon = Color(0xFF2E7D32);
  static const _textSecondary = Color(0xFF64748B);

  /// 1. Confirmation Dialog: "Selesaikan Laporan?"
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Batalkan'.tr,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, _, _) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: _ConfirmationContent(onConfirm: onConfirm),
          ),
        );
      },
    );
  }

  /// 2. Success Dialog: "Laporan Selesai!"
  static Future<void> showSuccess(
    BuildContext context, {
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, _, _) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: _SuccessContent(onClose: onClose),
          ),
        );
      },
    );
  }
}

class _ConfirmationContent extends StatelessWidget {
  const _ConfirmationContent({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : ObCompleteReportDialog._navy;
    final messageColor = isDark ? Colors.white70 : ObCompleteReportDialog._textSecondary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Lingkaran Hijau
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: ObCompleteReportDialog._greenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: ObCompleteReportDialog._greenIcon,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              // Judul
              Text(
                'Selesaikan Laporan?'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Konfirmasi apakah anda sudah menyelesaikan laporan anda.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: messageColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 26),
              // Tombol Primary: "Ya, Selesai"
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ObCompleteReportDialog._navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Ya, Selesai'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol Secondary: "Batalkan"
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObCompleteReportDialog._navy,
                    side: const BorderSide(
                      color: ObCompleteReportDialog._navy,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Batalkan'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppDarkColors.surface : Colors.white;
    final titleColor = isDark ? Colors.white : ObCompleteReportDialog._navy;
    final messageColor = isDark ? Colors.white70 : ObCompleteReportDialog._textSecondary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Close "X" di Pojok Kanan Atas
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: ObCompleteReportDialog._navy,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 10),
              // Icon Lingkaran Hijau
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: ObCompleteReportDialog._greenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: ObCompleteReportDialog._greenIcon,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              // Judul
              Text(
                'Laporan Selesai!'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              Text(
                'Kerja bagus! Laporan telah terselesaikan.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: messageColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
