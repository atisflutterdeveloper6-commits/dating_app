
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/models/all_gender_model.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';

class ProfilegenderView extends StatefulWidget {
const ProfilegenderView({super.key});

@override
State<ProfilegenderView> createState() => _ProfilegenderViewState();
}

class _ProfilegenderViewState extends State<ProfilegenderView> {
// ============================================================
// CONTROLLER
// ============================================================

final ProfileServiceController profileController =
Get.find<ProfileServiceController>();

// ============================================================
// GENDER
// ============================================================

String? selectedGenderId;
String? selectedGenderTitle;

// ============================================================
// SEXUAL ORIENTATION
// ============================================================

String? selectedOrientationId;
String? selectedOrientationTitle;

// ============================================================
// API LISTS
// ============================================================

List<GenderModel> genders = [];
List<SexualOrientationModel> orientations = [];

// ============================================================
// LOADING
// ============================================================

bool isLoading = false;
bool isFetching = true;

// ============================================================
// GENDER IMAGE
// ============================================================

String _getGenderImagePath(String genderName) {
final normalized = genderName.trim().toLowerCase();

if (normalized == 'man' || normalized == 'male') {
return 'assets/images/male.png';
}

return 'assets/images/female.png';
}

// ============================================================
// INIT
// ============================================================

@override
void initState() {
super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) {
_loadData();
});
}

// ============================================================
// LOAD DATA
// ============================================================

Future<void> _loadData() async {
if (!mounted) return;

setState(() {
isFetching = true;
});

try {
debugPrint('========================================');
debugPrint('📤 Loading gender & orientation');
debugPrint('========================================');

final genderList =
await profileController.fetchGenders();

final orientationList =
await profileController.fetchSexualOrientations();

if (!mounted) return;

setState(() {
genders = genderList;
orientations = orientationList;

// ======================================================
// CURRENT PROFILE
// ======================================================

final currentProfile =
profileController.profile.value;

// ======================================================
// CURRENT GENDER
// ======================================================

if (currentProfile.gender != null &&
currentProfile.gender!.isNotEmpty) {
GenderModel? foundGender;

try {
foundGender = genders.firstWhere(
(g) => g.id == currentProfile.gender,
);
} catch (_) {
try {
foundGender = genders.firstWhere(
(g) =>
g.gender.trim().toLowerCase() ==
currentProfile.gender!
    .trim()
    .toLowerCase(),
);
} catch (_) {
foundGender = null;
}
}

if (foundGender != null) {
selectedGenderId = foundGender.id;
selectedGenderTitle = foundGender.gender;

debugPrint(
'✅ Current gender: '
'${foundGender.gender} (${foundGender.id})',
);
}
}

// ======================================================
// CURRENT SEXUAL ORIENTATION
// ======================================================

if (currentProfile.sexualOrientation != null &&
currentProfile.sexualOrientation!.isNotEmpty) {
SexualOrientationModel? foundOrientation;

try {
foundOrientation = orientations.firstWhere(
(o) => o.id == currentProfile.sexualOrientation,
);
} catch (_) {
try {
foundOrientation = orientations.firstWhere(
(o) =>
o.title.trim().toLowerCase() ==
currentProfile.sexualOrientation!
    .trim()
    .toLowerCase(),
);
} catch (_) {
foundOrientation = null;
}
}

if (foundOrientation != null) {
selectedOrientationId = foundOrientation.id;
selectedOrientationTitle = foundOrientation.title;

debugPrint(
'✅ Current orientation: '
'${foundOrientation.title} '
'(${foundOrientation.id})',
);
}
}

isFetching = false;
});
} catch (e) {
debugPrint(
'❌ Error loading gender/orientation: $e',
);

if (!mounted) return;

setState(() {
isFetching = false;
});

CustomToast.error(
'Failed to load gender & orientation',
);
}
}

// ============================================================
// UPDATE
// ============================================================

Future<void> updateGenderAndOrientation() async {
if (isLoading) return;

// ============================================================
// VALIDATION
// ============================================================

if (selectedGenderId == null ||
selectedGenderId!.isEmpty) {
CustomToast.error(
"Please select your gender",
);
return;
}

if (selectedOrientationId == null ||
selectedOrientationId!.isEmpty) {
CustomToast.error(
"Please select your sexual orientation",
);
return;
}

setState(() {
isLoading = true;
});

try {
debugPrint('========================================');
debugPrint('📤 UPDATING GENDER & ORIENTATION');
debugPrint(
'📤 Gender ID: $selectedGenderId',
);
debugPrint(
'📤 Gender Title: $selectedGenderTitle',
);
debugPrint(
'📤 Orientation ID: $selectedOrientationId',
);
debugPrint(
'📤 Orientation Title: $selectedOrientationTitle',
);
debugPrint('========================================');

// ========================================================
// UPDATE LOCAL PROFILE
// ========================================================

profileController.updateGender(
selectedGenderId,
);

profileController.updateSexualOrientation(
selectedOrientationId,
);

// ========================================================
// UPDATE SERVER
// ========================================================

final success =
await profileController.updateProfile();

if (!mounted) return;

setState(() {
isLoading = false;
});

debugPrint(
'📤 Update profile success: $success',
);

debugPrint(
'📤 Error: '
'${profileController.errorMessage.value}',
);

// ========================================================
// SUCCESS
// ========================================================

if (success) {
CustomToast.success(
"Gender & orientation updated successfully! 🎉",
);

// Refresh profile
await profileController.fetchMyProfile();

Future.delayed(
const Duration(milliseconds: 500),
() {
if (Get.isOverlaysOpen) return;
Get.back();
},
);
} else {
CustomToast.error(
profileController.errorMessage.value.isNotEmpty
? profileController.errorMessage.value
    : "Failed to update profile",
);
}
} catch (e) {
if (!mounted) return;

setState(() {
isLoading = false;
});

debugPrint(
'❌ Error updating gender/orientation: $e',
);

CustomToast.error(
"Failed to update: $e",
);
}
}

