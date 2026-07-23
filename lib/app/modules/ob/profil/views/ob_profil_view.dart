import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../../../shared/theme/theme_controller.dart';
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
            color: isDark ? AppDarkColors.header : const Color(0xFF0F4C81),
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
            controller.name.value,
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
            '${'OB'.tr} | ${controller.username.value}',
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
          height: 48,
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
              backgroundColor: isDark ? AppDarkColors.header : const Color(0xFF0F4C81),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 24),
        _ActiveLocationSection(controller: controller),
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
              color: const Color(0xFF0F4C81),
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

class _ActiveLocationSection extends StatelessWidget {
  const _ActiveLocationSection({required this.controller});

  final ObProfilController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFCFD5E3),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            color: isDark ? AppDarkColors.header : const Color(0xFF0F4C81),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lokasi Aktif Terkini'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(() {
                  if (controller.isEditingLocation.value) {
                    return GestureDetector(
                      onTap: controller.isSavingLocation.value
                          ? null
                          : controller.saveActiveLocations,
                      child: controller.isSavingLocation.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Simpan Perubahan'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }
                  return GestureDetector(
                    onTap: controller.toggleEditLocation,
                    child: Text(
                      'Edit Lokasi'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Body List
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Obx(() {
              if (controller.activeLocations.isEmpty) {
                return _EmptyLocationBox();
              }

              final list = controller.activeLocations.toList();
              final isEdit = controller.isEditingLocation.value;
              final displayedLocations = isEdit ? list : list.where((loc) => loc.isActive.value).toList();

              if (displayedLocations.isEmpty) {
                return _EmptyLocationBox();
              }

              return Column(
                children: [
                  for (var i = 0; i < displayedLocations.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == displayedLocations.length - 1 ? 0 : 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppDarkColors.surfaceVariant : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppDarkColors.border : const Color(0xFFCFD5E3),
                            width: 1.5,
                          ),
                        ),
                        child: _LocationTile(
                          location: displayedLocations[i],
                          isEditMode: isEdit,
                          onToggle: () => controller.toggleLocation(displayedLocations[i]),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptyLocationBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(
              Icons.location_off_outlined,
              color: isDark ? Colors.white60 : const Color(0xFF8A94A4),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada lokasi aktif'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.isEditMode,
    required this.onToggle,
  });

  final ActiveLocation location;
  final bool isEditMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isEditMode) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: Color(0xFF0F4C81),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    location.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF4A5568),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => Checkbox(
                      value: location.isActive.value,
                      onChanged: (_) => onToggle(),
                      activeColor: const Color(0xFF0F4C81),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C81).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFF0F4C81),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF4A5568),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2BAE66).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Aktif'.tr,
              style: const TextStyle(
                color: Color(0xFF2BAE66),
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
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
            _SettingsTile(
              icon: Icons.mail_outline_rounded,
              label: 'Kontak'.tr,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    final isDark = Theme.of(ctx).brightness == Brightness.dark;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Hubungi Kami'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jika Anda memiliki pertanyaan atau kendala, silakan hubungi kami melalui:'.tr,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Icon(Icons.email, color: Color(0xFF0F4C81), size: 20),
                              SizedBox(width: 8),
                              Text('support@wgs.com', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.phone, color: Color(0xFF0F4C81), size: 20),
                              SizedBox(width: 8),
                              Text('+62 21-1234-5678', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Tutup'.tr, style: const TextStyle(color: Color(0xFF0F4C81))),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(height: 1),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => LogoutConfirmationDialog.show(
              context,
              onConfirm: controller.logout,
            ),
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: Text('Keluar Sesi'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
              backgroundColor: isDark ? AppDarkColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFCFD5E3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ReportPill(style: _priorityStyle(report.priority)),
                    _ReportPill(style: _statusStyle(report.status)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  report.title.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF172033),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF0F4C81),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.location.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F4C81),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  report.description.tr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF7A8B9B),
                    fontSize: 12,
                    height: 1.3,
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


