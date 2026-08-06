// lib/app/services/permission_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionService extends GetxService {
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.camera,
      Permission.storage,
    ];
    
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (!allGranted) {
      Get.snackbar(
        'Permissions Required',
        'Please grant microphone and camera permissions to make calls',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      // Open settings if permissions are permanently denied
      bool isPermanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);
      if (isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    
    return allGranted;
  }
}