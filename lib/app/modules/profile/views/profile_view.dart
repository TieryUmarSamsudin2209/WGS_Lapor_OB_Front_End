import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../shared/theme/theme_controller.dart';
import '../../../shared/translations/app_translations.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/edit_profile_dialog.dart';
import '../../../shared/widgets/logout_confirmation_dialog.dart';
import '../controllers/profile_controllers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.isNested = false});

  final bool isNested;

  static const _blue = Color(0xFF14558B);
  static const _text = Color(0xFF172033);
  static const _pageBg = Color(0xFFF4F4F8);
  static const _panelTop = 142.0;
  static const _bottomSpace = 116.0;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController controller;
  final TextEditingController _searchController = TextEditingController();
  bool _showAllHistory = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_showAllHistory,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showAllHistory) {
          _closeHistory();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppDarkColors.background : ProfilePage._pageBg,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _showAllHistory
                    ? _AllHistoryView(
                        key: const ValueKey('history'),
                        controller: controller,
                        searchController: _searchController,
                        onBack: _closeHistory,
                      )
                    : _ProfileDashboard(
                        key: const ValueKey('profile'),
                        controller: controller,
                        onEditProfile: _showEditProfileDialog,
                        onOpenHistory: _openHistory,
                      ),
              ),
            ),
            if (!widget.isNested)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ProfileBottomNav(),
              ),
          ],
        ),
      ),
    );
  }

  void _openHistory() {
    _searchController.clear();
    controller.onSearchChanged('');
    controller.setFilter('Semua');
    setState(() => _showAllHistory = true);
  }

  void _closeHistory() {
    _searchController.clear();
    controller.onSearchChanged('');
    controller.setFilter('Semua');
    setState(() => _showAllHistory = false);
  }

  void _showEditProfileDialog() {
    EditProfileDialog.show(
      context,
      avatarUrl: controller.avatarUrl.value,
      firstName: controller.firstName,
      lastName: controller.lastName,
      onSave: controller.updateProfile,
    );
  }
}

class _ProfileDashboard extends StatelessWidget {
  const _ProfileDashboard({
    super.key,
    required this.controller,
    required this.onEditProfile,
    required this.onOpenHistory,
  });

  final ProfileController controller;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minPanelHeight =
            constraints.maxHeight - ProfilePage._panelTop - ProfilePage._bottomSpace;

        return RefreshIndicator(
          onRefresh: controller.loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: ProfilePage._bottomSpace),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const _ProfileHeader(),
                Padding(
                  padding: const EdgeInsets.only(top: ProfilePage._panelTop),
                  child: _ProfilePanel(
                    controller: controller,
                    minHeight: minPanelHeight > 0 ? minPanelHeight : 0,
                    onEditProfile: onEditProfile,
                    onOpenHistory: onOpenHistory,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 238,
      color: isDark ? AppDarkColors.header : ProfilePage._blue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 34),
          child: Text(
            'Profil Saya'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
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
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.controller,
    required this.minHeight,
    required this.onEditProfile,
    required this.onOpenHistory,
  });

