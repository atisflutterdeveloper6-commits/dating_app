
// lib/app/modules/edit_profile/views/editphoto_view.dart

import 'dart:io';

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class EditphotoView extends StatefulWidget {
const EditphotoView({super.key});

@override
State<EditphotoView> createState() => _EditPhotoViewState();
}

class _EditPhotoViewState extends State<EditphotoView> {
final ImagePicker picker = ImagePicker();

final ProfileServiceController profileService =
Get.find<ProfileServiceController>();

final List<dynamic> photos = List<dynamic>.filled(6, null);

bool isLoading = false;
bool isFetching = false;

@override
void initState() {
super.initState();
_loadExistingPhotos();
}

// ============================================================
// LOAD EXISTING PHOTOS
// ============================================================

void _loadExistingPhotos() {
try {
isFetching = true;

for (int i = 0; i < photos.length; i++) {
photos[i] = null;
}

final existingPhotoPaths = profileService.photoPaths;

if (existingPhotoPaths.isNotEmpty) {
print(
'📸 Loading ${existingPhotoPaths.length} existing photos from photoPaths',
);

for (int i = 0;
i < existingPhotoPaths.length && i < 6;
i++) {
final path = existingPhotoPaths[i];

if (path.isNotEmpty && File(path).existsSync()) {
photos[i] = File(path);

print('📸 Loaded local photo $i: $path');
}
}
} else {
final profilePhotos = profileService.profile.value.photos;

if (profilePhotos != null && profilePhotos.isNotEmpty) {
print(
'📸 Loading ${profilePhotos.length} photos from profile data',
);

for (int i = 0; i < profilePhotos.length && i < 6; i++) {
final photo = profilePhotos[i];

if (photo is Map<String, dynamic> &&
photo.containsKey('image')) {
final imageUrl = photo['image'] as String?;

if (imageUrl != null && imageUrl.isNotEmpty) {
photos[i] = imageUrl;

print(
'📸 Loaded network photo $i: $imageUrl',
);
}
} else if (photo is String && photo.isNotEmpty) {
if (photo.startsWith('http://') ||
photo.startsWith('https://')) {
photos[i] = photo;

print(
'📸 Loaded network photo $i: $photo',
);
} else if (File(photo).existsSync()) {
photos[i] = File(photo);

if (!profileService.photoPaths.contains(photo)) {
profileService.photoPaths.add(photo);
}

print(
'📸 Loaded local photo $i: $photo',
);
}
}
}
}
}

if (mounted) {
setState(() {});
}

isFetching = false;
} catch (e) {
print('❌ Error loading photos: $e');

isFetching = false;
}
}

// ============================================================
// PICK IMAGE
// ============================================================

Future<void> pickImage(int index) async {
if (isLoading) return;

final XFile? image = await picker.pickImage(
source: ImageSource.gallery,
imageQuality: 80,
);

if (image != null) {
setState(() {
photos[index] = File(image.path);
});

CustomToast.success('Photo added successfully');
}
}

// ============================================================
// REMOVE IMAGE
// ============================================================

void removeImage(int index) {
setState(() {
photos[index] = null;
});

CustomToast.info('Photo removed');
}

// ============================================================
// PHOTO COUNT
// ============================================================

int get uploadedPhotoCount {
return photos.where((photo) => photo != null).length;
}

bool get hasMinimumPhotos {
return uploadedPhotoCount >= 1;
}

bool _isFile(dynamic photo) {
return photo is File;
}

bool _isUrl(dynamic photo) {
return photo is String &&
(photo.startsWith('http://') ||
photo.startsWith('https://'));
}

// ============================================================
// UPDATE PHOTOS
// ============================================================

Future<void> updatePhotos() async {
if (isLoading) return;

if (!hasMinimumPhotos) {
CustomToast.warning('Please add at least 1 photo');
return;
}

setState(() {
isLoading = true;
});

try {
final List<String> validPhotoPaths = photos
    .where(
(photo) =>
photo != null &&
_isFile(photo) &&
photo.existsSync(),
)
    .map<String>((photo) => photo.path)
    .toList();

if (validPhotoPaths.isNotEmpty) {
print(
'📸 Updating ${validPhotoPaths.length} photos',
);

profileService.setPhotoPaths(validPhotoPaths);

final bool success =
await profileService.updateProfile();

if (mounted) {
setState(() {
isLoading = false;
});
}

if (success) {
await profileService.fetchMyProfile();

_loadExistingPhotos();

CustomToast.success(
'Photos updated successfully! 🎉',
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
CustomToast.error(
profileService.errorMessage.value,
);

_loadExistingPhotos();
}
} else {
CustomToast.info(
'No new photos to upload',
);

if (mounted) {
setState(() {
isLoading = false;
});
}

Get.back();
}
} catch (e) {
if (mounted) {
setState(() {
isLoading = false;
});
}

CustomToast.error(
'Failed to update photos: $e',
);

print(
'❌ Error updating photos: $e',
);
}
}

// ============================================================
// SHIMMER
// ============================================================

Widget _buildShimmerPhoto(int index) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16.r),
),
child: Shimmer.fromColors(
baseColor: Colors.grey[300]!,
highlightColor: Colors.grey[100]!,
child: Container(
width: double.infinity,
height: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16.r),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.photo_camera,
size: 28.sp,
color: Colors.grey[400],
),
SizedBox(height: 4.h),
Text(
'Photo ${index + 1}',
style: TextStyle(
fontSize: 10.sp,
color: Colors.grey[400],
),
),
],
),
),
),
);
}

