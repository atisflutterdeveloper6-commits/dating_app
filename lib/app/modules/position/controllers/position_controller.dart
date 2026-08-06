import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/gender/views/gender_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PositionController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var positionsList = <PositionData>[].obs;
  var selectedId = Rxn<String>();
  var selectedIndex = (-1).obs;

  // Get ProfileServiceController
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  @override
  void onInit() {
    super.onInit();
    fetchPositions();
  }

  // 🔥 API Function in Controller
  Future<void> fetchPositions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.position}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Position Response Status: ${response.statusCode}');
      print('Position Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final responseData = PositionResponse.fromJson(jsonData);
        
        if (responseData.success && responseData.data.isNotEmpty) {
          positionsList.value = responseData.data;
          print('✅ Fetched ${positionsList.length} positions');
        } else {
          errorMessage.value = 'No position data available';
          CustomToast.warning('No position data available');
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        CustomToast.error('Failed to load data');
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('❌ Error fetching positions: $e');
      CustomToast.error('Error fetching positions');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPosition(int index) {
    selectedIndex.value = index;
    if (index < positionsList.length) {
      selectedId.value = positionsList[index].id;
      // ✅ Terminal mein ID show ho rahi hai
      print('✅ Selected: ${positionsList[index].title} (ID: ${positionsList[index].id})');
    }
  }

  void next() {
    if (selectedIndex.value == -1 || selectedId.value == null) {
      CustomToast.warning("Please select your position");
      return;
    }

    // Save position ID to ProfileServiceController
    final selectedPosition = positionsList[selectedIndex.value];
    profileController.updatePosition(selectedPosition.id);
    
    print('📤 Saved Position ID: ${selectedPosition.id}');

    // Navigate to next screen
    Get.to(() => const GenderView());
  }

  // Retry loading
  void retryLoading() {
    fetchPositions();
  }

  // Get position title by index
  String getPositionTitle(int index) {
    if (index < positionsList.length) {
      return positionsList[index].title;
    }
    return '';
  }

  // Get position subtitle by index
  String getPositionSubTitle(int index) {
    if (index < positionsList.length) {
      return positionsList[index].subTitle;
    }
    return '';
  }

  // Check if position list is empty
  bool get isEmpty => positionsList.isEmpty;
}

class PositionResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<PositionData> data;

  PositionResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    return PositionResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<PositionData>.from(json['data'].map((x) => PositionData.fromJson(x)))
          : [],
    );
  }
}

class PositionData {
  final String id;
  final String title;
  final String subTitle;
  final String createdAt;
  final String updatedAt;

  PositionData({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PositionData.fromJson(Map<String, dynamic> json) {
    return PositionData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subTitle: json['subTitle'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}