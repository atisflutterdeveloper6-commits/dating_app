
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

final isKeyboardOpen =
MediaQuery.of(context).viewInsets.bottom > 0;

return Scaffold(
extendBodyBehindAppBar: true,
backgroundColor: Colors.transparent,

appBar: const CustomAppBar(
title: "Tell Us About You",
subtitle: "Tell us a little about yourself",
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
padding: EdgeInsets.symmetric(horizontal: 22.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 20.h),

SizedBox(height: 60.h),

// ======================================================
// WHITE CONTAINER
// Same style as Profile Setup
// ======================================================
  Row(
    children: [
      Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFE0CC), // light orange
            width: 1.2,
          ),
        ),
        child: const Icon(
          Icons.person_outlined,
          color: Color(0xFFFF6B00),
        ),
      ),
      SizedBox(width: 20,),
      Column(
    crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Tell Us About You",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(height: 8.h),

          // ==================================================
          // DESCRIPTION
          // ==================================================

          Text(
            "Tell Us a Little About Yourself.",
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ],
  ),

  SizedBox(height: 28.h),

Container(
width: double.infinity,
padding: EdgeInsets.fromLTRB(
16.w,
20.h,
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
// TITLE
// ==================================================


// ==================================================
// FIRST NAME
// ==================================================

_buildField(
title: "First Name",
controller: controller.firstNameController,
hint: "Enter Your First Name",
),

SizedBox(height: 18.h),

// ==================================================
// LAST NAME
// ==================================================

_buildField(
title: "Last Name",
controller: controller.lastNameController,
hint: "Enter Your Last Name",
),

SizedBox(height: 18.h),

// ==================================================
// NICK NAME
// ==================================================

_buildField(
title: "Nick Name",
controller: controller.nickNameController,
hint: "Enter your nickname",
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
print("=== Continue button clicked ===");
controller.continueToBirthday();
},
),

SizedBox(height: 120.h),
],
],
),
),
),
],
),
);
}

// ============================================================
// TEXT FIELD
// ============================================================

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
color: Colors.grey,
fontSize: 11.sp,
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
),
],
);
}
}

