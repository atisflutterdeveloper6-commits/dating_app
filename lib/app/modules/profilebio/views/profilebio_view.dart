import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/profilebio_controller.dart';

class ProfilebioView extends GetView<ProfilebioController> {
  const ProfilebioView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    if (!Get.isRegistered<ProfilebioController>()) {
      Get.put(ProfilebioController());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,

      // ================= APP BAR =================
      appBar: CustomAppBar(
        title: "Bio",
        subtitle: "Update your bio",
        onBackPressed: () {
          Get.back();
        },
        actions: [
          IconButton(
            onPressed: () {
              Get.find<DashboardController>().changeTab(6);
              Get.offAllNamed('/dashboard');
            },
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
      // ================= BODY =================
      body: Stack(
        children: [

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
              child: Obx(
                    () {
                  final keyboardOpen =
                      MediaQuery.of(context).viewInsets.bottom > 0;

                  // Keyboard open hone par height reduce
                  final double bioHeight =
                  keyboardOpen ? 150.h : 220.h;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // ================= HEADER =================
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
                              Icons.edit_note_rounded,
                              color: const Color(0xFFFF6B00),
                              size: 22.sp,
                            ),
                          ),

                          SizedBox(width: 20.w),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Bio",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.black,
                                  ),
                                ),

                                SizedBox(height: 8.h),

                                Text(
                                  "Write something that tells people about you.",
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

                      // ================= WHITE CARD =================
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          20.h,
                          16.w,
                          12.h,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tell us about yourself",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff1F1F1F),
                              ),
                            ),

                            SizedBox(height: 10.h),

                            // ================= BIO FIELD =================
                            Container(
                              width: double.infinity,
                              height: bioHeight,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius:
                                BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xffDCDCDC),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    controller:
                                    controller.bioController,
                                    maxLines: null,
                                    maxLength: 500,
                                    expands: true,
                                    textAlignVertical:
                                    TextAlignVertical.top,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.sp,
                                      height: 1.5,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText:
                                      "Write something about yourself...",
                                      hintStyle:
                                      GoogleFonts.poppins(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 6.h),

                            // ================= CHARACTER COUNT =================
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${controller.count.value} characters',
                                  style: TextStyle(
                                    color:
                                    controller.count.value > 450
                                        ? Colors.orange
                                        : Colors.green,
                                    fontSize: 8.sp,
                                  ),
                                ),
                                Text(
                                  "/500",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // ================= AI HELP =================
                      Center(
                        child: Text(
                          "✨ Need help? Use AI to write bio",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xffFF6B00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // ================= SPACER =================
                      const Spacer(),

                      // ================= UPDATE BUTTON =================
                      SafeArea(
                        top: false,
                        child: CustomButton(
                          text: controller.isLoading.value
                              ? "Updating..."
                              : "Update",
                          onPressed: controller.isLoading.value
                              ? () {}
                              : controller.updateBio,
                          isLoading: controller.isLoading.value,
                          backgroundColor:
                          const Color(0xffFF6B00),
                          textColor: Colors.white,

                          borderRadius: 30.r,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          showArrow: true,
                        ),
                      ),

                      // Keyboard open = small gap
                      // Keyboard closed = 80.h
                      SizedBox(
                        height: keyboardOpen ? 8.h : 80.h,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}