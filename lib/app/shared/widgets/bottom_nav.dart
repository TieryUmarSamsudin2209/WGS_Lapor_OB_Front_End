import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final inactiveColor = isDark ? const Color(0xFF8B929C) : const Color(0xFF003366).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Ensures the entire slot is clickable
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: isActive
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: isActive
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: activeContentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          label.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: activeContentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: inactiveColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: inactiveColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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
