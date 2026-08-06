// lib/app/modules/profilesetup/controllers/profilesetup_controller.dart

import 'dart:io';

import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/birthday/views/birthday_view.dart';
import 'package:dating_app/app/modules/tellmeaboutyou/views/tellmeaboutyou_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfilesetupController extends GetxController {
  // Reactive variables
  final photos = RxList<File?>.filled(6, null);
  final isLoading = false.obs;
  final uploadedCount = 0.obs;

  final ImagePicker picker = ImagePicker();

  // Get ProfileServiceController instance
  final ProfileServiceController profileController =
      Get.find<ProfileServiceController>();

  @override
  void onInit() {
    super.onInit();
    // Listen to photos changes and update count
    ever(photos, (_) {
      uploadedCount.value = photos.where((file) => file != null).length;
    });
    print('ProfilesetupController initialized');
  }

  // Method to pick image from gallery
  Future<void> pickImage(int index) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        photos[index] = File(image.path);
        Get.snackbar(
          'Success',
          'Image added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to remove image
  void removeImage(int index) {
    if (isLoading.value) return;
    photos[index] = null;
  }

  // ============================================================
  // GET PHOTOS - CORRECTED VERSIONS
  // ============================================================

  // Get all non-null photo files (List<File>)
  List<File> getImageFiles() {
    return photos
        .where((file) => file != null)
        .map((file) => file!)
        .toList();
  }

  // Get all non-null photo paths (List<String>)
  List<String> getImagePaths() {
    return photos
        .where((file) => file != null)
        .map((file) => file!.path)
        .toList();
  }

  // Get count of uploaded photos
  int get uploadedPhotoCount {
    return photos.where((file) => file != null).length;
  }

  // Check if minimum photos are uploaded
  bool get hasMinimumPhotos {
    return uploadedPhotoCount >= 1;
  }

  // Check if all photos are uploaded
  bool get isComplete {
    return uploadedPhotoCount == 6;
  }

  // Reset all photos
  void resetPhotos() {
    if (isLoading.value) return;
    photos.assignAll(List<File?>.filled(6, null));
  }

  // ============================================================
  // UPLOAD PHOTOS - UPDATED
  // ============================================================

  // Upload photos to server
  Future<bool> uploadPhotos() async {
    try {
      isLoading.value = true;

      final imageFiles = getImageFiles();

      if (imageFiles.isEmpty) {
        Get.snackbar(
          'Error',
          'Please add at least one photo',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return false;
      }

      // Option 1: Save as List<File> (Recommended)
      profileController.updatePhotos(imageFiles);
      
      // Option 2: Also save paths directly (backup)
      // profileController.setPhotoPaths(getImagePaths());

      print('✅ Photos uploaded: ${imageFiles.length} photos');
      print('📸 Photo paths: ${getImagePaths()}');

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to upload photos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ============================================================
  // NAVIGATION FUNCTIONS
  // ============================================================

  // Navigate to Tell Me About You screen
  Future<void> continueToTellmeabout() async {
    if (isLoading.value) return;

    if (!hasMinimumPhotos) {
      Get.snackbar(
        'Required',
        'Please add at least 1 photo to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final success = await uploadPhotos();

    if (success) {
      // Debug print before navigating
      profileController.debugPrintProfile();
      
      Get.to(() => const TellmeaboutyouView());
    }
  }

  // Navigate to Birthday screen (if you have that flow)
  Future<void> continueToBirthday() async {
    if (isLoading.value) return;

    if (!hasMinimumPhotos) {
      Get.snackbar(
        'Required',
        'Please add at least 1 photo to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final success = await uploadPhotos();

    if (success) {
      profileController.debugPrintProfile();
      Get.to(() => const BirthdayView());
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    super.onClose();
  }
}