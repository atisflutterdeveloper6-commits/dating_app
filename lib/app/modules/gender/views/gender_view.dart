import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class GenderView extends StatefulWidget {
  const GenderView({super.key});

  @override
  State<GenderView> createState() => _GenderViewState();
}

class _GenderViewState extends State<GenderView> {
  // Local state variables
  int selectedIndex = 1; // Default to "Man" (index 1)
  bool showGender = true;
  final List<String> genders = [
    "👩 Woman",
    "👨 Man",
    "⚧️ Others",
  ];

  // Get ProfileServiceController
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();

  @override
  Widget build(BuildContext context) {
    // ScreenUtil Initialization
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),

            Text(
              "What’s Your Gender?",
              style: TextStyle(
                letterSpacing: 1.5.w,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 20.h),

            // Gender options
            Column(
              children: List.generate(
                genders.length,
                (index) {
                  final bool selected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      // Check if "Others" is tapped (index 2)
                      if (index == 2) {
                        // Save gender and navigate to Sexual Orientation
                        profileController.updateGender(genders[index]);
                        // Navigate to Sexual Orientation
                        Get.toNamed(Routes.SEXUALORIENTAION);
                      } else {
                        // Normal selection for Woman and Man
                        setState(() {
                          selectedIndex = index;
                        });
                      }
                    },
                    child: Container(
                      height: 55.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xfffff2e8)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selected
                              ? const Color(0xffFF6B00)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                genders[index],
                                style: TextStyle(
                                  letterSpacing: 1.5.w,
                                  fontSize: 13.sp,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (index == 2)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            // Show gender checkbox
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showGender = !showGender;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        color: showGender
                            ? const Color(0xffFF6B00)
                            : Colors.white,
                      ),
                      child: showGender
                          ? Center(
                              child: Icon(
                                Icons.check,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Show My Gender On My Profile",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            SafeArea(
              child: CustomButton(
                text: "Next",
                onPressed: () {
                  _next();
                },
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _next() {
    if (selectedIndex == -1) {
      Get.snackbar(
        "Required",
        "Please Select Your Gender",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Save to ProfileServiceController
    profileController.updateGender(genders[selectedIndex]);
    // profileController.updateShowGender(showGender);

    // Check if selected gender is "Others"
    if (selectedIndex == 2) {
      // Navigate to Sexual Orientation
      Get.toNamed(Routes.SEXUALORIENTAION);
    } else {
      // Navigate to InterestedIn screen for Man and Woman
      Get.toNamed(Routes.INTRESTEDIN);
    }
  }
}