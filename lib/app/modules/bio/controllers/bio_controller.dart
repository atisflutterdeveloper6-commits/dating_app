  // lib/app/modules/bio/controllers/bio_controller.dart


  import 'package:dating_app/app/custom_widget/custom_toast.dart';
  import 'package:dating_app/app/custom_widget/location_controller.dart';
  import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
  import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
  import 'package:dating_app/app/routes/app_pages.dart';
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  class BioController extends GetxController {
    final bioController = TextEditingController();
    RxInt count = 0.obs;
    final isLoading = false.obs;

    final ProfileServiceController profileController = Get.find<ProfileServiceController>();

    @override
    void onInit() {
      super.onInit();
      bioController.addListener(() {
        count.value = bioController.text.length;
      });
      
      // Debug - Print current profile data
      profileController.debugPrintProfile();
    }

 // In BioController.finishProfile()
Future<void> finishProfile() async {
  if (isLoading.value) return;

  final bio = bioController.text.trim();

  // Validation with CustomToast


  try {
    isLoading.value = true;

    // Save bio locally
    profileController.updateBio(bio);

    final profileData = profileController.profile.value;

    // Debug - Print before API call
    print('========== BEFORE API CALL ==========');
    print('First Name: ${profileData.firstName}');
    print('Last Name: ${profileData.lastName}');
    print('Nick Name: ${profileData.nickName}');
    print('Photos: ${profileData.photos}');
    print('Photo Paths: ${profileController.photoPaths}');
    print('Birthday: ${profileData.birthday}');
    print('Gender: ${profileData.gender}');
    print('Position: ${profileData.position}');
    print('Bio: ${profileData.bio}');
    print('======================================');

    // Check required fields
    if (profileData.photos == null || profileData.photos!.isEmpty) {
      CustomToast.error("Please add at least one photo");
      isLoading.value = false;
      return;
    }

    if (profileData.birthday == null || profileData.birthday!.isEmpty) {
      CustomToast.error("Please enter your birthday");
      isLoading.value = false;
      return;
    }

    if (profileData.gender == null || profileData.gender!.isEmpty) {
      CustomToast.error("Please select your gender");
      isLoading.value = false;
      return;
    }

    if (profileData.position == null || profileData.position!.isEmpty) {
      CustomToast.error("Please select your position");
      isLoading.value = false;
      return;
    }

    // 🔥 Check if Firebase token exists
    final StorageService storage = StorageService();
    final String? firebaseToken = storage.getAuthToken();
    if (firebaseToken == null || firebaseToken.isEmpty) {
      CustomToast.error("Authentication error. Please login again.");
      isLoading.value = false;
      Get.offAllNamed('/login');
      return;
    }
    print('✅ Firebase token found in storage');

    // ============================================
    // GET LOCATION BEFORE CREATING PROFILE
    // ============================================
    
    final locationController = LocationController.to;
    if (!locationController.locationFetched.value) {
      print('📍 Fetching location...');
      await locationController.getCurrentLocation();
    }
    
    if (locationController.locationFetched.value) {
      final locString = '${locationController.latitude.value},${locationController.longitude.value}';
      profileController.updateLocation(locString);
      print('📍 Location set: $locString');
    } else {
      print('⚠️ Could not fetch location, using default');
      profileController.updateLocation('0,0');
    }

    // ============================================
    // CREATE PROFILE API CALL
    // ============================================
    
    print('📤 Calling createProfile API...');
    final success = await profileController.createProfile();

    if (success) {
      // Success - Profile created
      print("========== COMPLETE PROFILE DATA ==========");
      print("First Name: ${profileData.firstName}");
      print("Last Name: ${profileData.lastName}");
      print("Nick Name: ${profileData.nickName}");
      print("Photos: ${profileData.photos}");
      print("Birthday: ${profileData.birthday}");
      print("Gender: ${profileData.gender}");
      print("Position: ${profileData.position}");
      print("Bio: ${profileData.bio}");
      print("Profile ID: ${profileController.profileId}");
      print("============================================");

      isLoading.value = false;

      // Success Toast
      CustomToast.success("Profile created successfully! 🎉");

      // Navigate to Dashboard
      Get.find<DashboardController>().changeTab(0);
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      // Failed - Show error message
      isLoading.value = false;
      CustomToast.error(profileController.errorMessage.value);
      print('❌ Profile creation failed: ${profileController.errorMessage.value}');
    }

  } catch (e) {
    isLoading.value = false;
    CustomToast.error("Failed to create profile: $e");
    print('❌ Error in finishProfile: $e');
  }
}
  
    @override
    void onClose() {
      bioController.dispose();
      super.onClose();
    }
  }