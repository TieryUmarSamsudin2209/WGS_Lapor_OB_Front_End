import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lapor_ob/app/modules/application_policy/privacy_policy/views/privacy_policy_view.dart';
import 'package:lapor_ob/app/modules/application_policy/terms_conditions/views/terms_conditions_view.dart';

import '../controllers/auth_activation_controller.dart';

class AuthActivationView extends GetView<AuthActivationController> {
  const AuthActivationView({super.key});
  @override
  Widget build(BuildContext context) {
  const activationToken = "1234567890";
    return Scaffold(
      backgroundColor: Color(0xFFF9F9FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Main Content Form
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                //WGS Logo
                                Image.asset(
                                  'assets/WGSLogoNoBG.png',
                                  width: 150,
                                ),
                                //Form Page
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(    
                                    color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF547BB5).withOpacity(0.5),
                                        blurRadius: 2,
                                        offset: Offset(0, 3) 
                                      )
                                    ]
                                  ),
                                  child: Column(
                                    children: [
                                      //Top Text
                                      Text('Halo, Usn!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
                                      Text('Selamat datang di Lapor OB', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F4C81)),),
                                      SizedBox(height: 20,),
                                      //Form Input
                                      Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            //Password Input
                                            Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Password', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F4C81)),),
                                                  SizedBox(height: 5,),
                                                  //Input
                                                  Obx(() => Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFFFFFFF),
                                                        border: Border.all(
                                                          color: controller.passwordError.value
                                                              ? Colors.red
                                                              : const Color(0xFFCBE7F5),
                                                        ),
                                                        borderRadius: BorderRadius.circular(50)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Obx(() => TextFormField(
                                                                controller: controller.passwordController,
                                                                obscureText: controller.obscurePassword.value,
                                                                decoration: const InputDecoration(
                                                                  border: InputBorder.none,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                                ),
                                                                onChanged: (_) {
                                                                  controller.passwordError.value = false;
                                                                },
                                                              ),
                                                            ) 
                                                          ),
                                                          Obx(() => IconButton(
                                                              onPressed: controller.togglePasswordVisibility,
                                                              icon: Icon(
                                                                controller.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9C9C9C), size: 22,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ),   
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            //Password Confirmation
                                            Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Password Confirmation',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF0F4C81),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),

                                                  Obx(
                                                    () => Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFFFFFF),
                                                        border: Border.all(
                                                          color: controller.confirmPasswordError.value
                                                              ? Colors.red
                                                              : const Color(0xFFCBE7F5),
                                                          width: controller.confirmPasswordError.value ? 2 : 1,
                                                        ),
                                                        borderRadius: BorderRadius.circular(50),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: controller.passwordConfirmationController,
                                                              obscureText: controller.obscurePassword.value,
                                                              decoration: const InputDecoration(
                                                                border: InputBorder.none,
                                                                isDense: true,
                                                                contentPadding: EdgeInsets.symmetric(
                                                                  horizontal: 20,
                                                                  vertical: 8,
                                                                ),
                                                              ),
                                                              onChanged: (_) {
                                                                controller.confirmPasswordError.value = false;
                                                              },
                                                            ),
                                                          ),
                                                          Obx(
                                                            () => IconButton(
                                                              onPressed: controller.togglePasswordVisibility,
                                                              icon: Icon(
                                                                controller.obscurePassword.value
                                                                    ? Icons.visibility_off_outlined
                                                                    : Icons.visibility_outlined,
                                                                color: const Color(0xFF9C9C9C),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            //Activation Button
                                            ElevatedButton(
                                              onPressed: () {
                                                controller.activation(activationToken);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF4EA1FF),
                                                padding: const EdgeInsets.symmetric(horizontal: 35),
                                              ),
                                              child: const Text('Aktivasi', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFFFFFFF), fontSize: 16),),
                                            ),
                                            SizedBox(height: 20,),
                                            //Don't Have Account Link
                                            Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Belum punya akun?', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF7A90A1)),),
                                                  SizedBox(width: 5,),
                                                  InkWell(
                                                    onTap: () {

                                                    },
                                                    child: Text('Hubungi admin', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81)),),
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
                            ),
                          ),
                          //Footer
                          Container(
                            margin: EdgeInsets.only(
                              bottom: 20
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => PrivacyPolicyView(),
                                      transition: Transition.rightToLeftWithFade,
                                      duration: const Duration(milliseconds: 700),
                                      curve: Curves.easeInOut
                                    );
                                  },
                                  child: Text('Kebijakan Privasi', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF7A90A1))),
                                ),
                                SizedBox(width: 5,),
                                Text('•', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF7A90A1)),),
                                SizedBox(width: 5,),
                                InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => TermsConditionsView(),
                                      transition: Transition.rightToLeftWithFade,
                                      duration: const Duration(milliseconds: 700),
                                      curve: Curves.easeInOut
                                    );
                                  },
                                  child: Text('Syarat & Ketentuan', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF7A90A1))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}
