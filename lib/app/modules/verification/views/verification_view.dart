
import 'dart:io';
import 'dart:ui';

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class VerificationView extends StatefulWidget {
const VerificationView({super.key});

@override
State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
File? selectedDocument;
File? selfieImage;

final ImagePicker picker = ImagePicker();

final ProfileServiceController profileController =
Get.find<ProfileServiceController>();

bool _isSubmitting = false;

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

// Keep this TRUE
extendBodyBehindAppBar: true,
extendBody: true,

appBar: CustomAppBar(
title: "Verification",
subtitle: "Verify your identity",
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

bottomNavigationBar: Container(
color: Colors.transparent,
padding: EdgeInsets.fromLTRB(
16.w,
8.h,
16.w,
8.h,
),
child: SafeArea(
child: CustomButton(
text: "Submit",
onPressed: _isSubmitting ? () {} : _submitVerification,
backgroundColor: const Color(0xffFF6A00),
textColor: Colors.white,
borderRadius: 30.r,
fontSize: 14.sp,
fontWeight: FontWeight.w600,
letterSpacing: 1.5.w,
showArrow: true,
isLoading: _isSubmitting,
),
),
),

body: Stack(
children: [
// Background
Positioned.fill(
child: Image.asset(
"assets/images/LoginBack2.png",
fit: BoxFit.cover,
),
),

// Background overlay
Positioned.fill(
child: Container(
color: Colors.white.withOpacity(0.70),
),
),

Obx(
() => SingleChildScrollView(
// IMPORTANT:
// Because extendBodyBehindAppBar is TRUE,
// start the white container below the AppBar.
padding: EdgeInsets.fromLTRB(
16.w,
120.h,
16.w,
90.h,
),
child: Container(
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
if (profileController
    .errorMessage
    .value
    .isNotEmpty)
Container(
padding: EdgeInsets.all(12.w),
margin: EdgeInsets.only(
bottom: 16.h,
),
decoration: BoxDecoration(
color: Colors.red.shade50,
borderRadius:
BorderRadius.circular(12.r),
border: Border.all(
color: Colors.red.shade200,
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.error_outline,
color: Colors.red.shade700,
size: 20.sp,
),
SizedBox(width: 10.w),
Expanded(
child: Text(
profileController
    .errorMessage
    .value,
style: GoogleFonts.poppins(
fontSize: 12.sp,
color:
Colors.red.shade700,
),
),
),
],
),
),

// WHY VERIFY
Container(
padding: EdgeInsets.all(14.w),
decoration: BoxDecoration(
color: const Color(0xffFFF4EB),
borderRadius:
BorderRadius.circular(15.r),
border: Border.all(
color: const Color(0xffFFD6B5),
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.info_outline,
color:
const Color(0xffFF6A00),
size: 22.sp,
),
SizedBox(width: 10.w),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
"Why Verify?",
style:
GoogleFonts.poppins(
letterSpacing: 1.5.w,
fontWeight:
FontWeight.w600,
fontSize: 14.sp,
),
),
SizedBox(height: 6.h),
Text(
"Verify Your Identity For Build Trust.",
style:
GoogleFonts.poppins(
fontSize: 12.sp,
color:
Colors.grey.shade700,
height: 1.6,
),
),
],
),
),
],
),
),

SizedBox(height: 25.h),

// TITLE
Text(
"Verify Your Identity",
style: GoogleFonts.poppins(
letterSpacing: 1.5.w,
fontWeight: FontWeight.w700,
fontSize: 14.sp,
),
),

SizedBox(height: 6.h),

Text(
"Choose Any One Option To Verify",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.grey.shade600,
),
),

SizedBox(height: 25.h),

// DOCUMENT TITLE
Row(
children: [
Text(
"Verify Document",
style: GoogleFonts.poppins(
letterSpacing: 1.5.w,
fontWeight: FontWeight.w600,
fontSize: 15.sp,
),
),
SizedBox(width: 15.w),
Text(
"Recommended",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.green,
fontWeight: FontWeight.w600,
),
),
],
),