// ============================================================
// NETWORK IMAGE
// ============================================================

Widget _buildNetworkImage(
String url,
int index,
) {
return ClipRRect(
borderRadius: BorderRadius.circular(14.r),
child: Image.network(
url,
fit: BoxFit.cover,
width: double.infinity,
height: double.infinity,
loadingBuilder:
(context, child, loadingProgress) {
if (loadingProgress == null) {
return child;
}

return _buildShimmerPhoto(index);
},
errorBuilder:
(context, error, stackTrace) {
return Container(
color: Colors.grey[200],
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.broken_image,
size: 28.sp,
color: Colors.grey[400],
),
SizedBox(height: 4.h),
Text(
'Photo ${index + 1}',
style: TextStyle(
fontSize: 10.sp,
color: Colors.grey[500],
),
),
],
),
);
},
),
);
}

// ============================================================
// PHOTO WIDGET
// ============================================================

Widget _buildPhotoWidget(
dynamic photo,
int index,
) {
if (photo is Map<String, dynamic>) {
final imageUrl =
photo['image'] as String?;

if (imageUrl != null &&
imageUrl.isNotEmpty) {
return _buildNetworkImage(
imageUrl,
index,
);
}
}

if (_isUrl(photo)) {
return _buildNetworkImage(
photo as String,
index,
);
}

if (_isFile(photo)) {
return ClipRRect(
borderRadius:
BorderRadius.circular(14.r),
child: Image.file(
photo,
fit: BoxFit.cover,
width: double.infinity,
height: double.infinity,
errorBuilder:
(context, error, stackTrace) {
return Container(
color: Colors.grey[200],
child: const Icon(
Icons.broken_image,
color: Colors.grey,
),
);
},
),
);
}

return Container(
color: Colors.grey[200],
child: Center(
child: Icon(
Icons.image_not_supported,
size: 28.sp,
color: Colors.grey[400],
),
),
);
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
// APP BAR - SAME AS EDIT PROFILE
// ========================================================

appBar: CustomAppBar(
title: "Edit Photo",
subtitle: "Update your profile photos",

onBackPressed: () {
Get.back();
},

actions: [
IconButton(
onPressed: () {
Get.find<DashboardController>()
    .changeTab(6);

Get.until(
(route) =>
route.settings.name ==
'/dashboard' ||
Get.currentRoute ==
'/dashboard',
);
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
color:
const Color(0xFFFF6B00),
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
// ----------------------------------------------------
// BACKGROUND
// ----------------------------------------------------

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


// ----------------------------------------------------
// MAIN CONTENT
// ----------------------------------------------------

SafeArea(
child: Padding(
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
// HEADER - SAME AS EDIT PROFILE
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
    .photo_library_outlined,
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
CrossAxisAlignment.start,
children: [
Text(
"Profile Photos",
style:
TextStyle(
fontSize: 14.sp,
fontWeight:
FontWeight.w700,
letterSpacing:
1.2,
),
),

SizedBox(height: 8.h),

Text(
"Update your profile photos.",
style:
TextStyle(
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
// WHITE CARD
// ==================================================

Expanded(
child: SingleChildScrollView(
physics:
const BouncingScrollPhysics(),
child: Container(
width:
double.infinity,

padding:
EdgeInsets.fromLTRB(
16.w,
24.h,
16.w,
24.h,
),

decoration:
BoxDecoration(
color:
Colors.white,

borderRadius:
BorderRadius.circular(
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
color:
Colors.black
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
// CARD TITLE
// ==================================================

Text(
"Your Photos",
style:
GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight:
FontWeight.w600,
color:
const Color(
0xff1F1F1F,
),
),
),

SizedBox(height: 6.h),

Row(
mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,
children: [
Text(
"$uploadedPhotoCount/6 photos uploaded",
style:
TextStyle(
fontSize:
11.sp,
color:
hasMinimumPhotos
? Colors.green
    : Colors.grey,
fontWeight:
FontWeight.w500,
),
),

if (profileService
    .photoPaths
    .isNotEmpty)
Text(
'${profileService.photoPaths.length} saved',
style:
TextStyle(
fontSize:
10.sp,
color:
Colors.blue,
fontWeight:
FontWeight.w400,
),
),
],
),

SizedBox(height: 18.h),

// ==================================================
// PHOTO GRID
// ==================================================

GridView.builder(
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: 6,

gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount:
2,
crossAxisSpacing:
10.w,
mainAxisSpacing:
10.h,
childAspectRatio:
1.4,
),

itemBuilder:
(context, index) {
final photo =
photos[index];

if (isFetching) {
return _buildShimmerPhoto(
index,
);
}

return GestureDetector(
onTap:
isLoading
? null
    : () =>
pickImage(
index,
),

child:
DottedBorder(
options:
RoundedRectDottedBorderOptions(
radius:
Radius.circular(
14.r,
),
color:
photo !=
null
? const Color(
0xffFF6B00,
)
    : Colors
    .grey
    .shade400,
strokeWidth:
photo !=
null
? 2.w
    : 1.5.w,
dashPattern:
const [
6,
4,
],
padding:
EdgeInsets
    .zero,
),

child:
Container(
decoration:
BoxDecoration(
color:
const Color(
0xffF5F5F5,
),
borderRadius:
BorderRadius
    .circular(
14.r,
),
),

child:
Stack(
children: [
// --------------------------------
// PHOTO
// --------------------------------

Positioned.fill(
child:
photo !=
null
? _buildPhotoWidget(
photo,
index,
)
    : Center(
child:
Icon(
Icons
    .camera_alt_outlined,
size:
28.sp,
color:
const Color(
0xffD2D1D1,
),
),
),
),

// --------------------------------
// ADD / REMOVE
// --------------------------------

Positioned(
right:
6.w,
bottom:
6.h,
child:
GestureDetector(
onTap:
isLoading
? null
    : () {
if (photo !=
null) {
removeImage(
index,
);
} else {
pickImage(
index,
);
}
},
child:
Container(
height:
26.h,
width:
26.w,
decoration:
const BoxDecoration(
color:
Colors.white,
shape:
BoxShape.circle,
boxShadow: [
BoxShadow(
color:
Colors.black12,
blurRadius:
5,
offset:
Offset(
0,
2,
),
),
],
),
child:
Icon(
photo ==
null
? Icons
    .add
    : Icons
    .close,
size:
16.sp,
color:
const Color(
0xffFF6B00,
),
),
),
),
),

// --------------------------------
// LOADING
// --------------------------------

if (isLoading)
Positioned.fill(
child:
Container(
decoration:
BoxDecoration(
color: Colors
    .black
    .withOpacity(
0.30,
),
borderRadius:
BorderRadius.circular(
14.r,
),
),
child:
Center(
child:
SizedBox(
height:
26.h,
width:
26.w,
child:
const CircularProgressIndicator(
color:
Colors.white,
strokeWidth:
2,
),
),
),
),
),
],
),
),
),
);
},
),

SizedBox(height: 18.h),

// ==================================================
// PROFILE PHOTO COUNT
// ==================================================

if (profileService
    .photoPaths
    .isNotEmpty ||
(profileService
    .profile
    .value
    .photos !=
null &&
profileService
    .profile
    .value
    .photos!
    .isNotEmpty))
Center(
child: Text(
'${profileService.photoPaths.isNotEmpty ? profileService.photoPaths.length : profileService.profile.value.photos?.length ?? 0} photos in profile',
style:
TextStyle(
fontSize:
10.sp,
color:
Colors.grey[600],
fontStyle:
FontStyle.italic,
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
// UPDATE BUTTON - SAME AS EDIT PROFILE
// ==================================================

SafeArea(
top: false,
child: CustomButton(
text: "Update Photos",
onPressed:
isLoading ||
isFetching
? () {}
    : updatePhotos,
isLoading:
isLoading,
backgroundColor:
hasMinimumPhotos
? const Color(
0xffFF6B00,
)
    : Colors.grey,
textColor:
Colors.white,
height: 50.h,
borderRadius:
30.r,
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

// ========================================================
// LOADING OVERLAY
// ========================================================

if (isFetching)
Positioned.fill(
child: Container(
color:
Colors.white.withOpacity(
0.10,
),
),
),
],
),
);
}
}

