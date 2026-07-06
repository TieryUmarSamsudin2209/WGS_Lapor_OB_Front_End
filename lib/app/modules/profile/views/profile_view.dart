import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/edit_profile_dialog.dart';
import '../../../shared/widgets/logout_confirmation_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String avatarUrl =
      'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256';

  final Color navyTextColor = const Color(0xFF003366);
  String firstName = 'Alex';
  String lastName = 'Karyawan';

  final List<Map<String, dynamic>> reports = const [
    {
      "priority": "URGENT",
      "status": "Selesai",
      "title": "Kebocoran Pipa Air",
      "location": "HQ Tower A, Lantai 4 (Toilet Pria)",
      "description":
          "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
    },
    {
      "priority": "STANDARD",
      "status": "Pending",
      "title": "Kebocoran Pipa Air",
      "location": "HQ Tower A, Lantai 4 (Toilet Pria)",
      "description":
          "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
    },
    {
      "priority": "URGENT",
      "status": "Ditolak",
      "title": "Kebocoran Pipa Air",
      "location": "HQ Tower A, Lantai 4 (Toilet Pria)",
      "description":
          "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
    },
    {
      "priority": "STANDARD",
      "status": "Pending",
      "title": "Kebocoran Pipa Air",
      "location": "HQ Tower A, Lantai 4 (Toilet Pria)",
      "description":
          "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final fullName = '$firstName $lastName'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFF104A7F),
      body: Stack(
        children: [
      SingleChildScrollView(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Background & Content Column
            Column(
              children: [
                // Blue header background with title
                Container(
                  width: double.infinity,
                  height: 180,
                  color: const Color(0xFF104A7F),
                  child: const SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Text(
                          "Profil Saya",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // White body container
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 70), // Spacing for the overlapping avatar
                      
                      // Name and Username
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              fullName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: navyTextColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => EditProfileDialog.show(
                              context,
                              avatarUrl: avatarUrl,
                              firstName: firstName,
                              lastName: lastName,
                              onSave: (newFirstName, newLastName) {
                                setState(() {
                                  firstName = newFirstName.isEmpty
                                      ? firstName
                                      : newFirstName;
                                  lastName = newLastName;
                                });
                              },
                              onAvatarChanged: (newAvatarPath) {
                                setState(() => avatarUrl = newAvatarPath);
                              },
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: navyTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_pin, size: 14, color: navyTextColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            "@username",
                            style: TextStyle(
                              color: navyTextColor.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // "My Reports" Button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF104A7F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                        ),
                        child: const Text(
                          "Laporan Saya",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2EAF8), width: 1.5),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Search reports by ID or category...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Filter Button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, size: 16, color: Colors.black87),
                          label: const Text(
                            "Filter",
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2EAF8), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // List of Reports
                      ...reports.map((report) => _buildReportCard(report)),

                      const SizedBox(height: 12),

                      _LogoutButton(
                        onPressed: () => LogoutConfirmationDialog.show(
                          context,
                          onConfirm: () => Get.offAllNamed(Routes.LOGIN),
                        ),
                      ),
                      
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ],
            ),
            
            // Positioned Avatar drawn ON TOP of the white container
            Positioned(
              top: 126, // 180 (header height) - 54 (radius + border) = 126
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Hero(
                  tag: 'profile-avatar',
                  child: ClipOval(
                    child: avatarUrl.startsWith('http')
                        ? Image.network(
                            avatarUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(avatarUrl),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- FLOATING NAVIGATION BAR ---
      Positioned(
        bottom: 25,
        left: 20,
        right: 20,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FA0FF).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: BottomNavItem(
                  icon: Icons.home_outlined,
                  label: "Home",
                  isActive: false,
                  onTap: () => Get.offAllNamed(Routes.HOME),
                  navyColor: navyTextColor,
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Icons.add_circle_outline,
                  label: "Report",
                  isActive: false,
                  onTap: () => Get.toNamed(Routes.REPORT),
                  navyColor: navyTextColor,
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Icons.person,
                  label: "Profile",
                  isActive: true,
                  onTap: () {},
                  navyColor: navyTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final String priority = report["priority"] as String;
    final String status = report["status"] as String;
    final String title = report["title"] as String;
    final String location = report["location"] as String;
    final String description = report["description"] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFD6DCE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: const Color(0xFF00518E),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildPriorityBadge(priority),
                          const Spacer(),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1E2A3A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFF0057D9),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0057D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF3F4653),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
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

  Widget _buildPriorityBadge(String priority) {
    final isUrgent = priority == "URGENT";
    final color = isUrgent ? const Color(0xFFD11C25) : const Color(0xFFFFB020);
    final bgColor = isUrgent ? const Color(0xFFFFE4E7) : const Color(0xFFFFF2C8);

    return _ReportBadge(
      text: priority,
      icon: Icons.error_outline,
      color: color,
      bgColor: bgColor,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case "Selesai":
        bgColor = const Color(0xFFDDF8E9);
        textColor = const Color(0xFF2B9A57);
        icon = Icons.check_circle_outline;
        break;
      case "Pending":
        bgColor = const Color(0xFFFFF2C8);
        textColor = const Color(0xFFFFA000);
        icon = Icons.schedule_outlined;
        break;
      case "Ditolak":
        bgColor = const Color(0xFFFFE4E7);
        textColor = const Color(0xFFD11C25);
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = const Color(0xFFE8ECF3);
        textColor = const Color(0xFF596273);
        icon = Icons.info_outline;
    }

    return _ReportBadge(
      text: status,
      icon: icon,
      color: textColor,
      bgColor: bgColor,
    );
  }

  // Helper untuk Item Navigation Bar (sama seperti ReportPage)
}

class _ReportBadge extends StatelessWidget {
  const _ReportBadge({
    required this.text,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded, size: 28),
        label: const Text(
          "Log Out",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFA11E1E),
          side: const BorderSide(color: Color(0xFFA11E1E), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
