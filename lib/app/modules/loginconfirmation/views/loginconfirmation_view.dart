// lib/app/modules/loginconfirmation/views/loginconfirmation_view.dart

import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/location_controller.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/primiumplan/views/primiumplan_view.dart';
import 'package:dating_app/app/modules/dashboard/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/loginconfirmation_controller.dart';

class LoginconfirmationView extends GetView<LoginconfirmationController> {
  final String phoneNumber;
  
  const LoginconfirmationView({
    super.key,
    required this.phoneNumber,
  });

  // Don't put final fields here with initialization
  // Use StatefulWidget or initialize in initState

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // Get controller
    final LoginconfirmationController loginconfirmationController = Get.put(
      LoginconfirmationController(phoneNumber: phoneNumber), // Pass phone number
    );

    final StorageService _storage = StorageService();
    final LocationController _locationController = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : Get.put(LocationController());

    // Start fetching location when build is called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation(_locationController, _storage);
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBFB), Color(0xFFFFE4E7)],
            ),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned(
                top: 0.h,
                left: 0,
                right: 0,
                height: 460.h,
                child: Image.asset(
                  'assets/images/loginBack.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              // Bottom White Card
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 300.h,
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 15.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon + Text Row
                      Row(
                        children: [
                          Container(
                            height: 48.h,
                            width: 48.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDECEF),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Color(0xFFE61E45),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Login To Dating',
                                  style: TextStyle(
                                    letterSpacing: 1.2.w,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  phoneNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12.h),

                      // // 🔥 Location Status Indicator
                      // Obx(() {
                      //   if (_locationController.isLoading.value) {
                      //     return Container(
                      //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      //       decoration: BoxDecoration(
                      //         color: Colors.orange.withOpacity(0.1),
                      //         borderRadius: BorderRadius.circular(12.r),
                      //         border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      //       ),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           SizedBox(
                      //             width: 16,
                      //             height: 16,
                      //             child: const CircularProgressIndicator(
                      //               strokeWidth: 2,
                      //               color: Colors.orange,
                      //             ),
                      //           ),
                      //           SizedBox(width: 8.w),
                      //           Text(
                      //             'Getting location...',
                      //             style: TextStyle(
                      //               color: Colors.orange[700],
                      //               fontSize: 12.sp,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   } else if (_locationController.locationFetched.value) {
                      //     return Container(
                      //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      //       decoration: BoxDecoration(
                      //         color: Colors.green.withOpacity(0.1),
                      //         borderRadius: BorderRadius.circular(12.r),
                      //         border: Border.all(color: Colors.green.withOpacity(0.3)),
                      //       ),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           const Icon(
                      //             Icons.location_on,
                      //             color: Colors.green,
                      //             size: 16,
                      //           ),
                      //           SizedBox(width: 8.w),
                      //           Text(
                      //             'Location detected',
                      //             style: TextStyle(
                      //               color: Colors.green,
                      //               fontSize: 12.sp,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   } else if (_locationController.errorMessage.value.isNotEmpty) {
                      //     return Container(
                      //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      //       decoration: BoxDecoration(
                      //         color: Colors.red.withOpacity(0.1),
                      //         borderRadius: BorderRadius.circular(12.r),
                      //         border: Border.all(color: Colors.red.withOpacity(0.3)),
                      //       ),
                      //       child: Row(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           const Icon(
                      //             Icons.warning,
                      //             color: Colors.red,
                      //             size: 16,
                      //           ),
                      //           SizedBox(width: 8.w),
                      //           Text(
                      //             'Location not available',
                      //             style: TextStyle(
                      //               color: Colors.red,
                      //               fontSize: 12.sp,
                      //               fontWeight: FontWeight.w500,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }
                      //   return const SizedBox.shrink();
                      // }),

                      SizedBox(height: 15.h),

                      // Continue Button
                      CustomButton(
                        text: "Continue",
                        onPressed: () {
                          _handleContinue(_storage);
                        },
                      ),

                      SizedBox(height: 12.h),

                      // Change Number
                      TextButton(
                        onPressed: () {
                          loginconfirmationController.onChangeNumberTap();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Use Another Mobile Number',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13.sp,
                            letterSpacing: 0.8.w,
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Terms Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 10.5.sp,
                            height: 1.4,
                            letterSpacing: 0.3.w,
                          ),
                          children: const [
                            TextSpan(
                              text: 'By continuing you accept to share your Truecaller ',
                            ),
                            TextSpan(
                              text: 'Profile Information',
                              style: TextStyle(
                                color: Color(0xffFF6B00),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' with Dating, and agree to the privacy policy and terms of service of Dating',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FETCH LOCATION
  Future<void> _fetchLocation(LocationController locationController, StorageService storage) async {
    try {
      print('📍 LoginConfirmation: Fetching location...');
      
      bool success = await locationController.getCurrentLocation();
      
      if (success) {
        String location = locationController.getLocationString();
        print('✅ LoginConfirmation: Location fetched: $location');
        
        // Save location to storage
        await storage.saveData('user_location', location);
        
        // Update profile controller if it exists
        try {
          final profileController = Get.find<ProfileServiceController>();
          profileController.updateLocation(location);
          print('✅ Location saved to profile controller: $location');
        } catch (e) {
          print('⚠️ Profile controller not found yet');
        }
      } else {
        print('❌ LoginConfirmation: Location fetch failed: ${locationController.errorMessage.value}');
      }
    } catch (e) {
      print('❌ LoginConfirmation: Location error: $e');
    }
  }

  // ✅ Handle Continue Button Logic
  void _handleContinue(StorageService storage) {
    final isProfileCreated = storage.isProfileCreated();
    final isLoggedIn = storage.isLoggedIn();
    final hasToken = storage.hasLoginToken();

    print('🔍 Login Confirmation Status:');
    print('  Is Logged In: $isLoggedIn');
    print('  Has Token: $hasToken');
    print('  Is Profile Created: $isProfileCreated');

    // Always go to Premium Plan
    print('🟡 Navigating to Premium Plan');
    Get.to(() => const PrimiumplanView());
  }
}