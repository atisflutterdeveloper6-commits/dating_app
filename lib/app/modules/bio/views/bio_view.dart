import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/bio_controller.dart';

class BioView extends GetView<BioController> {
  const BioView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    Get.put(BioController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: const CustomAppBar(
        title: "Your Bio",
        subtitle: "Tell us a little about yourself",
        useIllustration: true,
      ),

      body: Stack(
        children: [
          // ==========================================================
          // BACKGROUND
          // ==========================================================
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ==========================================================
          // LIGHT ORANGE OVERLAY
          // ==========================================================
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFFF0E6).withOpacity(0.10),
            ),
          ),

          // ==========================================================
          // MAIN CONTENT
          // ==========================================================
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // ==================================================
                  // HEADER
                  // SAME AS GENDER VIEW
                  // ==================================================
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What's Your Bio?",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),

                            SizedBox(height: 8.h),

                            Text(
                              "Share something that makes you uniquely you.",
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

                  SizedBox(height: 30.h),

                  // ==================================================
                  // WHITE CONTAINER
                  // SAME STYLE AS GENDER VIEW
                  // ==================================================
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        16.h,
                        16.w,
                        16.h,
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

                      // ==================================================
                      // BIO TEXT FIELD
                      // ==================================================
                      child: TextField(
                        controller: controller.bioController,
                        maxLines: null,
                        maxLength: 500,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.6,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText:
                          "Write Something About Yourself...",
                          hintStyle: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                          contentPadding: EdgeInsets.all(4.w),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // ==================================================
                  // CHARACTER COUNT
                  // ==================================================
                  Obx(
                        () => Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${controller.count.value}/500",
                        style: TextStyle(
                          color: controller.count.value > 450
                              ? Colors.red
                              : controller.count.value > 400
                              ? Colors.orange
                              : Colors.green,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // ==================================================
                  // NEXT BUTTON
                  // SAME AS GENDER VIEW
                  // ==================================================
                  SafeArea(
                    top: false,
                    child: Obx(
                          () => CustomButton(
                        text: controller.isLoading.value
                            ? "Creating Profile..."
                            : "Next",
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.finishProfile,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                  ),

                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}