
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class HeightView extends StatefulWidget {
const HeightView({super.key});

@override
State<HeightView> createState() => _HeightViewState();
}

class _HeightViewState extends State<HeightView> {
final ProfileServiceController profileService =
Get.find<ProfileServiceController>();

final Rx<String?> selectedHeight = Rx<String?>(null);
final RxBool isLoading = false.obs;
final RxBool isFetching = false.obs;

final List<String> heights = [
"4 ft 8 in (142 cm)",
"4 ft 9 in (144 cm)",
"4 ft 10 in (147 cm)",
"4 ft 11 in (149 cm)",
"5 ft (152 cm)",
"5 ft 1 in (155 cm)",
"5 ft 2 in (157 cm)",
"5 ft 3 in (160 cm)",
"5 ft 4 in (162 cm)",
"5 ft 5 in (165 cm)",
"5 ft 6 in (167 cm)",
"5 ft 7 in (170 cm)",
"5 ft 8 in (172 cm)",
"5 ft 9 in (175 cm)",
"6 ft (182 cm)",
];

@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
_loadHeight();
});
}

void _loadHeight() {
try {
isFetching.value = true;

final height = profileService.profile.value.height;

debugPrint('📤 Loading height: $height');

if (height != null && height.isNotEmpty) {
if (heights.contains(height)) {
selectedHeight.value = height;
debugPrint('✅ Height loaded: $height');
} else {
final matchingHeight = heights.firstWhere(
(h) => h.contains(height) || height.contains(h),
orElse: () => heights.first,
);

selectedHeight.value = matchingHeight;

debugPrint(
'✅ Using matching height: $matchingHeight',
);
}
} else {
selectedHeight.value = null;
}

isFetching.value = false;
} catch (e) {
debugPrint('❌ Error loading height: $e');

isFetching.value = false;
selectedHeight.value = null;
}
}

Future<void> updateHeight() async {
if (isLoading.value) return;

if (selectedHeight.value == null) {
CustomToast.warning('Please select your height');
return;
}

isLoading.value = true;

try {
final height = selectedHeight.value!;

debugPrint('========================================');
debugPrint('📤 UPDATING HEIGHT');
debugPrint('📤 Selected Height: $height');
debugPrint(
'📤 Current height: '
'${profileService.profile.value.height}',
);
debugPrint('========================================');

profileService.updateHeight(height);

final success = await profileService.updateProfile();

debugPrint('📤 Update profile success: $success');
debugPrint(
'📤 Profile height after update: '
'${profileService.profile.value.height}',
);
debugPrint(
'📤 Error message: '
'${profileService.errorMessage.value}',
);

isLoading.value = false;

if (success) {
await profileService.fetchMyProfile();

_loadHeight();

CustomToast.success(
'Height updated successfully! 🎉',
);

Future.delayed(
const Duration(milliseconds: 500),
() {
Get.back();
},
);
} else {
CustomToast.error(
profileService.errorMessage.value,
);

_loadHeight();
}
} catch (e) {
isLoading.value = false;

CustomToast.error(
'Failed to update height: $e',
);

debugPrint('❌ Error updating height: $e');
}
}

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
resizeToAvoidBottomInset: true,

appBar: CustomAppBar(
title: "Height",
subtitle: "Update your height",
onBackPressed: () {
Get.back();
},
actions: [
IconButton(
onPressed: () {
Get.find<DashboardController>().changeTab(6);
Get.offAllNamed('/dashboard');
},
padding: EdgeInsets.zero,
icon: Container(
width: 40.w,
height: 40.w,
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.10),
blurRadius: 8.r,
offset: Offset(0, 3.h),
),
],
),
child: Center(
child: Icon(
Icons.settings_outlined,
color: const Color(0xFFFF6B00),
size: 22.w,
),
),
),
),
SizedBox(width: 8.w),
],
),

