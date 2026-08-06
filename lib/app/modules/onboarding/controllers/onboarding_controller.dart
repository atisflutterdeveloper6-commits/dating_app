// lib/app/modules/onboarding/controllers/onboarding_controller.dart

import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class OnboardingController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var onboardingData = <OnboardingItem>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOnboardingData();
  }

  // Fetch onboarding data from API
  Future<void> fetchOnboardingData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.onboarding}'), // ✅ Changed to onboarding
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['data'];
          onboardingData.value = items.map((item) {
            return OnboardingItem.fromJson(item);
          }).toList();
          
          print('Onboarding data loaded: ${onboardingData.length} items');
        } else {
          errorMessage.value = data['message'] ?? 'Failed to load onboarding data';
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      print('Error fetching onboarding: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Retry function
  void retry() {
    fetchOnboardingData();
  }
}

// Onboarding Item Model
class OnboardingItem {
  final String id;
  final String title;
  final String subTitle;
  final String img;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  OnboardingItem({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.img,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnboardingItem.fromJson(Map<String, dynamic> json) {
    return OnboardingItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subTitle: json['subTitle'] ?? '',
      img: json['img'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}