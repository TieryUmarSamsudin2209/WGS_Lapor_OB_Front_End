import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lapor_ob/app/modules/application_policy/terms_conditions/views/terms_conditions_view.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});
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
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 5
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kebijakan Privasi', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, height: 2)),
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
                  //Protecting data
                  SizedBox(height: 20,),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // penting untuk rata kiri
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Melindungi Data Anda di Lapor-OB', textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 2),),
                        Text('Privasi Anda adalah prioritas kami. Dokumen ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat menggunakan platform manajemen Office Boy kami.', style: TextStyle(fontSize: 15),)
                      ],
                    ),
                  ),
                  //Main Points Card
                  SizedBox(height: 10,),
                  Container(
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
                        Text('Poin Penting:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F4C81)),),
                        //Poin 1
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.security_outlined, color: Color(0xFF22C55E), size: 30,),
                              SizedBox(width: 7,),
                              Flexible(
                                child: Text('Data anda dienkripsi dengan standar industri.', style: TextStyle(fontSize: 15)),
                              )
                            ],
                          ),
                        ),
                        //Poin 2
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.visibility_off_outlined, color: Color(0xFF00629E), size: 30,),
                              SizedBox(width: 7,),
                              Flexible(
                                child: Text('Kami tidak pernah menjual data pribadi Anda kepada pihak ketiga.', style: TextStyle(fontSize: 15)),
                              )
                            ],
                          ),
                        ),
                        //Poin 3
                        Container(
                          margin: EdgeInsets.only(
                            top: 10,
                            bottom: 10
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline_rounded, color: Color(0xFFF59E0B), size: 30,),
                              SizedBox(width: 7,),
                              Flexible(
                                child: Text('Anda memiliki kendali penuh atas informasi profil Anda.', style: TextStyle(fontSize: 15)),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  //Information section
                  Container(
                    margin: EdgeInsets.only(
                      top: 20
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Icon
                              Container(
                                margin: EdgeInsets.only(
                                  right: 5
                                ),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.person_search_outlined, color: Color(0xFF00629E),),
                              ),
                              Flexible(
                                child: Text('1. Informasi yang kami kumpulkan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        //Content
                        Container(
                          margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kami mengumpulkan informasi untuk memberikan layanan yang lebih baik kepada semua pengguna kami. Hal ini mencakup:', style: TextStyle(fontSize: 15),),
                              SizedBox(height: 7,),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Color(0xFF000000), fontSize: 15),
                                  children: [
                                    TextSpan(text: 'Informasi Akun: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'Nama, email, nomor telepon dan peran (Karyawan atau Office Boy).')
                                  ]
                                )
                              ),
                              SizedBox(height: 7,),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Color(0xFF000000), fontSize: 15),
                                  children: [
                                    TextSpan(text: 'Data Laporan: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'Deskripsi tugas, foto bukti pekerjaan, dan waktu penyelesaian.')
                                  ]
                                )
                              ),
                              SizedBox(height: 7,),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(color: Color(0xFF000000), fontSize: 15),
                                  children: [
                                    TextSpan(text: 'Lokasi: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: 'Data lokasi saat melakukan pelaporan untuk validasi kehadiran tugas (hanya jika diizinkan).')
                                  ]
                                )
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //Use of information
                  Container(
                    margin: EdgeInsets.only(
                      top: 20
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Icon
                              Container(
                                margin: EdgeInsets.only(
                                  right: 5
                                ),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.settings_outlined, color: Color(0xFF00629E),),
                              ),
                              Flexible(
                                child: Text('2. Penggunaan Informasi', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        //Content
                        Container(
                          margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Informasi yang kami kumpulkan digunakan untuk mengoperasikan, memelihara, dan menyediakan fitur layanan Lapor-OB, termasuk:', style: TextStyle(fontSize: 15),),
                              SizedBox(height: 7,),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F3FF),
                                  border: Border.all(
                                    color: Color(0x4BBFC7D4)
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text('"Memantau kinerja operasional harian secara real-time untuk memastikan kebersihan gedung terjaga."', style: TextStyle(fontStyle: FontStyle.italic),),
                              ),
                              SizedBox(height: 7,),
                              Text('Kami juga menggunakan data untuk mengirimkan notifikasi tugas baru atau pembaruan status laporan langsung ke perangkat Anda.', style: TextStyle(fontSize: 15),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //Data Security
                  Container(
                    margin: EdgeInsets.only(
                      top: 20
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Icon
                              Container(
                                margin: EdgeInsets.only(
                                  right: 5
                                ),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.lock_outline, color: Color(0xFF00629E),),
                              ),
                              Flexible(
                                child: Text('3. Keamanan Data', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        //Content
                        Container(
                          margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kami bekerja keras untuk melindungi Lapor-OB dan pengguna kami dari akses tanpa izin atau pengubahan, pengungkapan, maupun penghancuran informasi yang kami pegang secara tidak sah.', style: TextStyle(fontSize: 15),),
                              SizedBox(height: 7,),
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(10),
                                child: Image.asset(
                                  'assets/image_assets/privacy_policy_image.jpg',
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //Your Rights
                  Container(
                    margin: EdgeInsets.only(
                      top: 20
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Title
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //Icon
                              Container(
                                margin: EdgeInsets.only(
                                  right: 5
                                ),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFCFE5FF),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Icon(Icons.lock_outline, color: Color(0xFF00629E),),
                              ),
                              Flexible(
                                child: Text('4. Hak Anda', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        //Content
                        Container(
                          margin: EdgeInsets.only(
                            top: 5,
                            bottom: 5
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Anda dapat meminta akses, koreksi, atau penghapusan data pribadi Anda kapan saja dengan cara menghubungi admin. ', style: TextStyle(fontSize: 15),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //Question sections
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(
                      top: 20,
                      bottom: 20
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3FF),
                      border: Border.all(
                        color: Color(0x4BBFC7D4)
                      ),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Punya Pertanyaan Lain?', style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        Text('Silakan baca Syarat & Ketentuan kami atau hubungi pusat bantuan untuk klarifikasi lebih lanjut.')
                      ],
                    ),
                  )
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
                          child: Text('Kebijakan Privasi', style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.w700),),
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
                          child: Text('Syarat & Ketentuan', style: TextStyle(color: Color(0xFF3F4852), fontWeight: FontWeight.w700),),
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