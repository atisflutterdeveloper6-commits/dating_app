import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profilebio_controller.dart';

class ProfilebioView extends GetView<ProfilebioController> {
  const ProfilebioView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    // Initialize controller if not already
    if (!Get.isRegistered<ProfilebioController>()) {
      Get.put(ProfilebioController());
    }

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: "Bio",
        onBackPressed: () {
          Get.back();
        },
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
              Get.until((route) => route.settings.name == '/dashboard' || Get.currentRoute == '/dashboard');
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Icon(
                Icons.settings,
                size: 24.sp,
                color: const Color(0xff444444),
              ),
            ),
          )
        ],
      ),
      body: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),

              Text(
                "Your Bio",
                style: TextStyle(
                  letterSpacing: 1.5.w,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                'Write something about yourself',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 20.h),

              // Bio Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // TextField
                      TextField(
                        controller: controller.bioController,
                        maxLines: null,
                        maxLength: 500,
                        expands: true,
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Write something about yourself...",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.all(16.w),
                          border: InputBorder.none,
                        ),
                      ),
                      
                      // Edit Icon at bottom right
                      Positioned(
                        bottom: 8.h,
                        right: 12.w,
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Character Counter
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.count.value} characters',
                    style: TextStyle(
                      color: controller.count.value > 450 
                          ? Colors.orange 
                          : Colors.green,
                      fontSize: 9.sp,
                    ),
                  ),
                  Text(
                    "/500",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25.h),

              // AI Help Text
              Center(
                child: Text(
                  "✨ Need help? Use AI to write bio",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xffFF6B00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // Update Button
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : controller.updateBio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF6A00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Update",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}