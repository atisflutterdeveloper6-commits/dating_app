import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SexualorientaionController extends GetxController {
  var showOrientation = true.obs;
  final List<String> orientations = [
    "Straight",
    "Gay",
    "Lesbian",
    "Bisexual",
    "Pansexual",
    "Asexual",
    "Queer",
    "Other",
  ];

  RxList<String> selected = <String>[].obs;
  
  // Get ProfileServiceController
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  void toggle(String value) {
    if (selected.contains(value)) {
      selected.remove(value);
    } else {
      selected.add(value);
    }
  }

  void next() {
    if (selected.isEmpty) {
      Get.snackbar(
        "Required",
        "Please select at least one option",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Save to ProfileServiceController
    profileController.updateSexualOrientation(selected.join(', '));
    // profileController.updateShowOrientation(showOrientation.value);

    print("=== Sexual Orientation saved ===");
    print("Orientation: ${selected.join(', ')}");
    print("Show Orientation: ${showOrientation.value}");
    print("================================");

    Get.toNamed(Routes.INTRESTEDIN);
  }
}