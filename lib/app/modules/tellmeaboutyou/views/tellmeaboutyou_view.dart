import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/tellmeaboutyou/controllers/tellmeaboutyou_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TellmeaboutyouView extends StatelessWidget {
  const TellmeaboutyouView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // Ensure controller is registered
    TellmeaboutyouController controller;
    if (!Get.isRegistered<TellmeaboutyouController>()) {
      print("=== Creating new TellmeaboutyouController ===");
      controller = Get.put(TellmeaboutyouController());
    } else {
      controller = Get.find<TellmeaboutyouController>();
      print("=== Found existing TellmeaboutyouController ===");
    }

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: ""),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),

            Text(
              "Tell Us About You",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "Tell Us a Little About Yourself.",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),

            SizedBox(height: 28.h),

            _buildField(
              title: "First Name",
              controller: controller.firstNameController,
              hint: "Enter Your First Name",
            ),

            SizedBox(height: 18.h),

            _buildField(
              title: "Last Name",
              controller: controller.lastNameController,
              hint: "Enter Your Last Name",
            ),

            SizedBox(height: 18.h),

            _buildField(
              title: "Nick Name",
              controller: controller.nickNameController,
              hint: "Enter your nickname",
            ),

            const Spacer(),
            isKeyboardOpen ? const SizedBox.shrink() :
            SafeArea(
              child: CustomButton(
                text: "Continue",
                onPressed: () {
                  print("=== Continue button clicked ===");
                  controller.continueToBirthday();
                },
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
       TextField(
  controller: controller,
  decoration: InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.grey, // ya Color(0xFF9E9E9E)
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16.w,
      vertical: 16.h,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(
        color: Color(0xffFF6B00),
        width: 1,
      ),
    ),
  ),
)
     
      ],
    );
  }



}