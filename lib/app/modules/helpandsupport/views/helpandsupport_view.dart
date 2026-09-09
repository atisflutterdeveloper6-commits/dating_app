import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../controllers/helpandsupport_controller.dart';

class HelpandsupportView extends StatelessWidget {
  const HelpandsupportView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final controller = Get.put(HelpandsupportController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: const CustomAppBar(
        title: "Help & Support",
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // White opacity overlay - NO BLUR
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerLoading();
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorWidget(controller);
                }

                if (controller.helpData.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildHelpContent(controller);
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SHIMMER =================

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        40.h,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160.w,
                height: 20.h,
                color: Colors.white,
              ),

              SizedBox(height: 12.h),

              ...List.generate(
                4,
                    (index) => Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 24.h),

              Container(
                width: 150.w,
                height: 16.h,
                color: Colors.white,
              ),

              SizedBox(height: 12.h),

              ...List.generate(
                3,
                    (index) => Container(
                  width: double.infinity,
                  height: 14.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 24.h),

              Container(
                width: 120.w,
                height: 16.h,
                color: Colors.white,
              ),

              SizedBox(height: 12.h),

              ...List.generate(
                3,
                    (index) => Container(
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

  // ================= ERROR =================

  Widget _buildErrorWidget(
      HelpandsupportController controller,
      ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 0.6.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 60.sp,
                color: Colors.red.shade300,
              ),

              SizedBox(height: 16.h),

              Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 20.h),

              ElevatedButton(
                onPressed: controller.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6A00),
                  elevation: 0,
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
        ),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 0.6.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                size: 60.sp,
                color: Colors.grey.shade400,
              ),

              SizedBox(height: 16.h),

              Text(
                'No help content available',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8.h),

              Text(
                'Please check back later',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELP CONTENT =================

  Widget _buildHelpContent(
      HelpandsupportController controller,
      ) {
    final items = controller.helpData;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        40.h,
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.75),
            width: 0.6.w,
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
          children: _buildHelpItems(items),
        ),
      ),
    );
  }

  // ================= HELP ITEMS =================

  List<Widget> _buildHelpItems(
      List<HelpItem> items,
      ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Title
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: 12.h,
            top: i > 0 ? 24.h : 0,
          ),
          child: Text(
            item.title,
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: 16.sp,
              fontWeight:
              i == 0 ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xff333333),
            ),
          ),
        ),
      );

      // Content
      widgets.addAll(
        _parseContent(item.content),
      );

      // Divider
      if (i < items.length - 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
            ),
            child: Divider(
              height: 24.h,
              color: Colors.grey.shade200,
              thickness: 1,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ================= PARSE CONTENT =================

  List<Widget> _parseContent(String content) {
    final List<Widget> widgets = [];

    final lines = content.split('\n');

    for (var line in lines) {
      final trimmed = _cleanText(line);

      if (trimmed.isEmpty) continue;

      // Bullet
      if (trimmed.startsWith('•') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('*') ||
          trimmed.startsWith('·')) {
        String bulletText = trimmed.substring(1).trim();

        if (bulletText.isNotEmpty) {
          widgets.add(
            _bullet(bulletText),
          );
        }
      } else {
        widgets.add(
          _text(trimmed),
        );

        widgets.add(
          SizedBox(height: 4.h),
        );
      }
    }

    return widgets;
  }

  // ================= NORMAL TEXT =================

  Widget _text(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        _cleanText(text),
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          height: 1.7,
          color: const Color(0xff7A7A7A),
        ),
      ),
    );
  }

  // ================= BULLET =================

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7.h),
            child: Icon(
              Icons.circle,
              size: 6.sp,
              color: const Color(0xffFF6A00),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              _cleanText(text),
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                height: 1.7,
                color: const Color(0xff7A7A7A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CLEAN HTML =================

  String _cleanText(String text) {
    String cleaned = text;

    // Remove HTML comments
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<!--.*?-->',
        dotAll: true,
      ),
      '',
    );

    // Remove HTML tags
    cleaned = cleaned.replaceAll(
      RegExp(
        r'<[^>]*>',
        dotAll: true,
      ),
      ' ',
    );

    // Decode common HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&apos;', "'");

    // Remove extra spaces
    cleaned = cleaned.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return cleaned.trim();
  }
}