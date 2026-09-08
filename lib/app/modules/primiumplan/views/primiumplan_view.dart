import 'dart:ui';

import 'package:dating_app/app/modules/paymentplan/views/paymentplan_view.dart';
import 'package:dating_app/app/modules/primiumplan/controllers/primiumplan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:shimmer/shimmer.dart';

class PrimiumplanView extends StatelessWidget {
  const PrimiumplanView({super.key});

  @override
  Widget build(BuildContext context) {
    final PrimiumplanController controller = Get.put(PrimiumplanController());

    return Scaffold(
      body: Obx(() {
        // 🔥 Loading State with Shimmer
        if (controller.isLoading.value) {
          return const PrimiumplanShimmer();
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
        return Stack(
          children: [
            // Background Video
       // Background Video
Positioned.fill(
  child: controller.isVideoAvailable()
      ? Video(
          controller: controller.videoController!,
          controls: NoVideoControls,
          fit: BoxFit.cover,
        )
      : Image.asset(
          "assets/images/bg.jpg",
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
),
            // Dark Overlay
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
                    stops: const [0.2, 1.0],
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

                    // Dynamic Title
                    Text(
                      controller.getTitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Dynamic Features
                    ...controller.getFeatures().map((feature) {
                      return FeatureTile(
                        icon: feature['icon'],
                        title: feature['title'],
                        subtitle: feature['subtitle'],
                      );
                    }).toList(),

                    const Spacer(flex: 2),

                    // Continue Button

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
        onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => const PaymentplanView(),
        ),
        );
        },
        style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        ),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Shield Icon
        const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 18,
        ),

        const SizedBox(width: 10),

        // Divider
        Container(
        height: 20,
        width: 0.7,
        color: Colors.white.withOpacity(0.45),
        ),

        const SizedBox(width: 10),

        // Text
        const Text(
        "Continue",
        style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.2,
        ),
        ),
        ],
        ),
        ),
        ),


        const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// 🔥 Shimmer Loading Widget
class PrimiumplanShimmer extends StatelessWidget {
  const PrimiumplanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFC55007).withOpacity(0.4),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 🔥 Shimmer Title
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: [
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
                        height: 30,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 Shimmer Features (5 items)
                ...List.generate(5, (index) {
                  return const ShimmerFeatureTile();
                }),

                const Spacer(flex: 2),

                // 🔥 Shimmer Button
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔥 Shimmer Feature Tile
class ShimmerFeatureTile extends StatelessWidget {
  const ShimmerFeatureTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer Icon Circle
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Shimmer Text Lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Feature Tile Widget (Same as before)

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xffFF9A44),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
