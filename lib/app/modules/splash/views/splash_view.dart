// lib/app/modules/splash/views/splash_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  SplashView({super.key});

  final SplashController controller =
  Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          height: double.infinity,
          width: double.infinity,

          // ======================================================
          // BACKGROUND - 2ND UI JAISE
          // ======================================================

          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/splashbg.jpeg',
              ),
              fit: BoxFit.cover,
            ),
          ),

          child: Column(
            children: [
              const Spacer(),

              // ==================================================
              // APP LOGO - CENTER
              // ==================================================

              Image.asset(
                'assets/icons/app_icon.jpeg',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}