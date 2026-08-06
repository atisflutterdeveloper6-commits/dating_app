import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/sexualorientaion/controllers/sexualorientaion_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SexualorientaionView extends GetView<SexualorientaionController> {
  const SexualorientaionView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    Get.put(SexualorientaionController());

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15.h),

            Text(
              "Your Sexual Orientation?",
              style: TextStyle(
                letterSpacing: 1.5,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 10.h),

            Obx(
              () => Column(
                children: List.generate(
                  controller.orientations.length,
                  (index) {
                    final item = controller.orientations[index];
                    final selected = controller.selected.contains(item);

                    return GestureDetector(
                      onTap: () => controller.toggle(item),
                      child: Container(
                        height: 55.h,
                        margin: EdgeInsets.only(bottom: 8.h),
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
                        child: Center(
                          child: Text(
                            item,
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontSize: 13.sp,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

Obx(
  () => Row(
    children: [
      GestureDetector(
        onTap: () {
          controller.showOrientation.toggle();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 20.w,
            height: 20.w,
            padding: EdgeInsets.all(4.w), // 👈 Icon padding
            decoration: BoxDecoration(
              color: controller.showOrientation.value
                  ? const Color(0xffFF6B00)
                  : Colors.white,
              borderRadius: BorderRadius.circular(30.r),
           
            ),
            child: controller.showOrientation.value
                ? Icon(
                    Icons.check,
                    size: 12.sp, // 👈 Small icon
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Text(
          "Show My Orientation On My Profile",
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  ),
), 
       
            SizedBox(height: 7.h),

            SafeArea(
              child: CustomButton(
                text: "Next",
                onPressed: () {
                  controller.next();
                },
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}