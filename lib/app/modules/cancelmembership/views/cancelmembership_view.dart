import 'package:dating_app/app/modules/contactsupport/views/contactsupport_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../../../custom_widget/custom_button.dart';
import '../controllers/cancelmembership_controller.dart';

class CancelmembershipView extends StatefulWidget {
  const CancelmembershipView({super.key});

  @override
  State<CancelmembershipView> createState() => _CancelmembershipViewState();
}

class _CancelmembershipViewState extends State<CancelmembershipView> {
  String? _selectedReason;

  final TextEditingController _feedbackController =
  TextEditingController();

  final CancelmembershipController controller =
  Get.put(CancelmembershipController());

  final List<String> _reasons = [
    "Too expensive",
    "Not enough matches",
    "Found someone",
    "Technical issues",
    "Privacy concerns",
    "Switching to other app",
    "Not satisfied with features",
    "Others",
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 50.sp,
                color: const Color(0xffFF6B00),
              ),
              SizedBox(height: 16.h),
              Text(
                "Cancel Membership?",
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff444444),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to cancel your premium membership?\n"
                    "This will take effect from the next billing cycle.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: const Color(0xff666666),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffEFEFEF),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        "Keep Plan",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: const Color(0xff444444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _cancelMembership();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cancelMembership() async {
    final success = await controller.cancelMembership(
      reason: _selectedReason,
      feedback: _feedbackController.text,
    );

    if (success) {
      Get.snackbar(
        "Membership Cancelled",
        "Your premium membership has been cancelled successfully.",
        backgroundColor: const Color(0xffFF6B00),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } else {
      Get.snackbar(
        "Failed",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
      backgroundColor: Colors.transparent,

      // ✅ Same background style
      extendBodyBehindAppBar: true,
      extendBody: true,

      appBar: const CustomAppBar(
        title: "Cancel Membership",
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─────────────────────────────────────
          // Background Image
          // ─────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ─────────────────────────────────────
          // White Opacity Overlay
          // No Blur
          // ─────────────────────────────────────
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ─────────────────────────────────────
          // Content
          // ─────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  40.h,
                ),
                child: Column(
                  children: [
                    // ─────────────────────────────
                    // Main Card
                    // ─────────────────────────────
                    Container(
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
                        children: [
                          // ─────────────────────────
                          // Header
                          // ─────────────────────────
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xffFFF0E6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.card_membership_outlined,
                                  size: 24.sp,
                                  color: const Color(0xffFF6B00),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              Expanded(
                                child: Text(
                                  "Premium Membership",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff444444),
                                  ),
                                ),
                              ),

                              SizedBox(width: 3.w),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius:
                                  BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  "ACTIVE",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                    letterSpacing: 1.2.w,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // ─────────────────────────
                          // Membership Details
                          // ─────────────────────────
                          Obx(() {
                            if (controller.isLoading.value) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xffFF6B00),
                                  ),
                                ),
                              );
                            }

                            final sub = controller.subscription.value ??
                                controller.defaultData;

                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                _infoRow(
                                  "Plan",
                                  sub.planName.isNotEmpty
                                      ? sub.planName
                                      : "Premium Plus",
                                ),

                                _infoRow(
                                  "Billing Cycle",
                                  "Monthly",
                                ),

                                _infoRow(
                                  "Amount",
                                  "₹${sub.priceAfterTrial}/month",
                                ),

                                if (sub.trialText.isNotEmpty)
                                  _infoRow(
                                    "Trial",
                                    "${sub.trialText} ₹${sub.trialPrice}",
                                  ),

                                if (controller
                                    .errorMessage.value.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 4.h,
                                    ),
                                    child: Text(
                                      controller.errorMessage.value,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),

                          SizedBox(height: 24.h),

                          Divider(
                            color: Colors.grey.shade200,
                            height: 1.h,
                          ),

                          SizedBox(height: 24.h),

                          // ─────────────────────────
                          // Cancel Title
                          // ─────────────────────────
                          Text(
                            "Why are you cancelling?",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff444444),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // ─────────────────────────
                          // Reasons
                          // ─────────────────────────
                          ..._reasons.map(
                                (reason) => _reasonTile(reason),
                          ),

                          SizedBox(height: 16.h),

                          // ─────────────────────────
                          // Feedback
                          // ─────────────────────────
                          Text(
                            "Additional Feedback (Optional)",
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff444444),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          TextField(
                            controller: _feedbackController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                              "Share your thoughts to help us improve...",
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12.r),
                                borderSide: const BorderSide(
                                  color: Color(0xffFF6B00),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(12.w),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ─────────────────────────────
                    // Important Note
                    // ─────────────────────────────
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xffFFE0CC),
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20.sp,
                            color: const Color(0xffFF6B00),
                          ),

                          SizedBox(width: 12.w),

                          Expanded(
                            child: Text(
                              "Your membership will remain active until "
                                  "the end of the current billing cycle. "
                                  "You won't be charged again.",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: const Color(0xff666666),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ─────────────────────────────
                    // Cancel Button
                    // ─────────────────────────────
                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: controller.isCancelling.value
                            ? Container(
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFB88A),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 20.h,
                              width: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                            : CustomButton(
                          text: "Cancel Membership",
                          onPressed: _showConfirmDialog,
                          backgroundColor: const Color(0xffFF6B00),
                          textColor: Colors.white,
                          borderRadius: 30.r,

                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // ─────────────────────────────
                    // Contact Support
                    // ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Need help? ",
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Get.to(
                                  () => const ContactsupportView(),
                            );
                          },
                          child: Text(
                            "Contact Support",
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: const Color(0xffFF6B00),
                              fontWeight: FontWeight.w600,
                              decoration:
                              TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xff444444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonTile(String reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        height: 55.h,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xfffff2e8)
              : Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xffFF6B00)
                : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            reason,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              letterSpacing: 1.5,
              fontSize: 11.sp,
              fontWeight:
              isSelected ? FontWeight.w700 : FontWeight.bold,
              color: const Color(0xff444444),
            ),
          ),
        ),
      ),
    );
  }
}