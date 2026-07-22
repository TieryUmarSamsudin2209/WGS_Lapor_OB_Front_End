import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../theme/theme_controller.dart';

enum ObBottomNavItem { home, checklist, profile }

class ObBottomNav extends StatelessWidget {
  const ObBottomNav({
    super.key,
    required this.activeItem,
    this.middleLabel = 'Tugas',
    this.compact = false,
    this.onTap,
  });

  final ObBottomNavItem activeItem;
  final String middleLabel;
  final bool compact;
  final ValueChanged<ObBottomNavItem>? onTap;

  static const _blue = Color(0xFF15598D);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor = isDark ? _NavButton.darkInactiveText : _blue;

    return SafeArea(
      top: false,
      child: Container(
        height: compact ? 50 : 80,
        margin: compact
            ? const EdgeInsets.fromLTRB(13, 0, 13, 7)
            : const EdgeInsets.fromLTRB(13, 0, 13, 14),
        padding: EdgeInsets.all(compact ? 4 : 7),
        decoration: isDark
            ? _darkDecoration(compact)
            : _lightDecoration(compact),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactWidth = (constraints.maxWidth - 12) / 3;
            final useCompact = compact || constraints.maxWidth < 360;
            final iconOnly = compact ? compactWidth < 42 : compactWidth < 58;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  width: useCompact
                      ? compactWidth
                      : activeItem == ObBottomNavItem.home
                      ? 126
                      : 112,
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: activeItem == ObBottomNavItem.home,
                  isDark: isDark,
                  color: itemColor,
                  iconOnly: iconOnly,
                  compact: compact,
                  onTap: () => _goTo(ObBottomNavItem.home),
                ),
                _NavButton(
                  width: useCompact
                      ? compactWidth
                      : activeItem == ObBottomNavItem.checklist
                      ? 126
                      : 112,
                  icon: Icons.add_circle,
                  label: middleLabel,
                  isActive: activeItem == ObBottomNavItem.checklist,
                  isDark: isDark,
                  color: itemColor,
                  iconOnly: iconOnly,
                  compact: compact,
                  onTap: () => _goTo(ObBottomNavItem.checklist),
                ),
                _NavButton(
                  width: useCompact
                      ? compactWidth
                      : activeItem == ObBottomNavItem.profile
                      ? 126
                      : 112,
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: activeItem == ObBottomNavItem.profile,
                  isDark: isDark,
                  color: itemColor,
                  iconOnly: iconOnly,
                  compact: compact,
                  onTap: () => _goTo(ObBottomNavItem.profile),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _darkDecoration(bool compact) {
    return BoxDecoration(
      color: const Color(0xFF101418),
      borderRadius: BorderRadius.circular(compact ? 15 : 24),
      border: Border.all(
        color: AppDarkColors.border.withValues(alpha: 0.75),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.55),
          blurRadius: 10,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _lightDecoration(bool compact) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(compact ? 15 : 24),
      border: Border.all(color: const Color(0xFFCFE2FF), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7195FF).withValues(alpha: 0.9),
          blurRadius: compact ? 5 : 4,
          spreadRadius: 0,
          offset: Offset(0, compact ? 2 : 4),
        ),
      ],
    );
  }

  void _goTo(ObBottomNavItem item) {
    if (item == activeItem) return;

    if (onTap != null) {
      onTap!(item);
      return;
    }

    switch (item) {
      case ObBottomNavItem.home:
        Get.offNamed(Routes.OB_HOME);
        break;
      case ObBottomNavItem.checklist:
        Get.offNamed(Routes.OB_CHECKLIST);
        break;
      case ObBottomNavItem.profile:
        Get.offNamed(Routes.OB_PROFIL);
        break;
    }
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.color,
    required this.iconOnly,
    required this.compact,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final Color color;
  final bool iconOnly;
  final bool compact;
  final VoidCallback onTap;

  static const _lightActiveBlue = Color(0xFF15598D);
  static const _darkActiveBlue = Color(0xFF052C58);
  static const _darkActiveText = Color(0xFF1D8CFF);
  static const darkInactiveText = Color(0xFF8B929C);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 8 : 12);
    final activeForeground = isDark ? _darkActiveText : Colors.white;
    final inactiveForeground = isDark ? darkInactiveText : color;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isActive
                  ? isDark
                        ? _darkActiveBlue
                        : _lightActiveBlue
                  : Colors.transparent,
              borderRadius: borderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? activeForeground : inactiveForeground,
                  size: iconOnly
                      ? compact
                            ? 16
                            : 22
                      : isActive
                      ? compact
                            ? 16
                            : 31
                      : compact
                      ? 14
                      : 26,
                ),
                if (!iconOnly) ...[
                  SizedBox(width: compact ? 4 : 6),
                  Flexible(
                  child: Text(
                      label.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? activeForeground : inactiveForeground,
                        fontSize: compact ? 8 : 13,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
