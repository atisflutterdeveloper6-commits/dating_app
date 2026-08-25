import 'dart:convert';

import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/login/views/login_view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginconfirmationController extends GetxController {
  final phoneNumber = ''.obs;

  // Splash API se aane wala dynamic logo URL
  final splashImageUrl = ''.obs;
  final isSplashLogoLoading = false.obs;

  final ProfileServiceController profileController =
      Get.find<ProfileServiceController>();

  LoginconfirmationController({String? phoneNumber}) {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      this.phoneNumber.value = phoneNumber;
      profileController.setPhoneNumber(phoneNumber);
      print('📱 Phone number saved in profile: $phoneNumber');
    }
  }

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && phoneNumber.value.isEmpty) {
      phoneNumber.value = Get.arguments.toString();
      profileController.setPhoneNumber(phoneNumber.value);
      print('📱 Phone number saved from arguments: ${phoneNumber.value}');
    }

    // Login confirmation screen ke liye dynamic splash logo fetch karega
    fetchSplashLogo();
  }

  Future<void> fetchSplashLogo() async {
    try {
      isSplashLogoLoading.value = true;

      final response = await http
          .get(
            Uri.parse('${ApiUrls.baseUrl}${ApiUrls.splashScreen}'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] is List &&
            (data['data'] as List).isNotEmpty) {
          final firstItem = (data['data'] as List).first;

          if (firstItem is Map && firstItem['splashImg'] != null) {
            splashImageUrl.value = firstItem['splashImg'].toString();
            print('✅ Splash logo loaded: ${splashImageUrl.value}');
          }
        }
      }
    } catch (e) {
      print('❌ Splash logo loading error: $e');
    } finally {
      isSplashLogoLoading.value = false;
    }
  }

  void onContinueTap() {
    Get.toNamed('/primiumplan');
  }

  void onChangeNumberTap() {
    Get.offAll(() => const LoginView());
  }
}