SizedBox(height: 8.h),

Text(
"Upload your government-issued ID like Aadhaar, PAN, Driving License or Passport.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.grey.shade600,
),
),

SizedBox(height: 12.h),

// DOCUMENT UPLOAD
DottedBorder(
options:
RoundedRectDottedBorderOptions(
radius: Radius.circular(16.r),
dashPattern: const [8, 4],
color: Colors.grey,
strokeWidth: 1.5.w,
padding: EdgeInsets.zero,
),
child: SizedBox(
width: double.infinity,
child: selectedDocument == null
? Padding(
padding:
EdgeInsets.all(15.w),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Icon(
Icons
    .cloud_upload_outlined,
size: 30.sp,
color: Colors.grey,
),
SizedBox(height: 8.h),
Text(
"select your file or drag and drop",
style:
GoogleFonts.poppins(
fontSize: 12.sp,
fontWeight:
FontWeight.w500,
),
),
SizedBox(height: 4.h),
Text(
"pdf, jpg, docx accepted",
style:
GoogleFonts.poppins(
fontSize: 11.sp,
color:
Colors.grey.shade500,
),
),
SizedBox(height: 12.h),
SizedBox(
height: 40.h,
child: ElevatedButton(
onPressed:
pickDocument,
style:
ElevatedButton
    .styleFrom(
backgroundColor:
const Color(
0xffFF6A00,
),
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
30.r,
),
),
minimumSize:
Size(
120.w,
40.h,
),
),
child: Text(
"Browse",
style:
GoogleFonts
    .poppins(
color:
Colors.white,
fontSize: 12.sp,
fontWeight:
FontWeight.w600,
),
),
),
),
],
),
)
    : Stack(
children: [
ClipRRect(
borderRadius:
BorderRadius
    .circular(12.r),
child: Image.file(
selectedDocument!,
width:
double.infinity,
height: 180.h,
fit: BoxFit.cover,
),
),
Positioned(
top: 8.h,
right: 8.w,
child:
GestureDetector(
onTap: () {
setState(() {
selectedDocument =
null;
});
},
child: Container(
padding:
EdgeInsets.all(
4.w,
),
decoration:
BoxDecoration(
color: Colors.black
    .withOpacity(
0.6,
),
shape:
BoxShape.circle,
),
child: Icon(
Icons.close,
color:
Colors.white,
size: 18.sp,
),
),
),
),
],
),
),
),

SizedBox(height: 25.h),

// SELFIE TITLE
Text(
"Verify Photo (Selfie)",
style: GoogleFonts.poppins(
letterSpacing: 1.5.w,
fontWeight: FontWeight.w600,
fontSize: 15.sp,
),
),

SizedBox(height: 8.h),

Text(
"Take a clear selfie so we can verify that you are the person in your profile.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.grey.shade600,
),
),

SizedBox(height: 12.h),

