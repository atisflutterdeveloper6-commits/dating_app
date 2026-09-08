
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/intrestedin/controllers/intrestedin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntrestedinView extends StatefulWidget {
const IntrestedinView({super.key});

@override
State<IntrestedinView> createState() => _IntrestedinViewState();
}

class _IntrestedinViewState extends State<IntrestedinView> {
final IntrestedinController controller =
Get.put(IntrestedinController());

@override
Widget build(BuildContext context) {
ScreenUtil.init(
context,
designSize: const Size(375, 812),
minTextAdapt: true,
splitScreenMode: true,
);

return Scaffold(
extendBodyBehindAppBar: true,
backgroundColor: Colors.transparent,

// ============================================================
// APP BAR
// ============================================================
appBar: const CustomAppBar(
title: "Your Preference",
subtitle: "Tell us who you'd like to meet",
useIllustration: true,
),

body: Stack(
children: [
// ==========================================================
// BACKGROUND
// ==========================================================
Positioned.fill(
child: Image.asset(
'assets/images/LoginBack2.png',
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
// SAME AS GENDER SCREEN
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
Icons.favorite_border_rounded,
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
"Who Are You Interested In?",
style: TextStyle(
fontSize: 14.sp,
fontWeight: FontWeight.w700,
letterSpacing: 1.2,
),
),

SizedBox(height: 8.h),

Text(
"Choose who you'd like to connect with.",
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
// SAME AS GENDER SCREEN
// ==================================================
Container(
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

child: Column(
children: List.generate(
controller.interests.length,
(index) {
final bool selected =
controller.selectedIndex == index;

return GestureDetector(
onTap: () {
setState(() {
controller.selectedIndex = index;
});
},

child: AnimatedContainer(
duration:
const Duration(milliseconds: 180),

// ==================================================
// OPTION HEIGHT
// ==================================================
height: 80.h,

margin: EdgeInsets.only(
bottom:
index ==
controller.interests.length - 1
? 0
    : 12.h,
),

padding: EdgeInsets.symmetric(
horizontal: 18.w,
),

decoration: BoxDecoration(
color: selected
? const Color(0xFFFFF2E8)
    : Colors.white,

borderRadius:
BorderRadius.circular(10.r),

border: Border.all(
color: selected
? const Color(0xffFF6B00)
    : Colors.grey.shade300,
width: selected ? 1.5 : 1,
),
),

child: Row(
children: [
// ==========================================
// RADIO ICON
// ==========================================
Icon(
selected
? Icons.radio_button_checked
    : Icons.radio_button_off,
size: 18.sp,
color: selected
? const Color(0xffFF6B00)
    : Colors.grey.shade500,
),

SizedBox(width: 12.w),

// ==========================================
// INTEREST TEXT
// ==========================================
Expanded(
child: Text(
controller.interests[index],
style: TextStyle(
fontSize: 12.sp,
fontWeight: selected
? FontWeight.w600
    : FontWeight.w500,
letterSpacing: 0.5,
color: selected
? const Color(0xffFF6B00)
    : Colors.black87,
),
),
),
],
),
),
);
},
),
),
),

const Spacer(),

// ==================================================
// NEXT BUTTON
// ==================================================
SafeArea(
top: false,
child: CustomButton(
text: "Next",
onPressed: () {
controller.next();
},
),
),

SizedBox(height: 90.h),
],
),
),
),
],
),
);
}
}

