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

    // Get the controller
    final PositionController controller = Get.put(PositionController());

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      appBar: const CustomAppBar(title: ""),
      body: Obx(() => _buildBody(controller)),
    );
  }

  Widget _buildBody(PositionController controller) {
    // Loading State with Shimmer
    if (controller.isLoading.value) {
      return const PositionShimmer();
    }

    // Error State
    if (controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.retryLoading();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty State
    if (controller.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No positions available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.retryLoading();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF6A00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Main Content
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25.h),

          Text(
            "Select Your Position",
            style: TextStyle(
              letterSpacing: 1.5,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            "Choose The Position That Best Represents You.",
            style: TextStyle(
              letterSpacing: 1.5,
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: 35.h),

          // Dynamic Position List
          Expanded(
            child: ListView.builder(
              itemCount: controller.positionsList.length,
              itemBuilder: (context, index) {
                final position = controller.positionsList[index];
                // ✅ Important: Directly access .value for comparison
                final bool selected = controller.selectedIndex.value == index;

                return GestureDetector(
                  onTap: () {
                    controller.selectPosition(index);
                  },
                  child: Obx(() => Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    height: 65.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: controller.selectedIndex.value == index
                          ? const Color(0xfffff2e8)  // Light orange background
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: controller.selectedIndex.value == index
                            ? const Color(0xffFF6B00)  // Orange border
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.selectedIndex.value == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20.sp,
                          color: controller.selectedIndex.value == index
                              ? const Color(0xffFF6B00)  // Orange color when selected
                              : Colors.grey.shade500,
                        ),
                        SizedBox(width: 14.w),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              position.title,
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: controller.selectedIndex.value == index
                                    ? const Color(0xffFF6B00) 
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              position.subTitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: controller.selectedIndex.value == index
                                    ? Colors.black87 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
                );
              },
            ),
          ),

          // Continue Button
          SafeArea(
            child: CustomButton(
              text: "Continue",
              onPressed: () {
                controller.next();
              },
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

// Shimmer Loading Widget (same as before)
class PositionShimmer extends StatelessWidget {
  const PositionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25.h),

          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 1500),
            child: Container(
              height: 24.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 1500),
            child: Container(
              height: 14.h,
              width: 250.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          SizedBox(height: 35.h),

          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                period: const Duration(milliseconds: 1500),
                child: Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 1500),
            child: Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}