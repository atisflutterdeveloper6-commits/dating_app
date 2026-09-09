// lib/app/modules/loginconfirmation/views/loginconfirmation_view.dart

import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/primiumplan/views/primiumplan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/loginconfirmation_controller.dart';

class LoginconfirmationView extends GetView<LoginconfirmationController> {
  final String phoneNumber;

  const LoginconfirmationView({
    super.key,
    required this.phoneNumber,
  });

  // ============================================================
  // COLORS - 1ST UI KE SAME COLORS
  // ============================================================

  static const Color bgColor = Color(0xFFFFF0E6);
  static const Color orange = Color(0xFFFF6B00);
  static const Color orangeLight = Color(0xFFFFA23A);
  static const Color darkText = Color(0xFF172033);
  static const Color greyText = Color(0xFF85858F);

  TextStyle poppins({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = darkText,
  }) {
    return GoogleFonts.poppins(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // ============================================================
    // CONTROLLER - SAME AS 1ST CODE
    // ============================================================

    final LoginconfirmationController loginconfirmationController =
    Get.put(
      LoginconfirmationController(
        phoneNumber: phoneNumber,
      ),
    );

    // ============================================================
    // STORAGE
    // ============================================================

    final StorageService storage = StorageService();

    // ============================================================
    // LOCATION CONTROLLER
    // ============================================================

    final LocationController locationController =
    Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation(
        locationController,
        storage,
      );
    });

    // ============================================================
    // SCREEN SIZE
    // ============================================================

    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;

    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    final bool isKeyboardOpen = keyboardHeight > 0;

