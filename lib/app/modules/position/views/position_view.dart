
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/position/controllers/position_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PositionView extends StatelessWidget {
const PositionView({super.key});

@override
Widget build(BuildContext context) {
ScreenUtil.init(
context,
designSize: const Size(375, 812),
minTextAdapt: true,
splitScreenMode: true,
);

final PositionController controller = Get.put(PositionController());

return Scaffold(
extendBodyBehindAppBar: true,
backgroundColor: Colors.transparent,

// ============================================================
// APP BAR
// ============================================================
appBar: const CustomAppBar(
title: "Your Position",
subtitle: "Choose what best represents you",
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

// ============================================================
// LIGHT ORANGE OVERLAY
// ============================================================
Positioned.fill(
child: Container(
color: const Color(0xFFFFF0E6).withOpacity(0.10),
),
),

// ============================================================
// CONTENT
// ============================================================
Obx(
() => _buildBody(controller),
),
],
),
);
}

// ================================================================
// MAIN BODY
// ================================================================
Widget _buildBody(PositionController controller) {
// ================================================================
// LOADING
// ================================================================
if (controller.isLoading.value) {
return const PositionShimmer();
}

// ================================================================
// ERROR
// ================================================================
if (controller.errorMessage.value.isNotEmpty) {
return SafeArea(
child: Center(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.error_outline,
size: 55.sp,
color: Colors.grey.shade600,
),

SizedBox(height: 15.h),

Text(
'Something went wrong',
style: TextStyle(
fontSize: 17.sp,
fontWeight: FontWeight.w600,
color: Colors.grey.shade700,
),
),

SizedBox(height: 8.h),

Text(
controller.errorMessage.value,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 11.sp,
color: Colors.grey.shade600,
),
),

SizedBox(height: 22.h),

ElevatedButton(
onPressed: () {
controller.retryLoading();
},
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xffFF6B00),
elevation: 0,
padding: EdgeInsets.symmetric(
horizontal: 35.w,
vertical: 12.h,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30.r),
),
),
child: Text(
'Retry',
style: TextStyle(
fontSize: 12.sp,
fontWeight: FontWeight.w600,
color: Colors.white,
),
),
),
],
),
),
),
);
}

// ================================================================
// EMPTY
// ================================================================
if (controller.isEmpty) {
return SafeArea(
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.info_outline,
size: 55.sp,
color: Colors.grey.shade400,
),

SizedBox(height: 15.h),

Text(
'No positions available',
style: TextStyle(
fontSize: 16.sp,
fontWeight: FontWeight.w600,
color: Colors.grey.shade600,
),
),

SizedBox(height: 22.h),

ElevatedButton(
onPressed: () {
controller.retryLoading();
},
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xffFF6B00),
elevation: 0,
padding: EdgeInsets.symmetric(
horizontal: 35.w,
vertical: 12.h,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30.r),
),
),
child: Text(
'Retry',
style: TextStyle(
fontSize: 12.sp,
fontWeight: FontWeight.w600,
color: Colors.white,
),
),
),
],
),
),
);
}

// ================================================================
// MAIN CONTENT
// ================================================================
return SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 40.h),

// ========================================================
// HEADER
// OUTSIDE WHITE CONTAINER
// ========================================================
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
Icons.location_on_outlined,
color: const Color(0xFFFF6B00),
size: 22.sp,
),
),

SizedBox(width: 20.w),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
"Select Your Position",
style: TextStyle(
fontSize: 14.sp,
fontWeight: FontWeight.w700,
letterSpacing: 1.2,
),
),

SizedBox(height: 8.h),

Text(
"Choose The Position That Best Represents You.",
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

// ========================================================
// WHITE CONTAINER
// ========================================================
// WHITE CONTAINER
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
          color: Colors.black.withOpacity(0.035),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.positionsList.length,
      itemBuilder: (context, index) {
        final position = controller.positionsList[index];

        return Obx(() {
          final bool selected =
              controller.selectedIndex.value == index;

          return GestureDetector(
            onTap: () {
              controller.selectPosition(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                bottom: index ==
                    controller.positionsList.length - 1
                    ? 0
                    : 12.h,
              ),
              height:80.h,
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFF2E8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: selected
                      ? const Color(0xffFF6B00)
                      : Colors.grey.shade300,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18.sp,
                    color: selected
                        ? const Color(0xffFF6B00)
                        : Colors.grey.shade500,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          position.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: selected
                                ? const Color(0xffFF6B00)
                                : Colors.black,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          position.subTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: selected
                                ? Colors.black87
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    ),
  ),

// ================================================================
// SAME BUTTON PLACEMENT AS BIRTHDAY
// ================================================================
  const Spacer(),

// CONTINUE BUTTON
// OUTSIDE WHITE CONTAINER
// ========================================================
SafeArea(
top: false,
child: Padding(
padding: EdgeInsets.only(
top: 15.h,
bottom: 5.h,
),
child: CustomButton(
text: "Continue",
onPressed: () {
controller.next();
},
),
),
),

SizedBox(height: 90.h),
],
),
),
);
}
}

// ====================================================================
// POSITION SHIMMER
// ====================================================================
class PositionShimmer extends StatelessWidget {
const PositionShimmer({super.key});

@override
Widget build(BuildContext context) {
return Stack(
children: [
// ==============================================================
// BACKGROUND
// ==============================================================
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

// ==============================================================
// SHIMMER CONTENT
// ==============================================================
SafeArea(
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 28.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 40.h),

// ======================================================
// HEADER SHIMMER
// ======================================================
Row(
children: [
_shimmerBox(
width: 40.w,
height: 40.w,
radius: 40.r,
),

SizedBox(width: 20.w),

Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_shimmerBox(
width: 160.w,
height: 18.h,
),

SizedBox(height: 8.h),

_shimmerBox(
width: 220.w,
height: 10.h,
),
],
),
],
),

SizedBox(height: 30.h),

// ======================================================
// WHITE CONTAINER SHIMMER
// ======================================================
Expanded(
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
borderRadius:
BorderRadius.circular(14.r),
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
child: ListView.builder(
physics:
const NeverScrollableScrollPhysics(),
itemCount: 4,
itemBuilder: (context, index) {
return Padding(
padding:
EdgeInsets.only(bottom: 12.h),
child: _shimmerBox(
width: double.infinity,
height: 62.h,
radius: 10.r,
),
);
},
),
),
),

SizedBox(height: 15.h),

// ======================================================
// BUTTON SHIMMER
// ======================================================
_shimmerBox(
width: double.infinity,
height: 52.h,
radius: 30.r,
),

SizedBox(height: 110.h),
],
),
),
),
],
);
}

// ================================================================
// SHIMMER BOX
// ================================================================
Widget _shimmerBox({
required double width,
required double height,
double radius = 5,
}) {
return Shimmer.fromColors(
baseColor: Colors.grey.shade300,
highlightColor: Colors.grey.shade100,
period: const Duration(milliseconds: 1500),
child: Container(
width: width,
height: height,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(radius),
),
),
);
}
}
