import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';
import '../theme/theme_controller.dart';

enum ObBottomNavItem { home, checklist, profile }

class ObBottomNav extends StatelessWidget {
  const ObBottomNav({
    super.key,
    required this.activeItem,
  });

  final ObBottomNavItem activeItem;

  static const _blue = Color(0xFF14558B);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemColor = isDark ? _NavButton.darkInactiveText : _blue;

    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        margin: const EdgeInsets.fromLTRB(13, 0, 13, 14),
        padding: const EdgeInsets.all(7),
        decoration: isDark ? _darkDecoration() : _lightDecoration(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactWidth = (constraints.maxWidth - 12) / 3;
            final useCompact = constraints.maxWidth < 360;
            final iconOnly = compactWidth < 58;

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
                  onTap: () => _goTo(ObBottomNavItem.home),
                ),
                _NavButton(
                  width: useCompact
                      ? compactWidth
                      : activeItem == ObBottomNavItem.checklist
                          ? 126
                          : 112,
                  icon: Icons.add_circle,
                  label: 'Checklist',
                  isActive: activeItem == ObBottomNavItem.checklist,
                  isDark: isDark,
                  color: itemColor,
                  iconOnly: iconOnly,
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
                  onTap: () => _goTo(ObBottomNavItem.profile),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _darkDecoration() {
    return BoxDecoration(
      color: const Color(0xFF101418),
      borderRadius: BorderRadius.circular(24),
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

  BoxDecoration _lightDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFFCFE2FF),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7195FF).withValues(alpha: 0.9),
          blurRadius: 4,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _goTo(ObBottomNavItem item) {
    if (item == activeItem) return;

    switch (item) {
      case ObBottomNavItem.home:
        Get.offAllNamed(Routes.OB_HOME);
        break;
      case ObBottomNavItem.checklist:
        Get.toNamed(Routes.OB_CHECKLIST);
        break;
      case ObBottomNavItem.profile:
        Get.offAllNamed(Routes.OB_PROFIL);
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
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final Color color;
  final bool iconOnly;
  final VoidCallback onTap;

  static const _lightActiveBlue = Color(0xFF14558B);
  static const _darkActiveBlue = Color(0xFF052C58);
  static const _darkActiveText = Color(0xFF1D8CFF);
  static const darkInactiveText = Color(0xFF8B929C);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
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
                      ? 22
                      : isActive
                          ? 31
                          : 26,
                ),
                if (!iconOnly) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? activeForeground : inactiveForeground,
                        fontSize: 13,
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