    final double topSectionHeight = isKeyboardOpen
        ? screenHeight * 0.34
        : screenHeight * 0.43;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/LoginBack2.png',
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF0E6),
                        Color(0xFFFFF8F3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // SOFT ORANGE OVERLAY
          // ======================================================

          Positioned.fill(
            child: Container(
              color: bgColor.withOpacity(0.10),
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // ==================================================
                        // TOP SECTION
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: topSectionHeight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // ==================================================
                                // LEFT CONTENT
                                // ==================================================

                                Expanded(
                                  flex: 50,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 8.w,
                                      top: isKeyboardOpen
                                          ? screenHeight * 0.025
                                          : screenHeight * 0.060,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        // TITLE
                                        SizedBox(height: 80.h,),

                                        Text(
                                          "Welcome back",
                                          style: poppins(
                                            size: 20,
                                            weight: FontWeight.w700,
                                          ),
                                        ),

                                        SizedBox(height: 2.h),

                                        // ORANGE TITLE

                                        Row(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Text(
                                              "to Dating",
                                              style: poppins(
                                                size: 20,
                                                weight:
                                                FontWeight.w700,
                                                color: orange,
                                              ),
                                            ),

                                            SizedBox(width: 6.w),

                                            Icon(
                                              Icons.favorite_rounded,
                                              color: orange,
                                              size: 19.sp,
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8.h),

                                        // DESCRIPTION

                                        Text(
                                          "You are securely logged in\n"
                                              "with your mobile number.",
                                          style: poppins(
                                            size: 8.5,
                                            color: greyText,
                                          ).copyWith(
                                            height: 1.45,
                                          ),
                                        ),

                                        SizedBox(height: 12.h),

                                        // ==================================================
                                        // PHONE NUMBER
                                        // ==================================================


                                      ],
                                    ),
                                  ),
                                ),

                                // ==================================================
                                // RIGHT IMAGE
                                // ==================================================

                                Expanded(
                                  flex: 50,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: isKeyboardOpen
                                          ? screenHeight * 0.025
                                          : screenHeight * 0.017,
                                    ),
                                    child: Image.asset(
                                      'assets/images/loginback.png',
                                      height: isKeyboardOpen
                                          ? screenHeight * 0.30
                                          : screenHeight * 0.40,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      alignment:
                                      Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ==================================================
                        // SMALL GAP
                        // ==================================================

                        SizedBox(
                          height:
                          isKeyboardOpen ? 8.h : 5.h,
                        ),

                        // ==================================================
                        // WHITE CARD
                        // ==================================================

                        Transform.translate(
                          offset: Offset(0, -12.h),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                14.w,
                                20.h,
                                14.w,
                                18.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(20.r),
                                border: Border.all(
                                  color:
                                  Colors.grey.shade300,
                                  width: 0.7,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    orange.withOpacity(0.10),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                    offset:
                                    const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  // ==================================================
                                  // TOP CARD ROW
                                  // ==================================================

                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      // ==================================================
                                      // LOGO
                                      // ==================================================

                                      Container(
                                        width: 53.w,
                                        height: 53.w,
                                        decoration:
                                        BoxDecoration(
                                          color: const Color(
                                            0xFFFFF0E6,
                                          ),
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            14.r,
                                          ),
                                        ),
                                        alignment:
                                        Alignment.center,
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            12.r,
                                          ),
                                          child: Image.asset(
                                            'assets/icons/app_icon.jpeg',
                                            width: 48.w,
                                            height: 48.w,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 14.w),

                                      // ==================================================
                                      // LOGIN TEXT
                                      // ==================================================

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              'Login to Dating',
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                              style: poppins(
                                                size: 12,
                                                weight:
                                                FontWeight.w600,
                                                color:
                                                darkText,
                                              ).copyWith(
                                                height: 1.25,
                                              ),
                                            ),

                                            SizedBox(height: 5.h),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .phone_android_rounded,
                                                  size: 15.sp,
                                                  color: orange,
                                                ),

                                                SizedBox(
                                                    width: 3.w),

                                                Flexible(
                                                  child: Text(
                                                    phoneNumber,
                                                    maxLines: 1,
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                    style: poppins(
                                                      size: 11,
                                                      weight:
                                                      FontWeight
                                                          .w400,
                                                      color:
                                                      const Color(
                                                        0xFF4B4B4B,
                                                      ),
                                                    ).copyWith(
                                                      height: 1.2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.h),

                                  // ==================================================
                                  // CONTINUE BUTTON
                                  // ==================================================

                                  SizedBox(
                                    width: double.infinity,
                                    height: 40.h,
                                    child: Container(
                                      decoration:
                                      BoxDecoration(
                                        gradient:
                                        const LinearGradient(
                                          begin: Alignment
                                              .centerLeft,
                                          end: Alignment
                                              .centerRight,
                                          colors: [
                                            orange,
                                            orange,
                                            orangeLight,
                                          ],
                                          stops: [
                                            0.0,
                                            0.72,
                                            1.0,
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
                                                0.20),
                                            blurRadius: 12,
                                            offset:
                                            const Offset(
                                              0,
                                              5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _handleContinue(
                                            storage,
                                          );
                                        },
                                        style: ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          Colors.transparent,
                                          foregroundColor:
                                          Colors.white,
                                          disabledBackgroundColor:
                                          Colors.transparent,
                                          shadowColor:
                                          Colors.transparent,
                                          elevation: 0,
                                          padding:
                                          EdgeInsets.zero,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              30.r,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .arrow_forward_rounded,
                                              color:
                                              Colors.white,
                                              size: 18.sp,
                                            ),

                                            SizedBox(
                                                width: 10.w),

                                            Container(
                                              height: 20.h,
                                              width: 0.7.w,
                                              color: Colors
                                                  .white
                                                  .withOpacity(
                                                0.45,
                                              ),
                                            ),

                                            SizedBox(
                                                width: 11.w),

                                            Text(
                                              "Continue",
                                              style: poppins(
                                                size: 12,
                                                weight:
                                                FontWeight.w700,
                                                color:
                                                Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 13.h),

                                  // ==================================================
                                  // DIVIDER
                                  // ==================================================

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: const Color(
                                            0xFFE4E4E7,
                                          ),
                                          thickness: 1,
                                        ),
                                      ),

                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                        ),
                                        child: Text(
                                          "or continue with",
                                          style: poppins(
                                            size: 9.5,
                                            color:
                                            greyText,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Divider(
                                          color: const Color(
                                            0xFFE4E4E7,
                                          ),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // ==================================================
                                  // CHANGE NUMBER
                                  // ==================================================

                                  GestureDetector(
                                    onTap: () {
                                      loginconfirmationController
                                          .onChangeNumberTap();
                                    },
                                    child: SizedBox(
                                      width:
                                      double.infinity,
                                      height: 20.h,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Icon(
                                            Icons
                                                .phone_android_rounded,
                                            size: 17.sp,
                                            color: orange,
                                          ),

                                          SizedBox(
                                              width: 9.w),

                                          Text(
                                            'Use Another Mobile Number',
                                            style: poppins(
                                              size: 11,
                                              weight:
                                              FontWeight
                                                  .w600,
                                              color: orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 13.h),

                                  // ==================================================
                                  // SECURITY / PRIVACY BOX
                                  // ==================================================

                                  Container(
                                    width: double.infinity,
                                    padding:
                                    EdgeInsets.fromLTRB(
                                      10.w,
                                      10.h,
                                      10.w,
                                      15.h,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color: const Color(
                                        0xFFFFF7F2,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(
                                        5.r,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center,
                                      children: [
                                        Container(
                                          width: 36.w,
                                          height: 36.w,
                                          decoration:
                                          BoxDecoration(
                                            color: Colors.white,
                                            shape:
                                            BoxShape.circle,
                                            border:
                                            Border.all(
                                              color: orange
                                                  .withOpacity(
                                                0.20,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .verified_user_outlined,
                                            size: 18.sp,
                                            color: orange,
                                          ),
                                        ),

                                        SizedBox(width: 9.w),

                                        Expanded(
                                          child: RichText(
                                            textAlign:
                                            TextAlign.left,
                                            text:
                                            TextSpan(
                                              style:
                                              GoogleFonts
                                                  .poppins(
                                                fontSize:
                                                6.sp,
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                                color:
                                                const Color(
                                                  0xFF686868,
                                                ),
                                                height:
                                                1.45,
                                              ),
                                              children: [
                                                const TextSpan(
                                                  text:
                                                  'By continuing you accept to share your Truecaller ',
                                                ),

                                                TextSpan(
                                                  text:
                                                  'profile information',
                                                  style:
                                                  GoogleFonts
                                                      .poppins(
                                                    fontSize:
                                                    8.sp,
                                                    color:
                                                    orange,
                                                    decoration:
                                                    TextDecoration
                                                        .underline,
                                                  ),
                                                ),

                                                const TextSpan(
                                                  text:
                                                  ' with Dating, and agree to the ',
                                                ),

                                                TextSpan(
                                                  text:
                                                  'privacy policy',
                                                  style:
                                                  GoogleFonts
                                                      .poppins(
                                                    fontSize:
                                                    8.sp,
                                                    color:
                                                    orange,
                                                    decoration:
                                                    TextDecoration
                                                        .underline,
                                                  ),
                                                ),

                                                const TextSpan(
                                                  text:
                                                  ' and ',
                                                ),

                                                TextSpan(
                                                  text:
                                                  'terms of service',
                                                  style:
                                                  GoogleFonts
                                                      .poppins(
                                                    fontSize:
                                                    8.sp,
                                                    color:
                                                    orange,
                                                    decoration:
                                                    TextDecoration
                                                        .underline,
                                                  ),
                                                ),

                                                const TextSpan(
                                                  text:
                                                  ' of Dating',
                                                ),
                                              ],
                                            ),
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

                        SizedBox(height: 8.h),

                        // ==================================================
                        // BOTTOM SECURITY TEXT
                        // ==================================================

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25.w,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 14.sp,
                                color: orange,
                              ),

                              SizedBox(width: 5.w),

                              Flexible(
                                child: Text(
                                  "Your number is safe with us. "
                                      "We never share it with anyone.",
                                  textAlign:
                                  TextAlign.center,
                                  style: poppins(
                                    size: 8,
                                    color: Colors.black,
                                  ).copyWith(
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ============================================================
          // BACK BUTTON
          // ============================================================

          Positioned(
            top: 55.h,
            left: 25.w,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                  width: 31.w,
                  height: 31.w,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14.sp,
                    color: darkText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FETCH LOCATION - SAME AS 1ST CODE
  // ============================================================

  Future<void> _fetchLocation(
      LocationController locationController,
      StorageService storage,
      ) async {
    try {
      print(
        '📍 LoginConfirmation: Fetching location...',
      );

      bool success =
      await locationController.getCurrentLocation();

      if (success) {
        String location =
        locationController.getLocationString();

        print(
          '✅ LoginConfirmation: Location fetched: $location',
        );

        await storage.saveData(
          'user_location',
          location,
        );

        try {
          final profileController =
          Get.find<ProfileServiceController>();

          profileController.updateLocation(location);

          print(
            '✅ Location saved to profile controller: $location',
          );
        } catch (e) {
          print(
            '⚠️ Profile controller not found yet',
          );
        }
      } else {
        print(
          '❌ LoginConfirmation: Location fetch failed: '
              '${locationController.errorMessage.value}',
        );
      }
    } catch (e) {
      print(
        '❌ LoginConfirmation: Location error: $e',
      );
    }
  }

  // ============================================================
  // CONTINUE - SAME AS 1ST CODE
  // ============================================================

  void _handleContinue(
      StorageService storage,
      ) {
    final isProfileCreated =
    storage.isProfileCreated();

    final isLoggedIn =
    storage.isLoggedIn();

    final hasToken =
    storage.hasLoginToken();

    print(
      '🔍 Login Confirmation Status:',
    );

    print(
      '  Is Logged In: $isLoggedIn',
    );

    print(
      '  Has Token: $hasToken',
    );

    print(
      '  Is Profile Created: $isProfileCreated',
    );

    print(
      '🟡 Navigating to Premium Plan',
    );

    Get.to(
          () => const PrimiumplanView(),
    );
  }
}