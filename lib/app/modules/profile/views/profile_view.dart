import 'dart:io';

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

import '../../../custom_widget/profile_service_controller.dart';

// ✅ StatelessWidget se StatefulWidget me convert kiya — taaki
// screen open hote hi profile fetch trigger ho sake.
class ProfileView extends StatefulWidget {
  ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final List<Map<String, dynamic>> menuList = [
    {
      "icon": Icons.person_outline,
      "title": "Edit Profile",
      "page": EditprofileView(),
    },
    {
      "icon": Icons.camera_alt_outlined,
      "title": "Edit Photo",
      "page": EditphotoView(),
    },
    {
      "icon": Icons.cake_outlined,
      "title": "Date of Birth",
      "page": DateofbirthView(),
    },
    {
      "icon": Icons.straighten_outlined,
      "title": "Height",
      "page": HeightView(),
    },
    {
      "icon": Icons.monitor_weight_outlined,
      "title": "Weight",
      "page": WeightView(),
    },
    {
      "icon": Icons.transgender_outlined,
      "title": "Gender",
      "page": ProfilegenderView(),
    },
    {
      "icon": Icons.info_outline,
      "title": "Bio",
      "page": ProfilebioView(),
    },
  ];

  late final ProfileServiceController profileService;

  @override
  void initState() {
    super.initState();
    profileService = Get.find<ProfileServiceController>();

    // ✅ Screen open hote hi fresh profile data fetch karo
    // (agar aapke controller me already ek flag hai jaise
    // profileService.profile.value.id.isEmpty to us se guard bhi laga sakte ho)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileService.fetchMyProfile();
    });
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
        title: "Profile",
        subtitle: "Update your profile",
        onBackPressed: () {
          Get.find<DashboardController>().changeTab(0);
        },
        actions: [
          IconButton(
            onPressed: () {
              Get.find<DashboardController>().changeTab(6);
              Get.offAllNamed('/dashboard');
            },
            padding: EdgeInsets.zero,
            icon: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.settings_outlined,
                  color: const Color(0xFFFF6B00),
                  size: 22.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),

      body: Stack(
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

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 28.h),

                  // ✅ Builder → Obx (reactive) — jab bhi profile ya photoPaths
                  // update ho, ye widget khud rebuild ho jayega
                  Obx(() {
                    Widget? photoWidget;

                    // 1) Prefer local file path (freshly picked/updated photo)
                    if (profileService.photoPaths.isNotEmpty) {
                      final path = profileService.photoPaths.first;
                      if (path.isNotEmpty && File(path).existsSync()) {
                        photoWidget = Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          width: 60.w,
                          height: 60.h,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 35.sp,
                            color: Colors.grey,
                          ),
                        );
                      }
                    }

                    // 2) Fall back to network photo from profile data
                    if (photoWidget == null) {
                      final profilePhotos = profileService.profile.value.photos;
                      if (profilePhotos != null && profilePhotos.isNotEmpty) {
                        final first = profilePhotos.first;
                        String? imageUrl;

                        if (first is Map<String, dynamic>) {
                          imageUrl = first['image'] as String?;
                        } else if (first is String) {
                          imageUrl = first;
                        }

                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          photoWidget = Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: 60.w,
                            height: 60.h,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 35.sp,
                              color: Colors.grey,
                            ),
                          );
                        }
                      }
                    }

                    return Container(
                      height: 60.h,
                      width: 60.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffFF6A00),
                          width: 1.w,
                        ),
                      ),
                      child: photoWidget != null
                          ? ClipOval(
                        child: photoWidget,
                      )
                          : Icon(
                        Icons.person,
                        size: 35.sp,
                        color: Colors.grey,
                      ),
                    );
                  }),

                  SizedBox(height: 26.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    20.h,
                    16.w,
                    20.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFF1E8E4),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: const Color(0xffEFEFEF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'],
                                    size: 20.sp,
                                    color: const Color(0xffFF6A00),
                                  ),
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

                  ),


              )],


              ),

            ),
          ),

        ],
      ),
    );
  }
}