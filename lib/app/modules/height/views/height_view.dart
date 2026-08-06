import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class HeightView extends StatefulWidget {
  const HeightView({super.key});

  @override
  State<HeightView> createState() => _HeightViewState();
}

class _HeightViewState extends State<HeightView> {
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();

  final Rx<String?> selectedHeight = Rx<String?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFetching = false.obs;

  final List<String> heights = [
    "4 ft 8 in (142 cm)",
    "4 ft 9 in (144 cm)",
    "4 ft 10 in (147 cm)",
    "4 ft 11 in (149 cm)",
    "5 ft (152 cm)",
    "5 ft 1 in (155 cm)",
    "5 ft 2 in (157 cm)",
    "5 ft 3 in (160 cm)",
    "5 ft 4 in (162 cm)",
    "5 ft 5 in (165 cm)",
    "5 ft 6 in (167 cm)",
    "5 ft 7 in (170 cm)",
    "5 ft 8 in (172 cm)",
    "5 ft 9 in (175 cm)",
    "6 ft (182 cm)",
  ];

  @override
  void initState() {
    super.initState();
    _loadHeight();
  }

  void _loadHeight() {
    try {
      isFetching.value = true;
      
      // Get height from profile service
      final height = profileService.profile.value.height;
      
      print('📤 Loading height: $height');
      
      if (height != null && height.isNotEmpty) {
        // Check if the height exists in the list
        if (heights.contains(height)) {
          selectedHeight.value = height;
          print('✅ Height loaded: $height');
        } else {
          print('⚠️ Height not found in list: $height');
          // Try to find matching height
          final matchingHeight = heights.firstWhere(
            (h) => h.contains(height) || height.contains(h),
            orElse: () => heights.first,
          );
          selectedHeight.value = matchingHeight;
          print('✅ Using matching height: $matchingHeight');
        }
      } else {
        print('ℹ️ No height found in profile');
        selectedHeight.value = null;
      }
      
      isFetching.value = false;
    } catch (e) {
      print('❌ Error loading height: $e');
      isFetching.value = false;
      selectedHeight.value = null;
    }
  }

  // Update Height
  Future<void> updateHeight() async {
    if (isLoading.value) return;

    if (selectedHeight.value == null) {
      CustomToast.warning('Please select your height');
      return;
    }

    isLoading.value = true;

    try {
      final height = selectedHeight.value!;
      
      print('========================================');
      print('📤 UPDATING HEIGHT');
      print('📤 Selected Height: $height');
      print('📤 Current profile height before update: ${profileService.profile.value.height}');
      print('========================================');

      // Update in profile service
      profileService.updateHeight(height);
      
      print('📤 After updateHeight() - profile height: ${profileService.profile.value.height}');

      // Save to server
      bool success = await profileService.updateProfile();

      print('📤 Update profile success: $success');
      print('📤 Profile height after update: ${profileService.profile.value.height}');
      print('📤 Error message: ${profileService.errorMessage.value}');

      isLoading.value = false;

      if (success) {
        // Refresh profile data after update
        await profileService.fetchMyProfile();
        
        // Reload the height in UI
        _loadHeight();
        
        CustomToast.success('Height updated successfully! 🎉');

        // Navigate back after success
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        CustomToast.error(profileService.errorMessage.value);
        // Reload to show correct data
        _loadHeight();
      }
    } catch (e) {
      isLoading.value = false;
      CustomToast.error('Failed to update height: $e');
      print('❌ Error updating height: $e');
    }
  }

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
      backgroundColor: const Color(0xffFAFAFA),
      appBar: CustomAppBar(
        title: "Height",
        onBackPressed: () {
          Get.back();
        },
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
           Get.offAllNamed('/dashboard');
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

      body: SafeArea(
        child: Obx(
          () => isFetching.value
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xffFF6A00),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading height...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25.h),

                      // Title Text
                      Text(
                        'Height',
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5.w,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff3B3B3B),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        'Select your height',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // Dropdown
                      Container(
                        height: 48.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xffE5E5E5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedHeight.value,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20.sp,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: const Color(0xff444444),
                            ),
                            hint: Text(
                              'Select your height',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: const Color(0xff999999),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Select your height'),
                              ),
                              ...heights.map((height) {
                                return DropdownMenuItem<String?>(
                                  value: height,
                                  child: Text(height),
                                );
                              }),
                            ],
                            onChanged: isLoading.value
                                ? null
                                : (newValue) {
                                    if (newValue != null) {
                                      selectedHeight.value = newValue;
                                    }
                                  },
                          ),
                        ),
                      ),

                      // Show current height if saved
                      if (profileService.profile.value.height != null &&
                          profileService.profile.value.height!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Text(
                            'Current: ${profileService.profile.value.height}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Update Button
                      CustomButton(
                        text: "Update",
                        onPressed: isLoading.value ? () {} : updateHeight,
                        isLoading: isLoading.value,
                        backgroundColor: selectedHeight.value != null 
                            ? const Color(0xffFF6B00) 
                            : Colors.grey,
                      ),

                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}