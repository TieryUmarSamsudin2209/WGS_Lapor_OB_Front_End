import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ob_home_controller.dart';

class ObHomeView extends GetView<ObHomeController> {
  const ObHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ObHomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ObHomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
