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
      theme: ThemeData(
        fontFamily: 'sans-serif',
      ),
      home: const TrackReportsPage(),
    );
  }
}

class TrackReportsPage extends StatelessWidget {
  const TrackReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.business, color: Color(0xFF003366), size: 24),
            SizedBox(width: 8),
            Text(
              "Lapor OB",
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "My Reports",
              style: TextStyle(
                color: Color(0xFF1A2138),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Track the status of your submitted facility issues.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search reports by ID or category...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            
            // Filter Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list, size: 18, color: Colors.grey),
              label: const Text("Filter", style: TextStyle(color: Colors.black87, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Colors.black12),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // List of Reports
            _buildReportCard(
              id: "#REP-8492",
              status: "In Progress",
              title: "HVAC Leak in Sector 4",
              description: "Water pooling near the main vent in hallway B. Requires immediate attention before floor damage",
              date: "Oct 24, 2023",
              accentColor: const Color(0xFF004A8D),
              statusBg: const Color(0xFFE3F2FD),
              statusTextColor: const Color(0xFF004A8D),
              isStrikethrough: false,
            ),
            _buildReportCard(
              id: "#REP-8490",
              status: "Pending",
              title: "Broken Entry Door Lock",
              description: "The electronic strike on the north entrance is failing to engage. Security concern.",
              date: "Oct 22, 2023",
              accentColor: Colors.orange,
              statusBg: const Color(0xFFFFF3E0),
              statusTextColor: Colors.orange[800]!,
              isStrikethrough: false,
            ),
            _buildReportCard(
              id: "#REP-8475",
              status: "Rejected",
              title: "Flickering Lights in Breakroom",
              description: "Fluorescent tubes in the main staff breakroom are flickering constantly causing headaches.",
              date: "Oct 18, 2023",
              accentColor: Colors.red[400]!,
              statusBg: const Color(0xFFFFEBEE),
              statusTextColor: Colors.red[800]!,
              isStrikethrough: true,
            ),
            _buildReportCard(
              id: "#REP-8412",
              status: "Resolved",
              title: "Restroom Sink Clog",
              description: "Men's restroom sink on floor 2 is completely blocked and overflowing slightly.",
              date: "Oct 10, 2023",
              accentColor: const Color(0xFF4CAF50),
              statusBg: const Color(0xFFE8F5E9),
              statusTextColor: const Color(0xFF2E7D32),
              isStrikethrough: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFE8F0FE),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black54,
        currentIndex: 2, // Track is active
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed(Routes.HOME);
          } else if (index == 3) {
            Get.offAllNamed(Routes.PROFILE);
          } else if (index == 1) {
            Get.toNamed(Routes.REPORT);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "New Report"),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF004A8D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment, color: Colors.white),
            ),
            label: "Track",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF004A8D)),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildReportCard({
    required String id,
    required String status,
    required String title,
    required String description,
    required String date,
    required Color accentColor,
    required Color statusBg,
    required Color statusTextColor,
    required bool isStrikethrough,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Vertical color indicator
            Container(width: 5, height: 160, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Icon(
                                status == "Resolved" ? Icons.check_circle_outline : 
                                status == "Rejected" ? Icons.cancel_outlined : 
                                status == "Pending" ? Icons.access_time : Icons.info_outline,
                                size: 14, color: statusTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(status, style: TextStyle(color: statusTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isStrikethrough ? Colors.grey : const Color(0xFF1A2138),
                        decoration: isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    )
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