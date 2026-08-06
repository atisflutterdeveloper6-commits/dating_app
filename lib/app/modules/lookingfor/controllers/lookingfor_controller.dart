// lib/app/modules/lookingfor/controllers/lookingfor_controller.dart

import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/models/all_gender_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/app/modules/bio/views/bio_view.dart';

class LookingforController extends GetxController {
  final RxList<LookingForModel> lookingForList = <LookingForModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = (-1).obs;
  
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  @override
  void onInit() {
    super.onInit();
    fetchLookingForOptions();
  }

  Future<void> fetchLookingForOptions() async {
    try {
      isLoading.value = true;
      final options = await profileController.fetchLookingFor();
      
      if (options.isNotEmpty) {
        lookingForList.assignAll(options);
        selectedIndex.value = 0; // Select first by default
      }
      
      print('✅ Loaded ${lookingForList.length} looking for options from API');
    } catch (e) {
      print('❌ Error fetching looking for options: $e');
      Get.snackbar(
        "Error",
        "Failed to load options. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Method to select an item
  void selectItem(int index) {
    if (index >= 0 && index < lookingForList.length) {
      selectedIndex.value = index;
      print('✅ Selected index: $index, Title: ${lookingForList[index].title}');
    }
  }

  void next() {
    if (selectedIndex.value == -1 || selectedIndex.value >= lookingForList.length) {
         CustomToast.warning("Please select one option");
      return;
    }

    final selectedItem = lookingForList[selectedIndex.value];
    
    // Save to ProfileServiceController
    profileController.updateLookingForId(selectedItem.id);
    profileController.updateLookingFor(selectedItem.title);

    print("=== Looking For saved ===");
    print("Looking For ID: ${selectedItem.id}");
    print("Looking For Title: ${selectedItem.title}");
    print("Looking For Icon: ${selectedItem.icon}");
    print("==========================");

    Get.to(() => const BioView());
  }
}