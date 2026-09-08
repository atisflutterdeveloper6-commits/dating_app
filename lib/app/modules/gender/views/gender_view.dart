
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class GenderView extends StatefulWidget {
const GenderView({super.key});

@override
State<GenderView> createState() => _GenderViewState();
}

class _GenderViewState extends State<GenderView> {
// ============================================================
// LOCAL STATE
// ============================================================
int selectedIndex = 1; // Default = Man
bool showGender = true;

final List<String> genders = [
"👩 Woman",
"👨 Man",
"⚧️ Others",
];

// ============================================================
// PROFILE CONTROLLER
// ============================================================
final ProfileServiceController profileController =
Get.find<ProfileServiceController>();

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
title: "Your Gender",
subtitle: "Tell us how you identify",
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
// SAME AS POSITION SCREEN
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
Icons.person_outline,
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
"What’s Your Gender?",
style: TextStyle(
fontSize: 14.sp,
fontWeight: FontWeight.w700,
letterSpacing: 1.2,
),
),

SizedBox(height: 8.h),

Text(
"Choose the option that best represents you.",
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
color:
Colors.black.withOpacity(0.035),
blurRadius: 12,
offset: const Offset(0, 3),
),
],
),

child: Column(
children: List.generate(
genders.length,
(index) {
final bool selected =
selectedIndex == index;

return GestureDetector(
onTap: () {
if (index == 2) {
// ==================================
// SAVE OTHERS
// ==================================
profileController.updateGender(
genders[index],
);

// ==================================
// NAVIGATE DIRECTLY
// ==================================
Get.toNamed(
Routes.SEXUALORIENTAION,
);
} else {
setState(() {
selectedIndex = index;
});
}
},
child: AnimatedContainer(
duration:
const Duration(milliseconds: 180),

height: 80.h,

margin: EdgeInsets.only(
bottom: index ==
genders.length - 1
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
width:
selected ? 1.5 : 1,
),
),

child: Row(
children: [
// =================================
// RADIO ICON
// =================================
Icon(
selected
? Icons
    .radio_button_checked
    : Icons.radio_button_off,
size: 18.sp,
color: selected
? const Color(
0xffFF6B00,
)
    : Colors.grey.shade500,
),

SizedBox(width: 12.w),

// =================================
// GENDER TEXT
// =================================
Expanded(
child: Text(
genders[index],
style: TextStyle(
fontSize: 12.sp,
fontWeight: selected
? FontWeight.w600
    : FontWeight.w500,
letterSpacing: 0.5,
color: selected
? const Color(
0xffFF6B00,
)
    : Colors.black87,
),
),
),

// =================================
// ARROW FOR OTHERS
// =================================
if (index == 2)
Icon(
Icons
    .arrow_forward_ios_rounded,
size: 13.sp,
color: Colors.black54,
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
// SHOW GENDER CHECKBOX
// ==================================================
GestureDetector(
onTap: () {
setState(() {
showGender = !showGender;
});
},
child: Row(
children: [
Container(
width: 20.w,
height: 20.w,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: showGender
? const Color(0xffFF6B00)
    : Colors.white,
border: Border.all(
color: showGender
? const Color(0xffFF6B00)
    : Colors.grey.shade400,
width: 1,
),
),
child: showGender
? Center(
child: Icon(
Icons.check,
size: 12.sp,
color: Colors.white,
),
)
    : null,
),

SizedBox(width: 10.w),

Expanded(
child: Text(
"Show My Gender On My Profile",
style: TextStyle(
fontSize: 10.sp,
color: Colors.black54,
letterSpacing: 0.3,
),
),
),
],
),
),

SizedBox(height: 15.h),

// ==================================================
// NEXT BUTTON
// SAME BOTTOM PLACEMENT
// ==================================================
SafeArea(
top: false,
child: CustomButton(
text: "Next",
onPressed: () {
_next();
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

// ================================================================
// NEXT
// ================================================================
void _next() {
if (selectedIndex == -1) {
Get.snackbar(
"Required",
"Please Select Your Gender",
snackPosition: SnackPosition.BOTTOM,
backgroundColor: const Color(0xffFF6B00),
colorText: Colors.white,
margin: EdgeInsets.all(15.w),
borderRadius: 10.r,
);

return;
}

// ==============================================================
// SAVE GENDER
// ==============================================================
profileController.updateGender(
genders[selectedIndex],
);

// ==============================================================
// NAVIGATION
// ==============================================================
if (selectedIndex == 2) {
Get.toNamed(
Routes.SEXUALORIENTAION,
);
} else {
Get.toNamed(
Routes.INTRESTEDIN,
);
}
}
}
