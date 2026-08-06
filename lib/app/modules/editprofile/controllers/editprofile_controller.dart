import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditprofileController extends GetxController {
  // Profile Service
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController nickNameController;
  late TextEditingController mobileController;

  // Observables
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('📤 EditprofileController initialized');
    
    // Initialize controllers
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    nickNameController = TextEditingController();
    mobileController = TextEditingController();
    
    // Load profile data
    loadProfile();
  }

  @override
  void onClose() {
    print('🔄 EditprofileController closed - disposing controllers');
    firstNameController.dispose();
    lastNameController.dispose();
    nickNameController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  // Load profile data
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📤 Loading profile for editing...');

      // 🔥 FIX: Get profile from service
      var profile = profileService.profile.value;
      
      // 🔥 FIX: Debug print the actual profile data
      print('📊 Profile data from service:');
      print('   ID: ${profile.id}');
      print('   FirstName: ${profile.firstName}');
      print('   LastName: ${profile.lastName}');
      print('   NickName: ${profile.nickName}');
      print('   Phone: ${profile.phone}');
      print('   Full profile: ${profile.toJson()}');

      // 🔥 FIX: Check if profile exists and has data
      if (profile.id == null || profile.id!.isEmpty) {
        print('⚠️ Profile ID is null or empty, fetching from server...');
        
        // Try to fetch from server
        bool success = await profileService.fetchMyProfile();
        
        if (!success) {
          errorMessage.value = 'Failed to load profile';
          isLoading.value = false;
          CustomToast.error('Failed to load profile');
          return;
        }
        
        // 🔥 FIX: Get the updated profile after fetch
        profile = profileService.profile.value;
        print('📊 Profile after fetch:');
        print('   FirstName: ${profile.firstName}');
        print('   LastName: ${profile.lastName}');
        print('   NickName: ${profile.nickName}');
        print('   Phone: ${profile.phone}');
      }

      // 🔥 FIX: Update text controllers with profile data (handle null values)
      firstNameController.text = profile.firstName ?? '';
      lastNameController.text = profile.lastName ?? '';
      nickNameController.text = profile.nickName ?? '';
      mobileController.text = profile.phone ?? '';

      print('✅ Profile loaded successfully');
      print('   First Name: ${firstNameController.text}');
      print('   Last Name: ${lastNameController.text}');
      print('   Nick Name: ${nickNameController.text}');
      print('   Phone: ${mobileController.text}');

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error loading profile: $e';
      print('❌ Error in loadProfile: $e');
      isLoading.value = false;
      CustomToast.error('Error loading profile: $e');
    }
  }

  // Update profile
 // In editprofile_controller.dart
Future<void> updateProfile() async {
  try {
    isSaving.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    // Validate fields
    if (firstNameController.text.isEmpty) {
      errorMessage.value = 'First name is required';
      isSaving.value = false;
      CustomToast.warning('Please enter your first name');
      return;
    }

    // Update profile data in the service
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final nickName = nickNameController.text.trim();
    final phone = mobileController.text.trim();

    print('📤 Updating profile with:');
    print('   FirstName: $firstName');
    print('   LastName: $lastName');
    print('   NickName: $nickName');
    print('   Phone: $phone');

    // Update only the fields that changed
    if (firstName.isNotEmpty) {
      profileService.updateFirstName(firstName);
    }
    if (lastName.isNotEmpty) {
      profileService.updateLastName(lastName);
    }
    if (nickName.isNotEmpty) {
      profileService.updateNickName(nickName);
    }
    if (phone.isNotEmpty) {
      profileService.updatePhone(phone);
    }

    // Save to server - use the fixed updateProfile method
    bool success = await profileService.updateProfile();

    if (success) {
      successMessage.value = 'Profile updated successfully!';
      CustomToast.success('Profile updated successfully!');
      
      // Navigate back after success
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } else {
      errorMessage.value = profileService.errorMessage.value.isNotEmpty 
          ? profileService.errorMessage.value 
          : 'Failed to update profile';
      CustomToast.error(errorMessage.value);  
    }
  } catch (e) {
    errorMessage.value = 'Error updating profile: $e';
    print('❌ Error in updateProfile: $e');
    CustomToast.error('Failed to update profile: $e');
  } finally {
    isSaving.value = false;
  }
}
  // Reset form
  void resetForm() {
    firstNameController.clear();
    lastNameController.clear();
    nickNameController.clear();
    mobileController.clear();
    errorMessage.value = '';
    successMessage.value = '';
  }
}