// lib/app/modules/premium/views/premium_view.dart

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/premium/controllers/premium_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  final PremiumController controller = Get.put(PremiumController());

  static const Color orangeColor = Color(0xffFF6B00);

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
        title: "Membership",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ============================================================
          // BACKGROUND IMAGE
          // ============================================================
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ============================================================
          // WHITE OPACITY OVERLAY
          // ============================================================
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================
          Positioned.fill(
            child: SafeArea(
              child: Obx(() {
                // ======================================================
                // LOADING
                // ======================================================
                if (controller.isLoading.value) {
                  return _buildShimmerLoading();
                }

                // ======================================================
                // ERROR
                // STATIC DATA SHOW
                // ======================================================
                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildStaticPremiumData();
                }

                // ======================================================
                // API SUCCESS
                // ======================================================
                return _buildPremiumContent();
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // API SUCCESS CONTENT
  // ================================================================

  Widget _buildPremiumContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14.w,
        14.h,
        14.w,
        40.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PREMIUM CARD
          // ==========================================================

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 0.8.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffD5C11D),
                    Color(0xff3E2D2D),
                    Color(0xffC96A11),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // ==================================================
                  // PREMIUM HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        height: 34.h,
                        width: 34.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Premium',
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5.w,
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            Text(
                              'Upgrade for Enjoy All Premium Benefits',
                              style: GoogleFonts.poppins(
                                letterSpacing: 0.8.w,
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  // ==================================================
                  // PURCHASE DATE
                  // ==================================================

                  _premiumRow(
                    'Purchase Date',
                    controller.purchaseDate.value,
                  ),

                  SizedBox(height: 10.h),

                  // ==================================================
                  // NEXT BILLING DATE
                  // ==================================================

                  _premiumRow(
                    'Next Billing Date',
                    controller.nextBillingDate.value,
                  ),

                  SizedBox(height: 10.h),

                  // ==================================================
                  // AMOUNT PAID
                  // ==================================================

                  _premiumRow(
                    'Amount Paid',
                    controller.amountPaid.value,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30.h),

          // ==========================================================
          // FAQ TITLE
          // ==========================================================

          Text(
            "FAQ's",
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2B2B2B),
            ),
          ),

          SizedBox(height: 14.h),

          // ==========================================================
          // FAQ
          // ==========================================================

          if (controller.faqList.isEmpty)
            _staticNoFaq()
          else
            ...controller.faqList.map<Widget>((e) {
              return _faqCard(
                question: e.question,
                answer: e.answer,
              );
            }).toList(),
        ],
      ),
    );
  }

  // ================================================================
  // STATIC DATA WHEN API ERROR
  // ================================================================
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} "
        "${date.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
  Widget _buildStaticPremiumData() {
    final DateTime now = DateTime.now();
    final DateTime nextBillingDate = now.add(
      const Duration(days: 1),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14.w,
        14.h,
        14.w,
        40.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PREMIUM CARD
          // ==========================================================

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 0.8.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffD5C11D),
                    Color(0xff3E2D2D),
                    Color(0xffC96A11),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        height: 34.h,
                        width: 34.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Premium',
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5.w,
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            Text(
                              'Upgrade for Enjoy All Premium Benefits',
                              style: GoogleFonts.poppins(
                                letterSpacing: 0.8.w,
                                color: Colors.white70,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  // ==================================================
                  // DYNAMIC PURCHASE DATE
                  // ==================================================

                  _premiumRow(
                    'Purchase Date',
                    _formatDate(now),
                  ),

                  SizedBox(height: 10.h),

                  // ==================================================
                  // DYNAMIC NEXT BILLING DATE
                  // ==================================================

                  _premiumRow(
                    'Next Billing Date',
                    _formatDate(nextBillingDate),
                  ),

                  SizedBox(height: 10.h),

                  // ==================================================
                  // STATIC AMOUNT
                  // ==================================================

                  _premiumRow(
                    'Amount Paid',
                    '₹1',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30.h),

          // ==========================================================
          // FAQ TITLE
          // ==========================================================

          Text(
            "FAQ's",
            style: GoogleFonts.poppins(
              letterSpacing: 1.5.w,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2B2B2B),
            ),
          ),

          SizedBox(height: 14.h),

          // ==========================================================
          // STATIC FAQ 1
          // ==========================================================

          _faqCard(
            question: 'What is Premium Membership?',
            answer:
            'Premium Membership gives you access to exclusive features and benefits.',
          ),

          // ==========================================================
          // STATIC FAQ 2
          // ==========================================================

          _faqCard(
            question: 'How long is my membership valid?',
            answer:
            'Your membership is valid for one month from the purchase date.',
          ),

          // ==========================================================
          // STATIC FAQ 3
          // ==========================================================

          _faqCard(
            question: 'When will I be charged again?',
            answer:
            'Your subscription will be renewed on the next billing date.',
          ),

          // ==========================================================
          // STATIC FAQ 4
          // ==========================================================

          _faqCard(
            question: 'Can I cancel my membership?',
            answer:
            'Yes, you can cancel your membership according to the subscription terms.',
          ),
        ],
      ),
    );
  }
  // ================================================================
  // PREMIUM ROW
  // ================================================================

  Widget _premiumRow(
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(width: 10.w),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // FAQ CARD
  // ================================================================

  Widget _faqCard({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.75),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 16.h,
          ),
          iconColor: orangeColor,
          collapsedIconColor: const Color(0xff666666),
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xff303030),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  height: 1.7,
                  color: const Color(0xff7B7B7B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // NO FAQ
  // ================================================================

  Widget _staticNoFaq() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.75),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'No FAQ available',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: const Color(0xff777777),
        ),
      ),
    );
  }

  // ================================================================
  // SHIMMER LOADING
  // ================================================================

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        14.w,
        14.h,
        14.w,
        40.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================================
          // PREMIUM CARD SHIMMER
          // ==========================================================

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 0.8.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xffD5C11D),
                    Color(0xff3E2D2D),
                    Color(0xffC96A11),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ShimmerContainer(
                        width: 34.w,
                        height: 34.h,
                        radius: 10.r,
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            ShimmerContainer(
                              width: 150.w,
                              height: 18.h,
                              radius: 4.r,
                            ),

                            SizedBox(height: 5.h),

                            ShimmerContainer(
                              width: 190.w,
                              height: 12.h,
                              radius: 4.r,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  _shimmerRow(),

                  SizedBox(height: 12.h),

                  _shimmerRow(),

                  SizedBox(height: 12.h),

                  _shimmerRow(),
                ],
              ),
            ),
          ),

          SizedBox(height: 30.h),

          // ==========================================================
          // FAQ TITLE SHIMMER
          // ==========================================================

          ShimmerContainer(
            width: 80.w,
            height: 18.h,
            radius: 4.r,
          ),

          SizedBox(height: 14.h),

          // ==========================================================
          // FAQ SHIMMER
          // ==========================================================

          ...List.generate(
            4,
                (index) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 17.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.82),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.75),
                    width: 0.8.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ShimmerContainer(
                        width: double.infinity,
                        height: 16.h,
                        radius: 4.r,
                      ),
                    ),

                    SizedBox(width: 15.w),

                    ShimmerContainer(
                      width: 18.w,
                      height: 18.w,
                      radius: 20.r,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SHIMMER ROW
  // ================================================================

  Widget _shimmerRow() {
    return Row(
      children: [
        ShimmerContainer(
          width: 100.w,
          height: 16.h,
          radius: 4.r,
        ),

        const Spacer(),

        ShimmerContainer(
          width: 80.w,
          height: 16.h,
          radius: 4.r,
        ),
      ],
    );
  }
}

// ==================================================================
// SHIMMER CONTAINER
// ==================================================================

class ShimmerContainer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  State<ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double value = _shimmerController.value;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Colors.white.withOpacity(0.25),
          ),
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.70),
                  Colors.white.withOpacity(0.15),
                ],
                stops: [
                  (value - 0.3).clamp(0.0, 1.0),
                  value.clamp(0.0, 1.0),
                  (value + 0.3).clamp(0.0, 1.0),
                ],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(widget.radius),
                color: Colors.white.withOpacity(0.30),
              ),
            ),
          ),
        );
      },
    );
  }
}