body: Stack(
children: [

  Positioned.fill(
    child: Image.asset(
      "assets/images/LoginBack2.png",
      fit: BoxFit.cover,
    ),
  ),

// ======================================================
// WHITE OVERLAY
// ======================================================

  Positioned.fill(
    child: Container(
      color: Colors.white.withOpacity(0.70),
    ),
  ),


SafeArea(
child: Obx(
() {
if (isFetching.value) {
return const Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CircularProgressIndicator(
color: Color(0xffFF6A00),
),
SizedBox(height: 16),
Text(
'Loading height...',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),
],
),
);
}

return Padding(
padding: EdgeInsets.symmetric(
horizontal: 28.w,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(height: 20.h),

// Header
Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
padding: EdgeInsets.all(8.w),
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color:
const Color(0xFFFFE0CC),
width: 1.2,
),
),
child: Icon(
Icons.height_rounded,
color:
const Color(0xFFFF6B00),
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
"Height",
style: GoogleFonts.poppins(
fontSize: 14.sp,
fontWeight:
FontWeight.w700,
letterSpacing: 1.2,
),
),
SizedBox(height: 8.h),
Text(
"Update your height.",
style: GoogleFonts.poppins(
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

SizedBox(height: 20.h),

// White content card
Expanded(
child: SingleChildScrollView(
child: Container(
width: double.infinity,
padding: EdgeInsets.fromLTRB(
16.w,
30.h,
16.w,
30.h,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(14.r),
border: Border.all(
color:
const Color(0xFFF1E8E4),
width: 0.8,
),
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.035),
blurRadius: 12,
offset:
const Offset(0, 3),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Select your height',
style:
GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight:
FontWeight.w500,
color:
const Color(0xff1F1F1F),
),
),

SizedBox(height: 12.h),

// Height dropdown
Container(
height: 50.h,
width: double.infinity,
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
12.r,
),
border: Border.all(
color:
const Color(0xffDCDCDC),
),
),
child:
DropdownButtonHideUnderline(
child:
DropdownButton<String?>(
value:
selectedHeight.value,
isExpanded: true,
icon: Icon(
Icons
    .keyboard_arrow_down,
size: 20.sp,
color:
const Color(
0xff555555,
),
),
style:
GoogleFonts.poppins(
fontSize: 13.sp,
color:
const Color(
0xff444444,
),
),
hint: Text(
'Select your height',
style:
GoogleFonts.poppins(
fontSize: 13.sp,
color:
const Color(
0xff999999,
),
),
),
items: heights.map(
(height) {
return DropdownMenuItem<
String?>(
value: height,
child: Text(
height,
maxLines: 1,
overflow:
TextOverflow
    .ellipsis,
),
);
},
).toList(),
onChanged:
isLoading.value
? null
    : (newValue) {
if (newValue !=
null) {
selectedHeight
    .value =
newValue;
}
},
),
),
),

// Current height
if (profileService
    .profile
    .value
    .height !=
null &&
profileService
    .profile
    .value
    .height!
    .isNotEmpty)
Padding(
padding: EdgeInsets.only(
top: 12.h,
),
child: Text(
'Current: ${profileService.profile.value.height}',
style:
GoogleFonts.poppins(
fontSize: 10.sp,
color:
Colors.grey[600],
fontStyle:
FontStyle.italic,
),
maxLines: 1,
overflow:
TextOverflow.ellipsis,
),
),
],
),
),
),
),

SizedBox(height: 18.h),

// Update button
SafeArea(
top: false,
child: Obx(
() => CustomButton(
text: "Update",
onPressed: selectedHeight.value ==
null ||
isLoading.value
? () {}
    : updateHeight,
isLoading: isLoading.value,
backgroundColor:
selectedHeight.value != null
? const Color(0xffFF6B00)
    : Colors.grey,
textColor: Colors.white,

borderRadius: 30.r,
fontSize: 11.sp,
fontWeight: FontWeight.w600,
letterSpacing: 0,
showArrow: true,
),
),
),

SizedBox(height: 90.h),
],
),
);
},
),
),

// Loading overlay
Obx(
() {
if (!isLoading.value) {
return const SizedBox.shrink();
}

return Container(
color: Colors.white.withOpacity(0.75),
child: const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircularProgressIndicator(
color: Color(0xffFF6A00),
),
SizedBox(height: 16),
Text(
'Updating height...',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),
],
),
),
);
},
),

// Error card
Obx(
() {
if (profileService
    .errorMessage.value.isEmpty ||
isLoading.value) {
return const SizedBox.shrink();
}

return Positioned(
left: 32.w,
right: 32.w,
bottom: 100.h,
child: Container(
padding: EdgeInsets.all(16.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(12.r),
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(0.08),
blurRadius: 10,
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.error_outline,
size: 40.sp,
color: Colors.red[300],
),

SizedBox(height: 8.h),

Text(
profileService.errorMessage.value,
style: GoogleFonts.poppins(
fontSize: 13.sp,
color: Colors.red,
),
textAlign: TextAlign.center,
),

SizedBox(height: 12.h),

ElevatedButton(
onPressed: _loadHeight,
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(0xffFF6A00),
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
30.r,
),
),
),
child: Text(
"Retry",
style: GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight:
FontWeight.w600,
color: Colors.white,
),
),
),
],
),
),
);
},
),
],
),
);
}
}

