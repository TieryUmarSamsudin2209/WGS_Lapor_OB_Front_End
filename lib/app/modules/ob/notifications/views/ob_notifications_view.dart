import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/theme/theme_controller.dart';
import '../controllers/ob_notifications_controller.dart';

class ObNotificationsView extends GetView<ObNotificationsController> {
  const ObNotificationsView({super.key});

  static const _blue = Color(0xFF0F5B93);
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
                  _SectionTitle(
                    title: _translatedSection(entry.key),
                  ),
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

  final ObNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = _styleForType(item.type);
    final cardColor = isDark ? AppDarkColors.surface : Colors.white;
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFE0E7EF);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                        item.title.trParams(
                          _translatedParams(item.titleParams),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : ObNotificationsView._text,
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _translatedTimeLabel(item.timeLabel),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : ObNotificationsView._muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message.trParams(
                    _translatedParams(item.messageParams),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : ObNotificationsView._muted,
                    fontSize: 12,
                    height: 1.28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
  if (type == 'report') {
    return const _NotificationStyle(
      icon: Icons.warning_amber_rounded,
      background: Color(0xFFFFEAB8),
      foreground: Color(0xFFFFA21A),
    );
  }
  if (type == 'system') {
    return const _NotificationStyle(
      icon: Icons.info_rounded,
      background: Color(0xFFD5F7E3),
      foreground: Color(0xFF2BC36A),
    );
  }
  return const _NotificationStyle(
    icon: Icons.assignment_rounded,
    background: Color(0xFFD8F0FF),
    foreground: Color(0xFF1689D8),
  );
}

String _translatedSection(String section) {
  switch (section) {
    case 'HARI INI':
      return 'Hari Ini'.tr;
    case 'KEMARIN':
      return 'Kemarin'.tr;
    case 'TERBARU':
      return 'terbaru'.tr;
    case 'SEBELUMNYA':
      return 'sebelumnya'.tr;
    default:
      return section.tr;
  }
}

Map<String, String> _translatedParams(Map<String, String> params) {
  return params.map((key, value) => MapEntry(key, _translatedParamValue(value)));
}

String _translatedParamValue(String value) {
  final text = value.trim();
  final employeeMatch = RegExp(r'^Karyawan\s*(\(.*\))$').firstMatch(text);
  if (employeeMatch != null) {
    return '${'Karyawan'.tr} ${employeeMatch.group(1)}';
  }
  return text.tr;
}

String _translatedTimeLabel(String label) {
  final value = label.trim();
  if (value == 'Baru') return 'Baru'.tr;
  if (value == 'Kemarin') return 'Kemarin'.tr;

  final parts = value.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final count = parts.first;
    final unit = parts[1];
    if (unit == 'mnt') {
      return '@count mnt'.trParams({'count': count});
    }
    if (unit == 'jam') {
      return '@count jam'.trParams({'count': count});
    }
    if (unit == 'hari') {
      return '@count hari'.trParams({'count': count});
    }
  }

  return value.tr;
}
