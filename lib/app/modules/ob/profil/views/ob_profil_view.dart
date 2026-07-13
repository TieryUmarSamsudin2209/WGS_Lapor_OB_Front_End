import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/theme/theme_controller.dart';
import '../../../../shared/translations/app_translations.dart';
import '../../../../shared/widgets/edit_profile_dialog.dart';
import '../../../../shared/widgets/logout_confirmation_dialog.dart';
import '../../../../shared/widgets/ob_bottom_nav.dart';
import '../controllers/ob_profil_controller.dart';

class ObProfilView extends GetView<ObProfilController> {
  const ObProfilView({super.key, this.isNested = false});

  final bool isNested;

  static const _blue = Color(0xFF14558B);
  static const _text = Color(0xFF172033);
  static const _pageBg = Color(0xFFF4F4F8);
  static const _panelTop = 154.0;
  static const _bottomScrollSpace = 116.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppDarkColors.background : _pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minPanelHeight =
                    constraints.maxHeight - _panelTop - _bottomScrollSpace;

                return RefreshIndicator(
                  onRefresh: controller.loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: _bottomScrollSpace),
                    child: _ProfileScrollContent(
                      controller: controller,
                      minHeight: minPanelHeight > 0 ? minPanelHeight : 0.0,
                    ),
                  ),
                );
              },
            ),
          ),
          if (!isNested)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ObBottomNav(activeItem: ObBottomNavItem.profile),
            ),
        ],
      ),
    );
  }
}

class _ProfileScrollContent extends StatelessWidget {
  const _ProfileScrollContent({
    required this.controller,
    required this.minHeight,
  });

