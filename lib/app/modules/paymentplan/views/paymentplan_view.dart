import 'dart:ui';

import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/paymentsuccess/views/paymentsuccess_view.dart';
import 'package:dating_app/app/modules/paymentplan/controllers/paymentplan_controller.dart';
import 'package:dating_app/app/modules/privacypolicy/views/privacypolicy_view.dart';
import 'package:dating_app/app/modules/profilesetup/views/profilesetup_view.dart';
import 'package:dating_app/app/modules/termsandconditions/views/termsandconditions_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:shimmer/shimmer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentplanView extends StatefulWidget {
  const PaymentplanView({super.key});

  @override
  State<PaymentplanView> createState() => _PaymentplanViewState();
}

class _PaymentplanViewState extends State<PaymentplanView> {
  late final PaymentplanController controller;
  late final Razorpay razorpay;

  @override
  void initState() {
    super.initState();

    controller = Get.put(PaymentplanController());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final locationController = LocationController.to;
    if (!locationController.locationFetched.value) {
      locationController.getCurrentLocation();
    }
  });
    // ✅ Razorpay ab StatefulWidget ki lifecycle ke sath ek hi baar banta hai
    razorpay = Razorpay();
    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    // ✅ Listeners clear karna zaroori hai warna dispose hone ke baad
    // bhi native callback fire ho sakta hai aur crash de sakta hai
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Loading State with Shimmer
        if (controller.isLoading.value) {
          return const PaymentplanShimmer();
        }

        // Error State
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.retryLoading(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF6A00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Main Content
        final data = controller.getSubscription();

        return Stack(
          children: [
            // Background Video
            Positioned.fill(
              child: controller.isVideoAvailable()
                  ? Video(
                      controller: controller.videoController!,
                      controls: NoVideoControls, // koi default controls na dikhein
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/bg.jpg",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
            ),

            // Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFC55007).withOpacity(0.65),
                      Colors.black.withOpacity(0.50),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Dynamic Main Tagline

        ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
        filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
        ),
        child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
        ),
        decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
        color: Colors.white.withOpacity(0.18),
        width: 1,
        ),
        ),
        child: Column(
        children: [
        // Dynamic Main Tagline
        RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
        style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.5,
        ),
        children: _buildMainTitle(data.mainTitle),
        ),
        ),

        // Highlight + Location
        if (data.highlightText.isNotEmpty) ...[
        const SizedBox(height: 12),

        Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        const SizedBox(width: 6),
        Text(
        data.highlightText,
        style: const TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: 1.0,
        ),
        ),
        ],
        ),

        const SizedBox(height: 12),

        // Location Row
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const SizedBox(width: 6),

        const Text(
        "In ",
        style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        ),
        ),

        Obx(() {
        final locationController =
        LocationController.to;

        if (locationController.isLoading.value) {
        return const SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xffFF9A44),
        ),
        );
        }

        if (locationController
            .currentLocation
            .value
            .isNotEmpty) {
        return Flexible(
        child: Text(
        locationController
            .currentLocation
            .value,
        style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
        ),
        );
        }

        return TextButton(
        onPressed: () async {
        await locationController
            .getCurrentLocation();
        },
        style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize:
        MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
        'Tap to get location',
        style: TextStyle(
        color: Color(0xffFF9A44),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        decoration:
        TextDecoration.underline,
        decorationColor:
        Color(0xffFF9A44),
        ),
        ),
        );
        }),
        ],
        ),
        ),

        const SizedBox(height: 20),
        ],

        // Dynamic Plan Card
        Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
        ),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
        const Color(0xff8B4A21).withOpacity(0.92),
        const Color(0xff6A3718).withOpacity(0.95),
        ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
        color:
        const Color(0xffFF7A00).withOpacity(0.6),
        width: 1.5,
        ),
        boxShadow: [
        BoxShadow(
        color:
        const Color(0xffFF7A00).withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
        ),
        ],
        ),
        child: Column(
        children: [
        if (data.highlightText.isNotEmpty) ...[
        Container(
        padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
        ),
        decoration: BoxDecoration(
        color: const Color(0xffFFB000),
        borderRadius:
        BorderRadius.circular(20),
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        const Icon(
        Icons.workspace_premium,
        color: Colors.white,
        size: 28,
        ),
        ],
        ),
        ),
        const SizedBox(height: 12),
        ],

        const SizedBox(height: 16),

        // Trial Price
        RichText(
        text: TextSpan(
        style: const TextStyle(
        letterSpacing: 0.8,
        ),
        children: [
        TextSpan(
        text: data.trialText,
        style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        ),
        ),
        TextSpan(
        text: controller.isTrialFree()
        ? ' '
            : ' ₹${data.trialPrice}',
        style: const TextStyle(
        color: Color(0xffFFB000),
        fontWeight: FontWeight.w800,
        fontSize: 22,
        ),
        ),
        ],
        ),
        ),

        const SizedBox(height: 20),

        const Divider(
        color: Colors.white24,
        thickness: 1,
        height: 1,
        ),

        const SizedBox(height: 14),

        // Price After Trial
        Container(
        padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
        ),
        decoration: BoxDecoration(
        color:
        const Color(0xffFF7A00).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
        data.afterTrialText.isNotEmpty
        ? '₹${data.afterTrialText}'
            : '₹${data.priceAfterTrial} AFTER TRIAL',
        style: const TextStyle(
        letterSpacing: 1.5,
        color: Color(0xffFF9A44),
        fontSize: 16,
        fontWeight: FontWeight.w700,
        ),
        ),
        ),
        ],
        ),
        ),

        const SizedBox(height: 20),

        // Cancel Anytime
        const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Icon(
        Icons.check_circle_outline,
        color: Color(0xffFF9A44),
        size: 16,
        ),
        SizedBox(width: 8),
        Text(
        "Cancel Anytime · No Hidden Charges",
        style: TextStyle(
        fontSize: 13,
        letterSpacing: 0.6,
        color: Colors.white70,
        ),
        ),
        ],
        ),
        ],
        ),
        ),
        ),
        ),

                    const Spacer(flex: 2),

                    // Pay Button with Razorpay
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffFF6A00),
                            Color(0xffFF8C00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffFF6A00).withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isPaymentInProgress.value
                            ? null
                            : () {
                          Get.to(() => const ProfilesetupView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: controller.isPaymentInProgress.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),

                            const SizedBox(width: 10),

                            Container(
                              width: 1,
                              height: 22,
                              color: Colors.white.withOpacity(0.45),
                            ),

                            const SizedBox(width: 10),

                            Text(
                              controller.getPayButtonText(),
                              style: const TextStyle(
                                letterSpacing: 1.8,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Privacy Policy — branded footer
                 // Privacy Policy and Terms & Conditions - Separate Clickable TextButtons
// Privacy Policy, Terms & Conditions with App Name
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
      onPressed: () {
        Get.to(PrivacypolicyView());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        splashFactory: NoSplash.splashFactory,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Privacy Policy',
        style: TextStyle(
          letterSpacing: 0.5,
          fontSize: 12,
          color:  Colors.white,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xffFF9A44),
        ),
      ),
    ),
    const Text(
      ' And ',
      style: TextStyle(
        letterSpacing: 0.5,
        fontSize: 12,
        color: Colors.white54,
      ),
    ),
    TextButton(
      onPressed: () {
        Get.to(TermsandconditionsView());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        splashFactory: NoSplash.splashFactory,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Terms & Conditions',
        style: TextStyle(
          letterSpacing: 0.5,
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xffFF9A44),
        ),
      ),
    ),
    const Text(
      ' of ',
      style: TextStyle(
        letterSpacing: 0.5,
        fontSize: 12,
        color: Colors.white54,
      ),
    ),
    Text(
      data.appName,
      style: const TextStyle(
        letterSpacing: 0.5,
        fontSize: 12,
        color: Color(0xffFF9A44),
        fontWeight: FontWeight.w700,
      ),
    ),
  ],
),             
                
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Decides the flow after the button is tapped
  void _handlePayButtonTap(dynamic data) async {
    if (controller.isPaymentInProgress.value) return; // ✅ guard against double tap
    controller.isPaymentInProgress.value = true;

    try {
      CustomToast.info('Preparing your subscription...');

      final created = await controller.createSubscription();
      if (!created) {
        CustomToast.error('Could not start subscription. Please try again.');
        return;
      }

      // Check if subscription is actually ACTIVE before navigating
      if (controller.isSubscriptionActive()) {
        // ✅ Already authenticated/active — Razorpay open nahi hoga
        if (mounted) Get.offAll(() => const ProfilesetupView());
        return;
      }

      // Even if isExistingSubscription is true, if it's not active,
      // we should still show Razorpay for payment
      if (controller.isTrialFree()) {
        // ₹0 trial — no Razorpay charge needed, subscription already active.
        CustomToast.success('Trial activated! 🎉');
        if (mounted) Get.to(() => const PaymentsuccessView());
      } else {
        if (controller.pendingRazorpayKeyId == null ||
            controller.pendingRazorpayKeyId!.isEmpty) {
          CustomToast.error(
              'Payment configuration error. Please contact support.');
          return;
        }

        _startPayment(
          data,
          controller.pendingRazorpaySubscriptionId!,
          controller.pendingRazorpayKeyId!,
        );
      }
    } catch (e) {
      print('Error in _handlePayButtonTap: $e');
      CustomToast.error('Something went wrong. Please try again.');
    } finally {
      // Note: agar Razorpay checkout khul gaya hai to isPaymentInProgress
      // ko yahin false mat karo — checkout callback (success/error) mein karo.
      if (!_razorpayCheckoutOpened) {
        controller.isPaymentInProgress.value = false;
      }
    }
  }

  bool _razorpayCheckoutOpened = false;

  // Opens Razorpay checkout for a Razorpay Subscription
  void _startPayment(
    dynamic data,
    String subscriptionId,
    String keyId,
  ) {
    CustomToast.info('Opening payment gateway...');

    String contactNumber = '9876543210';
    try {
      final profileController = Get.find<ProfileServiceController>();
      final savedNumber = profileController.phoneNumber.value;
      if (savedNumber.isNotEmpty) {
        contactNumber = savedNumber;
      }
    } catch (e) {
      print('ProfileServiceController not found, using fallback contact: $e');
    }

    // Debug-only: what the trial price / paise amount would be
    // ✅ safe parse — malformed price se crash nahi hoga
    final int amountInPaise = (int.tryParse(data.trialPrice) ?? 0) * 100;
    print('========================================');
    print('💰 RAZORPAY SUBSCRIPTION CHECKOUT');
    print('Trial Price (raw): ${data.trialPrice}');
    print('Amount in paise (for reference only, NOT sent): $amountInPaise');
    print('Amount in ₹: ${amountInPaise / 100}');
    print('Subscription ID: $subscriptionId');
    print('Key ID (from backend): $keyId');
    print('========================================');

    var options = {
      'key': keyId,
      'subscription_id': subscriptionId,
      'name': 'Dating App Subscription',
      'description': data.planName,
      'prefill': {
        'contact': contactNumber,
        'email': 'user@example.com',
      },
      'theme': {
        'color': '#FF6A00',
      },
    };

    print('Full options: $options');
    print('========================================');

    try {
      _razorpayCheckoutOpened = true;
      razorpay.open(options);
    } catch (e) {
      print("Error: $e");
      _razorpayCheckoutOpened = false;
      controller.isPaymentInProgress.value = false;
      CustomToast.error('Failed to open payment gateway');
    }
  }

  // Called by Razorpay after a successful checkout
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('========================================');
    print('✅ RAZORPAY SUCCESS CALLBACK');
    print('Payment ID: ${response.paymentId}');
    print('Subscription ID: ${controller.pendingRazorpaySubscriptionId}');
    print('Signature: ${response.signature}');
    print('========================================');

    _razorpayCheckoutOpened = false;

    // ✅ Widget/controller disposed ho chuka ho to aage kuch mat karo
    if (!mounted || !Get.isRegistered<PaymentplanController>()) return;

    CustomToast.info('Verifying your payment...');

    try {
      final verified = await controller.verifyPayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        razorpaySubscriptionId: controller.pendingRazorpaySubscriptionId,
      );

      if (!mounted) return;

      if (verified) {
        CustomToast.success('Payment Successful! 🎉');
        Get.to(() => const PaymentsuccessView());
      } else {
        CustomToast.error('Payment verification failed. Please contact support.');
      }
    } catch (e) {
      print('Error verifying payment: $e');
      if (mounted) {
        CustomToast.error('Payment verification failed. Please contact support.');
      }
    } finally {
      if (Get.isRegistered<PaymentplanController>()) {
        controller.isPaymentInProgress.value = false;
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('========================================');
    print('❌ RAZORPAY PAYMENT ERROR');
    print('Code: ${response.code}');
    print('Message: ${response.message}');
    print('Error (raw): ${response.error}');
    print('========================================');

    _razorpayCheckoutOpened = false;
    if (Get.isRegistered<PaymentplanController>()) {
      controller.isPaymentInProgress.value = false;
    }

    String errorMessage = 'Payment failed. Please try again.';

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
    CustomToast.info('Selected wallet: ${response.walletName}');
  }

  // Helper function to build main title with highlight
  List<TextSpan> _buildMainTitle(String mainTitle) {
    final parts = mainTitle.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i > 0) {
        spans.add(const TextSpan(text: '\n'));
      }

      final String part = parts[i];
      if (part.contains('singles') ||
          part.contains('+') ||
          part.contains('matches') ||
          part.contains('people')) {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 1.2,
              color: Color(0xffFF9A44),
            ),
          ),
        );
      } else if (part.toLowerCase().contains('location')) {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: part));
      }
    }

    return spans;
  }
}

// Shimmer Loading Widget
class PaymentplanShimmer extends StatelessWidget {
  const PaymentplanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFC55007).withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Shimmer Title
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 30,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Shimmer Plan Card
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Shimmer Subtext
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Shimmer Button
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Shimmer Privacy Policy
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}