import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class WeightView extends StatefulWidget {
  const WeightView({super.key});

  @override
  State<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends State<WeightView> {
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();

  final Rx<String?> selectedWeight = Rx<String?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFetching = false.obs;

  final List<String> weights = [
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg',
    '80 kg',
    '85 kg',
    '90 kg',
    '95 kg',
    '100 kg',
    '105 kg',
    '110 kg',
    '115 kg',
    '120 kg',
  ];

  @override
  void initState() {
    super.initState();
    _loadWeight();
  }

  void _loadWeight() {
    try {
      isFetching.value = true;
      
      // Get weight from profile service
      final weight = profileService.profile.value.weight;
      
      print('📤 Loading weight: $weight');
      
      if (weight != null && weight.isNotEmpty) {
        // Check if the weight exists in the list
        if (weights.contains(weight)) {
          selectedWeight.value = weight;
          print('✅ Weight loaded: $weight');
        } else {
          print('⚠️ Weight not found in list: $weight');
          // Try to find matching weight
          final matchingWeight = weights.firstWhere(
            (w) => w.contains(weight) || weight.contains(w),
            orElse: () => weights.first,
          );
          selectedWeight.value = matchingWeight;
          print('✅ Using matching weight: $matchingWeight');
        }
      } else {
        print('ℹ️ No weight found in profile');
        selectedWeight.value = null;
      }
      
      isFetching.value = false;
    } catch (e) {
      print('❌ Error loading weight: $e');
      isFetching.value = false;
      selectedWeight.value = null;
    }
  }

  // Update Weight
  Future<void> updateWeight() async {
    if (isLoading.value) return;

    if (selectedWeight.value == null) {
      CustomToast.warning('Please select your weight');
      return;
    }

    isLoading.value = true;

    try {
      final weight = selectedWeight.value!;
      
      print('========================================');
      print('📤 UPDATING WEIGHT');
      print('📤 Selected Weight: $weight');
      print('📤 Current profile weight before update: ${profileService.profile.value.weight}');
      print('========================================');

      // Update in profile service
      profileService.updateWeight(weight);
      
      print('📤 After updateWeight() - profile weight: ${profileService.profile.value.weight}');

      // Save to server
      bool success = await profileService.updateProfile();

      print('📤 Update profile success: $success');
      print('📤 Profile weight after update: ${profileService.profile.value.weight}');
      print('📤 Error message: ${profileService.errorMessage.value}');

      isLoading.value = false;

      if (success) {
        // Refresh profile data after update
        await profileService.fetchMyProfile();
        
        // Reload the weight in UI
        _loadWeight();
        
        CustomToast.success('Weight updated successfully! 🎉');

        // Navigate back after success
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        CustomToast.error(profileService.errorMessage.value);
        // Reload to show correct data
        _loadWeight();
      }
    } catch (e) {
      isLoading.value = false;
      CustomToast.error('Failed to update weight: $e');
      print('❌ Error updating weight: $e');
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
        title: "Weight",
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
                        'Loading weight...',
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
                        'Weight',
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5.w,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff3B3B3B),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        'Select your weight',
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
                            value: selectedWeight.value,
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
                              'Select your weight',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: const Color(0xff999999),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Select your weight'),
                              ),
                              ...weights.map((weight) {
                                return DropdownMenuItem<String?>(
                                  value: weight,
                                  child: Text(weight),
                                );
                              }),
                            ],
                            onChanged: isLoading.value
                                ? null
                                : (newValue) {
                                    if (newValue != null) {
                                      selectedWeight.value = newValue;
                                    }
                                  },
                          ),
                        ),
                      ),

                      // Show current weight if saved
                      if (profileService.profile.value.weight != null &&
                          profileService.profile.value.weight!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Text(
                            'Current: ${profileService.profile.value.weight}',
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
                        onPressed: isLoading.value ? () {} : updateWeight,
                        isLoading: isLoading.value,
                        backgroundColor: selectedWeight.value != null 
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