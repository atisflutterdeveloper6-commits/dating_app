import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/models/all_gender_model.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart'; // Add this import

class ProfilegenderView extends StatefulWidget {
  const ProfilegenderView({super.key});

  @override
  State<ProfilegenderView> createState() => _ProfilegenderViewState();
}

class _ProfilegenderViewState extends State<ProfilegenderView> {
  final ProfileServiceController profileController = Get.find<ProfileServiceController>();
 String _getGenderImagePath(String genderName) {
  final normalized = genderName.trim().toLowerCase();
  
  if (normalized == 'man' || normalized == 'male') {
    return 'assets/images/male.png';
  } else {
    return 'assets/images/female.png';  // ✅ Ab sirf Man/Woman hi aayenge, safe hai
  }
}
  // Gender selection (Man/Woman)
  String? selectedGenderId;
  String? selectedGenderTitle;
  
  // Sexual Orientation selection
  String? selectedOrientationId;
  String? selectedOrientationTitle;
  
  // Lists from API
  List<GenderModel> genders = [];
  List<SexualOrientationModel> orientations = [];
  
  bool isLoading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isFetching = true;
    });

    try {
      // Fetch genders and orientations from API
      final genderList = await profileController.fetchGenders();
      final orientationList = await profileController.fetchSexualOrientations();

      setState(() {
        genders = genderList;
        orientations = orientationList;
        
        // Set current values from profile
        final currentProfile = profileController.profile.value;
        
        // Check if gender is set (could be ID or title)
        if (currentProfile.gender != null && currentProfile.gender!.isNotEmpty) {
          // Try to find by ID first
          final foundGender = genders.firstWhere(
            (g) => g.id == currentProfile.gender,
            orElse: () => genders.firstWhere(
              (g) => g.gender == currentProfile.gender,
              orElse: () => GenderModel(
                id: '',
                gender: '',
                isDeleted: false,
                createdAt: '',
                updatedAt: '',
                v: 0,
              ),
            ),
          );
          if (foundGender.id.isNotEmpty) {
            selectedGenderId = foundGender.id;
            selectedGenderTitle = foundGender.gender;
          }
        }
        
        // Check if sexual orientation is set
        if (currentProfile.sexualOrientation != null && 
            currentProfile.sexualOrientation!.isNotEmpty) {
          final foundOrientation = orientations.firstWhere(
            (o) => o.id == currentProfile.sexualOrientation,
            orElse: () => orientations.firstWhere(
              (o) => o.title == currentProfile.sexualOrientation,
              orElse: () => SexualOrientationModel(
                id: '',
                title: '',
                isDeleted: false,
                createdAt: '',
                updatedAt: '',
                v: 0,
              ),
            ),
          );
          if (foundOrientation.id.isNotEmpty) {
            selectedOrientationId = foundOrientation.id;
            selectedOrientationTitle = foundOrientation.title;
          }
        }
        
        isFetching = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        isFetching = false;
      });
    }
  }

  Future<void> updateGenderAndOrientation() async {
    if (isLoading) return;

    // Validate selections
    if (selectedGenderId == null || selectedGenderId!.isEmpty) {
      CustomToast.error("Please select your gender");
      return;
    }

    if (selectedOrientationId == null || selectedOrientationId!.isEmpty) {
      CustomToast.error("Please select your sexual orientation");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update gender
      profileController.updateGender(selectedGenderId);
      
      // Update sexual orientation
      profileController.updateSexualOrientation(selectedOrientationId);
      
      // Save to server
      final success = await profileController.updateProfile();
      
      setState(() {
        isLoading = false;
      });

      if (success) {
        CustomToast.success("Gender updated successfully");
        
        // Navigate back after update
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        CustomToast.error(profileController.errorMessage.value);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomToast.error("Failed to update: $e");
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
      backgroundColor: const Color(0xffF7F7F7),
      appBar: CustomAppBar(
        title: "Gender & Orientation",
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
              Get.offAllNamed('/dashboard');
            },
            child: Icon(
              Icons.settings,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: isFetching
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xffFF6B00),
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  
                  // Gender Section
                  Text(
                    'Select Your Gender',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1E1E1E),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Gender selection (Man / Woman)
                Row(
  children: genders
      .where((gender) {
        final normalized = gender.gender.trim().toLowerCase();
        return normalized == 'man' || normalized == 'male' || 
               normalized == 'woman' || normalized == 'female';
      })
      .map((gender) {
        final isSelected = selectedGenderId == gender.id;
        final imagePath = _getGenderImagePath(gender.gender);
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedGenderId = gender.id;
                selectedGenderTitle = gender.gender;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xffFF6B00).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xffFF6B00)
                      : const Color(0xffE5E5E5),
                  width: isSelected ? 1.5.w : 1.w,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 54.h,
                    width: 54.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: const Color(0xffFF6B00), width: 0.5)
                          : null,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    gender.gender,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? const Color(0xffFF6B00) : const Color(0xff1E1E1E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
),
                  SizedBox(height: 40.h),

                  // Sexual Orientation Section
                  Text(
                    'Select Your Sexual Orientation',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1E1E1E),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Dropdown for sexual orientation
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        12.r,
                      ),
                      border: Border.all(
                        color: const Color(0xffE5E5E5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedOrientationId,
                        isExpanded: true,
                        hint: Text(
                          'Select orientation',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: const Color(0xff999999),
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.sp,
                          color: const Color(0xff444444),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: const Color(0xff444444),
                        ),
                        items: orientations
                            .map(
                              (orientation) => DropdownMenuItem(
                                value: orientation.id,
                                child: Text(orientation.title),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedOrientationId = value;
                              final found = orientations.firstWhere(
                                (o) => o.id == value,
                                orElse: () => SexualOrientationModel(
                                  id: '',
                                  title: '',
                                  isDeleted: false,
                                  createdAt: '',
                                  updatedAt: '',
                                  v: 0,
                                ),
                              );
                              selectedOrientationTitle = found.title;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Update Button
                  CustomButton(
                    text: "Update",
                    onPressed: isLoading ? () {} : updateGenderAndOrientation,
                    isLoading: isLoading,
                    backgroundColor: (selectedGenderId != null && selectedOrientationId != null)
                        ? const Color(0xffFF6B00)
                        : Colors.grey,
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
    );
  }
}