// SELFIE
GestureDetector(
onTap: selfieImage == null
? pickSelfie
    : null,
child: Container(
width: double.infinity,
height: 130.h,
alignment: Alignment.center,
child: selfieImage == null
? Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: [
Stack(
clipBehavior:
Clip.none,
children: [
Container(
height: 80.h,
width: 80.w,
decoration:
const BoxDecoration(
color: Color(
0xFFFFF0E6,
),
shape: BoxShape
    .circle,
),
child: Icon(
Icons
    .camera_alt_outlined,
size: 28.sp,
color: Colors.grey,
),
),
Positioned(
bottom: -2.h,
right: -2.w,
child: Container(
height: 24.h,
width: 24.w,
decoration:
BoxDecoration(
color:
Colors.white,
shape: BoxShape
    .circle,
border:
Border.all(
color:
const Color(
0xffEAEAEA,
),
width: 1.w,
),
),
child: Icon(
Icons.add,
size: 16.sp,
color:
const Color(
0xFFFF6A00,
),
),
),
),
],
),
SizedBox(height: 10.h),
Text(
"Add Photo (Selfie)",
style:
GoogleFonts.poppins(
fontSize: 12.sp,
color: Colors.grey,
fontWeight:
FontWeight.w500,
),
),
],
)
    : Stack(
alignment:
Alignment.center,
children: [
Container(
padding:
EdgeInsets.all(2.w),
decoration:
BoxDecoration(
shape:
BoxShape.circle,
border: Border.all(
color:
const Color(
0xffFF6A00,
),
width: 1.5.w,
),
),
child: CircleAvatar(
radius: 40.r,
backgroundColor:
const Color(
0xFFFFF0E6,
),
backgroundImage:
FileImage(
selfieImage!,
),
),
),
Positioned(
bottom: 0,
right: 0,
child:
GestureDetector(
onTap: () {
setState(() {
selfieImage =
null;
});
},
child: Container(
height: 28.h,
width: 28.w,
decoration:
BoxDecoration(
color:
Colors.white,
shape: BoxShape
    .circle,
border:
Border.all(
color:
const Color(
0xffEAEAEA,
),
width: 1.w,
),
),
child: Icon(
Icons.close,
size: 16.sp,
color: Colors.red,
),
),
),
),
],
),
),
),

SizedBox(height: 16.h),

// SECURITY INFO
Container(
padding: EdgeInsets.symmetric(
vertical: 12.h,
horizontal: 16.w,
),
decoration: BoxDecoration(
color: const Color(0xFFE8F5E9),
borderRadius:
BorderRadius.circular(12.r),
border: Border.all(
color: Colors.green.shade300,
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
Icons.lock_outline,
size: 18.sp,
color: Colors.green,
),
SizedBox(width: 10.w),
Expanded(
child: Text(
"Your information is secure and encrypted. We never share your data with anyone.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color:
Colors.green.shade800,
fontWeight: FontWeight.w500,
height: 1.5,
),
),
),
],
),
),
],
),
),
),
),
],
),
);
}

Future<void> pickDocument() async {
final XFile? file = await picker.pickImage(
source: ImageSource.gallery,
imageQuality: 80,
);

if (file != null) {
setState(() {
selectedDocument = File(file.path);
});
}
}

Future<void> pickSelfie() async {
final XFile? image = await picker.pickImage(
source: ImageSource.camera,
imageQuality: 80,
);

if (image != null) {
setState(() {
selfieImage = File(image.path);
});
}
}

Future<void> _submitVerification() async {
if (selectedDocument == null && selfieImage == null) {
Get.snackbar(
'Error',
'Please upload a document or take a selfie to verify your identity.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.red.shade50,
colorText: Colors.red.shade800,
duration: const Duration(seconds: 3),
);
return;
}

setState(() {
_isSubmitting = true;
});

try {
final success = await profileController.updateVerification(
document: selectedDocument,
selfie: selfieImage,
);

if (success) {
Get.snackbar(
'Success',
'Verification submitted successfully!',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.green.shade50,
colorText: Colors.green.shade800,
duration: const Duration(seconds: 3),
);

Future.delayed(
const Duration(milliseconds: 500),
() {
if (mounted) {
Get.back();
}
},
);
} else {
Get.snackbar(
'Error',
profileController.errorMessage.value.isNotEmpty
? profileController.errorMessage.value
    : 'Failed to submit verification. Please try again.',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.red.shade50,
colorText: Colors.red.shade800,
duration: const Duration(seconds: 3),
);
}
} catch (e) {
Get.snackbar(
'Error',
'An unexpected error occurred: $e',
snackPosition: SnackPosition.BOTTOM,
backgroundColor: Colors.red.shade50,
colorText: Colors.red.shade800,
duration: const Duration(seconds: 3),
);
} finally {
if (mounted) {
setState(() {
_isSubmitting = false;
});
}
}
}
}

