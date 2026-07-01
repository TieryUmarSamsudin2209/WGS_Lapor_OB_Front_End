import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

void main() {
  runApp(const HomePages());
}

class HomePages extends StatelessWidget {
  const HomePages({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(" ", style: TextStyle(color: Colors.blueGrey[600], fontSize: 16)),
            const Text("Lapor OB", style: TextStyle(color: Color(0xFF003366), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text("Good morning,", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const Text("Alex Karyawan", style: TextStyle(color: Color(0xFF003366), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Tombol Report New Issue
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.REPORT),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Laporkan Masalah Baru", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Card Active Reports
            GestureDetector(
              onTap: () => Get.toNamed(Routes.TASK),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF004A8D), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.assignment, color: Colors.white, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.lightBlue[100], borderRadius: BorderRadius.circular(20)),
                          child: const Text("Action Needed", style: TextStyle(color: Color(0xFF004A8D), fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text("3", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                    const Text("Active Reports", style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Grid Categories
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildCategoryCard(context, Icons.home_outlined, "Plumbing"),
                _buildCategoryCard(context, Icons.bolt, "Electrical"),
                _buildCategoryCard(context, Icons.ac_unit, "HVAC"),
                _buildCategoryCard(context, Icons.chair_outlined, "Furniture"),
              ],
            ),
            const SizedBox(height: 30),

            // Section Recent Activities
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Activities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                TextButton(onPressed: () => Get.toNamed(Routes.TASK), child: const Text("View All", style: TextStyle(color: Color(0xFF003366), fontWeight: FontWeight.bold))),
              ],
            ),
            
            _buildActivityCard(
              icon: Icons.home_outlined,
              title: "Leaking Pipe in Restroom B",
              id: "#REP-2023-11A",
              time: "Today, 09:30 AM",
              status: "In Progress",
              statusColor: Colors.grey[400]!,
            ),
            _buildActivityCard(
              icon: Icons.bolt,
              title: "Flickering Lights in Meeting Room 4",
              id: "#REP-2023-10X",
              time: "Yesterday, 14:15 PM",
              status: "Resolved",
              statusColor: const Color(0xFFE3F2FD),
              textColor: const Color(0xFF004A8D),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF003366),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Get.offAllNamed(Routes.TASK);
          } else if (index == 3) {
            Get.offAllNamed(Routes.PROFILE);
          } else if (index == 1) {
            Get.toNamed(Routes.REPORT);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "New Report"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.REPORT, arguments: title),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF003366), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String id,
    required String time,
    required String status,
    required Color statusColor,
    Color textColor = Colors.black54,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
            child: Icon(icon, color: const Color(0xFF003366)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF003366))),
                const SizedBox(height: 4),
                Text("Reported: $time • ID: $id", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      status == "Resolved" ? "✓ $status" : "🕒 $status",
                      style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}