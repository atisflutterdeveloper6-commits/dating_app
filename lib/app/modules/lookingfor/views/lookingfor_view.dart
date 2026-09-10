
// lib/app/modules/lookingfor/views/lookingfor_view.dart

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/models/all_gender_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/lookingfor_controller.dart';

// ============================================================
// SHIMMER EFFECT
// Keep your existing ShimmerEffect and ShimmerMask here
// ============================================================

class ShimmerEffect extends StatefulWidget {
final Widget child;
final Duration duration;
final Color baseColor;
final Color highlightColor;

const ShimmerEffect({
super.key,
required this.child,
this.duration = const Duration(milliseconds: 1500),
this.baseColor = Colors.grey,
this.highlightColor = Colors.white,
});

@override
State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
with SingleTickerProviderStateMixin {
late AnimationController _controller;
late Animation<double> _animation;

@override
void initState() {
super.initState();

_controller = AnimationController(
vsync: this,
duration: widget.duration,
)..repeat();

_animation = Tween<double>(
begin: -1.0,
end: 1.0,
).animate(
CurvedAnimation(
parent: _controller,
curve: Curves.easeInOut,
),
);
}

@override
void dispose() {
_controller.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return AnimatedBuilder(
animation: _animation,
builder: (context, child) {
return ShimmerMask(
animationValue: _animation.value,
baseColor: widget.baseColor,
highlightColor: widget.highlightColor,
child: widget.child,
);
},
);
}
}

class ShimmerMask extends StatelessWidget {
final double animationValue;
final Color baseColor;
final Color highlightColor;
final Widget child;

const ShimmerMask({
super.key,
required this.animationValue,
required this.baseColor,
required this.highlightColor,
required this.child,
});

@override
Widget build(BuildContext context) {
return ShaderMask(
shaderCallback: (bounds) {
final width = bounds.width;

final start = animationValue * width;
final end = start + width * 0.5;

return LinearGradient(
colors: [
baseColor,
baseColor,
highlightColor,
highlightColor,
baseColor,
baseColor,
],
stops: const [
0.0,
0.2,
0.3,
0.7,
0.8,
1.0,
],
begin: Alignment(start / width, 0),
end: Alignment(end / width, 0),
tileMode: TileMode.clamp,
).createShader(bounds);
},
blendMode: BlendMode.srcATop,
child: child,
);
}
}

// ============================================================
// LOOKING FOR VIEW
// ============================================================

class LookingforView extends StatefulWidget {
const LookingforView({super.key});

@override
State<LookingforView> createState() => _LookingforViewState();
}

class _LookingforViewState extends State<LookingforView> {
late final LookingforController controller;

int selectedIndex = -1;

@override
void initState() {
super.initState();

controller = Get.put(LookingforController());

WidgetsBinding.instance.addPostFrameCallback((_) {
if (controller.selectedIndex.value != -1) {
setState(() {
selectedIndex = controller.selectedIndex.value;
});
}
});
}

// ============================================================
// SELECT ITEM
// ============================================================

void _selectItem(int index) {
setState(() {
selectedIndex = index;
controller.selectedIndex.value = index;
});

print(
'✅ Selected: ${controller.lookingForList[index].title}',
);
}

// ============================================================
// NEXT
// ============================================================

void _goToNext() {
if (selectedIndex == -1) {
CustomToast.warning("Please select one option");
return;
}

controller.next();
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

// ========================================================
// APP BAR
// ========================================================

appBar: const CustomAppBar(
title: "What Are You Looking For?",
subtitle: "Tell us what you want to find",
useIllustration: true,
),

// ========================================================
// BODY
// ========================================================

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
// OVERLAY
// ======================================================

Positioned.fill(
child: Container(
color: const Color(0xFFFFF0E6).withOpacity(0.10),
),
),

// ======================================================
// CONTENT
// ======================================================

SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// ==================================================
// HEADER
// ==================================================

SizedBox(height: 20.h),

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
Icons.search_rounded,
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
"What Are You Looking For?",
style: TextStyle(
fontSize: 14.sp,
fontWeight: FontWeight.w700,
letterSpacing: 1.2,
),
),

SizedBox(height: 8.h),

Text(
"Choose what best matches what you want.",
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

SizedBox(height: 10.h),

// ==================================================
// WHITE OUTER CONTAINER
// ==================================================

Expanded(
child: Container(
width: double.infinity,
padding: EdgeInsets.fromLTRB(
16.w,
25.h,
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
color:
Colors.black.withOpacity(0.035),
blurRadius: 12,
offset: const Offset(0, 3),
),
],
),

// ==================================================
// GRID / STATES
// ==================================================

child: Obx(() {
// ================================================
// LOADING
// ================================================

if (controller.isLoading.value) {
return GridView.builder(
padding: EdgeInsets.zero,
shrinkWrap: true,
physics:
const NeverScrollableScrollPhysics(),
itemCount: 6,
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 9.w,
mainAxisSpacing: 10.h,
childAspectRatio: 0.75,
),
itemBuilder: (_, index) {
return ShimmerEffect(
baseColor: Colors.grey[300]!,
highlightColor:
Colors.grey[100]!,
child: Container(
decoration: BoxDecoration(
color: Colors.grey[300],
borderRadius:
BorderRadius.circular(12.r),
),
),
);
},
);
}

// ================================================
// EMPTY STATE
// ================================================

if (controller.lookingForList.isEmpty) {
return Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.error_outline,
size: 45.sp,
color: Colors.grey,
),

SizedBox(height: 10.h),

Text(
"No options available",
style: TextStyle(
fontSize: 14.sp,
color: Colors.grey,
),
),

SizedBox(height: 10.h),

ElevatedButton(
onPressed: () {
controller
    .fetchLookingForOptions();
},
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(0xffFF6B00),
),
child: const Text(
"Retry",
style: TextStyle(
color: Colors.white,
),
),
),
],
),
);
}

