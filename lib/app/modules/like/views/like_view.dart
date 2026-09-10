import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/like2/views/like2_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LikeView extends StatelessWidget {
  const LikeView({super.key});

  static const Color orangeColor = Color(0xffFF6B00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      extendBodyBehindAppBar: true,
      extendBody: false,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: CustomAppBar(
        title: "Like",
        subtitle: "Your Likes",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================================
          // FALLBACK BACKGROUND
          // ==========================================================

          Positioned.fill(
            child: Container(
              color: const Color(0xFFF7F7F7),
            ),
          ),

          // ==========================================================
          // BACKGROUND IMAGE
          // ==========================================================

          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================================
          // WHITE OVERLAY
          // ==========================================================

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ==========================================================
          // CONTENT
          // ==========================================================

          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    14.w,
                    14.h,
                    14.w,
                    30.h,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      12.w,
                      14.h,
                      12.w,
                      14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFFF1E8E4),
                        width: 0.8.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.035),
                          blurRadius: 12.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HEADER CARD
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFCFB),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: const Color(0xFFF1E8E4),
                              width: 0.8.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.035),
                                blurRadius: 10.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your Likes",
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5.w,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff222222),
                                ),
                              ),

                              SizedBox(height: 7.h),

                              Text(
                                "See the people you've liked and "
                                    "check your connections.",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: const Color(0xff7B7B7B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 25.h),

                        // ==================================================
                        // YOUR LIKES CARD
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            18.w,
                            24.h,
                            18.w,
                            20.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFCFB),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFFF1E8E4),
                              width: 0.8.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.045),
                                blurRadius: 12.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ==================================================
                              // LIKE ICON
                              // ==================================================

                              Container(
                                height: 76.w,
                                width: 76.w,
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: orangeColor.withOpacity(0.55),
                                    width: 2.w,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: orangeColor.withOpacity(0.08),
                                    child: Icon(
                                      Icons.favorite,
                                      size: 38.sp,
                                      color: orangeColor,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 18.h),

                              // ==================================================
                              // TITLE
                              // ==================================================

                              Text(
                                "People You Liked",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.1.w,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xff222222),
                                ),
                              ),

                              SizedBox(height: 10.h),

                              // ==================================================
                              // DESCRIPTION
                              // ==================================================

                              Text(
                                "Here are the profiles you've liked. "
                                    "Check their profiles and see if you've "
                                    "made a match.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: const Color(0xff8A8A8A),
                                  height: 1.6,
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // ==================================================
                              // BUTTON
                              // ==================================================

                              CustomButton(
                                text: "View Your Likes",
                                showArrow: true,
                                onPressed: () {
                                  Get.to(
                                        () => const Like2View(),
                                  );
                                },
                                backgroundColor: orangeColor,
                                textColor: Colors.white,
                                height: 50,
                                borderRadius: 30,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}