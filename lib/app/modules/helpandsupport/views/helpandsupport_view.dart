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

    final controller = Get.put(
      HelpandsupportController(),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: const CustomAppBar(
        title: "Help & Support",
        subtitle: "We're here to assist you",
      ),

      body: Stack(
        fit: StackFit.expand,
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
          // CONTENT
          // ======================================================

          Positioned.fill(
            child: Obx(
                  () {
                if (controller.isLoading.value) {
                  return _buildShimmerLoading();
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorWidget(controller);
                }

                // If API returns empty data,
                // show static Help & Support content.
                if (controller.helpData.isEmpty) {
                  return _buildStaticHelpContent();
                }

                return _buildHelpContent(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAME CONTAINER DECORATION
  // ============================================================

  BoxDecoration _mainContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),

      border: Border.all(
        color: const Color(0xFFF1E8E4),
        width: 0.8.w,
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 12.r,
          offset: Offset(0, 3.h),
        ),
      ],
    );
  }

  // ============================================================
  // SHIMMER
  // ============================================================

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
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
        decoration: _mainContainerDecoration(),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 190.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),

              SizedBox(height: 14.h),

              ...List.generate(
                5,
                    (index) {
                  return Container(
                    width: index == 4
                        ? 230.w
                        : double.infinity,
                    height: 14.h,
                    margin: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              Container(
                width: 180.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(6.r),
                ),
              ),

              SizedBox(height: 14.h),

              ...List.generate(
                4,
                    (index) {
                  return Container(
                    width: index == 3
                        ? 200.w
                        : double.infinity,
                    height: 14.h,
                    margin: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),

              SizedBox(height: 24.h),

              Container(
                width: 120.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(6.r),
                ),
              ),

              SizedBox(height: 14.h),

              ...List.generate(
                4,
                    (index) {
                  return Container(
                    width: index == 3
                        ? 180.w
                        : double.infinity,
                    height: 14.h,
                    margin: EdgeInsets.only(
                      bottom: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(5.r),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorWidget(
      HelpandsupportController controller,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
        16.w,
        90.h,
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight:
          MediaQuery.of(Get.context!).size.height -
              210.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 24.h,
        ),
        decoration: _mainContainerDecoration(),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 34.sp,
                color: Colors.red.shade300,
              ),
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
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),

            SizedBox(height: 18.h),

            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: controller.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xffFF6A00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // API HELP CONTENT
  // ============================================================

  Widget _buildHelpContent(
      HelpandsupportController controller,
      ) {
    final items = controller.helpData;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
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
        decoration: _mainContainerDecoration(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: _buildHelpItems(items),
        ),
      ),
    );
  }

  // ============================================================
  // STATIC HELP CONTENT
  // ============================================================

  Widget _buildStaticHelpContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        120.h,
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
        decoration: _mainContainerDecoration(),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildStaticSection(
              title:
              "Need Assistance? We're Here to Help!",
              content:
              "Welcome to Vibely's Help & Support Center. "
                  "If you have any questions, concerns, or need "
                  "assistance with anything related to the app, "
                  "you're in the right place. Our team is dedicated "
                  "to ensuring you have a smooth and enjoyable "
                  "experience on Vibely.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title:
              "Frequently Asked Questions (FAQs)",
              content:
              "Browse through our comprehensive FAQs to find "
                  "quick answers to common questions about using "
                  "the app, profile setup, matching, chatting, "
                  "subscriptions, and more.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title: "Contact Us",
              content:
              "If you can't find the information you're "
                  "looking for in our FAQs, feel free to reach "
                  "out to us directly. We're here to assist you "
                  "with any specific inquiries you may have.\n\n"
                  "You can contact us through the app's "
                  "'Contact Support' feature or by emailing "
                  "our support team at support@vibelyapp.com.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title: "User Safety and Privacy",
              content:
              "Your safety and privacy are our top priorities. "
                  "If you encounter any suspicious behavior or "
                  "need assistance with privacy settings, please "
                  "let us know. You can also report profiles or "
                  "users that violate our community guidelines.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title: "Account & Profile",
              content:
              "For assistance with your account, profile "
                  "information, photos, preferences, or other "
                  "profile-related settings, please make sure "
                  "your information is up to date. If you are "
                  "unable to make changes, contact our support team.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title: "Subscription & Payments",
              content:
              "If you have questions about your subscription, "
                  "payment, or premium features, please contact "
                  "our support team with the relevant details. "
                  "Our team will help you resolve payment-related "
                  "issues as quickly as possible.",
            ),

            _buildDivider(),

            _buildStaticSection(
              title: "We're Here to Help",
              content:
              "We value your experience on Vibely. If you "
                  "need any additional assistance, don't hesitate "
                  "to contact us. Our support team is always happy "
                  "to help.",
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATIC SECTION
  // ============================================================

  Widget _buildStaticSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            letterSpacing: 1.0.w,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.5,
          ),
        ),

        SizedBox(height: 10.h),

        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            height: 1.7,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 18.h,
      ),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: const Color(0xFFEFE8E4),
      ),
    );
  }

  // ============================================================
  // API ITEMS
  // ============================================================

  List<Widget> _buildHelpItems(
      List<HelpItem> items,
      ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            top: i > 0 ? 8.h : 0,
            bottom: 10.h,
          ),
          child: Text(
            item.title,
            style: GoogleFonts.poppins(
              letterSpacing: 1.0.w,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      );

      widgets.addAll(
        _parseContent(item.content),
      );

      if (i < items.length - 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.h,
            ),
            child: Divider(
              height: 1.h,
              thickness: 1,
              color: const Color(0xFFEFE8E4),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ============================================================
  // PARSE CONTENT
  // ============================================================

  List<Widget> _parseContent(
      String content,
      ) {
    final List<Widget> widgets = [];

    final lines = content.split('\n');

    for (final line in lines) {
      final trimmed = _cleanText(line);

      if (trimmed.isEmpty) {
        widgets.add(
          SizedBox(height: 6.h),
        );
        continue;
      }

      if (trimmed.startsWith('•') ||
          trimmed.startsWith('-') ||
          trimmed.startsWith('*') ||
          trimmed.startsWith('·')) {
        String bulletText =
        trimmed.substring(1).trim();

        if (bulletText.isNotEmpty) {
          widgets.add(
            _bullet(bulletText),
          );
        }
      } else {
        widgets.add(
          _text(trimmed),
        );
      }
    }

    return widgets;
  }

  // ============================================================
  // TEXT
  // ============================================================

  Widget _text(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.h,
      ),
      child: Text(
        _cleanText(text),
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          height: 1.7,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // BULLET
  // ============================================================

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8.h,
        left: 4.w,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 7.h,
            ),
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
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLEAN HTML
  // ============================================================

  String _cleanText(String text) {
    String cleaned = text;

    cleaned = cleaned.replaceAll(
      RegExp(
        r'<!--.*?-->',
        dotAll: true,
      ),
      '',
    );

    cleaned = cleaned.replaceAll(
      RegExp(
        r'<[^>]*>',
        dotAll: true,
      ),
      ' ',
    );

    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&apos;', "'");

    cleaned = cleaned.replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return cleaned.trim();
  }
}