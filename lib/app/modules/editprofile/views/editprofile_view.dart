// lib/app/modules/edit_profile/views/editprofile_view.dart

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/editprofile/controllers/editprofile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditprofileView extends GetView<EditprofileController> {
  const EditprofileView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 FIX: Don't create new instance here, use Get.find() or Get.put() in initState
    // The controller will be created when the route is pushed
    Get.put(EditprofileController());
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: "Edit Profile",
        onBackPressed: () {
          // 🔥 FIX: Proper navigation back
          Get.back();
        },
        actions: [
          GestureDetector(
            onTap: () {
              // 🔥 FIX: Navigate to settings properly
              Get.toNamed('/settings') ?? Get.back();
            },
            child: const Icon(Icons.settings),
          )
        ],
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          );
        }

        // Error State
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => controller.loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6A00),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Main Content
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 22.w,
                  vertical: 28.h,
                ),
                child: Column(
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

            // Update Button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () => controller.updateProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6A00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Update",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  )),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

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