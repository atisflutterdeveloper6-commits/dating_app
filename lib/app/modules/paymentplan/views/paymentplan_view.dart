import 'package:dating_app/app/modules/paymentplan/controllers/paymentplan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

class PaymentplanView extends StatelessWidget {
  const PaymentplanView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Razorpay is no longer created here — it lives in the controller's
    // onInit()/onClose(), so build() reruns don't spawn new instances.
    final PaymentplanController controller = Get.put(PaymentplanController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const PaymentplanShimmer();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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

        final data = controller.getSubscription();

        return Stack(
          children: [
            Positioned.fill(
              child: controller.isVideoAvailable()
                  ? VideoPlayer(controller.videoController.value!)
                  : Image.asset(
                      "assets/images/bg.jpg",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
            ),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                          if (data.highlightText.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xffFFB000),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium, color: Colors.white, size: 14),
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
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(letterSpacing: 0.8),
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
                                  text: controller.isTrialFree() ? ' ' : ' ₹${data.trialPrice}',
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
                          const Divider(color: Colors.white24, thickness: 1, height: 1),
                          const SizedBox(height: 14),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Color(0xffFF9A44), size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Cancel Anytime · No Hidden Charges",
                          style: TextStyle(fontSize: 13, letterSpacing: 0.6, color: Colors.white70),
                        ),
                      ],
                    ),
                    const Spacer(flex: 2),

                    // 🔥 Pay button now just calls the controller — no
                    // Razorpay wiring here at all.
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
                        onPressed: () => controller.handlePayButtonTap(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(letterSpacing: 0.5, fontSize: 12, color: Colors.white54),
                          children: [
                            const TextSpan(text: 'Privacy Policy and Terms of Service of '),
                            TextSpan(
                              text: controller.appName,
                              style: const TextStyle(color: Color(0xffFF9A44), fontWeight: FontWeight.w700),
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
            style: const TextStyle(fontSize: 28, letterSpacing: 1.2, color: Color(0xffFF9A44)),
          ),
        );
      } else if (part.toLowerCase().contains('location')) {
        spans.add(
          TextSpan(
            text: part,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white70),
          ),
        );
      } else {
        spans.add(TextSpan(text: part));
      }
    }

    return spans;
  }
}

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
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Column(
                  children: [
                    Container(
                      height: 30,
                      width: 200,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 30,
                      width: 250,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: 180,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                ),
              ),
              const SizedBox(height: 20),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const Spacer(flex: 2),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 16),
              Shimmer.fromColors(
                baseColor: Colors.grey[400]!,
                highlightColor: Colors.grey[200]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
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