// ================================================
// ORIGINAL 3 COLUMN GRID
// ================================================

return GridView.builder(
padding: EdgeInsets.only(
bottom: 10.h,
),
shrinkWrap: true,
physics:
const BouncingScrollPhysics(),

itemCount:
controller.lookingForList.length,

// ==============================================
// SAME GRID SETTINGS
// ==============================================

gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
crossAxisSpacing: 9.w,
mainAxisSpacing: 10.h,
childAspectRatio: 1.1,
),

itemBuilder: (_, index) {
final bool selected =
selectedIndex == index;

final LookingForModel item =
controller
    .lookingForList[index];

return GestureDetector(
onTap: () => _selectItem(index),

// ==================================================
// ORIGINAL GRID CARD UI - UNCHANGED
// ==================================================

child: AnimatedContainer(
duration: const Duration(
milliseconds: 200,
),
decoration: BoxDecoration(
color: selected
? const Color(0xFFFFF2E8)
    : Colors.white,

borderRadius:
BorderRadius.circular(12.r),

border: Border.all(
width:
selected ? 1.5.w : 1.w,
color: selected
? const Color(0xffFF6B00)
    : Colors.grey.shade200,
),

boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.03),
blurRadius: 5,
offset:
const Offset(0, 2),
),
],
),

child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
// ==========================================
// ORIGINAL IMAGE
// ==========================================

if (item.icon.isNotEmpty)
Image.network(
item.icon,
width: 30.w,
height: 30.h,
fit: BoxFit.contain,
errorBuilder:
(
context,
error,
stackTrace,
) {
return Text(
'📌',
style: TextStyle(
fontSize: 25.sp,
),
);
},
)
else
Text(
'📌',
style: TextStyle(
fontSize: 25.sp,
),
),

SizedBox(height: 10.h),

// ==========================================
// ORIGINAL TITLE
// ==========================================

Padding(
padding:
EdgeInsets.symmetric(
horizontal: 4.w,
),
child: Text(
item.title,
textAlign:
TextAlign.center,
maxLines: 3,
overflow:
TextOverflow.ellipsis,
style: TextStyle(
letterSpacing: 0.5.w,
fontSize: 9.sp,
height: 1.25,
fontWeight: selected
? FontWeight.w700
    : FontWeight.w600,
color: Colors.black,
),
),
),
],
),
),
);
},
);
}),
),
),

// ==================================================
// NEXT BUTTON
// ==================================================

  SizedBox(height: 12.h),
SafeArea(
top: false,
child: Padding(
padding: EdgeInsets.only(top: 8.h),
child: CustomButton(
text: "Next",
onPressed: _goToNext,
),
),
),

// ==================================================
// BOTTOM SPACE
// ==================================================

SizedBox(height: 120.h),
],
),
),
),
],
),
);
}
}

