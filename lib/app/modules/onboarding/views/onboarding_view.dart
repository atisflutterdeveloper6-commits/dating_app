// lib/app/modules/onboarding/views/onboarding_view.dart

import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/login/views/login_view.dart';
import 'package:dating_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffFFF7F7),
      body: SafeArea(
        child: Obx(() {
          // Loading state - Show Shimmer only in image section
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

          // Error state
        if (controller.errorMessage.value.isNotEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Please check your internet connection.",
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: controller.retry,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF6338),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

          // Data loaded successfully
          if (controller.onboardingData.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          return PageView.builder(
            controller: pageController,
            itemCount: controller.onboardingData.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (_, index) {
              final item = controller.onboardingData[index];
              return Column(
                children: [
                  const SizedBox(height: 20),

                  // Image Section - with shimmer while loading
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Image.network(
                        item.img,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Show shimmer only for image while loading
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // White Bottom Container - Shows actual text/content
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          children: [
                            SizedBox(height: 30.h),

                            // Title
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: const Color(0xff222222),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Subtitle
                            Text(
                              item.subTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                height: 1.6,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Dots Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                controller.onboardingData.length,
                                (dot) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  width: currentIndex == dot ? 18.w : 7.w,
                                  height: 7.h,
                                  decoration: BoxDecoration(
                                    color: currentIndex == dot
                                        ? Colors.deepOrange
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),
                            SizedBox(height: 15.h),

                            // Button
                            CustomButton(
                              text: currentIndex == controller.onboardingData.length - 1
                                  ? "Get Started"
                                  : "Next",
                              onPressed: () {
                                if (currentIndex < controller.onboardingData.length - 1) {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                  );
                                } else {
                                  Get.off(() => const LoginView());
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  // Shimmer loading - only image section has shimmer, bottom container shows actual text
  Widget _buildShimmerLoading() {
    // Get dummy data for shimmer loading state
    final dummyData = controller.onboardingData.isNotEmpty 
        ? controller.onboardingData[0] 
        : null;

    return Column(
      children: [
        const SizedBox(height: 20),
        
        // Image Section - Shimmer Effect
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ),
        
        // Bottom Container - Shows actual text or placeholders (without shimmer)
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  
                  // Title - Show actual or placeholder
                  Text(
                    dummyData?.title ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: const Color(0xff222222),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Subtitle - Show actual or placeholder
                  Text(
                    dummyData?.subTitle ?? 'Please wait while we load content...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Dots Indicator - Static while loading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3, // Default 3 dots
                      (dot) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: dot == 0 ? 18.w : 7.w,
                        height: 7.h,
                        decoration: BoxDecoration(
                          color: dot == 0 ? Colors.deepOrange : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  SizedBox(height: 15.h),
                  
                  // Button - Show static button
                  Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffFF6338),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}