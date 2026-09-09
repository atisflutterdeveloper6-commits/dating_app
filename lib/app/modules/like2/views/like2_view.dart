
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/models/profile_all_model.dart';
import 'package:dating_app/app/modules/like2/controllers/like2_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class Like2View extends StatefulWidget {
const Like2View({super.key});

@override
State<Like2View> createState() => _Like2ViewState();
}

class _Like2ViewState extends State<Like2View> {
late final Like2Controller controller;

@override
void initState() {
super.initState();

// Reuse existing controller if already registered
controller = Get.isRegistered<Like2Controller>()
? Get.find<Like2Controller>()
    : Get.put(Like2Controller());

// Refresh liked profiles every time screen opens
controller.refreshLikedProfiles();
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
backgroundColor: Colors.transparent,
extendBodyBehindAppBar: true,
extendBody: true,

appBar: CustomAppBar(
title: "Like",
actions: [
IconButton(
onPressed: () => controller.refreshLikedProfiles(),
icon: const Icon(
Icons.refresh,
color: Colors.white,
),
),
],
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
child: Obx(() {
print(
'🖼️ BUILD like2 view — '
'isLoading=${controller.isLoading.value}, '
'count=${controller.likedProfiles.length}',
);

// ======================================================
// ERROR STATE
// ======================================================

if (controller.errorMessage.value.isNotEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline,
size: 64.sp,
color: Colors.red,
),

SizedBox(height: 16.h),

Text(
controller.errorMessage.value,
style: GoogleFonts.poppins(
fontSize: 16.sp,
color: Colors.grey[600],
),
textAlign: TextAlign.center,
),

SizedBox(height: 16.h),

ElevatedButton(
onPressed: () => controller.retryFetch(),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12.r),
),
),
child: Text(
'Retry',
style: GoogleFonts.poppins(
color: Colors.white,
fontWeight: FontWeight.w600,
),
),
),
],
),
);
}

// ======================================================
// EMPTY STATE
// ======================================================

if (!controller.isLoading.value &&
controller.likedProfiles.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.favorite_border,
size: 80.sp,
color: Colors.grey[400],
),

SizedBox(height: 16.h),

Text(
'No liked profiles yet',
style: GoogleFonts.poppins(
fontSize: 18.sp,
fontWeight: FontWeight.w600,
color: Colors.grey[600],
),
),

SizedBox(height: 8.h),

Text(
'Start liking profiles to see them here',
style: GoogleFonts.poppins(
fontSize: 14.sp,
color: Colors.grey[400],
),
),
],
),
);
}

// ======================================================
// LIKED PROFILES GRID
// ======================================================

return Padding(
padding: EdgeInsets.all(16.w),
child: GridView.builder(
itemCount: controller.isLoading.value
? 4
    : controller.likedProfiles.length,

gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 14.w,
mainAxisSpacing: 18.h,
childAspectRatio: 0.90,
),

itemBuilder: (context, index) {
// ==================================================
// SHIMMER LOADING
// ==================================================

if (controller.isLoading.value) {
return _buildShimmerCard(context);
}

// ==================================================
// PROFILE CARD
// ==================================================

final profile =
controller.likedProfiles[index];

return _buildLikedProfileCard(
context,
profile,
);
},
),
);
}),
),
],
),
);
}

// ================================================================
// SHIMMER CARD
// ================================================================

Widget _buildShimmerCard(BuildContext context) {
return ClipRRect(
borderRadius: BorderRadius.circular(16.r),
child: Shimmer.fromColors(
baseColor: Colors.grey[300]!,
highlightColor: Colors.grey[100]!,
child: Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16.r),
),

child: Stack(
children: [
// ======================================================
// IMAGE PLACEHOLDER
// ======================================================

Positioned.fill(
child: Container(
color: Colors.grey[300],
),
),

// ======================================================
// GRADIENT PLACEHOLDER
// ======================================================

Positioned.fill(
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.transparent,
Colors.black.withOpacity(0.5),
],
),
),
),
),

// ======================================================
// LIKE ICON PLACEHOLDER
// ======================================================

Positioned(
top: 10.h,
right: 10.w,
child: CircleAvatar(
radius: 11.r,
backgroundColor: Colors.grey[400],
child: Icon(
Icons.favorite,
color: Colors.grey[300],
size: 14.sp,
),
),
),

// ======================================================
// CLOSE ICON PLACEHOLDER
// ======================================================

Positioned(
top: 10.h,
left: 10.w,
child: CircleAvatar(
radius: 11.r,
backgroundColor: Colors.grey[400],
child: Icon(
Icons.close,
color: Colors.grey[300],
size: 14.sp,
),
),
),

