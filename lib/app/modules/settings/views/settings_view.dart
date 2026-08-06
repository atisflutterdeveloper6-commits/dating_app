import 'package:dating_app/app/custom_widget/custom_appbar.dart';
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
      "page": const InvoiceView(),
    },
  ];

Future<void> _logout() async {
  try {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // ✅ 1. Online status false karo (Firestore update, purani auth se)
    try {
      final chatService = Get.find<ChatService>();
      await chatService.updateOnlineStatus(false);
    } catch (e) {
      print('⚠️ Could not update online status: $e');
    }

    // ✅ 2. Zego call service se properly disconnect karo
    try {
      await CallInvitationService.uninit();
    } catch (e) {
      print('⚠️ Could not uninit call service: $e');
    }

    // ✅ 3. Firebase Auth se sign out karo — SABSE ZAROORI, pehle missing tha
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('⚠️ Firebase sign out error: $e');
    }

    // ✅ 4. Local storage clear karo
    await _storage.clearAllIncludingPreferences();

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    CustomToast.success("Logged out successfully");
    Get.offAllNamed("/login");

  } catch (e) {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    CustomToast.error("Failed to logout. Please try again.");
    print('❌ Logout error: $e');
  }
}
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 40.sp, color: const Color(0xffFF6A00)),
              SizedBox(height: 16.h),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff444444),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Are you sure you want to logout from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                        side: const BorderSide(color: Color(0xffEFEFEF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xff444444)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        _logout(); // Perform logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Delete Account Method
  Future<void> _deleteAccount() async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // TODO: Call delete account API
      // await _deleteAccountApi();
      
      // Clear all storage data including preferences
      await _storage.clearAllIncludingPreferences();
      
      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show success toast
      CustomToast.success("Your account has been permanently deleted");

      // Navigate to login screen
      Get.offAllNamed("/login");

    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error toast
      CustomToast.error("Failed to delete account. Please try again.");
      print('❌ Delete account error: $e');
    }
  }

  // Improved Delete Account Dialog
  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever, size: 40.sp, color: const Color(0xffFF6B00)),
              SizedBox(height: 16.h),
              Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffFF6B00),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "This action is permanent and cannot be undone.\nAll your data will be deleted.",
                textAlign: TextAlign.center,
                style: TextStyle(
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
                        side: const BorderSide(color: Color(0xffEFEFEF)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xff444444)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        _deleteAccount(); // Perform delete
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF6B00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Invoice Dialog
  void _showInvoiceDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: const Color(0xffFFF2E8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 40.sp,
                  color: const Color(0xffFF6B00),
                ),
              ),
              SizedBox(height: 16.h),
              
              Text(
                "Invoice Details",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1E1E1E),
                ),
              ),
              SizedBox(height: 8.h),
              
              Text(
                "View or download your invoice",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xff666666),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Invoice Preview
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F9FA),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xffEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Invoice #INV-2024-001",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1E1E1E),
                          ),
                        ),
                        Text(
                          "Date: 15 Jan 2024",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xff666666),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 12.h),
                    _buildInvoiceRow("Premium Plan", "\$29.99"),
                    _buildInvoiceRow("Duration", "1 Month"),
                    _buildInvoiceRow("Tax (10%)", "\$3.00"),
                    Divider(color: Colors.grey.shade300),
                    _buildInvoiceRow("Total", "\$32.99", isTotal: true),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),

              // View Invoice Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _viewInvoice();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF6B00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "View Full Invoice",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),

              // Download Invoice Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    _downloadInvoice();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xffFF6B00)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 20.sp,
                        color: const Color(0xffFF6B00),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Download Invoice",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffFF6B00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 8.h),

              // Cancel Button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xff999999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Download Invoice Function
  void _downloadInvoice() {
    CustomToast.info("Downloading invoice...");
    
    // TODO: Implement actual download logic
    // You can generate PDF or download from API
    
    Future.delayed(const Duration(seconds: 2), () {
      CustomToast.success("Invoice downloaded successfully! 📄");
    });
  }

  Widget _buildInvoiceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? const Color(0xff1E1E1E) : const Color(0xff666666),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? const Color(0xffFF6B00) : const Color(0xff1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  // View Invoice Function
  void _viewInvoice() {
    CustomToast.info("Opening invoice details...");
    
    // TODO: Navigate to full invoice page
    // Get.to(() => InvoiceDetailView());
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
      backgroundColor: const Color(0xffF7F7F7),
      appBar: CustomAppBar(
        title: "Settings",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(5);
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  final item = settings[index];
                  final isInvoice = item["isInvoice"] ?? false;
                  
                  return GestureDetector(
                    onTap: () {
                      if (isInvoice) {
                        _showInvoiceDialog(context);
                      } else if (item["page"] != null) {
                        Get.to(item["page"]);
                      }
                    },
                    child: Container(
                      height: 56.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xffEFEFEF)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item["icon"], 
                            size: 20.sp, 
                            color: const Color(0xffFF6B00),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              item["title"],
                              style: TextStyle(
                                letterSpacing: 1.5.w,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff444444),
                              ),
                            ),
                          ),
                          if (isInvoice)
                            Icon(
                              Icons.keyboard_arrow_right, 
                              color: const Color(0xffB5B5B5), 
                              size: 20.sp,
                            )
                          else if (item["verified"] == true)
                            Icon(
                              Icons.check_circle, 
                              color: Colors.green, 
                              size: 18.sp,
                            )
                          else
                            Icon(
                              Icons.keyboard_arrow_right, 
                              color: const Color(0xffB5B5B5), 
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 15.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffFF6B00)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    letterSpacing: 1.5.w,
                    fontSize: 14.sp,
                    color: const Color(0xffFF6B00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Delete Account Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => _showDeleteAccountDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF6B00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                ),
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    letterSpacing: 1.5.w,
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}