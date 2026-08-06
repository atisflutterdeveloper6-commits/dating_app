// lib/app/modules/blockuser/controllers/blockuser_controller.dart


import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/app/models/profile_all_model.dart';

class BlockuserController extends GetxController {
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();
  
  // Observable states
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final blockedUsers = <ProfileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final success = await profileService.fetchBlockedUsers();
      
      if (success) {
        blockedUsers.assignAll(profileService.blockedProfilesList);
        print('✅ Loaded ${blockedUsers.length} blocked users');
      } else {
        errorMessage.value = profileService.errorMessage.value;
        print('❌ Failed to fetch blocked users: ${errorMessage.value}');
        // Show error toast
        CustomToast.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Error loading blocked users: $e';
      print('❌ ${errorMessage.value}');
      CustomToast.error('Failed to load blocked users');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unblockUser(String profileId) async {
    try {
      isLoading.value = true;
      
      print('========== UNBLOCKING USER ==========');
      print('📤 Profile ID to unblock: $profileId');
      
      final success = await profileService.unblockUser(profileId);
      
      if (success) {
        // Remove from local list
        blockedUsers.removeWhere((user) => user.id == profileId);
        
        // ✅ Show success toast
        CustomToast.success('User unblocked successfully');
        print('✅ User unblocked and removed from list');
      } else {
        final errorMsg = profileService.errorMessage.value.isNotEmpty 
            ? profileService.errorMessage.value 
            : 'Failed to unblock user';
        
        // ❌ Show error toast
        CustomToast.error(errorMsg);
        print('❌ Unblock failed: $errorMsg');
      }
    } catch (e) {
      // ❌ Show error toast
      CustomToast.error('An unexpected error occurred');
      print('❌ Error in unblockUser: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBlockedUsers() async {
    await fetchBlockedUsers();
  }

  // Helper method to get user's display name
  String getUserDisplayName(ProfileModel user) {
    return user.getFullName();
  }

  // Helper method to get user's profile image
  String? getUserProfileImage(ProfileModel user) {
    return user.getProfileImage();
  }

  // Helper method to get user's age
  int? getUserAge(ProfileModel user) {
    return user.getAge();
  }

  // Helper method to check if user has photos
  bool hasPhotos(ProfileModel user) {
    return user.hasPhotos;
  }

  @override
  void onClose() {
    super.onClose();
  }
}