  final ProfileController controller;
  final double minHeight;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.background : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 58, 19, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ProfileSummary(
                  controller: controller,
                  onEditProfile: onEditProfile,
                ),
                const SizedBox(height: 14),
                _TotalReportCard(controller: controller),
                const SizedBox(height: 17),
                _HistoryPreviewSection(
                  controller: controller,
                  onOpenHistory: onOpenHistory,
                ),
                const SizedBox(height: 18),
                _SettingsSection(controller: controller),
              ],
            ),
          ),
          Positioned(
            top: -39,
            child: _Avatar(controller: controller, onTap: onEditProfile),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.controller,
    required this.onEditProfile,
  });

  final ProfileController controller;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : ProfilePage._text;
    final mutedColor = isDark ? Colors.white60 : const Color(0xFF7C8694);

    return Column(
      children: [
        Obx(
          () => Text(
            controller.name.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Obx(
          () => Text(
            '${'Karyawan'.tr} | ${controller.username.value}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 41,
          child: ElevatedButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text('Edit Profil'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfilePage._blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.controller, required this.onTap});

  final ProfileController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: Obx(() => _AvatarImage(url: controller.avatarUrl.value)),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 5,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: ProfilePage._blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final value = url.trim();
    if (value.isEmpty) return const _AvatarFallback();

    if (value.startsWith('http')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarFallback(),
      );
    }

    return Image.file(
      File(value),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _AvatarFallback(),
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
        size: 38,
        color: Color(0xFF8A94A4),
      ),
    );
  }
}

class _TotalReportCard extends StatelessWidget {
  const _TotalReportCard({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : const Color(0xFFFBFCFE);
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFE0E7F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 9),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Laporan'.tr,
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF7A8492),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Obx(
            () => Row(
              children: [
                Text(
                  controller.totalReports.toString(),
                  style: const TextStyle(
                    color: Color(0xFF0071B9),
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF21B36A),
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryPreviewSection extends StatelessWidget {
  const _HistoryPreviewSection({
    required this.controller,
    required this.onOpenHistory,
  });

  final ProfileController controller;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Riwayat Laporan Saya'.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : ProfilePage._text,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenHistory,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Semua'.tr,
                style: const TextStyle(
                  color: ProfilePage._blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Obx(() {
          if (controller.isLoading.value) {
            return const _StateBox(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            );
          }

          final reports = controller.recentReports;
          if (reports.isEmpty) {
            return _StateBox(
              child: Text(
                'Belum ada riwayat laporan'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            );
          }

          return Column(
            children: [
              for (var i = 0; i < reports.length; i++) ...[
                _ReportCard(
                  report: reports[i],
                  onTap: () => controller.openReport(reports[i]),
                ),
                if (i != reports.length - 1) const SizedBox(height: 9),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan & Akun'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : ProfilePage._text,
            fontSize: 15,
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
          height: 46,
          child: OutlinedButton.icon(
            onPressed: () => LogoutConfirmationDialog.show(
              context,
              onConfirm: controller.logout,
            ),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: Text('Keluar Sesi'.tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE53935),
              side: BorderSide(
                color: isDark ? AppDarkColors.border : const Color(0xFFE1E8F0),
              ),
              backgroundColor: isDark ? AppDarkColors.surface : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
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
              color: Colors.black.withValues(alpha: 0.035),
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
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                      fontSize: 12,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllHistoryView extends StatelessWidget {
  const _AllHistoryView({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onBack,
  });

  final ProfileController controller;
  final TextEditingController searchController;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.loadProfile,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _HistoryHeader(onBack: onBack),
            ),
            SliverToBoxAdapter(
              child: _SearchAndFilters(
                controller: controller,
                searchController: searchController,
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final reports = controller.filteredReports;
              if (reports.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 118),
                    child: Center(
                      child: Text(
                        'Tidak ada laporan yang cocok',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF718096),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 118),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final report = reports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ReportCard(
                          report: report,
                          onTap: () => controller.openReport(report),
                        ),
                      );
                    },
                    childCount: reports.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 18, 11),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : ProfilePage._blue,
              size: 22,
            ),
            tooltip: 'Kembali'.tr,
          ),
          Expanded(
            child: Text(
              'Semua Riwayat Laporan'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : ProfilePage._blue,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.searchController,
  });

  final ProfileController controller;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldColor = isDark ? AppDarkColors.surfaceVariant : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFDDE5EF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
      child: Column(
        children: [
          Container(
            height: 43,
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: searchController,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: 'Cari laporan atau lokasi...'.tr,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF9AA4B2),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF718096),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: Obx(
              () {
                final selectedFilter = controller.selectedFilter.value;
                
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    const filters = [
                      'Semua',
                      'Proses',
                      'Selesai',
                      'Tertolak',
                      'Pending',
                    ];
                    final filter = filters[index];
                    return _FilterChip(
                      label: filter,
                      active: selectedFilter == filter,
                      onTap: () => controller.setFilter(filter),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemCount: 5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = active
        ? ProfilePage._blue
        : isDark
            ? AppDarkColors.surfaceVariant
            : Colors.white;
    final fg = active
        ? Colors.white
        : isDark
            ? Colors.white70
            : const Color(0xFF5C6675);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 17),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? ProfilePage._blue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label.tr,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  final Map<String, dynamic> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFD1D9E5);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF465160);
    final priority = report['priority']?.toString() ?? 'STANDARD';
    final status = report['status']?.toString() ?? 'Pending';
    final title = report['title']?.toString() ?? 'Laporan';
    final location = report['location']?.toString() ?? '-';
    final description = report['description']?.toString() ?? '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 101),
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
                  width: 4,
                  decoration: const BoxDecoration(
                    color: ProfilePage._blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 11, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ReportPill(style: _priorityStyle(priority)),
                            const Spacer(),
                            _ReportPill(style: _statusStyle(status)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          title.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            height: 1.04,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF064BFF),
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                location.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF064BFF),
                                  fontSize: 10,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: bodyColor,
                            fontSize: 10,
                            height: 1.24,
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

class _StateBox extends StatelessWidget {
  const _StateBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 104,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE1E8F0),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
        ),
        child: child,
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
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 10, color: style.foreground),
          const SizedBox(width: 3),
          Text(
            style.label.tr,
            style: TextStyle(
              color: style.foreground,
              fontSize: 9,
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
  final normalized = priority.trim().toUpperCase();
  if (normalized.contains('URGENT') ||
      normalized.contains('HIGH') ||
      normalized.contains('TINGGI')) {
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

_PillStyle _statusStyle(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized.contains('selesai') ||
      normalized.contains('resolved') ||
      normalized.contains('done')) {
    return const _PillStyle(
      label: 'Selesai',
      icon: Icons.check_circle_outline,
      background: Color(0xFFDDF8E9),
      foreground: Color(0xFF2BAE66),
    );
  }
  if (normalized.contains('tolak') || normalized.contains('reject')) {
    return const _PillStyle(
      label: 'Ditolak',
      icon: Icons.cancel_outlined,
      background: Color(0xFFFFE2E5),
      foreground: Color(0xFFC72535),
    );
  }
  if (normalized.contains('proses') || normalized.contains('progress')) {
    return const _PillStyle(
      label: 'Proses',
      icon: Icons.sync_rounded,
      background: Color(0xFFE3F0FF),
      foreground: Color(0xFF1976D2),
    );
  }

  return const _PillStyle(
    label: 'Pending',
    icon: Icons.schedule_outlined,
    background: Color(0xFFFFF2C8),
    foreground: Color(0xFFFFA000),
  );
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav();

  static const _navyTextColor = Color(0xFF003366);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 7),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: isDark ? AppDarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppDarkColors.border : const Color(0xFFD9E7FF),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FA0FF).withValues(alpha: 0.38),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: BottomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HOME),
                navyColor: _navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.add_circle,
                label: 'Report',
                isActive: false,
                onTap: () => Get.toNamed(Routes.REPORT),
                navyColor: _navyTextColor,
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: true,
                onTap: () {},
                navyColor: _navyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
