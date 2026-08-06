// lib/app/modules/loginconfirmation/controllers/loginconfirmation_controller.dart

import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/login/views/login_view.dart';
import 'package:dating_app/app/modules/primiumplan/views/primiumplan_view.dart';
import 'package:get/get.dart';

class LoginconfirmationController extends GetxController {
  var phoneNumber = ''.obs;
  
  // 🔥 Profile controller instance
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  // Constructor to receive phone number
  LoginconfirmationController({String? phoneNumber}) {
    if (phoneNumber != null) {
      this.phoneNumber.value = phoneNumber;
      // 🔥 Phone number profile controller mein set karo
      profileController.setPhoneNumber(phoneNumber);
      print('📱 Phone number saved in profile: $phoneNumber');
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Check if phone number was passed via Get.arguments (fallback)
    if (Get.arguments != null && phoneNumber.value.isEmpty) {
      phoneNumber.value = Get.arguments.toString();
      profileController.setPhoneNumber(phoneNumber.value);
      print('📱 Phone number saved from arguments: ${phoneNumber.value}');
    }
  }

  void onContinueTap() {
    Get.toNamed('/primiumplan');
  }

  void onChangeNumberTap() {
    Get.offAll(() => const LoginView());
  }
}