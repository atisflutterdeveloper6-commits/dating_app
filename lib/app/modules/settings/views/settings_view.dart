import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/blockuser/views/blockuser_view.dart';
import 'package:dating_app/app/modules/cancelmembership/views/cancelmembership_view.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/helpandsupport/views/helpandsupport_view.dart';
import 'package:dating_app/app/modules/invoice/views/invoice_view.dart';
import 'package:dating_app/app/modules/privacypolicy/views/privacypolicy_view.dart';
import 'package:dating_app/app/modules/safetyandpolicy/views/safetyandpolicy_view.dart';
import 'package:dating_app/app/modules/snotifications/views/snotifications_view.dart';
import 'package:dating_app/app/modules/termsandconditions/views/termsandconditions_view.dart';
import 'package:dating_app/app/modules/verification/views/verification_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final StorageService _storage = StorageService();

  final List<Map<String, dynamic>> settings = [
    {
      "title": "Verification",
      "icon": Icons.verified_user_outlined,
      "verified": true,
      "page": const VerificationView(),
    },
    {
      "title": "Notification",
      "icon": Icons.notifications_none,
      "page": const SnotificationsView(),
    },
    {
      "title": "Blocked User",
      "icon": Icons.block_outlined,
      "page": const BlockuserView(),
    },
    {
      "title": "Privacy Policy",
      "icon": Icons.privacy_tip_outlined,
      "page": const PrivacypolicyView(),
    },
    {
      "title": "Terms & Conditions",
      "icon": Icons.description_outlined,
      "page": const TermsandconditionsView(),
    },
    {
      "title": "Help & Support",
      "icon": Icons.support_agent_outlined,
      "page": const HelpandsupportView(),
    },
    {
      "title": "Safety & Child Protection Policy",
      "icon": Icons.health_and_safety_outlined,
      "page": const SafetyandpolicyView(),
    },
    {
      "title": "Cancel Premium Membership",
      "icon": Icons.card_membership_outlined,
      "page": const CancelmembershipView(),
    },
    {
      "title": "Invoice",
      "icon": Icons.receipt_long_outlined,
      "isInvoice": true,
      "page": const InvoiceView(),
    },
  ];

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final chatService = Get.find<ChatService>();
        await chatService.updateOnlineStatus(false);
      } catch (e) {
        print('⚠️ Could not update online status: $e');
      }

      try {
        await CallInvitationService.uninit();
      } catch (e) {
        print('⚠️ Could not uninit call service: $e');
      }

      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        print('⚠️ Firebase sign out error: $e');
      }

      await _storage.clearAllIncludingPreferences();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      CustomToast.success(
        "Logged out successfully",
      );

      Get.offAllNamed("/login");
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      CustomToast.error(
        "Failed to logout. Please try again.",
      );

      print('❌ Logout error: $e');
    }
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 24.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/LoginBack2.png",
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.70),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
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
                          width: 0.8.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.035),
                            blurRadius: 12.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 55.w,
                            width: 55.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                const Color(0xFFFFE0CC),
                                width: 0.8.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  Colors.black.withOpacity(0.06),
                                  blurRadius: 12.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              size: 22.sp,
                              color:
                              const Color(0xffFF6B00),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          Text(
                            "Logout",
                            style: GoogleFonts.poppins(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w700,
                              color:
                              const Color(0xff222222),
                            ),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            "Are you sure you want to logout from your account?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color:
                              const Color(0xff666666),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46.h,
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor:
                                const Color(0xff444444),
                                side: BorderSide(
                                  color:
                                  const Color(0xFFF1E8E4),
                                  width: 0.8.w,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    30.r,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight:
                                  FontWeight.w500,
                                  color:
                                  const Color(0xff444444),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(
                          child: SizedBox(
                            height: 46.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                _logout();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                const Color(0xffFF6B00),
                                foregroundColor:
                                Colors.white,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    30.r,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Logout",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount() async {
    try {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 24.h,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/LoginBack2.png",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.70),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 28.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 65.w,
                        width: 65.w,
                        decoration: BoxDecoration(
                          color:
                          Colors.white.withOpacity(0.78),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            Colors.white.withOpacity(0.85),
                            width: 0.8.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffFF6B00),
                            strokeWidth: 3,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        "Deleting Account",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                          const Color(0xff222222),
                        ),
                      ),

                      SizedBox(height: 5.h),

                      Text(
                        "Please wait...",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color:
                          const Color(0xff777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // TODO: Call delete account API

      await _storage.clearAllIncludingPreferences();

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      CustomToast.success(
        "Your account has been permanently deleted",
      );

      Get.offAllNamed("/login");
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      CustomToast.error(
        "Failed to delete account. Please try again.",
      );

      print('❌ Delete account error: $e');
    }
  }

  // ============================================================
  // DELETE ACCOUNT DIALOG
  // ============================================================

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 24.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/LoginBack2.png",
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.70),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 70.w,
                      width: 70.w,
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.78),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          Colors.white.withOpacity(0.85),
                          width: 0.8.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 34.sp,
                        color:
                        const Color(0xffFF6B00),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      "Delete Account",
                      style: GoogleFonts.poppins(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color:
                        const Color(0xff222222),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "This action is permanent and cannot be undone.\n"
                          "All your data will be deleted.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color:
                        const Color(0xff666666),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 22.h),

                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.55),
                        borderRadius:
                        BorderRadius.circular(16.r),
                        border: Border.all(
                          color:
                          Colors.white.withOpacity(0.70),
                          width: 0.7.w,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style:
                                OutlinedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                  Colors.white.withOpacity(
                                    0.65,
                                  ),
                                  foregroundColor:
                                  const Color(0xff444444),
                                  side: BorderSide(
                                    color:
                                    Colors.grey.shade300,
                                    width: 0.8,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      30.r,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight:
                                    FontWeight.w500,
                                    color:
                                    const Color(0xff444444),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          Expanded(
                            child: SizedBox(
                              height: 46.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  _deleteAccount();
                                },
                                style:
                                ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                  const Color(0xffFF6B00),
                                  foregroundColor:
                                  Colors.white,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      30.r,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Delete",
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================
  // INVOICE DIALOG
  // ============================================================

  void _showInvoiceDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 24.h,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/LoginBack2.png",
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.70),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withOpacity(0.75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 40.sp,
                        color:
                        const Color(0xffFF6B00),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      "Invoice Details",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color:
                        const Color(0xff1E1E1E),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "View or download your invoice",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color:
                        const Color(0xff666666),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(14.r),
                        border: Border.all(
                          color:
                          const Color(0xFFF1E8E4),
                          width: 0.8.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.035),
                            blurRadius: 12.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  "Invoice #INV-2024-001",
                                  style:
                                  GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    const Color(0xff1E1E1E),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Date: 15 Jan 2024",
                                style:
                                GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color:
                                  const Color(0xff666666),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          Divider(
                            color: Colors.grey.shade300,
                          ),

                          SizedBox(height: 12.h),

                          _buildInvoiceRow(
                            "Premium Plan",
                            "₹499",
                          ),

                          _buildInvoiceRow(
                            "Duration",
                            "1 Month",
                          ),

                          Divider(
                            color: Colors.grey.shade300,
                          ),

                          _buildInvoiceRow(
                            "Total",
                            "₹499",
                            isTotal: true,
                          ),


                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: "View Full Invoice",
                        onPressed: () {
                          Get.back();
                          _viewInvoice();
                        },
                        borderRadius: 30.r,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        textColor: Colors.white,
                        backgroundColor:
                        const Color(0xffFF6B00),
                        showArrow: false,
                        prefixIcon: Icon(
                          Icons.visibility_outlined,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          _downloadInvoice();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                          const Color(0xffFF6B00),
                          side: const BorderSide(
                            color: Color(0xffFF6B00),
                          ),
                          backgroundColor:
                          Colors.white.withOpacity(0.55),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 20.sp,
                              color:
                              const Color(0xffFF6B00),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Download Invoice",
                              style:
                              GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                const Color(0xffFF6B00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color:
                          const Color(0xff999999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INVOICE ROW
  // ============================================================

  Widget _buildInvoiceRow(
      String label,
      String value, {
        bool isTotal = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6.h,
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: isTotal
                  ? const Color(0xff1E1E1E)
                  : const Color(0xff666666),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: isTotal
                  ? const Color(0xffFF6B00)
                  : const Color(0xff1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DOWNLOAD INVOICE
  // ============================================================

  void _downloadInvoice() {
    CustomToast.info(
      "Downloading invoice...",
    );

    Future.delayed(
      const Duration(seconds: 2),
          () {
        CustomToast.success(
          "Invoice downloaded successfully! 📄",
        );
      },
    );
  }

  // ============================================================
  // VIEW INVOICE
  // ============================================================

  void _viewInvoice() {
    CustomToast.info(
      "Opening invoice details...",
    );

    // TODO:
    // Get.to(() => InvoiceDetailView());
  }

  // ============================================================
  // BUILD
  // ============================================================

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

      appBar: CustomAppBar(
        title: "Settings",
        subtitle: "Manage your account",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(5);
        },
      ),

      body: Stack(
        children: [
          // ========================================================
          // BACKGROUND
          // ========================================================

          Positioned.fill(
            child: Image.asset(
              "assets/images/LoginBack2.png",
              fit: BoxFit.cover,
            ),
          ),

          // ========================================================
          // WHITE OVERLAY
          // ========================================================

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.70),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 14.h,
                        bottom: 10.h,
                      ),
                      child: Container(
                        width: double.infinity,

                        // ==================================================
                        // WHITE MAIN CONTAINER
                        // ==================================================

                        padding: EdgeInsets.fromLTRB(
                          12.w,
                          14.h,
                          12.w,
                          14.h,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(14.r),
                          border: Border.all(
                            color:
                            const Color(0xFFF1E8E4),
                            width: 0.8.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              Colors.black.withOpacity(
                                0.035,
                              ),
                              blurRadius: 12.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            // ==================================================
                            // SETTINGS ITEMS
                            // ==================================================

                            ...List.generate(
                              settings.length,
                                  (index) {
                                final item =
                                settings[index];

                                final bool isInvoice =
                                    item["isInvoice"] ??
                                        false;

                                final bool isLast =
                                    index ==
                                        settings.length - 1;

                                return GestureDetector(
                                  onTap: () {
                                    if (isInvoice) {
                                      _showInvoiceDialog(
                                        context,
                                      );
                                    } else if (item["page"] !=
                                        null) {
                                      Get.to(
                                        item["page"],
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 56.h,
                                    margin: EdgeInsets.only(
                                      bottom:
                                      isLast ? 0 : 12.h,
                                    ),
                                    padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      const Color(
                                        0xFFFFFCFB,
                                      ),
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        12.r,
                                      ),
                                      border: Border.all(
                                        color:
                                        const Color(
                                          0xFFF1E8E4,
                                        ),
                                        width: 0.8.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // ICON
                                        Icon(
                                          item["icon"],
                                          size: 20.sp,
                                          color:
                                          const Color(
                                            0xffFF6A00,
                                          ),
                                        ),

                                        SizedBox(
                                          width: 12.w,
                                        ),

                                        // TITLE
                                        Expanded(
                                          child: Text(
                                            item["title"],
                                            style:
                                            GoogleFonts
                                                .poppins(
                                              letterSpacing:
                                              0.8.w,
                                              fontSize:
                                              13.sp,
                                              fontWeight:
                                              FontWeight
                                                  .w400,
                                              color:
                                              const Color(
                                                0xff444444,
                                              ),
                                            ),
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
                                          ),
                                        ),

                                        // VERIFIED / ARROW
                                        if (item[
                                        "verified"] ==
                                            true)
                                          Icon(
                                            Icons
                                                .check_circle,
                                            color:
                                            Colors.green,
                                            size: 18.sp,
                                          )
                                        else
                                          Icon(
                                            Icons
                                                .keyboard_arrow_right,
                                            color:
                                            const Color(
                                              0xffB5B5B5,
                                            ),
                                            size: 20.sp,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ========================================================
                  // LOGOUT BUTTON
                  // ========================================================

                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xffFF6A00),
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.2.w,
                          fontSize: 14.sp,
                          color:
                          const Color(0xffFF6A00),
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // ========================================================
                  // DELETE ACCOUNT
                  // ========================================================

                  CustomButton(
                    text: "Delete Account",
                    onPressed: () {
                      _showDeleteAccountDialog(
                        context,
                      );
                    },
                    backgroundColor:
                    const Color(0xffFF6B00),
                    textColor: Colors.white,
                    borderRadius: 30.r,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5.w,
                    showArrow: true,
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}