import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../controllers/termsandconditions_controller.dart';

class TermsandconditionsView extends StatelessWidget {
  const TermsandconditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final controller = Get.put(TermsandconditionsController());

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: const CustomAppBar(
        title: "Terms & Conditions",
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorWidget(controller);
        }

        if (controller.termsData.isEmpty) {
          return _buildEmptyState();
        }

        return _buildContent(controller);
      }),
    );
  }

  // Shimmer loading widget
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
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading shimmer
              Container(
                width: 120.w,
                height: 20.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              // Content lines shimmer
              ...List.generate(6, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 18.h),
              // Another heading shimmer
              Container(
                width: 150.w,
                height: 20.h,
                color: Colors.white,
              ),
              SizedBox(height: 12.h),
              // More content lines
              ...List.generate(4, (index) => 
                Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 18.h),
              // Address section shimmer
              Container(
                width: 100.w,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              ...List.generate(5, (index) => 
                Container(
                  width: index % 2 == 0 ? 200.w : 150.w,
                  height: 12.h,
                  margin: EdgeInsets.only(bottom: 4.h),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(TermsandconditionsController controller) {
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
              fontSize: 18.sp,
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
        'No terms & conditions available',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildContent(TermsandconditionsController controller) {
    // Parse the content from the API
    final String content = controller.termsData.isNotEmpty 
        ? controller.termsData.first.content 
        : '';

    // Split content into sections based on numbered headings
    final List<Widget> contentWidgets = _parseContent(content);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5.w,
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
          children: contentWidgets,
        ),
      ),
    );
  }

  List<Widget> _parseContent(String content) {
    if (content.isEmpty) return [];

    final List<Widget> widgets = [];
    final lines = content.split('\n');
    
    String currentHeading = '';
    final List<String> currentParagraphs = [];

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Check if this is a heading (starts with a number followed by a dot)
      if (RegExp(r'^\d+\.\s*').hasMatch(line)) {
        // If we have previous content, add it
        if (currentHeading.isNotEmpty || currentParagraphs.isNotEmpty) {
          widgets.addAll(_buildSection(currentHeading, currentParagraphs));
          currentHeading = '';
          currentParagraphs.clear();
        }
        currentHeading = line;
      } else {
        // Check if this line is a bold text (contains ":" or is all caps)
        if (line.contains(':') || line == line.toUpperCase()) {
          // Add as bold/address section
          if (currentParagraphs.isNotEmpty) {
            widgets.addAll(_buildSection(currentHeading, currentParagraphs));
            currentHeading = '';
            currentParagraphs.clear();
          }
          widgets.add(_buildBoldText(line));
        } else {
          currentParagraphs.add(line);
        }
      }
    }

    // Add any remaining content
    if (currentHeading.isNotEmpty || currentParagraphs.isNotEmpty) {
      widgets.addAll(_buildSection(currentHeading, currentParagraphs));
    }

    return widgets;
  }

  List<Widget> _buildSection(String heading, List<String> paragraphs) {
    final List<Widget> widgets = [];

    if (heading.isNotEmpty) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.h, top: widgets.isEmpty ? 0 : 18.h),
          child: Text(
            heading,
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    if (paragraphs.isNotEmpty) {
      for (String paragraph in paragraphs) {
        if (paragraph.trim().isNotEmpty) {
          widgets.add(
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Text(
                paragraph.trim(),
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  height: 1.7,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildBoldText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, top: 6.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          height: 1.7,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}