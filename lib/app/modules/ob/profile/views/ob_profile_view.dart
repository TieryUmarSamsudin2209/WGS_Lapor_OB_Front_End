import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ob_profile_controller.dart';

class ObProfileView extends GetView<ObProfileController> {
  const ObProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObProfileView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ObProfileView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
