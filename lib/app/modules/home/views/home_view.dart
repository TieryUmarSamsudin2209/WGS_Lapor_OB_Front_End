import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return const BottomNavigationLayout();
  }
}

class BottomNavigationLayout extends StatefulWidget {
  const BottomNavigationLayout({super.key});

  @override
  State<BottomNavigationLayout> createState() => _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState extends State<BottomNavigationLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Report')),
    const Center(child: Text('Profile')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFF0F4C81),
        title: const Text('Beranda'),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(
              foregroundColor: Color(0xFF0F4C81),
              backgroundColor: Colors.white,
            ),
            onPressed: () {
              // Handle notification press
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0x660015B0), 
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Item 1: Home ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 ? const Color(0xFF0F4C81) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                        color: _selectedIndex == 0 ? Colors.white : const Color(0xFF0F4C81),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: _selectedIndex == 0 ? Colors.white : const Color(0xFF0F4C81),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Item 2: Report ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1 ? const Color(0xFF0F4C81) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1 ? Colors.white : const Color(0xFF0F4C81),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: _selectedIndex == 1 ? const Color(0xFF0F4C81) : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Report',
                        style: TextStyle(
                          color: _selectedIndex == 1 ? Colors.white : const Color(0xFF0F4C81),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Item 3: Profile ---
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2 ? const Color(0xFF0F4C81) : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedIndex == 2 ? Icons.person : Icons.person_outline,
                        color: _selectedIndex == 2 ? Colors.white : const Color(0xFF0F4C81),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: _selectedIndex == 2 ? Colors.white : const Color(0xFF0F4C81),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF0F4C81),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat Pagi,', style: TextStyle(fontSize: 15, color: Color(0xFFFFFFFF)),),
                  const SizedBox(height: 4,),
                  const Text('Alex Karyawan', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),),
                  const SizedBox(height: 2,),
                  SizedBox(
                    width: double.infinity,
                    child: OverflowBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            padding: EdgeInsets.only(
                              top: 10,
                              bottom: 10
                            )
                          ),
                          onPressed: () {
                            //Handle new report button
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 20, color: Color(0xFF0F4C81),),
                              const SizedBox(width: 2,),
                              Text('Laporkan masalah baru', style: TextStyle(color: Color(0xFF0F4C81), fontSize: 16),)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5,),
                  const Text('Kategori', style: TextStyle(fontSize: 25, color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),),
                  const SizedBox(height: 2,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle button press
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10
                                      ),
                                      backgroundColor: Color(0xFFFFFFFF),
                                    ),
                                    child: Icon(Icons.plumbing_outlined, size: 30, color: Color(0xFF0F4C81),),
                                  ),
                                ],
                              ),
                              Text('Kebersihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),)
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle button press
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10
                                      ),
                                      backgroundColor: Color(0xFFFFFFFF),
                                    ),
                                    child: Icon(Icons.chair_outlined, size: 30, color: Color(0xFF0F4C81),),
                                  ),
                                ],
                              ),
                              Text('Peralatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),)
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: [
                              ButtonBar(
                                alignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle button press
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.only(
                                        left: 10,
                                        right: 10
                                      ),
                                      backgroundColor: Color(0xFFFFFFFF),
                                    ),
                                    child: Icon(Icons.air_outlined, size: 30, color: Color(0xFF0F4C81),),
                                  ),
                                ],
                              ),
                              Text('Maintenance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 2,),
          Container(
            margin: const EdgeInsets.all(15),
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF0F4C81),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aktivitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),),
                      TextButton(
                        child: Text('Lihat Semua', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),),
                        onPressed: () {
                          // Handle button press
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 2,),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 300,
                        padding: const EdgeInsets.all(10),
                        child: Column(                         
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Color(0xFFC7C7C7), width: 1),
                                    ),
                                    child: Icon(Icons.plumbing_outlined, size: 30, color: Color(0xFF9F9F9F),),
                                  ),
                                  SizedBox(width: 4,),
                                  Container(
                                    width: 210,
                                    child: Column(                                
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Leaking Pipe in Restroom B', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),),
                                        const Text('Reported: Today, 09:30 AM • ID: #REP-2023-11A')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 3,
                                      bottom: 3,
                                      left: 10,
                                      right: 10
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDDECFF),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.sync, size: 18, color: Color(0xFF0F4C81),),
                                        SizedBox(width: 2,),
                                        Text('In Progress', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F4C81)),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4,),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 300,
                        padding: const EdgeInsets.all(10),
                        child: Column(                         
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Color(0xFFC7C7C7), width: 1),
                                    ),
                                    child: Icon(Icons.electric_bolt_outlined, size: 30, color: Color(0xFF9F9F9F),),
                                  ),
                                  SizedBox(width: 4,),
                                  Container(
                                    width: 210,
                                    child: Column(                                
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Flickering Lights in Meeting Room 4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),),
                                        const Text('Reported: Yesterday, 14:15 PM • ID: #REP-2023-10X')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 3,
                                      bottom: 3,
                                      left: 10,
                                      right: 10
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDDECFF),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF0F4C81),),
                                        SizedBox(width: 2,),
                                        Text('Resolved', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F4C81)),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}