// ======================================================
// USER INFO PLACEHOLDER
// ======================================================

Positioned(
left: 10.w,
right: 10.w,
bottom: 10.h,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
height: 16.h,
width: 80.w,
color: Colors.grey[300],
),

SizedBox(height: 4.h),

Container(
height: 12.h,
width: 60.w,
color: Colors.grey[300],
),
],
),
),
],
),
),
),
);
}

// ================================================================
// LIKED PROFILE CARD
// ================================================================

Widget _buildLikedProfileCard(
BuildContext context,
ProfileModel profile,
) {
final imageUrl = controller.getProfileImage(profile);
final displayName = controller.getDisplayName(profile);

return ClipRRect(
borderRadius: BorderRadius.circular(16.r),
child: Stack(
children: [
// ==========================================================
// PROFILE IMAGE
// ==========================================================

Positioned.fill(
child: imageUrl != null && imageUrl.isNotEmpty
? CachedNetworkImage(
imageUrl: imageUrl,
fit: BoxFit.fill,

placeholder: (context, url) {
return Container(
color: Colors.grey[300],
);
},

errorWidget: (context, url, error) {
return Container(
color: Colors.grey[300],
child: Icon(
Icons.person,
size: 50.sp,
color: Colors.grey[600],
),
);
},
)
    : Container(
color: Colors.grey[300],
child: Icon(
Icons.person,
size: 50.sp,
color: Colors.grey[600],
),
),
),

// ==========================================================
// BOTTOM FADE OVERLAY
// ==========================================================

Positioned.fill(
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.transparent,
Colors.transparent,
Colors.black.withOpacity(0.3),
Colors.black.withOpacity(0.7),
Colors.black.withOpacity(0.9),
],
stops: const [
0.0,
0.4,
0.6,
0.8,
1.0,
],
),
),
),
),

// ==========================================================
// LIKE ICON
// ==========================================================

Positioned(
top: 10.h,
right: 10.w,
child: GestureDetector(
onTap: () => _showUnlikeDialog(
context,
profile.id,
),
child: CircleAvatar(
radius: 14.r,
backgroundColor: Colors.white,
child: Icon(
Icons.favorite,
color: Colors.red[700],
size: 18.sp,
),
),
),
),

// ==========================================================
// USER INFO
// ==========================================================

Positioned(
left: 10.w,
right: 10.w,
bottom: 10.h,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
displayName,
style: GoogleFonts.poppins(
color: Colors.white,
fontSize: 12.sp,
fontWeight: FontWeight.w600,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),

if (profile.bio != null &&
profile.bio!.isNotEmpty)
Text(
profile.bio!,
style: GoogleFonts.poppins(
color: Colors.white.withOpacity(0.85),
fontSize: 8.sp,
),
maxLines: 1,
overflow: TextOverflow.ellipsis,
),
],
),
),
],
),
);
}

// ================================================================
// UNLIKE DIALOG
// ================================================================

void _showUnlikeDialog(
BuildContext context,
String? profileId,
) {
if (profileId == null) return;

showDialog(
context: context,
barrierDismissible: false,
builder: (context) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16.r),
),

title: Row(
children: [
Icon(
Icons.favorite,
color: Colors.red[700],
size: 24.sp,
),

SizedBox(width: 8.w),

Text(
'Unlike Profile',
style: GoogleFonts.poppins(
fontWeight: FontWeight.w600,
fontSize: 18.sp,
),
),
],
),

content: Text(
'Are you sure you want to unlike this profile?',
style: GoogleFonts.poppins(
fontSize: 14.sp,
color: Colors.grey[700],
),
),

actions: [
// ========================================================
// CANCEL
// ========================================================

TextButton(
onPressed: () => Navigator.pop(context),
child: Text(
'Cancel',
style: GoogleFonts.poppins(
color: Colors.grey[600],
fontSize: 14.sp,
fontWeight: FontWeight.w500,
),
),
),

// ========================================================
// UNLIKE
// ========================================================

ElevatedButton(
onPressed: () {
Navigator.pop(context);
controller.unlikeProfile(profileId);
},

style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xffFF6B00),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30.r),
),
padding: EdgeInsets.symmetric(
horizontal: 24.w,
vertical: 10.h,
),
),

child: Text(
'Unlike',
style: GoogleFonts.poppins(
color: Colors.white,
fontWeight: FontWeight.w500,
fontSize: 11.sp,
),
),
),
],
);
},
);
}
}
