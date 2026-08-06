import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/lookingfor/views/lookingfor_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntrestedinController extends GetxController {
  final List<String> interests = [
    "👨 Male",
    "👩 Female",
    "🌍 Everyone",
  ];

  int selectedIndex = -1;
  
  // Get ProfileServiceController
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  void next() {
    if (selectedIndex == -1) {
      CustomToast.warning("Please select one option");
      return;
    }

    // Save to ProfileServiceController
    profileController.updateInterestedIn(interests[selectedIndex]);

    print("=== Interested In saved ===");
    print("Interested In: ${interests[selectedIndex]}");
    print("=============================");

    Get.to(() => const LookingforView());
  }
}