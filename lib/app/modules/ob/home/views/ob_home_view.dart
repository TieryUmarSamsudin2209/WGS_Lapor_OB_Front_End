import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ob_home_controller.dart';

class OBHomeView extends GetView<ObHomeController> {
  const OBHomeView({super.key});
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
    const ObHomePage(),
    const Center(child: Text('Report')),
    const Center(child: Text('Profile')),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Color(0xFF0F4C81),
        title: const Text('Beranda'),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _pages[_selectedIndex],
      ),
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

class ObHomePage extends StatelessWidget {
  const ObHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(17),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF0F4C81),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat Pagi,', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),),
                  const Text('Rahman OB', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF0F4C81),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tugas Harian', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 19, fontWeight: FontWeight.bold),),
                        TextButton(
                          onPressed: () {
                            //Handle button logic
                          }, 
                          child: Text('Lihat semua', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),))
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x480015B0), 
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.check_circle_outline, color: Color(0xFF0A952A), size: 20,),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mengepel', style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.w800, fontSize: 20),),
                                    Text('Gedung Baru, Lantai 1')
                                  ],
                                ),
                              )
                            ]
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Color(0xFF0A952A), size: 20,),
                                    SizedBox(width: 4,),
                                    Text('Resolved', style: TextStyle(color: Color(0xFF0A952A), fontWeight: FontWeight.w800, ),)
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x480015B0), 
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.error_outline, color: Color(0xFFFF8D28), size: 20,),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Menyapu', style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.w800, fontSize: 20),),
                                    Text('Gedung Lama, Toilet Lantai 1')
                                  ],
                                ),
                              )
                            ]
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFDCC),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Color(0xFFFF8D28), size: 20,),
                                    SizedBox(width: 4,),
                                    Text('Pending', style: TextStyle(color: Color(0xFFFF8D28), fontWeight: FontWeight.w800),)
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF0F4C81),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Laporan', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 19, fontWeight: FontWeight.bold),),
                        TextButton(
                          onPressed: () {
                            //Handle button logic
                          }, 
                          child: Text('Lihat semua', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700),))
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFDAD6),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_rounded, color: Color(0xFF93000A), size: 20,),
                                    SizedBox(width: 4,),
                                    Text('URGENT', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF93000A), fontSize: 15))
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDDECFF),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sync, color: Color(0xFF00355F), size: 18,),
                                    SizedBox(width: 4,),
                                    Text('Belum Diproses', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00355F), fontSize: 13))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HVAC Leak in Sector 4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Text('Water pooling near the main vent in hallway B. Requires immediate attention before floor damage')
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lihat Detail', style: TextStyle(color: Color(0xFF42474F)),),
                                    Icon(Icons.chevron_right_outlined, size: 20, color: Color(0xFF42474F),)
                                  ],
                                ),
                                onPressed: () {
                                  //Handle logic button
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFDCC),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_rounded, color: Color(0xFFFF8D28), size: 20,),
                                    SizedBox(width: 4,),
                                    Text('STANDARD', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFF8D28), fontSize: 15))
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDDECFF),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sync, color: Color(0xFF00355F), size: 18,),
                                    SizedBox(width: 4,),
                                    Text('Sedang Diproses', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00355F), fontSize: 13))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HVAC Leak in Sector 4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Text('Water pooling near the main vent in hallway B. Requires immediate attention before floor damage')
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFD900),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Kolaborasi', style: TextStyle(fontWeight: FontWeight.w600),)
                                  ],
                                ),
                              ),
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lihat Detail', style: TextStyle(color: Color(0xFF42474F)),),
                                    Icon(Icons.chevron_right_outlined, size: 20, color: Color(0xFF42474F),)
                                  ],
                                ),
                                onPressed: () {
                                  //Handle logic button
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFDCC),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_rounded, color: Color(0xFFFF8D28), size: 20,),
                                    SizedBox(width: 4,),
                                    Text('STANDARD', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFF8D28), fontSize: 15))
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                                decoration: BoxDecoration(
                                  color: Color(0xFFDDECFF),
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.sync, color: Color(0xFF00355F), size: 18,),
                                    SizedBox(width: 4,),
                                    Text('Belum Diproses', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00355F), fontSize: 13))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HVAC Leak in Sector 4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Text('Water pooling near the main vent in hallway B. Requires immediate attention before floor damage')
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lihat Detail', style: TextStyle(color: Color(0xFF42474F)),),
                                    Icon(Icons.chevron_right_outlined, size: 20, color: Color(0xFF42474F),)
                                  ],
                                ),
                                onPressed: () {
                                  //Handle logic button
                                },
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
      ),
    );
  }
}