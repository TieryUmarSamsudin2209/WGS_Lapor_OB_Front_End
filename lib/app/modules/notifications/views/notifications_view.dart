import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/theme_controller.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  static const _blue = Color(0xFF0F4C81);
  static const _pageBg = Color(0xFFF4F7FA);
  static const _text = Color(0xFF172033);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? AppDarkColors.background : _pageBg;
    final appBg = isDark ? AppDarkColors.surface : Colors.white;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: appBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : _blue,
          ),
        ),
        title: Text(
          'notifikasi'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : _blue,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadNotifications,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final grouped = controller.groupedNotifications;
                  if (grouped.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 40, 22, 24),
                      children: const [
                        _EmptyState(),
                      ],
                    );
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
                    children: grouped.entries.expand((entry) {
                      return [
                        _SectionTitle(title: entry.key == 'TERBARU' ? 'terbaru'.tr : 'sebelumnya'.tr),
                        const SizedBox(height: 10),
                        ...entry.value.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _NotificationCard(item: item),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ];
                    }).toList(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isDark = Get.isDarkMode;
    final chips = ['Semua', 'Laporan', 'Info'];
    final chipLabels = {
      'Semua': 'semua'.tr,
      'Laporan': 'laporan'.tr,
      'Info': 'info'.tr,
    };

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
      child: Obx(() {
        return Row(
          children: chips.map((chip) {
            final isSelected = controller.activeFilter.value == chip;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(
                  chipLabels[chip] ?? chip,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF4E5765)),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF0F4C81),
                backgroundColor: isDark ? AppDarkColors.surface : const Color(0xFFEDF2F7),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                onSelected: (val) {
                  if (val) {
                    controller.activeFilter.value = chip;
                  }
                },
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : const Color(0xFF4E5765),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _styleForType(item.type);
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFE0E7EF);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.type == 'received')
                Container(
                  width: 4,
                  color: const Color(0xFF1A73E8),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: style.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(style.icon, color: style.foreground, size: 23),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _translateTitle(item.title),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : NotificationsView._text,
                                      fontSize: 13,
                                      height: 1.15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.timeLabel == '2 mnt yang lalu'
                                      ? 'time_2_min_ago'.tr
                                      : item.timeLabel == '1 jam yang lalu'
                                          ? 'time_1_hr_ago'.tr
                                          : item.timeLabel == 'Kemarin'
                                              ? 'time_yesterday'.tr
                                              : item.timeLabel == '2 hari yang lalu'
                                                  ? 'time_2_days_ago'.tr
                                                  : item.timeLabel,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : NotificationsView._muted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            _buildMessage(context, _translateMessage(item.message), isDark),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: item.isUnread ? style.foreground : Colors.transparent,
                          shape: BoxShape.circle,
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
    );
  }

  String _translateTitle(String title) {
    if (title == 'Laporan Selesai') return 'laporan_selesai'.tr;
    if (title == 'Laporan Diterima') return 'laporan_diterima'.tr;
    if (title == 'Pembaruan Status') return 'pembaruan_status'.tr;
    return title.tr;
  }

  String _translateMessage(String message) {
    if (message.contains('Tumpahan air')) return 'notif_selesai_1'.tr;
    if (message.contains('AC Bocor')) return 'notif_diterima_1'.tr;
    if (message.contains('Lift B2')) return 'notif_status_1'.tr;
    if (message.contains('Kertas Habis')) return 'notif_selesai_2'.tr;
    return message.tr;
  }

  Widget _buildMessage(BuildContext context, String message, bool isDark) {
    final highlight = 'facility_status_normal'.tr;
    if (message.contains(highlight)) {
      final parts = message.split(highlight);
      return RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: TextStyle(
            color: isDark ? Colors.white70 : NotificationsView._muted,
            fontSize: 12,
            height: 1.28,
            fontWeight: FontWeight.w500,
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
          ),
          children: [
            TextSpan(text: parts[0]),
            TextSpan(
              text: highlight,
              style: const TextStyle(
                color: Color(0xFF2BC36A),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (parts.length > 1) TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(
      message,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isDark ? Colors.white70 : NotificationsView._muted,
        fontSize: 12,
        height: 1.28,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppDarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppDarkColors.border : const Color(0xFFE0E7EF),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: isDark ? Colors.white54 : const Color(0xFF8A96A8),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            'belum_ada_notifikasi'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4E5765),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationStyle {
  const _NotificationStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

_NotificationStyle _styleForType(String type) {
  if (type == 'resolved') {
    return const _NotificationStyle(
      icon: Icons.check_rounded,
      background: Color(0xFFE6F4EA),
      foreground: Color(0xFF2BC36A),
    );
  }
  if (type == 'received') {
    return const _NotificationStyle(
      icon: Icons.engineering_rounded,
      background: Color(0xFFE8F0FE),
      foreground: Color(0xFF1A73E8),
    );
  }
  if (type == 'status_update') {
    return const _NotificationStyle(
      icon: Icons.sync_rounded,
      background: Color(0xFFE8F0FE),
      foreground: Color(0xFF1A73E8),
    );
  }
  if (type == 'report') {
    return const _NotificationStyle(
      icon: Icons.warning_amber_rounded,
      background: Color(0xFFFFEAB8),
      foreground: Color(0xFFFFA21A),
    );
  }
  return const _NotificationStyle(
    icon: Icons.info_outline_rounded,
    background: Color(0xFFE8F0FE),
    foreground: Color(0xFF1A73E8),
  );
}