  final ObProfilController controller;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 238,
          child: Container(
            color: isDark ? AppDarkColors.header : ObProfilView._blue,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Text(
                'Profil Saya'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: ObProfilView._panelTop),
          child: _ProfilePanel(controller: controller, minHeight: minHeight),
        ),
      ],
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.controller, required this.minHeight});

  final ObProfilController controller;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.background : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 56, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProfileSummaryCard(controller: controller),
                const SizedBox(height: 24),
                _HistorySection(controller: controller),
                const SizedBox(height: 24),
                _SettingsSection(controller: controller),
              ],
            ),
          ),
          Positioned(top: -48, child: _Avatar(controller: controller)),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.controller});

  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 6),
        Obx(
          () => Text(
            _firstName(controller.name.value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : ObProfilView._text,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Obx(
          () => Text(
            '${'Staff OB'.tr} | ${controller.username.value}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF8A94A4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => EditProfileDialog.show(
              context,
              avatarUrl: controller.avatarUrl.value,
              firstName: controller.firstName,
              lastName: controller.lastName,
              onSave: controller.updateProfile,
            ),
            icon: const Icon(Icons.edit_rounded, size: 17),
            label: Text('Edit Profil'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: ObProfilView._blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: controller.completedTaskTotal.value.toString(),
                  label: 'Total Tugas\nSelesai',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: controller.handledReportTotal.toString(),
                  label: 'Komplain\nDitangani',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: controller.averageResponseLabel,
                  label: 'Rata-rata\nRespon',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller});

  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Obx(() {
              final url = controller.avatarUrl.value.trim();
              if (url.isEmpty) {
                return const _AvatarFallback();
              }
              if (url.startsWith('http')) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _AvatarFallback(),
                );
              }
              return Image.file(
                File(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _AvatarFallback(),
              );
            }),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 6,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: ObProfilView._blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5EAF1),
      child: const Icon(
        Icons.person_rounded,
        size: 48,
        color: Color(0xFF8A94A4),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE1E8F0),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0071B9),
              fontSize: 17,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.tr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5D6878),
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.controller});

  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Riwayat Laporan'.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : ObProfilView._text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: controller.goToReportHistory,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Semua'.tr,
                style: const TextStyle(
                  color: ObProfilView._blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoading.value) {
            return const _LoadingBox();
          }

          final reports = controller.recentReports;
          if (reports.isEmpty) {
            return const _EmptyBox(message: 'Belum ada riwayat laporan');
          }

          return Column(
            children: reports
                .map(
                  (report) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProfileReportCard(
                      report: report,
                      onTap: () => controller.openReport(report),
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.controller});

  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : ObProfilView._text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan & Akun'.tr,
          style: TextStyle(
            color: titleColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          children: [
            _SettingsTile(
              icon: Icons.description_outlined,
              label: 'Syarat & Ketentuan'.tr,
              onTap: () => Get.toNamed(Routes.TERMS),
            ),
            const Divider(height: 1),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Kebijakan Privasi'.tr,
              onTap: () => Get.toNamed(Routes.PRIVACY),
            ),
            const Divider(height: 1),
            Obx(() => _SettingsTile(
                  icon: Icons.translate_rounded,
                  label: 'Bahasa'.tr,
                  trailingText: controller.selectedLanguage.value,
                  onTap: () => _showLanguageBottomSheet(context, controller.selectedLanguage),
                )),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => LogoutConfirmationDialog.show(
              context,
              onConfirm: controller.logout,
            ),
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: Text('Keluar Sesi'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: const BorderSide(color: Color(0xFFE1E8F0)),
              backgroundColor: isDark ? AppDarkColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE1E8F0),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      trailingText!,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF718096),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileReportCard extends StatelessWidget {
  const _ProfileReportCard({required this.report, required this.onTap});

  final ReportModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD1D9E5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    color: ObProfilView._blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ReportPill(style: _priorityStyle(report.priority)),
                            const Spacer(),
                            _ReportPill(style: _statusStyle(report.status)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          report.title.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF064BFF),
                              size: 15,
                            ),
                            Expanded(
                              child: Text(
                                report.location.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF064BFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF465160),
                            fontSize: 11,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 112,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE1E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            color: isDark ? Colors.white60 : const Color(0xFF8A94A4),
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            message.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillStyle {
  const _PillStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

class _ReportPill extends StatelessWidget {
  const _ReportPill({required this.style});

  final _PillStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 10, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label.tr,
            style: TextStyle(
              color: style.foreground,
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

_PillStyle _priorityStyle(String priority) {
  if (priority == 'URGENT') {
    return const _PillStyle(
      label: 'URGENT',
      icon: Icons.error_outline,
      background: Color(0xFFFFE2E5),
      foreground: Color(0xFFC72535),
    );
  }

  return const _PillStyle(
    label: 'STANDARD',
    icon: Icons.error_outline,
    background: Color(0xFFFFF2C8),
    foreground: Color(0xFFFFA000),
  );
}

_PillStyle _statusStyle(ReportStatus status) {
  switch (status) {
    case ReportStatus.resolved:
      return const _PillStyle(
        label: 'Selesai',
        icon: Icons.check_circle_outline,
        background: Color(0xFFDDF8E9),
        foreground: Color(0xFF2BAE66),
      );
    case ReportStatus.rejected:
      return const _PillStyle(
        label: 'Ditolak',
        icon: Icons.cancel_outlined,
        background: Color(0xFFFFE2E5),
        foreground: Color(0xFFC72535),
      );
    case ReportStatus.inProgress:
      return const _PillStyle(
        label: 'Proses',
        icon: Icons.sync_rounded,
        background: Color(0xFFE3F0FF),
        foreground: Color(0xFF1976D2),
      );
    case ReportStatus.pending:
      return const _PillStyle(
        label: 'Pending',
        icon: Icons.schedule_outlined,
        background: Color(0xFFFFF2C8),
        foreground: Color(0xFFFFA000),
      );
  }
}

String _firstName(String value) {
  final text = value.trim();
  if (text.isEmpty) return 'OB';
  return text.split(RegExp(r'\s+')).first;
}

void _showLanguageBottomSheet(BuildContext context, RxString selectedLanguage) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final titleColor = isDark ? Colors.white : const Color(0xFF172033);
  final subtitleColor = isDark ? Colors.white70 : const Color(0xFF6F7785);
  final sheetBg = isDark ? AppDarkColors.surface : Colors.white;

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'language_sheet_title'.tr,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'language_sheet_subtitle'.tr,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Column(
              children: AppTranslations.languages.map((language) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildLanguageOption(
                    context: context,
                    label: language.nativeLabel,
                    value: language.nativeLabel,
                    isSelected: selectedLanguage.value == language.nativeLabel,
                    onTap: () async {
                      selectedLanguage.value = language.nativeLabel;
                      await AppTranslations.updateLocale(language);
                      Get.back();
                      Get.snackbar(
                        'language_changed_title'.tr,
                        'language_changed_message'.trParams({
                          'language': language.nativeLabel,
                        }),
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 2),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildLanguageOption({
  required BuildContext context,
  required String label,
  required String value,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final cardColor = isDark ? AppDarkColors.background : const Color(0xFFF7FAFC);
  final activeColor = const Color(0xFF0F4C81);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppDarkColors.border : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? activeColor
                      : (isDark ? Colors.white : const Color(0xFF2D3748)),
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: activeColor,
                size: 20,
              ),
          ],
        ),
      ),
    ),
  );
}