// ============================================================
// BUILD
// ============================================================

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

// ========================================================
// APP BAR
// ========================================================

appBar: CustomAppBar(
title: "Gender & Orientation",
subtitle: "Update your preferences",
onBackPressed: () {
Get.back();
},
actions: [
IconButton(
onPressed: () {
Get.find<DashboardController>()
    .changeTab(6);

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
color:
Colors.black.withOpacity(0.10),
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

// ========================================================
// BODY
// ========================================================

body: Stack(
children: [
// ======================================================
// BACKGROUND
// ======================================================


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


// ======================================================
// MAIN CONTENT
// ======================================================

SafeArea(
child: isFetching
? const Center(
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
CircularProgressIndicator(
color:
Color(0xffFF6A00),
),
SizedBox(height: 16),
Text(
'Loading...',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),
],
),
)
    : Padding(
padding:
EdgeInsets.symmetric(
horizontal: 28.w,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
SizedBox(height: 20.h),

// ==================================================
// HEADER
// ==================================================

Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
padding:
EdgeInsets.all(8.w),
decoration:
BoxDecoration(
shape:
BoxShape.circle,
border:
Border.all(
color:
const Color(
0xFFFFE0CC,
),
width: 1.2,
),
),
child: Icon(
Icons
    .person_outline,
color:
const Color(
0xFFFF6B00,
),
size: 22.sp,
),
),

SizedBox(width: 20.w),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
Text(
"Gender & Orientation",
style:
GoogleFonts
    .poppins(
fontSize: 14.sp,
fontWeight:
FontWeight
    .w700,
letterSpacing:
1.2,
),
),

SizedBox(
height: 8.h,
),

Text(
"Update your gender and sexual orientation.",
style:
GoogleFonts
    .poppins(
fontSize: 9.sp,
color:
Colors.black54,
letterSpacing:
0.5,
),
),
],
),
),
],
),

SizedBox(height: 20.h),

// ==================================================
// WHITE CONTENT CARD
// ==================================================

Expanded(
child:
SingleChildScrollView(
child: Container(
width:
double.infinity,
padding:
EdgeInsets.fromLTRB(
16.w,
30.h,
16.w,
30.h,
),
decoration:
BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius
    .circular(
14.r,
),
border:
Border.all(
color:
const Color(
0xFFF1E8E4,
),
width: 0.8,
),
boxShadow: [
BoxShadow(
color: Colors
    .black
    .withOpacity(
0.035,
),
blurRadius: 12,
offset:
const Offset(
0,
3,
),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,
children: [
// ==================================================
// GENDER TITLE
// ==================================================

Text(
'Select your gender',
style:
GoogleFonts
    .poppins(
fontSize: 13.sp,
fontWeight:
FontWeight
    .w500,
color:
const Color(
0xff1F1F1F,
),
),
),

SizedBox(
height: 12.h,
),

// ==================================================
// GENDER OPTIONS
// ==================================================

...genders
    .where(
(gender) {
final
normalized =
gender.gender
    .trim()
    .toLowerCase();

return normalized ==
'man' ||
normalized ==
'male' ||
normalized ==
'woman' ||
normalized ==
'female';
},
)
    .map(
(gender) {
final
isSelected =
selectedGenderId ==
gender.id;

final imagePath =
_getGenderImagePath(
gender.gender,
);

return GestureDetector(
onTap:
isLoading
? null
    : () {
setState(
() {
selectedGenderId =
gender.id;
selectedGenderTitle =
gender.gender;
},
);
},
child:
AnimatedContainer(
duration:
const Duration(
milliseconds:
180,
),
width:
double.infinity,
height:
68.h,
margin:
EdgeInsets.only(
bottom:
10.h,
),
padding:
EdgeInsets.symmetric(
horizontal:
14.w,
),
decoration:
BoxDecoration(
color: isSelected
? const Color(
0xFFFFF2E8,
)
    : Colors
    .white,
borderRadius:
BorderRadius.circular(
12.r,
),
border:
Border.all(
color: isSelected
? const Color(
0xffFF6B00,
)
    : const Color(
0xffDCDCDC,
),
width:
isSelected
? 1.5
    : 1,
),
),
child:
Row(
children: [
// ==================================
// IMAGE
// ==================================

Container(
height:
44.w,
width:
44.w,
decoration:
BoxDecoration(
shape:
BoxShape.circle,
border:
Border.all(
color: isSelected
? const Color(
0xffFF6B00,
)
    : const Color(
0xffE5E5E5,
),
width:
1,
),
),
child:
ClipOval(
child:
Image.asset(
imagePath,
fit:
BoxFit.cover,
),
),
),

SizedBox(
width:
12.w,
),

// ==================================
// GENDER NAME
// ==================================

Expanded(
child:
Text(
gender.gender,
style:
GoogleFonts.poppins(
fontSize:
12.sp,
fontWeight:
isSelected
? FontWeight.w600
    : FontWeight.w500,
color:
isSelected
? const Color(
0xffFF6B00,
)
    : const Color(
0xff1E1E1E,
),
),
),
),

// ==================================
// RADIO
// ==================================

Icon(
isSelected
? Icons
    .radio_button_checked
    : Icons
    .radio_button_off,
size:
19.sp,
color:
isSelected
? const Color(
0xffFF6B00,
)
    : Colors
    .grey
    .shade400,
),
],
),
),
);
},
),

SizedBox(height: 14.h),

// ==================================================
// ORIENTATION TITLE
// ==================================================

Text(
'Select your sexual orientation',
style:
GoogleFonts
    .poppins(
fontSize: 13.sp,
fontWeight:
FontWeight
    .w500,
color:
const Color(
0xff1F1F1F,
),
),
),

SizedBox(
height: 12.h,
),

// ==================================================
// ORIENTATION DROPDOWN
// ==================================================

Container(
height: 50.h,
width:
double.infinity,
padding:
EdgeInsets
    .symmetric(
horizontal:
14.w,
),
decoration:
BoxDecoration(
color:
Colors.white,
borderRadius:
BorderRadius
    .circular(
12.r,
),
border:
Border.all(
color:
const Color(
0xffDCDCDC,
),
),
),
child:
DropdownButtonHideUnderline(
child:
DropdownButton<
String>(
value:
selectedOrientationId,
isExpanded:
true,
icon:
Icon(
Icons
    .keyboard_arrow_down,
size:
20.sp,
color:
const Color(
0xff555555,
),
),
style:
GoogleFonts
    .poppins(
fontSize:
13.sp,
color:
const Color(
0xff444444,
),
),
hint: Text(
'Select your orientation',
style:
GoogleFonts
    .poppins(
fontSize:
13.sp,
color:
const Color(
0xff999999,
),
),
),
items:
orientations
    .map(
(
orientation,
) {
return DropdownMenuItem<
String>(
value:
orientation.id,
child:
Text(
orientation
    .title,
maxLines:
1,
overflow:
TextOverflow.ellipsis,
),
);
},
).toList(),
onChanged:
isLoading
? null
    : (
value,
) {
if (value !=
null) {
setState(
() {
selectedOrientationId =
value;

final found =
orientations.firstWhere(
(o) =>
o.id ==
value,
);

selectedOrientationTitle =
found.title;
},
);
}
},
),
),
),

// ==================================================
// CURRENT GENDER
// ==================================================

if (selectedGenderTitle !=
null &&
selectedGenderTitle!
    .isNotEmpty)
Padding(
padding:
EdgeInsets.only(
top: 12.h,
),
child: Text(
'Current gender: '
'$selectedGenderTitle',
style:
GoogleFonts
    .poppins(
fontSize:
10.sp,
color:
Colors
    .grey[600],
fontStyle:
FontStyle
    .italic,
),
),
),

// ==================================================
// CURRENT ORIENTATION
// ==================================================

if (selectedOrientationTitle !=
null &&
selectedOrientationTitle!
    .isNotEmpty)
Padding(
padding:
EdgeInsets.only(
top: 6.h,
),
child: Text(
'Current orientation: '
'$selectedOrientationTitle',
style:
GoogleFonts
    .poppins(
fontSize:
10.sp,
color:
Colors
    .grey[600],
fontStyle:
FontStyle
    .italic,
),
),
),
],
),
),
),
),

SizedBox(height: 18.h),

// ==================================================
// UPDATE BUTTON
// ==================================================

SafeArea(
top: false,
child: CustomButton(
text: "Update",
onPressed:
selectedGenderId ==
null ||
selectedOrientationId ==
null ||
isLoading
? () {}
    : updateGenderAndOrientation,
isLoading: isLoading,
backgroundColor:
selectedGenderId !=
null &&
selectedOrientationId !=
null
? const Color(
0xffFF6B00,
)
    : Colors.grey,
textColor: Colors.white,

borderRadius: 30.r,
fontSize: 11.sp,
fontWeight:
FontWeight.w600,
letterSpacing: 0,
showArrow: true,
),
),

SizedBox(height: 90.h),
],
),
),
),

// ============================================================
// LOADING OVERLAY
// ============================================================

if (isLoading)
Positioned.fill(
child: Container(
color:
Colors.white.withOpacity(0.75),
child: const Center(
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [
CircularProgressIndicator(
color:
Color(0xffFF6A00),
),
SizedBox(height: 16),
Text(
'Updating...',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
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
}

