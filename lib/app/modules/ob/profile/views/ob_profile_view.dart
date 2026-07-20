import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lapor_ob/app/modules/application_policy/privacy_policy/views/privacy_policy_view.dart';
import 'package:lapor_ob/app/modules/application_policy/terms_conditions/views/terms_conditions_view.dart';

import '../controllers/ob_profile_controller.dart';

class ObProfileView extends GetView<ObProfileController> {
  const ObProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F4C81),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              //Title Profil Saya
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text('Profil Saya', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)),),
                ),
              ),
              //Main White Page
              Container(
                padding: EdgeInsets.fromLTRB(10, 80, 10, 10),
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(10, 170, 10, 0),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30)
                  )
                ),
                child: Column(
                  children: [
                    //Name & Button Edit Profile
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Text
                          Obx(() => Text(controller.namaLengkap.value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
                          Obx(() => Text('${controller.role} | @${controller.username}', style: const TextStyle(fontWeight: FontWeight(400), color: Color(0xFF6F7883)))),
                          SizedBox(height: 10,),
                          //Button Edit Profile
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  isDismissible: false,
                                  enableDrag: false,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom,
                                      ),
                                      child: SingleChildScrollView(
                                        child: SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 20
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                //Title & Xmark Button Modal
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    //Title
                                                    Center(
                                                      child: const Text('Edit Profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),),
                                                    ),
                                                    //Xmark Button
                                                    Positioned(
                                                      right: 0,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        icon: Icon(Icons.close, size: 25,)
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 20,),
                                                //Edit Profile
                                                Center(
                                                  child: SizedBox(
                                                    width: 150,
                                                    height: 150,
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Obx(() {
                                                          return CircleAvatar(
                                                            radius: 70,
                                                            backgroundImage: controller.tempProfileImage.value != null
                                                                ? FileImage(controller.tempProfileImage.value!)
                                                                : const AssetImage("assets/guest_user_profile.jpg")
                                                                    as ImageProvider,
                                                          );
                                                        }),
                                                        Container(
                                                          width: 140,
                                                          height: 140,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: Colors.black.withOpacity(0.60),
                                                          ),
                                                        ),
                                                        // Tombol Upload
                                                        IconButton(
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.vertical(
                                                                  top: Radius.circular(20),
                                                                ),
                                                              ),
                                                              builder: (context) {
                                                                return SafeArea(
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [

                                                                      ListTile(
                                                                        leading: const Icon(Icons.camera_alt_outlined),
                                                                        title: const Text("Ambil Foto"),
                                                                        onTap: () async {
                                                                          Get.back();
                                                                          await controller.pickCamera();
                                                                        },
                                                                      ),

                                                                      ListTile(
                                                                        leading: const Icon(Icons.photo_library_outlined),
                                                                        title: const Text("Pilih dari Galeri"),
                                                                        onTap: () async {
                                                                          Get.back();
                                                                          await controller.pickImage();
                                                                        },
                                                                      ),

                                                                      ListTile(
                                                                        leading: const Icon(
                                                                          Icons.delete_outline,
                                                                          color: Colors.red,
                                                                        ),
                                                                        title: const Text(
                                                                          "Hapus Foto",
                                                                          style: TextStyle(color: Colors.red),
                                                                        ),
                                                                        onTap: () {
                                                                          Get.back();
                                                                          controller.deleteProfileImage();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons.add_photo_alternate_outlined,
                                                            color: Colors.white,
                                                            size: 42,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20,),
                                                //Form Field
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('Nama depan', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Color(0xFF0F4C81)),),
                                                      SizedBox(height: 5,),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Color(0xFF0F4c81)
                                                          ),
                                                          borderRadius: BorderRadius.circular(10)
                                                        ),
                                                        child: TextField(
                                                          keyboardType: TextInputType.name,
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 16,
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderSide: BorderSide.none
                                                            )
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Container(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      const Text('Nama belakang', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: Color(0xFF0F4C81)),),
                                                      SizedBox(height: 5,),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Color(0xFF0F4c81)
                                                          ),
                                                          borderRadius: BorderRadius.circular(10)
                                                        ),
                                                        child: TextField(
                                                          keyboardType: TextInputType.name,
                                                          decoration: InputDecoration(
                                                            contentPadding: const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 16,
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderSide: BorderSide.none
                                                            )
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20,),
                                                //Button Save Edit
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF0F4C81),
                                                      foregroundColor: Color(0xFFFFFFFF),
                                                      
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10)
                                                      )
                                                    ),
                                                    onPressed: () {

                                                    },
                                                    child: const Text('Simpan'),
                                                  ),
                                                )
                                              ],
                                            )
                                          ),
                                        ),
                                      ),                                 
                                    );
                                  }
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F4C81),
                                foregroundColor: Color(0xFFFFFFFF),
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(10)
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              label: const Text("Edit Profil"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    //Progress Card
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFE2E8F0),
                          width: 2.0
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Left Section Card
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Progress Kerja Hari Ini', style: TextStyle(fontWeight: FontWeight.w600),),
                                SizedBox(height: 5,),
                                //Progress Poin Rate
                                Obx(() => Text(controller.progressText, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C81), fontSize: 20))),
                                SizedBox(height: 5,),
                                //Progress Bar
                                Obx(() {
                                  final pv = controller.progressValue;
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: LinearProgressIndicator(
                                          value: pv,
                                          minHeight: 8,
                                          backgroundColor: const Color(0xFFDDE2FF),
                                          valueColor: const AlwaysStoppedAnimation(
                                            Color(0xFF0F4C81),
                                          ),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(controller.progressPercent),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          //Progress Circle
                          Obx(() {
                            final pv = controller.progressValue;
                            return SizedBox(
                              width: 60,
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: pv,
                                    strokeWidth: 7,
                                    constraints: const BoxConstraints(
                                      minWidth: 80,
                                      minHeight: 80,
                                    ),
                                    color: const Color(0xFF0F4C81),
                                  ),
                                  Text(controller.progressPercent, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    //Location Now Sections
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        border: Border.all(
                          color: Color(0xFF000000),
                          width: 2.0
                        ),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          //Top Sections
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            decoration: BoxDecoration(
                              color: Color(0xFF0F4C81),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8)
                              )
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Lokasi Aktif Terkini", style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700, fontSize: 16),),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        overlayColor: Colors.transparent,
                                      ),
                                      child: const Text("Edit Lokasi", style: TextStyle(color: Color(0xFFFFFFFF))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //Main Section Locations
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //Container Location 
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF0F3FF),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Color(0xFF0F4C81),
                                      width: 2.0
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Left Sections
                                      Container(
                                        child: Row(
                                          children: [
                                            //Icon
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF0F4C81),
                                                borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Icon(Icons.apartment_outlined, color: Color(0xFF8EBDF9), size: 22,),
                                            ),
                                            SizedBox(width: 10,),
                                            const Text('Gedung Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),)
                                          ],
                                        ),
                                      ),
                                      //Right Sections
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(50)
                                        ),
                                        child: const Text('Aktif', style: TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w700)),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                    SizedBox(height: 10,),
                    //Report History
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        children: [
                          //Title & Button Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Riwayat Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                ),
                                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF000000)))
                              ),
                            ],
                          ),
                          ...controller.laporanItems.map((item) {
                            final prioritas = item['prioritas']?.toString() ?? 'STANDARD';
                            final status = item['status']?.toString() ?? 'BELUM_DIKERJAKAN';
                            final deskripsi = item['deskripsi_kendala']?.toString() ?? '';
                            final lokasi = item['lokasi']?.toString() ?? '';
                            final lantai = item['nomor_lantai'];
                            final lokasiText = lantai != null ? '$lokasi, Lantai $lantai' : lokasi;

                            return Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 5),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFC2C7D1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Color(0xFF0F4C81),
                                      width: 4.0,
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
                                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                          decoration: BoxDecoration(
                                            color: controller.prioColor(prioritas),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.error_rounded, size: 22, color: controller.prioTextColor(prioritas)),
                                              const SizedBox(width: 5),
                                              Text(prioritas, style: TextStyle(color: controller.prioTextColor(prioritas), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                          decoration: BoxDecoration(
                                            color: controller.statusColor(status),
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.error_outline, size: 22, color: controller.statusTextColor(status)),
                                              const SizedBox(width: 5),
                                              Text(controller.statusLabel(status), style: TextStyle(color: controller.statusTextColor(status), fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(deskripsi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, color: Color(0xFF001CBF), size: 22),
                                        const SizedBox(width: 3),
                                        Text(lokasiText, style: const TextStyle(color: Color(0xFF001CBF), fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                    SizedBox(height: 10,),
                    //Setting Account
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pengaturan & Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),),
                          SizedBox(height: 10,),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFFE2E8F0)
                              ),
                            ),
                            child: Column(
                              children: [
                                //Terms & Conditions
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                      () => TermsConditionsView(),
                                      transition: Transition.fadeIn,
                                      duration: const Duration(milliseconds: 900),
                                      curve: Curves.easeInOut
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFFFFF),
                                    foregroundColor: Color(0xFF3F4852),
                                    elevation: 0.0,
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.vertical(
                                        top: Radius.circular(10)
                                      ),
                                      side: BorderSide(
                                        color: Color(0xFFE2E8F0)
                                      )
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Left
                                      Row(
                                        children: [
                                          const Icon(Icons.description_outlined),
                                          SizedBox(width: 5),
                                          const Text('Syarat & Ketentuan')
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right_outlined)
                                    ],
                                  ),
                                ),
                                //Privacy Police
                                ElevatedButton(
                                  onPressed: () {
                                    Get.to(
                                      () => PrivacyPolicyView(),
                                      transition: Transition.fadeIn,
                                      duration: const Duration(milliseconds: 900),
                                      curve: Curves.easeInOut
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFFFFF),
                                    foregroundColor: Color(0xFF3F4852),
                                    elevation: 0.0,
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.circular(0),
                                      side: BorderSide(
                                        color: Color(0xFFE2E8F0)
                                      )
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Left
                                      Row(
                                        children: [
                                          const Icon(Icons.privacy_tip_outlined),
                                          SizedBox(width: 5),
                                          const Text('Kebijakan Privasi')
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right_outlined)
                                    ],
                                  ),
                                ),
                                //Contact
                                ElevatedButton(
                                  onPressed: () {
                                    
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFFFFF),
                                    foregroundColor: Color(0xFF3F4852),
                                    elevation: 0.0,
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.circular(0),
                                      side: BorderSide(
                                        color: Color(0xFFE2E8F0)
                                      )
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Left
                                      Row(
                                        children: [
                                          const Icon(Icons.email_outlined),
                                          SizedBox(width: 5),
                                          const Text('Kontak')
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right_outlined)
                                    ],
                                  ),
                                ),
                                //Language
                                ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Color(0xFFFFFFFF),
                                      builder: (context) {
                                        return SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 15
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Pilih Bahasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                                SizedBox(height: 10,),
                                                Divider(),
                                                //Language Options
                                                ListTile(
                                                  title: const Text('Indonesia'),
                                                  onTap: () {

                                                  },
                                                ),
                                                ListTile(
                                                  title: const Text('Inggris'),
                                                  onTap: () {

                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        );
                                      }
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFFFFF),
                                    foregroundColor: Color(0xFF3F4852),
                                    elevation: 0.0,
                                    padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadiusGeometry.vertical(
                                        bottom: Radius.circular(10)
                                      ),
                                      side: BorderSide(
                                        color: Color(0xFFE2E8F0)
                                      )
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Left
                                      Row(
                                        children: [
                                          const Icon(Icons.translate_outlined),
                                          SizedBox(width: 5),
                                          const Text('Bahasa')
                                        ],
                                      ),
                                      const Icon(Icons.chevron_right_outlined)
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    //Logout Button
                    ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFFFF),
                        foregroundColor: Color(0xFFEF4444),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                          side: BorderSide(
                            color: Color(0xFFE2E8F0)
                          )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_outlined),
                          SizedBox(width: 5,),
                          const Text('Keluar Sesi')
                        ],
                      ),
                    )
                  ],
                ),
              ),
              //Profile Image
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Foto Profil
                        Obx(() {
                          ImageProvider image;
                          if (controller.profileImage.value != null) {
                            image = FileImage(controller.profileImage.value!);
                          } else if (controller.profilePicture.isNotEmpty) {
                            image = NetworkImage(controller.profilePicture.value);
                          } else {
                            image = const AssetImage("assets/guest_user_profile.jpg");
                          }
                          return CircleAvatar(
                            radius: 70,
                            backgroundImage: image,
                          );
                        }),
                        // Camera Button
                        Positioned(
                          right: 0,
                          bottom: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFF0F4C81),
                              child: IconButton(
                                color: Color(0xFFFFFFFF),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) {
                                      return SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 15,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Ubah Foto Profil",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ListTile(
                                                leading: const Icon(Icons.camera_alt_outlined),
                                                title: const Text("Ambil Foto"),
                                                onTap: () async {
                                                  Get.back();
                                                  await controller.pickCamera();
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.photo_library_outlined),
                                                title: const Text("Pilih dari Galeri"),
                                                onTap: () async {
                                                  Get.back();
                                                  await controller.pickImage();
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                title: const Text(
                                                  "Hapus Foto",
                                                  style: TextStyle(color: Colors.red),
                                                ),
                                                onTap: () async {
                                                  Get.back();
                                                  controller.deleteProfileImage();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.photo_camera_outlined),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
