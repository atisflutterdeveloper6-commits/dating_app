import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/paymentsuccess/views/paymentsuccess_view.dart';
import 'package:dating_app/app/modules/paymentplan/controllers/paymentplan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentplanView extends StatelessWidget {
  const PaymentplanView({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentplanController controller = Get.put(PaymentplanController());

    // Initialize Razorpay
    Razorpay _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

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
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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
                  ? VideoPlayer(controller.videoController.value!)
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

                    const SizedBox(height: 40),

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
                          color: const Color(0xffFF7A00).withOpacity(0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xffFF7A00).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Highlight Badge (if exists) — now with a crown icon
                          if (data.highlightText.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffFFB000),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    data.highlightText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Plan Name
                          Text(
                            data.planName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xffFF7A00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data.afterTrialText.isNotEmpty
                                  ? data.afterTrialText
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

                    // Subtext
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

                    const Spacer(flex: 2),

                    // Pay Button with Razorpay
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xffFF6A00), Color(0xffFF8C00)],
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
  onPressed: () async {
    // 🔧 TEMP: seedha activateFreeTrial() test karne ke liye
   _handlePayButtonTap(controller, _razorpay, data);
    print('🔥 Button tapped — calling activateFreeTrial()');
    final success = await controller.activateFreeTrial();
    print('🔥 TEST RESULT: $success');
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: Text(
    controller.getPayButtonText(),
    style: const TextStyle(
      letterSpacing: 1.8,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    ),
  ),
),
                  
                    ),

                    const SizedBox(height: 16),

                    // Privacy Policy — branded footer, e.g. "...Terms of Service of Vibely"
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                          children: [
                            const TextSpan(text: 'Privacy Policy and Terms of Service of '),
                            TextSpan(
                              text: controller.appName,
                              style: const TextStyle(
                                color: Color(0xffFF9A44),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Decides whether tapping the button should skip straight to a free trial
  // (no Razorpay — it can't charge ₹0) or open the payment gateway.
  void _handlePayButtonTap(
    PaymentplanController controller,
    Razorpay razorpay,
    dynamic data,
  ) async {
    if (controller.isTrialFree()) {
      CustomToast.info('Activating your free trial...');
      final success = await controller.activateFreeTrial();
      if (success) {
        Get.to(() => const PaymentsuccessView());
      } else {
        CustomToast.error('Could not start your free trial. Please try again.');
      }
    } else {
      _startPayment(razorpay, data);
    }
  }

  // Razorpay Payment Methods
void _startPayment(Razorpay razorpay, dynamic data) {
  // Show loading toast
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

  final int amountInPaise = int.parse(data.trialPrice) * 100;

  var options = {
    'key': 'rzp_test_TFlJuP5dNeFUjo',
    'amount': amountInPaise,
    'name': 'Dating App Subscription',
    'description': data.planName,
    'prefill': {
      'contact': contactNumber,
      'email': 'user@example.com'
    },
    'theme': {
      'color': '#FF6A00'
    }
  };

  // 🔥 PRINT RAZORPAY OPTIONS
  print('========================================');
  print('💰 RAZORPAY PAYMENT DETAILS');
  print('========================================');
  print('Trial Price (raw): ${data.trialPrice}');
  print('Amount sent to Razorpay (paise): $amountInPaise');
  print('Amount in ₹: ${amountInPaise / 100}');
  print('Full options: $options');
  print('========================================');

  try {
    razorpay.open(options);
  } catch (e) {
    print("Error: $e");
    CustomToast.error('Failed to open payment gateway');
  }
}
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Success toast
    CustomToast.success('Payment Successful! 🎉');

    // Wait a moment then navigate
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.to(() => const PaymentsuccessView());
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Error toast with specific message
    String errorMessage = 'Payment failed. Please try again.';

    // Handle different error codes
    switch(response.code) {
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
    // External wallet selected
    CustomToast.info('Selected wallet: ${response.walletName}');
  }

  // Helper function to build main title with highlight
  List<TextSpan> _buildMainTitle(String mainTitle) {
    // Split title by newline and highlight
    final parts = mainTitle.split('\n');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i > 0) {
        spans.add(const TextSpan(text: '\n'));
      }

      // Check if this part contains numbers or should be highlighted
      final String part = parts[i];
      if (part.contains('singles') || part.contains('+') ||
          part.contains('matches') || part.contains('people')) {
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

// 🔥 Shimmer Loading Widget
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