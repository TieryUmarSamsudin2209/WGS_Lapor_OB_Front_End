import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ob_checklist_controller.dart';

class ObChecklistView extends GetView<ObChecklistController> {
  const ObChecklistView({super.key});

  static const _navy = Color(0xFF0F2A5E);
  static const _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Scrollable body ──────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSectionsList(),
                const SizedBox(height: 110),
              ],
            ),
          ),

          // ── Floating Bottom Nav ──────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(controller: controller),
          ),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F4C81),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: const Text(
            'Daftar List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sections list ───────────────────────────────────────────────────────
  Widget _buildSectionsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: controller.sections
            .map((section) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _buildSectionCard(section),
                ))
            .toList(),
      );
    });
  }

  // ─── Section card ────────────────────────────────────────────────────────
  Widget _buildSectionCard(ChecklistSection section) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C81).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 2),
              child: Text(
                section.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),

            // Item cards
            ...section.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildItemCard(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Item card ───────────────────────────────────────────────────────────
  Widget _buildItemCard(ChecklistItem item) {
    return Obx(() {
      final status = item.status.value;
      final style = _statusStyle(status);

      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => controller.toggleItem(item),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading colored circle icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    style.icon,
                    color: style.color,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),

                // Text + badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: status == 'resolved'
                              ? Colors.grey.shade400
                              : const Color(0xFF1B2559),
                          decoration: status == 'resolved'
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Description
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: status == 'resolved'
                              ? Colors.grey.shade300
                              : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status badge — aligned to right
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: style.bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(style.icon,
                                  size: 11, color: style.color),
                              const SizedBox(width: 4),
                              Text(
                                style.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: style.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Status style helper ─────────────────────────────────────────────────────
class _StatusStyle {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;
  const _StatusStyle(this.color, this.bgColor, this.icon, this.label);
}

_StatusStyle _statusStyle(String status) {
  switch (status) {
    case 'resolved':
      return const _StatusStyle(
        Color(0xFF3FA76B),
        Color(0xFFE4F6EA),
        Icons.check_circle_outline_rounded,
        'Resolved',
      );
    case 'pending':
      return const _StatusStyle(
        Color(0xFFC98A1B),
        Color(0xFFFCF1DC),
        Icons.access_time_rounded,
        'Pending',
      );
    default: // 'todo'
      return const _StatusStyle(
        Color(0xFFD9534F),
        Color(0xFFFBE7E6),
        Icons.radio_button_unchecked_rounded,
        'To-Do',
      );
  }
}

// ─── Bottom Navigation Bar ───────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final ObChecklistController controller;

  static const _navy = Color(0xFF0F2A5E);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC3C9FA), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F6FE0).withValues(alpha: 1),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Home
            InkWell(
              onTap: controller.goHome,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: _navy, size: 22),
                    const SizedBox(width: 6),
                    const Text(
                      'Home',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Checklist — ACTIVE
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.checklist_rounded,
                      color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Checklist',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Profile
            InkWell(
              onTap: controller.goProfile,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        color: _navy, size: 22),
                    const SizedBox(width: 6),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}