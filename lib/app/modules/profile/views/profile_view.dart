import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../shared/widgets/bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final Color navyTextColor = const Color(0xFF003366);

  // Sample data to match the mockup
  final List<Map<String, dynamic>> reports = const [
    {
      "id": "#REP-8492",
      "title": "HVAC Leak in Sector 4",
      "description": "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
      "status": "In Progress",
      "date": "Oct 24, 2023",
      "color": 0xFF1A73E8, // Blue
    },
    {
      "id": "#REP-8490",
      "title": "Broken Entry Door Lock",
      "description": "The electronic strike on the north entrance is failing to engage. Security concern.",
      "status": "Pending",
      "date": "Oct 22, 2023",
      "color": 0xFFF9A825, // Orange
    },
    {
      "id": "#REP-8475",
      "title": "Flickering Lights in Breakroom",
      "description": "Fluorescent tubes in the main staff breakroom are flickering constantly causing headaches.",
      "status": "Rejected",
      "date": "Oct 18, 2023",
      "color": 0xFFD93025, // Red
    },
    {
      "id": "#REP-8412",
      "title": "Restroom Sink Clog",
      "description": "Men's restroom sink on floor 2 is completely blocked and overflowing slightly.",
      "status": "Resolved",
      "date": "Oct 10, 2023",
      "color": 0xFF137333, // Green
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                          "My Profile",
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
                      Text(
                        "Alex Karyawan",
                        style: TextStyle(
                          color: navyTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
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
                          "My Reports",
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
                        onPressed: () => Get.offAllNamed(Routes.LOGIN),
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256',
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
    final String id = report["id"] as String;
    final String title = report["title"] as String;
    final String description = report["description"] as String;
    final String status = report["status"] as String;
    final String date = report["date"] as String;
    final Color statusColor = Color(report["color"] as int);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EAF8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF104A7F).withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left indicator line
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID and Status Tag Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          id,
                          style: TextStyle(
                            color: navyTextColor.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: navyTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: status == "Resolved" ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Description
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    
                    const Divider(height: 24, color: Color(0xFFE2EAF8)),
                    
                    // Date & Chevron Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
                      ],
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case "In Progress":
        bgColor = const Color(0xFFE8F0FE);
        textColor = const Color(0xFF1A73E8);
        icon = Icons.sync;
        break;
      case "Pending":
        bgColor = const Color(0xFFFFF9E6);
        textColor = const Color(0xFFF9A825);
        icon = Icons.hourglass_empty;
        break;
      case "Rejected":
        bgColor = const Color(0xFFFCE8E6);
        textColor = const Color(0xFFD93025);
        icon = Icons.cancel_outlined;
        break;
      case "Resolved":
        bgColor = const Color(0xFFE6F4EA);
        textColor = const Color(0xFF137333);
        icon = Icons.check_circle_outline;
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        icon = Icons.info_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk Item Navigation Bar (sama seperti ReportPage)
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
