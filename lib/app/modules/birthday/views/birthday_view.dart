
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

final isKeyboardOpen =
MediaQuery.of(context).viewInsets.bottom > 0;

return Scaffold(
extendBodyBehindAppBar: true,
backgroundColor: Colors.transparent,

// ============================================================
// APP BAR
// ============================================================
appBar: const CustomAppBar(
title: "Your Birthday",
subtitle: "Let’s get to know you a little better",
useIllustration: true,
),

body: Stack(
children: [
// ============================================================
// BACKGROUND
// ============================================================
Positioned.fill(
child: Image.asset(
'assets/images/LoginBack2.png',
fit: BoxFit.cover,
),
),

// ============================================================
// LIGHT OVERLAY
// ============================================================
Positioned.fill(
child: Container(
color: const Color(0xFFFFF0E6).withOpacity(0.10),
),
),

// ============================================================
// MAIN CONTENT
// ============================================================
SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 40.h),
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
          Icons.cake_outlined,
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
              "Your Birthday",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "This Helps Us Show Your Age Accurately.",
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

// ======================================================
// WHITE CONTAINER
// Same style as Tell Me About You
// ======================================================
Container(
width: double.infinity,
padding: EdgeInsets.fromLTRB(
16.w,
0.h,
16.w,
20.h,
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
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// ICON + TITLE + DESCRIPTION

SizedBox(height: 30.h),

// ==================================================
// DATE DROPDOWNS
// ==================================================
Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 78.w,
child: _dayDropdown(),
),

SizedBox(width: 10.w),

Expanded(
child: _monthDropdown(),
),

SizedBox(width: 10.w),

Expanded(
child: _yearDropdown(),
),
],
),

SizedBox(height: 12.h),

Text(
"Your Profile Shows Your Age, Not Your Date Of Birth.",
style: TextStyle(
color: Colors.black54,
fontSize: 9.sp,
letterSpacing: 0.3,
),
),

SizedBox(height: 35.h),

// ==================================================
// MEETING PLACE
// ==================================================
Text(
"Do You Have A Place To Meet?",
style: TextStyle(
fontSize: 14.sp,
fontWeight: FontWeight.w700,
letterSpacing: 1.0,
),
),

SizedBox(height: 8.h),

Text(
"This Helps Us Match You Better.",
style: TextStyle(
color: Colors.black54,
fontSize: 9.sp,
letterSpacing: 0.5,
),
),

SizedBox(height: 18.h),

Obx(
() => Column(
children: [
_meetButton("Yes"),

SizedBox(height: 12.h),

_meetButton("No"),

  SizedBox(height: 20.h),
],
),
),
],
),
),

// ======================================================
// BUTTON
// OUTSIDE WHITE CONTAINER
// ======================================================
if (!isKeyboardOpen) ...[
const Spacer(),

CustomButton(
text: "Continue",
onPressed: () {
controller.next(context);
},
),

SizedBox(height: 110.h),
],
],
),
),
),
],
),
);
}

// ================================================================
// DAY DROPDOWN
// ================================================================
Widget _dayDropdown() {
return Obx(
() => Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Day",
style: TextStyle(
fontSize: 11.sp,
fontWeight: FontWeight.w500,
),
),

SizedBox(height: 6.h),

Container(
height: 42.h,
padding: EdgeInsets.symmetric(horizontal: 10.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(10.r),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: DropdownButtonHideUnderline(
child: DropdownButton<int>(
value: controller.selectedDay.value,
isExpanded: true,
icon: Icon(
Icons.keyboard_arrow_down_rounded,
size: 18.sp,
color: Colors.black54,
),
style: TextStyle(
fontSize: 11.sp,
color: Colors.black,
),
items: List.generate(
31,
(index) => DropdownMenuItem(
value: index + 1,
child: Text(
(index + 1).toString().padLeft(2, '0'),
style: TextStyle(
color: Colors.black,
fontSize: 11.sp,
),
),
),
),
onChanged: (value) {
if (value != null) {
controller.selectedDay.value = value;
}
},
),
),
),
],
),
);
}

// ================================================================
// MONTH DROPDOWN
// ================================================================
Widget _monthDropdown() {
return Obx(
() => Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Month",
style: TextStyle(
fontSize: 11.sp,
fontWeight: FontWeight.w500,
),
),

SizedBox(height: 6.h),

Container(
height: 42.h,
padding: EdgeInsets.symmetric(horizontal: 10.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(10.r),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: DropdownButtonHideUnderline(
child: DropdownButton<String>(
value: controller.selectedMonth.value,
isExpanded: true,
icon: Icon(
Icons.keyboard_arrow_down_rounded,
size: 18.sp,
color: Colors.black54,
),
style: TextStyle(
fontSize: 11.sp,
color: Colors.black,
),
items: controller.months
    .map(
(month) => DropdownMenuItem(
value: month,
child: Text(
month,
style: TextStyle(
color: Colors.black,
fontSize: 11.sp,
),
),
),
)
    .toList(),
onChanged: (value) {
if (value != null) {
controller.selectedMonth.value = value;
}
},
),
),
),
],
),
);
}

// ================================================================
// YEAR DROPDOWN
// ================================================================
Widget _yearDropdown() {
return Obx(
() => Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Year",
style: TextStyle(
fontSize: 11.sp,
fontWeight: FontWeight.w500,
),
),

SizedBox(height: 6.h),

Container(
height: 42.h,
padding: EdgeInsets.symmetric(horizontal: 10.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(10.r),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: DropdownButtonHideUnderline(
child: DropdownButton<int>(
value: controller.selectedYear.value,
isExpanded: true,
icon: Icon(
Icons.keyboard_arrow_down_rounded,
size: 18.sp,
color: Colors.black54,
),
style: TextStyle(
fontSize: 11.sp,
color: Colors.black,
),
items: List.generate(
70,
(index) {
final year = DateTime.now().year - index;

return DropdownMenuItem(
value: year,
child: Text(
year.toString(),
style: TextStyle(
color: Colors.black,
fontSize: 11.sp,
),
),
);
},
),
onChanged: (value) {
if (value != null) {
controller.selectedYear.value = value;
}
},
),
),
),
],
),
);
}

// ================================================================
// MEET PLACE BUTTON
// ================================================================
Widget _meetButton(String value) {
final selected = controller.meetPlace.value == value;

return GestureDetector(
onTap: () {
controller.toggleMeetPlace(value);
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 180),
height: 50.h,
padding: EdgeInsets.symmetric(horizontal: 14.w),
decoration: BoxDecoration(
color: selected
? const Color(0xFFFFF2E8)
    : Colors.white,
borderRadius: BorderRadius.circular(10.r),
border: Border.all(
color: selected
? const Color(0xffFF6B00)
    : Colors.grey.shade300,
width: selected ? 1.5 : 1,
),
),
child: Row(
children: [
Icon(
selected
? Icons.radio_button_checked
    : Icons.radio_button_off,
size: 17.sp,
color: selected
? const Color(0xffFF6B00)
    : Colors.grey,
),

SizedBox(width: 9.w),

Text(
value,
style: TextStyle(
fontSize: 12.sp,
fontWeight: FontWeight.w500,
color: selected
? Colors.black
    : Colors.grey.shade700,
),
),
],
),
),
);
}
}

