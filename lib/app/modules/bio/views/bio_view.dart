import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/bio_controller.dart';

class BioView extends GetView<BioController> {
  const BioView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // Remove Get.put() - GetView handles it
    Get.put(BioController());
    // Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(title: ""),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30.h),

            Text(
              "Add Bio",
              style: TextStyle(
                letterSpacing: 1.5.w,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 25.h),

            Expanded(
              child: Container(
                height: 240.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: controller.bioController,
                  maxLines: null,
                  maxLength: 500,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Write Something About Yourself...",
                    hintStyle: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.all(16.w),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

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
                  ),
                ),
              ),
            ),

         

            const Spacer(),

            SafeArea(
              child: Obx(() => CustomButton(
                text: controller.isLoading.value ? "Creating Profile..." : "Next",
                onPressed: controller.isLoading.value ? () {} : controller.finishProfile,
                isLoading: controller.isLoading.value,
              )),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}