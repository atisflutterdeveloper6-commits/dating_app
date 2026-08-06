import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilebioController extends GetxController {
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();
  
  final TextEditingController bioController = TextEditingController();
  final count = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBio();
    bioController.addListener(_updateCharCount);
    _updateCharCount();
  }

  void _loadBio() {
    try {
      final bio = profileService.profile.value.bio;
      print('📤 Loading bio: $bio');
      
      if (bio != null && bio.isNotEmpty) {
        bioController.text = bio;
        print('✅ Bio loaded successfully');
      } else {
        print('ℹ️ No bio found in profile');
        bioController.text = '';
      }
      
      _updateCharCount();
    } catch (e) {
      print('❌ Error loading bio: $e');
      bioController.text = '';
    }
  }

  void _updateCharCount() {
    count.value = bioController.text.length;
  }

  Future<void> updateBio() async {
    if (isLoading.value) return;

    final bio = bioController.text.trim();
    
    if (bio.isEmpty) {
      CustomToast.warning('Please write something about yourself');
      return;
    }

    if (bio.length < 10) {
      CustomToast.warning('Bio must be at least 10 characters long');
      return;
    }

    try {
      isLoading.value = true;

      print('========================================');
      print('📤 UPDATING BIO');
      print('📤 Bio: $bio');
      print('📤 Bio length: ${bio.length}');
      print('📤 Current profile bio before update: ${profileService.profile.value.bio}');
      print('========================================');

      // Update in profile service
      profileService.updateBio(bio);
      
      print('📤 After updateBio() - profile bio: ${profileService.profile.value.bio}');

      // Save to server
      bool success = await profileService.updateProfile();

      print('📤 Update profile success: $success');
      print('📤 Profile bio after update: ${profileService.profile.value.bio}');
      print('📤 Error message: ${profileService.errorMessage.value}');

      isLoading.value = false;

      if (success) {
        // Refresh profile data after update
        await profileService.fetchMyProfile();
        
        CustomToast.success('Bio updated successfully! 🎉');

        // Navigate back after success
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        CustomToast.error(profileService.errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      CustomToast.error('Failed to update bio: $e');
      print('❌ Error updating bio: $e');
    }
  }

  @override
  void onClose() {
    bioController.dispose();
    super.onClose();
  }
}