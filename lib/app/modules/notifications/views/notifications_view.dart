import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/theme/theme_controller.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  static const _blue = Color(0xFF003366);
  static const _pageBg = Color(0xFFF8FAFC);
  static const _text = Color(0xFF1E293B);
  static const _muted = Color(0xFF64748B);

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
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.unreadCount;
            if (unreadCount == 0) return const SizedBox.shrink();
            
            return TextButton(
              onPressed: controller.markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : _blue,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'read_all'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: grouped.entries.expand((entry) {
                return [
                  _SectionTitle(title: entry.key == 'TERBARU' ? 'TERBARU' : (entry.key == 'KEMARIN' ? 'KEMARIN' : 'SEBELUMNYA')),
                  const SizedBox(height: 12),
                  ...entry.value.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Get.find<NotificationsController>().markAsRead(item);
                        },
                        child: _NotificationCard(item: item),
                      ),
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
            : const Color(0xFF888888),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
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
    final borderColor = isDark ? AppDarkColors.border : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
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
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (style.stripeColor != null)
                Container(
                  width: 4,
                  color: style.stripeColor,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: style.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          style.icon,
                          color: style.foreground,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: isDark ? Colors.white : NotificationsView._text,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.message,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : NotificationsView._muted,
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
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
    this.stripeColor,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? stripeColor;
}

_NotificationStyle _styleForType(String type) {
  if (type == 'resolved') {
    return const _NotificationStyle(
      icon: Icons.check_circle_outline_rounded,
      background: Color(0xFFE8F5E9),
      foreground: Color(0xFF2E7D32),
      stripeColor: null,
    );
  }
  if (type == 'received') {
    return const _NotificationStyle(
      icon: Icons.assignment_ind_outlined,
      background: Color(0xFFE0E7FF),
      foreground: Color(0xFF1D4ED8),
      stripeColor: Color(0xFF1D4ED8),
    );
  }
  if (type == 'rejected') {
    return const _NotificationStyle(
      icon: Icons.error_outline_rounded,
      background: Color(0xFFFEE2E2),
      foreground: Color(0xFFDC2626),
      stripeColor: Color(0xFFDC2626),
    );
  }
  if (type == 'report') {
    return const _NotificationStyle(
      icon: Icons.warning_amber_rounded,
      background: Color(0xFFFFF7ED),
      foreground: Color(0xFFEA580C),
      stripeColor: Color(0xFFEA580C),
    );
  }
  return const _NotificationStyle(
    icon: Icons.info_outline_rounded,
    background: Color(0xFFE0E7FF),
    foreground: Color(0xFF1D4ED8),
    stripeColor: Color(0xFF1D4ED8),
  );
}
