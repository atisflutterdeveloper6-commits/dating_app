import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
class SubscriptionResponse {
  final bool success;
  final int statusCode;
  final String message;
  final List<SubscriptionData> data;

  SubscriptionResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<SubscriptionData>.from(json['data'].map((x) => SubscriptionData.fromJson(x)))
          : [],
    );
  }
}

class SubscriptionData {
  final String id;
  final String backgroundVideo;
  final String mainTitle;
  final String highlightText;
  final String planName;
  final String trialPrice;
  final String trialText;
  final String trialDuration;
  final String priceAfterTrial;
  final String afterTrialText;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  SubscriptionData({
    required this.id,
    required this.backgroundVideo,
    required this.mainTitle,
    required this.highlightText,
    required this.planName,
    required this.trialPrice,
    required this.trialText,
    required this.trialDuration,
    required this.priceAfterTrial,
    required this.afterTrialText,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['_id'] ?? '',
      backgroundVideo: json['backgroundVideo'] ?? '',
      mainTitle: json['mainTitle'] ?? 'Unlock Premium',
      highlightText: json['highlightText'] ?? 'Most Popular',
      planName: json['planName'] ?? 'Premium Monthly',
      trialPrice: json['trialPrice'] ?? '0',
      trialText: json['trialText'] ?? 'free trial',
      trialDuration: json['trialDuration'] ?? '7',
      priceAfterTrial: json['priceAfterTrial'] ?? '499',
      afterTrialText: json['afterTrialText'] ?? 'then ₹499/month',
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class PaymentplanController extends GetxController {
   final StorageService _storage = StorageService();
  // Observable variables
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var subscription = Rxn<SubscriptionData>();

  // Video player controller
  var videoController = Rxn<VideoPlayerController>();
  var isVideoInitialized = false.obs;

  // App branding — shown in the footer ("...Terms of Service of Vibely")
  final String appName = 'Vibely';

  // Default data (fallback)
  final SubscriptionData defaultData = SubscriptionData(
    id: 'default',
    backgroundVideo: '',
    mainTitle: 'Meet with\n1000+ singles',
    highlightText: 'Most Popular',
    planName: 'Premium Monthly',
    trialPrice: '1',
    trialText: '1 Day trial for',
    trialDuration: '1',
    priceAfterTrial: '299',
    afterTrialText: '₹299 AFTER TRIAL',
    isDeleted: false,
    createdAt: '',
    updatedAt: '',
  );

  @override
  void onInit() {
    super.onInit();
    fetchSubscription();
  }

  @override
  void onClose() {
    if (videoController.value != null) {
      videoController.value!.dispose();
    }
    super.onClose();
  }

  // 🔥 API Function in Controller
  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // API Call
      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.subscriptionScreen}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Subscription Response Status: ${response.statusCode}');
      print('Subscription Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final responseData = SubscriptionResponse.fromJson(jsonData);

        if (responseData.success && responseData.data.isNotEmpty) {
          subscription.value = responseData.data.first;

          // Initialize video
          await initializeVideo(responseData.data.first.backgroundVideo);
        } else {
          errorMessage.value = 'No subscription data available';
          // Use default data
          subscription.value = defaultData;
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        // Use default data
        subscription.value = defaultData;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error fetching subscription: $e');
      // Use default data
      subscription.value = defaultData;
    } finally {
      isLoading.value = false;
    }
  }

  // Initialize video
  Future<void> initializeVideo(String videoUrl) async {
    try {
      if (videoController.value != null) {
        videoController.value!.dispose();
      }

      // Try network video first
      try {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        await controller.initialize();
        controller.setLooping(true);
        controller.play();
        videoController.value = controller;
        isVideoInitialized.value = true;
        return;
      } catch (e) {
        print('Network video error: $e');
      }

      // Fallback to asset video
      try {
        final localController = VideoPlayerController.asset('assets/videos/bg_video.mp4');
        await localController.initialize();
        localController.setLooping(true);
        localController.play();
        videoController.value = localController;
        isVideoInitialized.value = true;
      } catch (localError) {
        print('Local video also failed: $localError');
        isVideoInitialized.value = false;
      }
    } catch (e) {
      print('Error initializing video: $e');
      isVideoInitialized.value = false;
    }
  }

  // Get subscription data
  SubscriptionData getSubscription() {
    return subscription.value ?? defaultData;
  }

  // Check if video is available
  bool isVideoAvailable() {
    return isVideoInitialized.value && videoController.value != null;
  }

  // Retry loading
  void retryLoading() {
    fetchSubscription();
    
  }

  // Format price with currency
  String formatPrice(String price) {
    if (price.isEmpty) return '₹0';
    return '₹$price';
  }

  // Whether the current plan's trial is free (₹0)
  bool isTrialFree() {
    final price = getSubscription().trialPrice;
    return price == '0' || (int.tryParse(price) ?? -1) == 0;
  }

  // Get pay button text — always "Pay ₹X" to match the design, even for a
  // free (₹0) trial. The free-vs-paid branching still happens separately in
  // activateFreeTrial()/isTrialFree(), this only controls what's displayed.
  String getPayButtonText() {
    final data = getSubscription();
    return 'Pay ₹${data.trialPrice}';
  }

  // 🔥 Activates a free trial directly with the backend — no payment gateway
  // involved, since Razorpay can't process a ₹0 charge.
  // NOTE: point this at your real "start trial" endpoint (add it to ApiUrls).
 Future<bool> activateFreeTrial() async {
    try {
      final data = getSubscription();
      final token = _storage.getLoginToken() ?? _storage.getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found — user might not be logged in');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'subscriptionPlanId': data.id}),
      );

      print('Subscribe Response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error activating free trial: $e');
      return false;
    }
  }


}


