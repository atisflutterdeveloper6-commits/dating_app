import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/profilesetup/views/profilesetup_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/location_permission_controller.dart';

class LocationPermissionView extends GetView<LocationPermissionController> {
  const LocationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LocationPermissionController());
    return Obx(() {
      final isGpsOff = controller.isGpsOff.value;

      return Scaffold(
    backgroundColor:  Colors.white,
        appBar:CustomAppBar(title: "Enable location"),
       
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
           
              children: [
                const SizedBox(height: 50),
            
                Center(
                  child: Image.asset(
                    isGpsOff
                        ? "assets/images/gps_off.png"
                        : "assets/images/location_permission.png",
                    width: 240,
                  ),
                ),
                
                const SizedBox(height: 70),
                Text(
                  isGpsOff
                      ? "Your location is turned off.\nPlease enable GPS to\n continue."
                      : "Allow location to find people near\nyou and show accurate distance.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
            
                const SizedBox(height: 30),
            
                if (!isGpsOff) ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Find matches near you",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
               padding: EdgeInsets.only(left:8.0),
                    child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Improve match accuracy",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
            
                const Spacer(),
            
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                onPressed: () {
              if (!isGpsOff) {
                // First Screen -> Second Screen
                controller.showGpsOffScreen();
              } else {
                // Open Settings button -> Profile Setup Screen
                Get.to(() => const ProfilesetupView());
            
                // Ya agar Location screen ko remove karna hai:
                // Get.off(() => const ProfilesetupView());
              }
            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6B00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isGpsOff ? "Open Settings" : "Allow Location",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            
                const SizedBox(height: 15),
            
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    "Not Now",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
            
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}