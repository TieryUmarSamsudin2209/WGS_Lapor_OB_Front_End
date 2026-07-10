import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lapor_ob/app/modules/application_policy/privacy_policy/views/privacy_policy_view.dart';
import 'package:lapor_ob/app/modules/application_policy/terms_conditions/controllers/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0F4C81),),
          onPressed: () {
            Get.back();
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/WGSLogoNoBG.png', width: 70,),
            SizedBox(width: 4,),
            Text('Lapor OB', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F4C81)),)
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top Body
            Container(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Title Top
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Syarat & Ketentuan', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, height: 2)),
                        Text('Terakhir diperbarui: 7 Juli 2026', style: TextStyle(height: 2),),
                        Divider(
                          color: Colors.blue,
                          thickness: 5,
                          endIndent: 250,
                          radius: BorderRadius.circular(50)
                        )
                      ],
                    ),
                  ),                  
                  SizedBox(height: 10,),
                  //Main Points Card
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  right: 15
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.gavel_outlined, color: Color(0xFF0F4C81))
                              ),
                              Text('1. Pendahuluan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                            ],
                          )
                        ),
                        //Text Pendahuluan
                        Container(
                          child: Column(
                            children: [
                              Text('Selamat datang di Lapor-OB. Dengan mengakses dan menggunakan platform kami, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Layanan ini disediakan untuk memfasilitasi pelaporan dan manajemen fasilitas gedung.', style: TextStyle(fontSize: 15),),
                              SizedBox(height: 10,),
                              Text('Jika Anda tidak menyetujui bagian mana pun dari ketentuan ini, Anda disarankan untuk berhenti menggunakan layanan kami segera.', style: TextStyle(fontSize: 15),),
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  //User Account Card
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  right: 15
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.person_outline, color: Color(0xFF0F4C81))
                              ),
                              Text('2. Akun Pengguna', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                            ],
                          )
                        ),
                        //List Akun Pengguna
                        Container(
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 22,),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text('Anda yang bertanggung jawab menjaga kerahasiaan kata sandi anda.', style: TextStyle(fontSize: 15),)
                                    )
                                  ],
                                )
                              ),
                              SizedBox(height: 10,),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 22,),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text('Informasi yang diberikan saat pendaftaran harus akurat dan valid.', style: TextStyle(fontSize: 15),)
                                    )
                                  ],
                                )
                              ),
                              SizedBox(height: 10,),
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 22,),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text('Satu akun hanya boleh digunakan oleh satu individu yang berwenang.', style: TextStyle(fontSize: 15),)
                                    )
                                  ],
                                )
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  //Office Image
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(5),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/image_assets/office_image.jpg',
                          width: double.infinity,
                        ),
                        Positioned(
                          bottom: 10,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Standar Pelayanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF)),),
                              Text('Komitmen Kebersihan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),)
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  //Penggunaan Layanan Card
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  right: 15
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.error_outline_rounded, color: Color(0xFF0F4C81))
                              ),
                              Text('3. Penggunaan Layanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                            ],
                          )
                        ),
                        //List Penggunaan
                        Container(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5
                                ),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F3FF),
                                  border: Border.all(
                                    color: Color(0x30BFC7D4)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text('Mengirim laporan palsu atau menyesatkan.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF3F4852)),),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5
                                ),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F3FF),
                                  border: Border.all(
                                    color: Color(0x30BFC7D4)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text('Menggunakan bahasa yang kasar atau tidak pantas dalam deskripsi.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF3F4852)),),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 5,
                                  bottom: 5
                                ),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F3FF),
                                  border: Border.all(
                                    color: Color(0x30BFC7D4)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text('Melakukan spamming sistem dengan permintaan berulang tanpa alasan.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF3F4852)),),
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  //Privasi & Data Card
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  right: 15
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.security_outlined, color: Color(0xFF0F4C81))
                              ),
                              Text('4. Privasi & Data', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                            ],
                          )
                        ),
                        //Content
                        Container(
                          child: Column(
                            children: [
                              Text('Pengumpulan dan penggunaan data pribadi Anda diatur oleh Kebijakan Privasi kami. Dengan menyetujui Syarat & Ketentuan ini, Anda juga dianggap telah memahami Kebijakan Privasi.', style: TextStyle(fontSize: 15)),
                              Container(
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(
                                      () => PrivacyPolicyView(),
                                      transition: Transition.rightToLeftWithFade,
                                      duration: const Duration(milliseconds: 700),
                                      curve: Curves.easeInOut
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Lihat Kebijakan Privasi', style: TextStyle(color: Color(0xFF0F4C81)),),
                                      SizedBox(width: 7,),
                                      Icon(Icons.open_in_new_outlined, color: Color(0xFF0F4c81),)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                  //Perubahan Ketentuan Card
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 10
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(
                                  right: 15
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.history_outlined, color: Color(0xFF0F4C81))
                              ),
                              Text('5. Perubahan Ketentuan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                            ],
                          )
                        ),
                        //Content
                        Container(
                          child: Column(
                            children: [
                              Text('Kami berhak memperbarui Syarat & Ketentuan ini sewaktu-waktu. Perubahan akan segera efektif setelah dipublikasikan di halaman ini. Penggunaan berkelanjutan atas layanan setelah perubahan menandakan persetujuan Anda.', style: TextStyle(fontSize: 15)),
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFEAEDFF)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Logo
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/WGSLogoNoBG.png',
                          width: 90,
                        ),
                        Text('Lapor OB', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F4C81), fontSize: 18),)
                      ],
                    ),
                  ),
                  //Footer Title
                  Container(
                    width: 250,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.copyright_outlined, size: 16),
                          Flexible( 
                            child: Text(
                              '2026 Lapor-OB. Hak Cipta Dilindungi Undang-Undang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                  SizedBox(height: 10,),
                  //Privacy Policy & Terms & Conditions Text
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.to(
                              () => PrivacyPolicyView(),
                              transition: Transition.leftToRightWithFade,
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeInOut   
                            );
                          },
                          child: Text('Kebijakan Privasi', style: TextStyle(color: Color(0xFF3F4852), fontWeight: FontWeight.w700),),
                        ),
                        SizedBox(width: 5,),
                        TextButton(
                          onPressed: () {
                            Get.to(
                              () => TermsConditionsView(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeInOut 
                            );
                          },
                          child: Text('Syarat & Ketentuan', style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.w700),),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}