
import 'dart:ui';

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SnotificationsView extends StatefulWidget {
const SnotificationsView({super.key});

@override
State<SnotificationsView> createState() => _SnotificationsViewState();
}

class _SnotificationsViewState extends State<SnotificationsView> {
bool pauseAll = true;
bool newMatches = true;
bool vote = true;
bool messages = false;

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

// Keep TRUE
extendBodyBehindAppBar: true,
extendBody: true,

// ==========================================================
// APP BAR
// ==========================================================

appBar: CustomAppBar(
title: "Notification",
    subtitle: "Manage your notification preferences",
onBackPressed: () {
Navigator.pop(context);
},
),

// ==========================================================
// BODY
// ==========================================================

body: Stack(
children: [
// ======================================================
// BACKGROUND IMAGE
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
// WHITE CONTENT CONTAINER
// ======================================================

SingleChildScrollView(
padding: EdgeInsets.fromLTRB(
16.w,
120.h, // AppBar ke niche
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
blurRadius: 12.r,
offset: Offset(0, 3.h),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// TOP DESCRIPTION CARD
// ==================================================

Container(
width: double.infinity,
padding: EdgeInsets.symmetric(
horizontal: 16.w,
vertical: 18.h,
),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.88),
borderRadius: BorderRadius.circular(16.r),
border: Border.all(
color: Colors.white.withOpacity(0.8),
width: 1,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.04),
blurRadius: 12.r,
offset: Offset(0, 4.h),
),
],
),
child: Text(
"Stay in the loop with Flirt Fever notifications! "
"Get alerts when you have a match, a new message, "
"or when someone likes your profile.",
textAlign: TextAlign.center,
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff7A7A7A),
height: 1.7,
),
),
),

SizedBox(height: 25.h),

// ==================================================
// MANAGE NOTIFICATIONS
// ==================================================

Text(
"Manage Your Notifications",
style: GoogleFonts.poppins(
fontSize: 15.sp,
fontWeight: FontWeight.w600,
letterSpacing: 0.3,
),
),

SizedBox(height: 8.h),

Text(
"Stay connected! Choose which notifications "
"you want to receive.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff7A7A7A),
height: 1.6,
),
),

SizedBox(height: 15.h),

// ==================================================
// PAUSE ALL
// ==================================================

_notificationTile(
title: "Pause all",
subtitle: "Temporarily pause notifications",
value: pauseAll,
onChanged: (value) {
setState(() {
pauseAll = value;
});
},
),

SizedBox(height: 25.h),

// ==================================================
// OTHER NOTIFICATIONS
// ==================================================

Text(
"Other Notifications",
style: GoogleFonts.poppins(
fontSize: 15.sp,
fontWeight: FontWeight.w600,
letterSpacing: 0.3,
),
),

SizedBox(height: 8.h),

Text(
"Never miss a chance to start a meaningful "
"conversation and explore exciting possibilities.",
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff7A7A7A),
height: 1.6,
),
),

SizedBox(height: 15.h),

// ==================================================
// NEW MATCHES
// ==================================================

_notificationTile(
title: "New Matches",
subtitle: "Get notified when you have a new match.",
value: newMatches,
onChanged: (value) {
setState(() {
newMatches = value;
});
},
),

SizedBox(height: 8.h),

// ==================================================
// LIKES / VOTES
// ==================================================

_notificationTile(
title: "Likes & Votes",
subtitle: "Someone likes or votes on your profile.",
value: vote,
onChanged: (value) {
setState(() {
vote = value;
});
},
),

SizedBox(height: 8.h),

// ==================================================
// MESSAGES
// ==================================================

_notificationTile(
title: "Messages",
subtitle: "Someone sends you a new message.",
value: messages,
onChanged: (value) {
setState(() {
messages = value;
});
},
),

SizedBox(height: 20.h),
],
),
),
),
],
),
);
}

// ==============================================================
// NOTIFICATION TILE
// ==============================================================

Widget _notificationTile({
required String title,
required String subtitle,
required bool value,
required ValueChanged<bool> onChanged,
}) {
return Container(
width: double.infinity,
padding: EdgeInsets.symmetric(
horizontal: 14.w,
vertical: 12.h,
),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.82),
borderRadius: BorderRadius.circular(15.r),
border: Border.all(
color: Colors.white.withOpacity(0.9),
width: 1,
),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.035),
blurRadius: 10.r,
offset: Offset(0, 3.h),
),
],
),
child: Row(
children: [
// ========================================================
// TEXT
// ========================================================

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight: FontWeight.w600,
color: Colors.black,
),
),

SizedBox(height: 3.h),

Text(
subtitle,
style: GoogleFonts.poppins(
fontSize: 11.sp,
color: const Color(0xff7A7A7A),
height: 1.4,
),
),
],
),
),

SizedBox(width: 8.w),

// ========================================================
// SWITCH
// ========================================================

Transform.scale(
scale: 0.75,
child: Switch(
value: value,
onChanged: onChanged,

activeColor: Colors.white,
activeTrackColor: const Color(0xffFF6A00),

inactiveThumbColor: Colors.white,
inactiveTrackColor: const Color(0xffE6E6E6),

trackOutlineColor:
WidgetStateProperty.all(Colors.transparent),

trackOutlineWidth:
WidgetStateProperty.all(0),
),
),
],
),
);
}
}
