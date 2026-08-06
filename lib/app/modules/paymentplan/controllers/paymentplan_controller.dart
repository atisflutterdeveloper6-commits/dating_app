import 'package:dating_app/app/apiurl/api_url.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/paymentsuccess/views/paymentsuccess_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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

// What Razorpay Checkout needs to open in SUBSCRIPTION mode.
class RazorpaySubscriptionInit {
  final String razorpaySubscriptionId;
  final String keyId;

  RazorpaySubscriptionInit({
    required this.razorpaySubscriptionId,
    required this.keyId,
  });
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

  // App branding
  final String appName = 'Vibely';

  // 🔥 Razorpay now lives here, created once in onInit(), cleared once in
  // onClose() — NOT re-created every time the view's build() runs.
  late final Razorpay razorpay;

  // Prevents double-handling if a payment event somehow fires twice.
  bool _paymentEventHandled = false;

  // Keeps the current userSubscriptionId around so the polling step knows
  // which record to check on the backend.
  String? _lastRazorpaySubscriptionId;

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
    print('🟢 [PaymentplanController] onInit — fetching subscription + setting up Razorpay');
    fetchSubscription();

    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    print('🔴 [PaymentplanController] onClose — disposing video + clearing Razorpay listeners');
    if (videoController.value != null) {
      videoController.value!.dispose();
    }
    razorpay.clear();
    super.onClose();
  }

  Future<void> fetchSubscription() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('${ApiUrls.baseUrl}${ApiUrls.subscriptionScreen}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Subscription-screen response: ${response.statusCode} ${response.body}');

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
      print('❌ Error fetching subscription: $e');
      subscription.value = defaultData;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeVideo(String videoUrl) async {
    try {
      if (videoController.value != null) {
        videoController.value!.dispose();
      }
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize();
        controller.setLooping(true);
        controller.play();
        videoController.value = controller;
        isVideoInitialized.value = true;
        return;
      } catch (e) {
        print('⚠️ Network video error: $e');
      }
      try {
        final localController = VideoPlayerController.asset('assets/videos/bg_video.mp4');
        await localController.initialize();
        localController.setLooping(true);
        localController.play();
        videoController.value = localController;
        isVideoInitialized.value = true;
      } catch (localError) {
        print('⚠️ Local video also failed: $localError');
        isVideoInitialized.value = false;
      }
    } catch (e) {
      print('❌ Error initializing video: $e');
      isVideoInitialized.value = false;
    }
  }

  SubscriptionData getSubscription() => subscription.value ?? defaultData;

  bool isVideoAvailable() => isVideoInitialized.value && videoController.value != null;

  void retryLoading() => fetchSubscription();

  String formatPrice(String price) => price.isEmpty ? '₹0' : '₹$price';

  bool isTrialFree() {
    final price = getSubscription().trialPrice;
    return price == '0' || (int.tryParse(price) ?? -1) == 0;
  }

  String getPayButtonText() {
    final data = getSubscription();
    return 'Pay ₹${data.trialPrice}';
  }

  String? _getAuthToken() {
    return _storage.getLoginToken() ?? _storage.getToken();
  }

  Future<bool> activateFreeTrial() async {
    try {
      final data = getSubscription();
      final token = _getAuthToken();
      print('🆓 activateFreeTrial() called for planId=${data.id}');

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

      print('📥 /subscribe (free trial) response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error activating free trial: $e');
      return false;
    }
  }

  Future<RazorpaySubscriptionInit?> createRazorpaySubscription() async {
    try {
      final data = getSubscription();
      final token = _getAuthToken();

      print('========================================');
      print('📡 CREATING RAZORPAY SUBSCRIPTION');
      print('subscriptionPlanId: ${data.id}');
      print('========================================');

      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found — user might not be logged in');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'subscriptionPlanId': data.id}),
      );

      print('📥 /subscribe response: ${response.statusCode} ${response.body}');

      if (response.statusCode != 200) {
        print('❌ /subscribe failed with status ${response.statusCode}');
        return null;
      }

      final body = json.decode(response.body);
      final resData = body['data'];
      if (resData == null) {
        print('❌ /subscribe response missing "data" field');
        return null;
      }

      final razorpaySubscriptionId = resData['razorpaySubscriptionId'];
      final keyId = resData['keyId'];

      if (razorpaySubscriptionId == null || keyId == null) {
        print('⚠️ Missing razorpaySubscriptionId or keyId in response');
        return null;
      }

      _lastRazorpaySubscriptionId = razorpaySubscriptionId;

      print('✅ razorpaySubscriptionId: $razorpaySubscriptionId');
      print('✅ keyId: $keyId');

      return RazorpaySubscriptionInit(
        razorpaySubscriptionId: razorpaySubscriptionId,
        keyId: keyId,
      );
    } catch (e) {
      print('❌ Error creating razorpay subscription: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Payment flow entry point — called by the view's button.
  // ─────────────────────────────────────────────────────────────
  Future<void> handlePayButtonTap() async {
    print('🔘 Pay button tapped. isTrialFree=${isTrialFree()}');
    _paymentEventHandled = false;

    if (isTrialFree()) {
      CustomToast.info('Activating your free trial...');
      final success = await activateFreeTrial();
      print('🆓 activateFreeTrial() result: $success');
      if (success) {
        Get.to(() => const PaymentsuccessView());
      } else {
        CustomToast.error('Could not start your free trial. Please try again.');
      }
    } else {
      await _startPayment();
    }
  }

  Future<void> _startPayment() async {
    CustomToast.info('Opening payment gateway...');

    final init = await createRazorpaySubscription();
    if (init == null) {
      print('❌ _startPayment: createRazorpaySubscription() returned null');
      CustomToast.error('Could not start subscription. Please try again.');
      return;
    }

    String contactNumber = '9876543210';
    try {
      final profileController = Get.find<ProfileServiceController>();
      final savedNumber = profileController.phoneNumber.value;
      if (savedNumber.isNotEmpty) {
        contactNumber = savedNumber;
      }
    } catch (e) {
      print('⚠️ ProfileServiceController not found, using fallback contact: $e');
    }

    final data = getSubscription();

    var options = {
      'key': init.keyId,
      'subscription_id': init.razorpaySubscriptionId,
      'name': 'Dating App Subscription',
      'description': data.planName,
      'prefill': {'contact': contactNumber, 'email': 'user@example.com'},
      'theme': {'color': '#FF6A00'},
    };

    print('========================================');
    print('💰 RAZORPAY SUBSCRIPTION CHECKOUT');
    print('razorpaySubscriptionId: ${init.razorpaySubscriptionId}');
    print('keyId: ${init.keyId}');
    print('contactNumber: $contactNumber');
    print('Full options: $options');
    print('========================================');

    try {
      razorpay.open(options);
      print('✅ razorpay.open() called successfully');
    } catch (e) {
      print('❌ Error opening Razorpay checkout: $e');
      CustomToast.error('Failed to open payment gateway');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_paymentEventHandled) {
      print('⚠️ Duplicate EVENT_PAYMENT_SUCCESS fired — ignoring (guard caught it)');
      return;
    }
    _paymentEventHandled = true;

    print('========================================');
    print('✅ PAYMENT SUCCESS (client-side callback)');
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Subscription ID: ${response.data?['razorpay_subscription_id']}');
    print('Signature: ${response.signature}');
    print('========================================');
    print('ℹ️ This callback ONLY confirms the checkout UI closed successfully.');
    print('ℹ️ Actual DB status update depends on the RAZORPAY WEBHOOK firing.');
    print('ℹ️ Polling GET /v1/api/user-subscription/me now to confirm...');
    print('========================================');

    CustomToast.success('Payment received — confirming subscription...');
    _pollSubscriptionStatusThenNavigate();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('========================================');
    print('❌ PAYMENT ERROR');
    print('Code: ${response.code}');
    print('Message: ${response.message}');
    print('========================================');

    String errorMessage;
    switch (response.code) {
      case -1:
        errorMessage = 'Payment cancelled by user';
        break;
      case -2:
        errorMessage = 'Network connection error';
        break;
      case -3:
        errorMessage = 'Payment failed. Please check your details';
        break;
      default:
        errorMessage = 'Payment failed. Please try again.';
    }
    CustomToast.error(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('🔥 External wallet selected: ${response.walletName}');
    CustomToast.info('Selected wallet: ${response.walletName}');
  }

  // ─────────────────────────────────────────────────────────────
  // 🔥 NEW: polls GET /v1/api/user-subscription/me right after checkout
  // closes, since your backend's status change ONLY happens via the
  // Razorpay webhook (subscription.authenticated etc — see
  // userSubscription.controller.ts razorpayWebhook). This gives you
  // visibility in the terminal into exactly when/if that webhook landed.
  // ─────────────────────────────────────────────────────────────
  Future<void> _pollSubscriptionStatusThenNavigate() async {
    final token = _getAuthToken();
    if (token == null || token.isEmpty) {
      print('⚠️ No auth token — cannot poll /me. Navigating anyway.');
      Get.to(() => const PaymentsuccessView());
      return;
    }

    const maxAttempts = 6; // ~ 6 x 2s = 12s window
    const delayBetween = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('${ApiUrls.baseUrl}/v1/api/user-subscription/me'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print('🔄 [poll #$attempt] GET /user-subscription/me → '
            '${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          final status = body['data']?['status'];
          print('🔄 [poll #$attempt] current status field: $status');

          if (status != null && status != 'created') {
            print('✅ Webhook confirmed! Subscription status is now "$status"');
            CustomToast.success('Subscription confirmed! 🎉');
            Get.to(() => const PaymentsuccessView());
            return;
          }
        }
      } catch (e) {
        print('❌ [poll #$attempt] Error checking subscription status: $e');
      }

      if (attempt < maxAttempts) {
        await Future.delayed(delayBetween);
      }
    }

    // Webhook still hasn't landed after the polling window — this is the
    // exact signal to go check Razorpay Dashboard → Webhooks → Logs.
    print('========================================');
    print('⚠️ TIMED OUT waiting for webhook to update status.');
    print('⚠️ Check Razorpay Dashboard → Webhooks → Logs for delivery');
    print('⚠️ attempts/response codes against ${_lastRazorpaySubscriptionId ?? "(unknown sub id)"}.');
    print('========================================');

    CustomToast.info('Payment received. Confirming subscription — this may take a moment.');
    Get.to(() => const PaymentsuccessView());
  }
}