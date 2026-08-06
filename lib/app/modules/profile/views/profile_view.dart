import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/dateofbirth/views/dateofbirth_view.dart';
import 'package:dating_app/app/modules/editphoto/views/editphoto_view.dart';
import 'package:dating_app/app/modules/editprofile/views/editprofile_view.dart';
import 'package:dating_app/app/modules/height/views/height_view.dart';
import 'package:dating_app/app/modules/profilebio/views/profilebio_view.dart';
import 'package:dating_app/app/modules/profilegender/views/profilegender_view.dart';
import 'package:dating_app/app/modules/weight/views/weight_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final List<Map<String, dynamic>> menuList = [
    {"icon": Icons.person_outline, "title": "Edit Profile", "page": EditprofileView()},
    {"icon": Icons.camera_alt_outlined, "title": "Edit Photo", "page": EditphotoView()},
    {"icon": Icons.cake_outlined, "title": "Date of Birth", "page": DateofbirthView()},
    {"icon": Icons.straighten_outlined, "title": "Height", "page": HeightView()},
    {"icon": Icons.monitor_weight_outlined, "title": "Weight", "page": WeightView()},
    {"icon": Icons.transgender_outlined, "title": "Gender", "page": ProfilegenderView()},
    {"icon": Icons.info_outline, "title": "Bio", "page": ProfilebioView()},
  
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: CustomAppBar(
        title: "Profile",
        onBackPressed: () {
          // Navigate to Dashboard Homepage (index 0)
          Get.find<DashboardController>().changeTab(0);
          // Optionally pop the current view if it's a separate route
          // Get.back();
      },
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
            },
            child: const Icon(Icons.settings),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 28.h),

            Stack(
              clipBehavior: Clip.none,
              children: [
               Container(
  height: 92.h,
  width: 92.w,
  alignment: Alignment.center,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: const Color(0xffFF6A00),
      width: 1.w,
    ),
  ),
  child: Icon(
    Icons.person,
    size: 50.sp,
    color: Colors.grey,
  ),
),
              
              ],
            ),



            SizedBox(height: 26.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: List.generate(
                  menuList.length,
                  (index) {
                    final item = menuList[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(item['page']);
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
                            Icon(item['icon'], size: 20.sp, color: const Color(0xffFF6A00)),
                            SizedBox(width: 12.w),
                            Text(
                              item['title'],
                              style: GoogleFonts.poppins(
                                letterSpacing: 1.5.w,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff444444),
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_right, color: const Color(0xffB5B5B5), size: 20.sp),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}