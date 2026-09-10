// lib/app/modules/onboarding/views/onboarding_view.dart

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

  final OnboardingController controller =
  Get.put(OnboardingController());

  // ============================================================
  // 1ST CODE KE COLORS
  // ============================================================

  static const Color bgColor = Color(0xFFFFF0E6);
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangeLight = Color(0xFFFFA23A);
  static const Color darkText = Color(0xFF172033);
  static const Color greyText = Color(0xFF85858F);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final size = MediaQuery.of(context).size;

    final bool isLandscape =
        size.width > size.height;

    return Scaffold(
      backgroundColor: bgColor,

      body: Obx(() {
        // ======================================================
        // LOADING
        // ======================================================

        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        // ======================================================
        // ERROR
        // ======================================================

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView();
        }

        // ======================================================
        // NO DATA
        // ======================================================

        if (controller.onboardingData.isEmpty) {
          return const Center(
            child: Text(
              'No data available',
            ),
          );
        }

        // ======================================================
        // MAIN ONBOARDING UI
        // ======================================================

        return Stack(
          children: [
            // ==================================================
            // FULL SCREEN PAGE VIEW
            // ==================================================

            Positioned.fill(
              child: PageView.builder(
                controller: pageController,
                itemCount:
                controller.onboardingData.length,

                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },

                itemBuilder: (
                    context,
                    index,
                    ) {
                  final item =
                  controller.onboardingData[index];

                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,

                    child: Image.network(
                      item.img,

                      width: double.infinity,
                      height: double.infinity,

                      fit: BoxFit.fill,

                      alignment: Alignment.center,

                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return Container(
                          color: bgColor,
                          child: Center(
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined,
                              size: 55.sp,
                              color: orange
                                  .withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // ==================================================
            // LIGHT OVERLAY
            // ==================================================

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,

                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.20),
                      ],

                      stops: const [
                        0.0,
                        0.65,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // SKIP BUTTON
            // ==================================================

            Positioned(
              left: 24.w,

              bottom: isLandscape
                  ? 20.h
                  : 105.h,

              child: GestureDetector(
                onTap: () {
                  _skip();
                },

                child: Container(
                  width: 115.w,

                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 7.h,
                  ),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(35.r),

                    color: Colors.white
                        .withOpacity(0.45),

                    border: Border.all(
                      color: Colors.white
                          .withOpacity(0.35),
                      width: 0.7,
                    ),
                  ),

                  child: Text(
                    "Skip",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: darkText,
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // NEXT BUTTON
            // ==================================================

            Positioned(
              right: 18.w,

              bottom: isLandscape
                  ? 20.h
                  : 105.h,

              child: GestureDetector(
                onTap: () {
                  _nextPage();
                },

                child: Container(
                  width: 115.w,

                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 7.h,
                  ),

                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(35.r),

                    gradient:
                    const LinearGradient(
                      begin:
                      Alignment.topLeft,
                      end:
                      Alignment.bottomRight,

                      colors: [
                        orange,
                        orangeLight,
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: orange
                            .withOpacity(0.30),

                        blurRadius: 12,
                        spreadRadius: 1,

                        offset:
                        const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,

                    mainAxisAlignment:
                    MainAxisAlignment.center,

                    children: [
                      Text(
                        currentIndex ==
                            controller
                                .onboardingData
                                .length -
                                1
                            ? "Next"
                            : "Next",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Icon(
                        currentIndex ==
                            controller
                                .onboardingData
                                .length -
                                1
                            ? Icons
                            .arrow_forward_rounded
                            : Icons
                            .arrow_forward_rounded,

                        color: Colors.white,

                        size: 21.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // DOT INDICATOR
            // ==================================================

            Positioned(
              left: 0,
              right: 0,

              bottom: isLandscape
                  ? 40.h
                  : 190.h,

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: List.generate(
                  controller
                      .onboardingData.length,

                      (dotIndex) {
                    final bool active =
                        currentIndex ==
                            dotIndex;

                    return AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ),

                      curve:
                      Curves.easeInOut,

                      margin:
                      EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),

                      height: 7.h,

                      width: active
                          ? 24.w
                          : 7.w,

                      decoration:
                      BoxDecoration(
                        color: active
                            ? orange
                            : Colors.white
                            .withOpacity(
                          0.90,
                        ),

                        borderRadius:
                        BorderRadius
                            .circular(
                          20.r,
                        ),

                        boxShadow: active
                            ? [
                          BoxShadow(
                            color: orange
                                .withOpacity(
                              0.30,
                            ),
                            blurRadius: 5,
                          ),
                        ]
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  void _nextPage() {
    if (currentIndex <
        controller.onboardingData.length - 1) {
      pageController.nextPage(
        duration:
        const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.off(
            () => const LoginView(),
      );
    }
  }

  // ============================================================
  // SKIP
  // ============================================================

  void _skip() {
    Get.off(
          () => const LoginView(),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildErrorView() {
    return Container(
      width: double.infinity,
      height: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,

          colors: [
            Color(0xFFFFF7F2),
            Color(0xFFFFEDE3),
          ],
        ),
      ),

      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            // ERROR ICON

            Container(
              width: 75.w,
              height: 75.w,

              decoration: BoxDecoration(
                color: orange
                    .withOpacity(0.10),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons
                    .wifi_off_rounded,
                size: 38.sp,
                color: orange,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              "Something went wrong",
              style: TextStyle(
                color: darkText,
                fontSize: 17.sp,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            SizedBox(height: 8.h),

            Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 35.w,
              ),

              child: Text(
                "Please check your internet connection.",
                textAlign:
                TextAlign.center,

                style: TextStyle(
                  color: greyText,
                  fontSize: 12.sp,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 22.h),

            // RETRY BUTTON

            GestureDetector(
              onTap: controller.retry,

              child: Container(
                width: 120.w,

                padding:
                EdgeInsets.symmetric(
                  vertical: 10.h,
                ),

                decoration:
                BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      orange,
                      orangeLight,
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    30.r,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: orange
                          .withOpacity(
                        0.25,
                      ),
                      blurRadius: 10,
                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Center(
                  child: Text(
                    "Retry",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHIMMER LOADING
  // ============================================================

  Widget _buildShimmerLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,

      color: bgColor,

      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,

        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(0),
          ),
        ),
      ),
    );
  }
}