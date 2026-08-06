import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../controllers/safetyandpolicy_controller.dart';

class SafetyandpolicyView extends StatelessWidget {
  const SafetyandpolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final controller = Get.put(SafetyandpolicyController());

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: const CustomAppBar(
        title: "Safety & Child Protection Policy",
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(controller);
        }

        if (controller.safetyPolicyData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPolicyContent(controller);
      }),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150.w,
                height: 20.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              ...List.generate(6, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: 120.w,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              ...List.generate(4, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 22.h),
              Container(
                width: 100.w,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              ...List.generate(3, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(SafetyandpolicyController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6C63FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 12.h,
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No safety policy data available',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildPolicyContent(SafetyandpolicyController controller) {
    // Show all items if multiple, or just the first one
    final items = controller.safetyPolicyData;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.4.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildPolicyItems(items),
        ),
      ),
    );
  }

  List<Widget> _buildPolicyItems(List<SafetyPolicyItem> items) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Add title
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h, top: i > 0 ? 24.h : 0),
          child: Text(
            item.title,
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: i == 0 ? 16.sp : 16.sp,
              fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      );

      // Parse and add content
      widgets.addAll(_parseContent(item.content));

      // Add divider between items
      if (i < items.length - 1) {
        widgets.add(
          Divider(
            height: 32.h,
            color: Colors.grey.shade200,
            thickness: 1,
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _parseContent(String content) {
    final List<Widget> widgets = [];
    
    // Split content by lines
    final lines = content.split('\n');
    
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check if it's a bullet point (starts with •, -, or number)
      if (trimmed.startsWith('•') || 
          trimmed.startsWith('-') || 
          trimmed.startsWith('*') ||
          RegExp(r'^\d+\.').hasMatch(trimmed)) {
        
        // Remove bullet symbol
        String bulletText = trimmed;
        if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
          bulletText = trimmed.substring(1).trim();
        } else {
          bulletText = trimmed.replaceFirst(RegExp(r'^\d+\.'), '').trim();
        }
        
        widgets.add(_bullet(bulletText));
      } else {
        // Regular text
        widgets.add(_text(trimmed));
        widgets.add(SizedBox(height: 8.h));
      }
    }

    return widgets;
  }

  Widget _text(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          height: 1.7,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Icon(
              Icons.circle,
              size: 6.sp,
              color: const Color(0xff6C63FF),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.7,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}