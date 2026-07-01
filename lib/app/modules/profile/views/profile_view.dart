import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

void main() {
  runApp(const FacilityFixApp());
}

class FacilityFixApp extends StatelessWidget {
  const FacilityFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'sans-serif'),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final Color navyColor = const Color(0xFF003366);
  final Color lightBlueBg = const Color(0xFFF8FAFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.business, color: navyColor, size: 24),
            const SizedBox(width: 8),
            Text(
              "Lapor OB",
              style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // --- PROFILE HEADER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=Marcus', // Placeholder image
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Marcus Thorne",
                    style: TextStyle(color: navyColor, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Senior HVAC Technician", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadge("ID: 88492"),
                      const SizedBox(width: 10),
                      _buildBadge("Region: North Wing"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- WEEKLY OUTPUT CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1), // Navy Blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "WEEKLY OUTPUT",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text("42", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text("tasks closed", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.85,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "85% of weekly goal",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- ACCOUNT SETTINGS SECTION ---
            _buildSectionHeader("Account Settings"),
            _buildSettingsItem(Icons.person_outline, "Personal Information", "Update contact details and emergency info"),
            _buildSettingsItem(Icons.notifications_none, "Notifications", "Configure push and SMS alerts"),
            _buildSettingsItem(Icons.security, "Security & Password", "Manage PIN and biometric login"),
            
            const SizedBox(height: 20),

            // --- SUPPORT & INFO SECTION ---
            _buildSectionHeader("Support & Info"),
            _buildSettingsItem(Icons.help_outline, "Help Center & FAQ", null),
            _buildSettingsItem(Icons.gavel_outlined, "Terms & Privacy Policy", null),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("App Version", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("v2.4.1 (Build 4921)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- SIGN OUT BUTTON ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFE8F0FE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        currentIndex: 3, // Profile is active
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed(Routes.HOME);
          } else if (index == 2) {
            Get.offAllNamed(Routes.TASK);
          } else if (index == 1) {
            Get.toNamed(Routes.REPORT);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "New Report"),
          const BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Track"),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF004A8D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            label: "Profile",
          ),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF004A8D)),
      ),
    );
  }

  // Widget Helper untuk Badge (ID & Region)
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF0277BD), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // Widget Helper untuk Header Section
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F7FF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Text(
        title,
        style: TextStyle(color: navyColor, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget Helper untuk Item List Pengaturan
  Widget _buildSettingsItem(IconData icon, String title, String? subtitle) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title, style: TextStyle(color: navyColor, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }
}