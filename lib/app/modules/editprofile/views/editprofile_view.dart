// lib/app/modules/edit_profile/views/editprofile_view.dart

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/editprofile/controllers/editprofile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../custom_widget/custom_button.dart';

class EditprofileView extends GetView<EditprofileController> {
  const EditprofileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EditprofileController());

    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,

      appBar: CustomAppBar(
        title: "Edit Profile",
        subtitle: "Update your personal information",

        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            padding: EdgeInsets.zero,
            icon: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.settings_outlined,
                  color: const Color(0xFFFF6B00),
                  size: 22.w,
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),
        ],
      ),

      body: Stack(
        children: [
          // Background

      Positioned.fill(
      child: Image.asset(
        "assets/images/LoginBack2.png",
        fit: BoxFit.cover,
      ),
    ),

// ======================================================
// WHITE OVERLAY
// ======================================================

    Positioned.fill(
    child: Container(
    color: Colors.white.withOpacity(0.70),
    ),
    ),


          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Header - same style as Intrestedin
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFE0CC),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: const Color(0xFFFF6B00),
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 20.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Update your profile details.",
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.black54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // White card - same outer style as Intrestedin
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          40.h,
                          16.w,
                          40.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFF1E8E4),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.035),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),

                        // IMPORTANT:
                        // Text fields bilkul original Edit Profile jaise hain.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(
                              title: 'First Name',
                              controller: controller.firstNameController,
                              hint: 'Enter your first name',
                            ),

                            SizedBox(height: 18.h),

                            _buildField(
                              title: 'Last Name',
                              controller: controller.lastNameController,
                              hint: 'Enter your last name',
                            ),

                            SizedBox(height: 18.h),

                            _buildField(
                              title: 'Nick Name',
                              controller: controller.nickNameController,
                              hint: 'Enter your nickname',
                            ),

                            SizedBox(height: 18.h),

                            _buildField(
                              title: 'Mobile Number',
                              controller: controller.mobileController,
                              hint: 'Enter your mobile number',
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Update Button
                  // Update Button - ORIGINAL GRADIENT
                  SafeArea(
                    top: false,
                    child: CustomButton(
                      text: "Update Profile",
                      onPressed: () => controller.updateProfile(),
                      backgroundColor: const Color(0xFFFF5C00),
                      textColor: Colors.white,

                      borderRadius: 30.r,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      showArrow: true,
                    ),
                  ),
                  SizedBox(height: 90.h),
                ],
              ),
            ),
          ),

          // Loading overlay
          Obx(() {
            if (!controller.isLoading.value) {
              return const SizedBox.shrink();
            }

            return Container(
              color: Colors.white.withOpacity(0.75),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xffFF6A00),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading profile...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Error message
          Obx(() {
            if (controller.errorMessage.value.isEmpty ||
                controller.isLoading.value) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: 32.w,
              right: 32.w,
              bottom: 100.h,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 40.sp,
                      color: Colors.red[300],
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      controller.errorMessage.value,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    ElevatedButton(
                      onPressed: () => controller.loadProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6A00),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        "Retry",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // ORIGINAL EDIT PROFILE TEXT FIELD
  // ============================================================
  Widget _buildField({
    required String title,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff1F1F1F),
          ),
        ),

        SizedBox(height: 8.h),

        Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xffDCDCDC),
            ),
          ),

          child: TextField(
            controller: controller,
            keyboardType: keyboardType,

            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: const Color(0xff444444),
            ),

            decoration: InputDecoration(
              border: InputBorder.none,

              hintText: hint,

              hintStyle: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: const Color(0xff999999),
              ),

              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 15.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}