import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color navyColor;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.navyColor = const Color(0xFF0F4C81),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF052C58) : navyColor;
    final activeContentColor = isDark ? AppDarkColors.accent : Colors.white;
    final inactiveColor = isDark ? const Color(0xFF8B929C) : navyColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: double.infinity,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeContentColor : inactiveColor,
              size: 24,
            ),
            if (isActive) const SizedBox(width: 6),
            if (isActive)
              Text(
                label,
                style: TextStyle(
                  color: activeContentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            if (!isActive) const SizedBox(width: 6),
            if (!isActive)
              Text(
                label,
                style: TextStyle(
                  color: inactiveColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
