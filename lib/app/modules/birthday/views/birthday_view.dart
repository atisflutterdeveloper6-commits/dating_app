import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/birthday_controller.dart';

class BirthdayView extends GetView<BirthdayController> {
  const BirthdayView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BirthdayController());
    
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const CustomAppBar(title: ""),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25.h),

                    Text(
                      "Your Birthday",
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "This Helps Us Show Your Age Accurately.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        SizedBox(width: 80.w, child: _dayDropdown()),
                        SizedBox(width: 12.w),
                        Expanded(child: _monthDropdown()),
                        SizedBox(width: 12.w),
                        Expanded(child: _yearDropdown()),
                      ],
                    ),

                    SizedBox(height: 15.h),

                    Text(
                      "Your Profile Shows Your Age, Not Your Date Of Birth.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                    ),

                    SizedBox(height: 45.h),

                    Text(
                      "Do You Have A Place To Meet?",
                      style: TextStyle(
                        letterSpacing: 1,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "This Helps Us Match You Better.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.sp,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Obx(
                      () => Column(
                        children: [
                          _meetButton("Yes"),
                          SizedBox(height: 15.h),
                          _meetButton("No"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 10.h),
              child: CustomButton(
                text: "Continue",
                onPressed: () {
                  controller.next(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==================== Dropdowns ====================
  Widget _dayDropdown() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Day",
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.selectedDay.value,
                isExpanded: true,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text((index + 1).toString().padLeft(2, '0')),
                  ),
                ),
                onChanged: (value) {
                  controller.selectedDay.value = value!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthDropdown() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Month", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 6.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedMonth.value,
                isExpanded: true,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                items: controller.months
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  controller.selectedMonth.value = value!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yearDropdown() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Year", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 6.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.selectedYear.value,
                isExpanded: true,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                items: List.generate(
                  70,
                  (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  },
                ),
                onChanged: (value) {
                  controller.selectedYear.value = value!;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Meet Button ====================
  Widget _meetButton(String value) {
    final selected = controller.meetPlace.value == value;

    return GestureDetector(
      onTap: () => controller.toggleMeetPlace(value),
      child: Container(
        height: 55.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF2E8) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? const Color(0xffFF6B00) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16.sp,
              color: selected ? const Color(0xffFF6B00) : Colors.grey,
            ),
            SizedBox(width: 8.w),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}