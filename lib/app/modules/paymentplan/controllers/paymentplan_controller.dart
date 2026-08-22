import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:convert';

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
          ? List<SubscriptionData>.from(
              json['data'].map((x) => SubscriptionData.fromJson(x)))
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

  static const platform = MethodChannel('com.atis.dating_app/audio_mute');
  // Observable variables
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var subscription = Rxn<SubscriptionData>();
  var subscriptionStatus = 'created'.obs;
  var isPaymentInProgress = false.obs;

 Player? player;
  VideoController? videoController;
  var isVideoInitialized = false.obs;


  // App branding
  final String appName = 'Vibely';

  // Subscription details
  String? pendingRazorpaySubscriptionId;
  String? pendingUserSubscriptionId;
  String? pendingRazorpayKeyId;
  bool isExistingSubscription = false;
  bool hasTriedPayment = false;

  // Default data
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
    checkExistingSubscriptionStatus().then((hasActive) {
      if (!hasActive) {
        fetchSubscription();
      } else {
        isLoading.value = false;
        fetchSubscription();
      }
    });
  }
Future<void> forceMuteMediaStream() async {
  try {
    final result = await platform.invokeMethod('muteMediaStream');
    print('✅ Native media stream muted, result: $result');
  } catch (e) {
    print('⚠️ Native mute failed: $e');
  }
}
  Future<void> forceUnmuteMediaStream() async {
    try {
      await platform.invokeMethod('unmuteMediaStream');
      print('✅ Native media stream unmuted');
    } catch (e) {
      print('⚠️ Native unmute failed: $e');
    }
  }

  Future<void> initializeVideo(String videoUrl) async {
    try {
      // Purana player dispose karo agar hai
      await player?.dispose();

      player = Player();
      videoController = VideoController(player!);

      // Pehle mute set karo, phir open karo
      await player!.setVolume(0.0); // 0-100 scale hoti hai media_kit me, 0.0 = fully mute

      await player!.open(Media(videoUrl));
      await player!.setPlaylistMode(PlaylistMode.loop);

      // Double safety
      await player!.setVolume(0.0);

      isVideoInitialized.value = true;
    } catch (e) {
      print('Network video error: $e');

      // Local asset fallback
      try {
        await player?.dispose();
        player = Player();
        videoController = VideoController(player!);

        await player!.setVolume(0.0);
        await player!.open(Media('asset:///assets/videos/bg_video.mp4'));
        await player!.setPlaylistMode(PlaylistMode.loop);
        await player!.setVolume(0.0);

        isVideoInitialized.value = true;
      } catch (localError) {
        print('Local video also failed: $localError');
        isVideoInitialized.value = false;
      }
    }
  }

  bool isVideoAvailable() {
    return isVideoInitialized.value && videoController != null;
  }
  @override
  void onClose() {
    player?.dispose();
    super.onClose();
  }


  Future<bool> checkExistingSubscriptionStatus() async {
    try {
      final token = _storage.getLoginToken() ?? _storage.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Check Subscription Status Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final status = jsonData['data']['status'] ?? 'created';
          subscriptionStatus.value = status;
          
          // Store subscription details even for created status
          pendingRazorpaySubscriptionId = jsonData['data']['razorpaySubscriptionId'];
          pendingUserSubscriptionId = jsonData['data']['_id'];
          
          if (status == 'active' || status == 'verified' || status == 'completed') {
            isExistingSubscription = true;
            // Store the plan data if available
            if (jsonData['data']['subscriptionPlan'] != null) {
              final planData = jsonData['data']['subscriptionPlan'];
              final subData = SubscriptionData(
                id: planData['_id'] ?? '',
                backgroundVideo: planData['backgroundVideo'] ?? '',
                mainTitle: planData['mainTitle'] ?? 'Unlock Premium',
                highlightText: planData['highlightText'] ?? 'Most Popular',
                planName: planData['planName'] ?? 'Premium Monthly',
                trialPrice: planData['trialPrice'] ?? '0',
                trialText: planData['trialText'] ?? 'free trial',
                trialDuration: planData['trialDuration'] ?? '7',
                priceAfterTrial: planData['priceAfterTrial'] ?? '499',
                afterTrialText: planData['afterTrialText'] ?? 'then ₹499/month',
                isDeleted: planData['isDeleted'] ?? false,
                createdAt: planData['createdAt'] ?? '',
                updatedAt: planData['updatedAt'] ?? '',
              );
              subscription.value = subData;
              await initializeVideo(subData.backgroundVideo);
            }
            return true;
          } else if (status == 'created' || status == 'pending') {
            // Subscription exists but payment not completed
            isExistingSubscription = true;
            hasTriedPayment = true;
            print('⚠️ Subscription exists with status: $status - need to complete payment');
            
            // Fetch the plan details if available
            if (jsonData['data']['subscriptionPlan'] != null) {
              final planData = jsonData['data']['subscriptionPlan'];
              final subData = SubscriptionData(
                id: planData['_id'] ?? '',
                backgroundVideo: planData['backgroundVideo'] ?? '',
                mainTitle: planData['mainTitle'] ?? 'Unlock Premium',
                highlightText: planData['highlightText'] ?? 'Most Popular',
                planName: planData['planName'] ?? 'Premium Monthly',
                trialPrice: planData['trialPrice'] ?? '0',
                trialText: planData['trialText'] ?? 'free trial',
                trialDuration: planData['trialDuration'] ?? '7',
                priceAfterTrial: planData['priceAfterTrial'] ?? '499',
                afterTrialText: planData['afterTrialText'] ?? 'then ₹499/month',
                isDeleted: planData['isDeleted'] ?? false,
                createdAt: planData['createdAt'] ?? '',
                updatedAt: planData['updatedAt'] ?? '',
              );
              subscription.value = subData;
              await initializeVideo(subData.backgroundVideo);
            }
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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
          await initializeVideo(responseData.data.first.backgroundVideo);
        } else {
          errorMessage.value = 'No subscription data available';
          subscription.value = defaultData;
        }
      } else {
        errorMessage.value = 'Failed to load data (${response.statusCode})';
        subscription.value = defaultData;
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      print('Error fetching subscription: $e');
      subscription.value = defaultData;
    } finally {
      isLoading.value = false;
    }
  }


  SubscriptionData getSubscription() {
    return subscription.value ?? defaultData;
  }



  void retryLoading() {
    fetchSubscription();
  }

  String formatPrice(String price) {
    if (price.isEmpty) return '₹0';
    return '₹$price';
  }

  bool isTrialFree() {
    final price = getSubscription().trialPrice;
    return price == '0' || (int.tryParse(price) ?? -1) == 0;
  }

  bool isSubscriptionActive() {
    final status = subscriptionStatus.value;
    return status == 'active' || status == 'verified' || status == 'completed';
  }

  bool shouldShowPayment() {
    final status = subscriptionStatus.value;
    return status == 'created' || status == 'pending' || status == 'initiated';
  }

  // FIXED: Get pay button text based on subscription status
  String getPayButtonText() {
    final data = getSubscription();
    final status = subscriptionStatus.value;
    
    // If subscription is active, show "Go to Profile Setup"
    if (isSubscriptionActive()) {
      return 'Go to Profile Setup';
    }
    
    // For created/pending status, show payment options
    if (status == 'created' || status == 'pending' || status == 'initiated') {
      if (isTrialFree()) {
        return 'Activate Free Trial';
      }
      return 'Pay ₹${data.trialPrice}';
    }
    
    // Default fallback
    return 'Pay ₹${data.trialPrice}';
  }

  void resetPaymentState() {
    isPaymentInProgress.value = false;
    hasTriedPayment = false;
  }

