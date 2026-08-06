// lib/app/modules/premium/views/premium_view.dart

import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/paymentplan/views/paymentplan_view.dart';
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: CustomAppBar(
        title: "Membership",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
      ),
      body: Obx(() {
        // Loading state - Show Shimmer
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        // Actual error state (network/server failure) — show Retry
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF6338),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // No active subscription — friendly empty state, not an "error"
        if (!controller.hasActiveSubscription.value) {
          return _buildNoSubscriptionState();
        }

        // Main Content — has an active subscription
        return SingleChildScrollView(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Premium Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
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
                        Container(
                          height: 34.h,
                          width: 34.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You are Premium',
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5.w,
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                controller.planName.value.isNotEmpty
                                    ? controller.planName.value
                                    : 'Enjoy All Premium Benefits',
                                style: GoogleFonts.poppins(
                                  letterSpacing: 1.5.w,
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

                    _premiumRow('Purchase Date', controller.purchaseDate.value),
                    SizedBox(height: 10.h),
                    _premiumRow('Next Billing Date', controller.nextBillingDate.value),
                    SizedBox(height: 10.h),
                    _premiumRow('Amount Paid', controller.amountPaid.value),
                    SizedBox(height: 16.h),

                    // Auto Renewal Toggle

                    SizedBox(height: 22.h),

                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: controller.cancelSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF6B00),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          'Cancel Subscription',
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5.w,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

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

              // Dynamic FAQ from API
              if (controller.faqList.isEmpty)
                const Center(
                  child: Text('No FAQ available'),
                )
              else
                ...controller.faqList.map<Widget>((e) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xffECECEC)),
                    ),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
                        childrenPadding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 16.h,
                        ),
                        title: Text(
                          e.question,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff303030),
                          ),
                        ),
                        children: [
                          Text(
                            e.answer,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              height: 1.7,
                              color: const Color(0xff7B7B7B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      }),
    );
  }

  // ✅ Friendly empty state — shown when the user simply has no active
  // subscription yet (not a network/server error). Offers a direct CTA
  // to the payment plan screen instead of a "Retry" button.
  Widget _buildNoSubscriptionState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(28.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
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
                Container(
                  height: 56.h,
                  width: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.subscriptionStatus.value.isNotEmpty
                      ? 'Subscription ${controller.subscriptionStatus.value}'
                      : 'You\'re not Premium yet',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.0.w,
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Unlock premium features and get noticed faster.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    letterSpacing: 0.5.w,
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const PaymentplanView()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6B00),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'View Plans',
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5.w,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "FAQ's",
              style: GoogleFonts.poppins(
                letterSpacing: 1.5.w,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2B2B2B),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          if (controller.faqList.isEmpty)
            const Center(child: Text('No FAQ available'))
          else
            ...controller.faqList.map<Widget>((e) {
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xffECECEC)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
                    childrenPadding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 16.h,
                    ),
                    title: Text(
                      e.question,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff303030),
                      ),
                    ),
                    children: [
                      Text(
                        e.answer,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          height: 1.7,
                          color: const Color(0xff7B7B7B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _premiumRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ✅ Shimmer Loading Widget
  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Card Shimmer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
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
                    // Premium Icon Shimmer
                    ShimmerContainer(
                      width: 34.w,
                      height: 34.h,
                      radius: 10.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Shimmer
                          ShimmerContainer(
                            width: 150.w,
                            height: 18.h,
                            radius: 4.r,
                          ),
                          SizedBox(height: 4.h),
                          // Subtitle Shimmer
                          ShimmerContainer(
                            width: 120.w,
                            height: 12.h,
                            radius: 4.r,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                // Purchase Date Shimmer
                _shimmerRow(),
                SizedBox(height: 10.h),
                // Next Billing Date Shimmer
                _shimmerRow(),
                SizedBox(height: 10.h),
                // Amount Paid Shimmer
                _shimmerRow(),
                SizedBox(height: 16.h),
                // Auto Renewal Toggle Shimmer
                Row(
                  children: [
                    ShimmerContainer(
                      width: 100.w,
                      height: 16.h,
                      radius: 4.r,
                    ),
                    const Spacer(),
                    ShimmerContainer(
                      width: 44.w,
                      height: 24.h,
                      radius: 20.r,
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                // Cancel Button Shimmer
                ShimmerContainer(
                  width: double.infinity,
                  height: 50.h,
                  radius: 30.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          // FAQ Title Shimmer
          ShimmerContainer(
            width: 80.w,
            height: 18.h,
            radius: 4.r,
          ),
          SizedBox(height: 14.h),
          // FAQ Items Shimmer
          ...List.generate(4, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xffECECEC)),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
                title: ShimmerContainer(
                  width: 200.w,
                  height: 16.h,
                  radius: 4.r,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 16.h,
                    ),
                    child: ShimmerContainer(
                      width: double.infinity,
                      height: 40.h,
                      radius: 4.r,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

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

// ✅ Shimmer Container Widget
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Colors.grey[300],
          ),
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: [
                  _shimmerController.value - 0.3,
                  _shimmerController.value,
                  _shimmerController.value + 0.3,
                ],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      },
    );
  }
}