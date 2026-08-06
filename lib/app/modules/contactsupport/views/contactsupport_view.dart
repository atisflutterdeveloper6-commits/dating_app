import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../custom_widget/custom_appbar.dart';
import '../controllers/contactsupport_controller.dart';

class ContactsupportView extends GetView<ContactsupportController> {
  const ContactsupportView({super.key});

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
      appBar: const CustomAppBar(
        title: "Contact Support",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // ─── Main Card ───
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
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
                children: [
                  // ─── Header ───
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF0E6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent,
                          size: 24.sp,
                          color: const Color(0xffFF6B00),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "How can we help you?",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff444444),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // ─── Description ───
                  Text(
                    "We're here to help! Choose a topic below or reach out to us directly.",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // ─── Quick Help Options ───
                  Text(
                    "Quick Help",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff444444),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  _helpTile(
                    icon: Icons.help_outline,
                    title: "FAQs",
                    subtitle: "Find answers to common questions",
                    onTap: () => controller.goToFaqs(),
                  ),

                  _helpTile(
                    icon: Icons.report_problem_outlined,
                    title: "Report a Problem",
                    subtitle: "Report bugs or technical issues",
                    onTap: () => controller.reportProblem(),
                  ),

                  _helpTile(
                    icon: Icons.feedback_outlined,
                    title: "Give Feedback",
                    subtitle: "Share your suggestions with us",
                    onTap: () => controller.giveFeedback(),
                  ),

                  _helpTile(
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy & Security",
                    subtitle: "Learn about your data privacy",
                    onTap: () => controller.privacySecurity(),
                  ),

                  SizedBox(height: 24.h),

                  // ─── Divider ───
                  Divider(
                    color: Colors.grey.shade200,
                    height: 1.h,
                  ),

                  SizedBox(height: 24.h),

                  // ─── Contact Methods ───
                  Text(
                    "Contact Us Directly",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff444444),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  _contactMethod(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "support@datingapp.com",
                    onTap: () => controller.sendEmail(),
                  ),

                  _contactMethod(
                    icon: Icons.phone_outlined,
                    title: "Call Us",
                    subtitle: "+91 98765 43210",
                    onTap: () => controller.makeCall(),
                  ),

                  _contactMethod(
                    icon: Icons.chat_outlined,
                    title: "Live Chat",
                    subtitle: "Available 24/7",
                    onTap: () => controller.startChat(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ─── Response Time Note ───
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xffFFF8F0),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xffFFE0CC),
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 20.sp,
                    color: const Color(0xffFF6B00),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "We typically respond within 24-48 hours. For urgent issues, please use Live Chat.",
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

          
            SizedBox(height: 12.h),

            // ─── Back Button ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Need to go back? ",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    "Go Back",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: const Color(0xffFF6B00),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xffFFF0E6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: const Color(0xffFF6B00),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff444444),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(
          horizontal: 14.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xffE6F7F0),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: const Color(0xff00A86B),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff444444),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}