Future<bool> createSubscription() async {
  try {
    // Fallback: agar in-memory keyId nahi hai to local storage se le lo
    pendingRazorpayKeyId ??= _storage.getRazorpayKeyId();

    if (hasTriedPayment &&
        pendingRazorpaySubscriptionId != null &&
        pendingRazorpaySubscriptionId!.isNotEmpty &&
        pendingRazorpayKeyId != null &&
        pendingRazorpayKeyId!.isNotEmpty) {
      print('🔄 Reusing existing subscription: $pendingRazorpaySubscriptionId');
      return true;
    }

    final data = getSubscription();
    final token = _storage.getLoginToken() ?? _storage.getToken();

    if (token == null || token.isEmpty) {
      print('⚠️ No auth token found');
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

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        pendingRazorpaySubscriptionId =
            jsonData['data']['razorpaySubscriptionId'];
        pendingUserSubscriptionId = jsonData['data']['userSubscriptionId'];

        // Sirf tab overwrite karo jab backend ne naya keyId bheja ho
        final String? freshKeyId = jsonData['data']['keyId'];
        if (freshKeyId != null && freshKeyId.isNotEmpty) {
          pendingRazorpayKeyId = freshKeyId;
          await _storage.saveRazorpayKeyId(freshKeyId); // <-- persist karo
        }

        subscriptionStatus.value = jsonData['data']['status'] ?? 'created';

        final String message = (jsonData['message'] ?? '').toString();
        isExistingSubscription =
            message.toLowerCase().contains('existing subscription found');

        if (isExistingSubscription) {
          if (isSubscriptionActive()) {
            return true;
          } else {
            hasTriedPayment = true;
            // Ab local-storage fallback ke wajah se keyId mil chuka hoga
            // agar pehle kabhi successfully fetch hua tha
            if (pendingRazorpayKeyId == null || pendingRazorpayKeyId!.isEmpty) {
              print('⚠️ Existing subscription but no keyId available (fresh install / cleared storage)');
              return false;
            }
            return true;
          }
        }

        if (pendingRazorpayKeyId == null || pendingRazorpayKeyId!.isEmpty) {
          print('⚠️ Backend did not return keyId');
          return false;
        }
        return pendingRazorpaySubscriptionId != null &&
            pendingRazorpaySubscriptionId!.isNotEmpty;
      }
    }
    return false;
  } catch (e) {
    print('Error creating subscription: $e');
    return false;
  }
}
 
  Future<bool> verifyPayment({
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? razorpaySubscriptionId,
  }) async {
    try {
      final token = _storage.getLoginToken() ?? _storage.getToken();

      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found');
        return false;
      }

      final body = <String, dynamic>{
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
        'razorpay_subscription_id':
            razorpaySubscriptionId ?? pendingRazorpaySubscriptionId ?? '',
      };

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.verifySubscription}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('Verify Payment Response: ${response.statusCode} ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['data'] != null && jsonData['data']['status'] != null) {
          subscriptionStatus.value = jsonData['data']['status'];
          isExistingSubscription = true;
          hasTriedPayment = false; // Reset after successful payment
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }
}