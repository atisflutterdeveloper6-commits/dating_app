import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/birthday/views/birthday_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';   // ← Added

// ================== CUSTOM TOAST CLASS ==================

class TellmeaboutyouController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nickNameController = TextEditingController();
  final isLoading = false.obs;

  late final ProfileServiceController profileController;

  @override
  void onInit() {
    super.onInit();
    
    try {
      profileController = Get.find<ProfileServiceController>();
      print("=== TellmeaboutyouController initialized ===");
    } catch (e) {
      print("ERROR: ProfileServiceController not found: $e");
      profileController = Get.put(ProfileServiceController());
    }

    // Load existing data
    final existingProfile = profileController.profile.value;
    if (existingProfile.firstName?.isNotEmpty == true) {
      firstNameController.text = existingProfile.firstName!;
    }
    if (existingProfile.lastName?.isNotEmpty == true) {
      lastNameController.text = existingProfile.lastName!;
    }
    if (existingProfile.nickName?.isNotEmpty == true) {
      nickNameController.text = existingProfile.nickName!;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nickNameController.dispose();
    super.onClose();
  }

  void continueToBirthday() {
    print("=== Continue button pressed ===");

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final nickName = nickNameController.text.trim();

    print("First Name: '$firstName'");
    print("Last Name: '$lastName'");
    print("Nick Name: '$nickName'");

    // Validation with Custom Toast
    if (firstName.isEmpty) {
      CustomToast.warning("Please enter your first name");
      return;
    }

    if (lastName.isEmpty) {
      CustomToast.warning("Please enter your last name");
      return;
    }

    if (nickName.isEmpty) {
      CustomToast.warning("Please enter your nickname");
      return;
    }

    print("All validations passed, saving data...");

    // Save data
    profileController.updateFirstName(firstName);
    profileController.updateLastName(lastName);
    profileController.updateNickName(nickName);

    // Verify saved data
    final savedProfile = profileController.profile.value;
    print("=== Verification after save ===");
    print("Saved First Name: ${savedProfile.firstName}");
    print("Saved Last Name: ${savedProfile.lastName}");
    print("Saved Nick Name: ${savedProfile.nickName}");

    // Navigate
    print("Navigating to BirthdayView...");
    Get.to(() => const BirthdayView());
  }
}