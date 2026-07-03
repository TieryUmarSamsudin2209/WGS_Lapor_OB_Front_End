import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ob_home_controller.dart';
import '../../../../routes/app_pages.dart';

class OBHomeView extends GetView<ObHomeController> {
  const OBHomeView({super.key});

  static const _navy = Color(0xFF0F2A5E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          // Scrollable Content
          const ObHomePage(),

          // Floating Navigation Bar
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
}

class ObHomePage extends GetView<ObHomeController> {
  const ObHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xFF0F4C81),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Beranda',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Selamat Pagi,',
                    style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                  ),
                  Obx(() => Text(
                    controller.name.value,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF)),
                  ))
                ],
              ),
            ),
            
            // Tugas Harian
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF0F4C81),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tugas Harian',
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.OB_CHECKLIST);
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w700),
                          ))
                    ],
                  ),
                  Obx(() => Column(
                    children: controller.dailyTasks
                        .map((task) => _buildTaskItem(task))
                        .toList(),
                  )),
                ],
              ),
            ),
            
            // Laporan
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF0F4C81),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Laporan',
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            Get.toNamed(Routes.OB_PROFIL);
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w700),
                          ))
                    ],
                  ),
                  Obx(() => Column(
                    children: controller.reports
                        .map((report) => _buildReportItem(report))
                        .toList(),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 110), // bottom spacer for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(DailyTask task) {
    return Obx(() {
      final isResolved = task.status.value == 'resolved';
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x480015B0),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      isResolved ? Icons.check_circle_outline : Icons.error_outline,
                      color: isResolved ? const Color(0xFF0A952A) : const Color(0xFFFF8D28),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                          color: Color(0xFF0F4C81),
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                    Text(task.location)
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                  decoration: BoxDecoration(
                      color: isResolved ? const Color(0xFFDCFCE7) : const Color(0xFFFFFDCC),
                      borderRadius: BorderRadius.circular(50)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isResolved ? Icons.check_circle_outline : Icons.error_outline,
                        color: isResolved ? const Color(0xFF0A952A) : const Color(0xFFFF8D28),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isResolved ? 'Resolved' : 'Pending',
                        style: TextStyle(
                          color: isResolved ? const Color(0xFF0A952A) : const Color(0xFFFF8D28),
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildReportItem(HomeReport report) {
    return Obx(() {
      final isUrgent = report.priority == 'URGENT';
      final statusVal = report.status.value;
      final showCollab = report.hasCollaboration.value;

      Color priorityBg = isUrgent ? const Color(0xFFFFDAD6) : const Color(0xFFFFFDCC);
      Color priorityFg = isUrgent ? const Color(0xFF93000A) : const Color(0xFFFF8D28);
      IconData priorityIcon = Icons.error_rounded;

      // Status Styling
      Color statusBg = const Color(0xFFDDECFF);
      Color statusFg = const Color(0xFF00355F);
      IconData statusIcon = Icons.sync;

      if (statusVal == 'Sedang Diproses') {
        statusBg = const Color(0xFFDDECFF);
        statusFg = const Color(0xFF00355F);
        statusIcon = Icons.sync;
      } else if (statusVal == 'Selesai' || statusVal == 'Resolved') {
        statusBg = const Color(0xFFDCFCE7);
        statusFg = const Color(0xFF0A952A);
        statusIcon = Icons.check_circle_outline;
      } else if (statusVal == 'Ditolak') {
        statusBg = const Color(0xFFFFDAD6);
        statusFg = const Color(0xFF93000A);
        statusIcon = Icons.close;
      }

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.OB_DETAIL, arguments: report),
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF878787))),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(
                  color: Color(0xFF0D3A62),
                  width: 6,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      decoration: BoxDecoration(
                          color: priorityBg,
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            priorityIcon,
                            color: priorityFg,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(report.priority,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: priorityFg,
                                  fontSize: 15))
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusFg,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(statusVal,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: statusFg,
                                  fontSize: 13))
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(report.description)
                    ],
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: showCollab
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  children: [
                    if (showCollab)
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFD900),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Kolaborasi',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Lihat Detail',
                            style: TextStyle(color: Color(0xFF42474F)),
                          ),
                          Icon(
                            Icons.chevron_right_outlined,
                            size: 20,
                            color: Color(0xFF42474F),
                          )
                        ],
                      ),
                      onPressed: () =>
                          Get.toNamed(Routes.OB_DETAIL, arguments: report),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Bottom Navigation Bar ───
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});
  final ObHomeController controller;

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
            // Home item (ACTIVE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.home_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Checklist item
            InkWell(
              onTap: controller.createReport,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.checklist_rounded, color: _navy, size: 22),
                    SizedBox(width: 6),
                    Text(
                      'Checklist',
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

            // Profile item
            InkWell(
              onTap: controller.goProfile,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: const [
                    Icon(Icons.person_outline_rounded, color: _navy, size: 22),
                    SizedBox(width: 6),
                    Text(
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