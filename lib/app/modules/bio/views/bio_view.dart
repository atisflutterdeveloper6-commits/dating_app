
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

// ================= APP BAR =================
appBar: const CustomAppBar(
title: "Your Bio",
subtitle: "Tell us a little about yourself",
useIllustration: true,
),

body: Stack(
children: [
// ================= BACKGROUND =================
Positioned.fill(
child: Image.asset(
"assets/images/LoginBack2.png",
fit: BoxFit.cover,
),
),

// ================= LIGHT OVERLAY =================
Positioned.fill(
child: Container(
color: const Color(0xFFFFF0E6).withOpacity(0.10),
),
),

// ================= CONTENT =================
SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 25.h),

// ================= TITLE =================
Text(
"Add Bio",
style: TextStyle(
letterSpacing: 1.2.w,
fontSize: 18.sp,
fontWeight: FontWeight.w700,
color: Colors.black,
),
),

SizedBox(height: 5.h),

// ================= SUBTITLE =================
Text(
"Share something that makes you uniquely you.",
style: TextStyle(
letterSpacing: 0.5.w,
fontSize: 9.sp,
color: Colors.black54,
fontWeight: FontWeight.w400,
),
),

SizedBox(height: 20.h),

// ================= BIO TEXT FIELD =================
Expanded(
child: Container(
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14.r),
border: Border.all(
color: Colors.grey.shade200,
width: 1,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.03),
blurRadius: 6,
offset: const Offset(0, 2),
),
],
),
child: TextField(
controller: controller.bioController,
maxLines: null,
maxLength: 500,
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
contentPadding: EdgeInsets.all(16.w),
border: InputBorder.none,
),
),
),
),

SizedBox(height: 8.h),

// ================= CHARACTER COUNT =================
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

SizedBox(height: 10.h),

// ================= NEXT BUTTON =================
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

SizedBox(height: 150.h),
],
),
),
),
],
),
);
}
}

