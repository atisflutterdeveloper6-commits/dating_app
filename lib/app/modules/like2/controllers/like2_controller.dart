// lib/app/modules/like2/controllers/like2_controller.dart


import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:dating_app/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Like2Controller extends GetxController {
  final ProfileServiceController _profileController = Get.find<ProfileServiceController>();
  
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final likedProfiles = <ProfileModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLikedProfiles();
  }
  // In Like2Controller
void forceRefreshFromHomepage() {
  print('🔄 Force refreshing liked profiles from homepage');
  fetchLikedProfiles();
}

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ============================================================
  // FETCH LIKED PROFILES
  // ============================================================

  Future<void> fetchLikedProfiles() async {
    print("🔍 startlikedprofile");
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await _profileController.fetchLikedProfiles();
      
      if (success) {
        likedProfiles.value = _profileController.likedProfilesList;
        print('✅ Loaded ${likedProfiles.length} liked profiles');
        
        // Debug: Print first profile info
        if (likedProfiles.isNotEmpty) {
          final firstProfile = likedProfiles.first;
          print('📸 First profile: ${getFullName(firstProfile)}');
          print('📸 Image: ${getProfileImage(firstProfile)}');
        }
      } else {
        errorMessage.value = _profileController.errorMessage.value;
        print('❌ Error: ${errorMessage.value}');
        CustomToast.error(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load liked profiles';
      print('❌ Error fetching liked profiles: $e');
      CustomToast.error('Failed to load liked profiles');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH LIKED PROFILES
  // ============================================================

  Future<void> refreshLikedProfiles() async {
    await fetchLikedProfiles();
  }

  // ============================================================
  // PROFILE HELPER METHODS
  // ============================================================

  /// Get profile image URL
  String? getProfileImage(ProfileModel profile) {
    return profile.getProfileImage();
  }

  /// Get all profile images
  List<String> getAllProfileImages(ProfileModel profile) {
    return profile.getAllProfileImages();
  }

  /// Get full name
  String getFullName(ProfileModel profile) {
    return profile.getFullName();
  }

  /// Get age
  String getAge(ProfileModel profile) {
    final age = profile.getAge();
    return age != null ? age.toString() : '';
  }

  /// Check if profile has photos
  bool hasPhotos(ProfileModel profile) {
    return profile.hasPhotos;
  }

  /// Get profile image with fallback
  String getProfileImageWithFallback(ProfileModel profile) {
    final image = getProfileImage(profile);
    return image ?? 'https://via.placeholder.com/200x200?text=No+Image';
  }

  /// Get display name with age
  String getDisplayName(ProfileModel profile) {
    final name = getFullName(profile);
    final age = getAge(profile);
    return age.isNotEmpty ? '$name, $age' : name;
  }

  // ============================================================
  // UNLIKE PROFILE
  // ============================================================

  /// Unlike a profile
  Future<bool> unlikeProfile(String profileId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('========== UNLIKING PROFILE ==========');
      print('📤 Profile ID to unlike: $profileId');

      // Call the unlike API from profile controller
      final success = await _profileController.unlikeProfile(profileId);
      
      if (success) {
        // Remove from local list
        likedProfiles.removeWhere((profile) => profile.id == profileId);
        CustomToast.success('Profile unliked successfully');
        print('✅ Profile unliked successfully');
       // ✅ Homepage ko sahi count sync karwao — server se fresh fetch karke
        try {
          if (Get.isRegistered<HomepageController>()) {
            Get.find<HomepageController>().syncLikeCountFromServer(profileId);
          }
        } catch (e) {
          print('⚠️ Could not notify HomepageController: $e');
        }
        return true;
      } else {
        errorMessage.value = _profileController.errorMessage.value;
        CustomToast.error(errorMessage.value);
        print('❌ Failed to unlike profile: ${errorMessage.value}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to unlike profile';
      CustomToast.error('Failed to unlike profile');
      print('❌ Error unliking profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LIKE PROFILE
  // ============================================================

  /// Like a profile

  // ============================================================
  // CHECK METHODS
  // ============================================================

  /// Check if profile is liked
  bool isProfileLiked(String profileId) {
    return likedProfiles.any((p) => p.id == profileId);
  }

  /// Get profile by ID
  ProfileModel? getProfileById(String profileId) {
    try {
      return likedProfiles.firstWhere((p) => p.id == profileId);
    } catch (e) {
      return null;
    }
  }

  /// Get liked profiles count
  int getLikedProfilesCount() {
    return likedProfiles.length;
  }

  // ============================================================
  // CLEAR METHODS
  // ============================================================

  /// Clear liked profiles
  void clearLikedProfiles() {
    likedProfiles.clear();
    print('🔄 Liked profiles cleared');
  }

  // ============================================================
  // DEBUG METHODS
  // ============================================================

  /// Debug: Print all liked profiles
  void debugPrintLikedProfiles() {
    print('========== LIKED PROFILES DEBUG ==========');
    print('Total: ${likedProfiles.length}');
    for (var i = 0; i < likedProfiles.length; i++) {
      final profile = likedProfiles[i];
      print('${i + 1}. ${getFullName(profile)} (${profile.id})');
      print('   Age: ${getAge(profile)}');
      print('   Photos: ${profile.photos?.length ?? 0}');
      print('   Image: ${getProfileImage(profile)}');
    }
    print('==========================================');
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Retry fetch
  Future<void> retryFetch() async {
    clearError();
    await fetchLikedProfiles();
  }
}