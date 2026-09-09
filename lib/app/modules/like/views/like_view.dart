
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/like2/views/like2_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LikeView extends StatelessWidget {
const LikeView({super.key});

static const Color orangeColor = Color(0xffFF6B00);

@override
Widget build(BuildContext context) {
ScreenUtil.init(
context,
designSize: const Size(375, 812),
minTextAdapt: true,
splitScreenMode: true,
);

return Scaffold(
backgroundColor: Colors.transparent,
extendBodyBehindAppBar: true,
extendBody: true,

appBar: CustomAppBar(
title: "Like",
onBackPressed: () {
Get.find<DashboardController>().changeTab(0);
},
),

body: Stack(
fit: StackFit.expand,
children: [
// ==========================================================
// BACKGROUND IMAGE
// ==========================================================

Positioned.fill(
child: Image.asset(
"assets/images/LoginBack2.png",
fit: BoxFit.cover,
),
),

// ==========================================================
// WHITE OPACITY OVERLAY
// ==========================================================

Positioned.fill(
child: Container(
color: Colors.white.withOpacity(0.70),
),
),

// ==========================================================
// CONTENT
// ==========================================================

Positioned.fill(
child: SafeArea(
child: Padding(
padding: EdgeInsets.fromLTRB(
14.w,
14.h,
14.w,
30.h,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// HEADER CARD
// ==================================================

Container(
width: double.infinity,
padding: EdgeInsets.all(18.w),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.88),
borderRadius: BorderRadius.circular(18.r),
border: Border.all(
color: Colors.white.withOpacity(0.75),
width: 0.8.w,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.06),
blurRadius: 15.r,
offset: Offset(0, 5.h),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Liked You",
style: GoogleFonts.poppins(
letterSpacing: 1.5.w,
fontSize: 16.sp,
fontWeight: FontWeight.w700,
color: const Color(0xff222222),
),
),

SizedBox(height: 7.h),

Text(
"They're into you! If you're into them too, "
"like them back to match instantly.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff7B7B7B),
height: 1.5,
),
),
],
),
),

const Spacer(),

// ==================================================
// SPOTLIGHT CARD
// ==================================================

Container(
width: double.infinity,
padding: EdgeInsets.fromLTRB(
18.w,
24.h,
18.w,
20.h,
),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.88),
borderRadius: BorderRadius.circular(20.r),
border: Border.all(
color: Colors.white.withOpacity(0.75),
width: 0.8.w,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.08),
blurRadius: 18.r,
offset: Offset(0, 6.h),
),
],
),
child: Column(
children: [
// ==========================================
// PROFILE IMAGE
// ==========================================

Container(
height: 76.w,
width: 76.w,
padding: EdgeInsets.all(2.w),
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: orangeColor.withOpacity(0.55),
width: 2.w,
),
),
child: ClipOval(
child: Image.asset(
"assets/images/profile1.png",
fit: BoxFit.cover,
),
),
),

SizedBox(height: 18.h),

// ==========================================
// TITLE
// ==========================================

Text(
"Be seen by up to 10x more people",
textAlign: TextAlign.center,
style: GoogleFonts.poppins(
letterSpacing: 1.1.w,
fontSize: 16.sp,
fontWeight: FontWeight.w700,
color: const Color(0xff222222),
),
),

SizedBox(height: 10.h),

// ==========================================
// DESCRIPTION
// ==========================================

Text(
"With Spotlights you'll be seen by more people "
"so you get even more chances to connect.",
textAlign: TextAlign.center,
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff8A8A8A),
height: 1.6,
),
),

SizedBox(height: 24.h),

// ==========================================
// CUSTOM BUTTON
// ==========================================

CustomButton(
text: "Try a spotlight",
  showArrow: true,
onPressed: () {
Get.to(() => Like2View());
},
backgroundColor: orangeColor,
textColor: Colors.white,
height: 50,
borderRadius: 30,
fontSize: 14,
fontWeight: FontWeight.w600,
letterSpacing: 0,

),
],
),
),

const Spacer(),
],
),
),
),
),
],
),
);
}
}

