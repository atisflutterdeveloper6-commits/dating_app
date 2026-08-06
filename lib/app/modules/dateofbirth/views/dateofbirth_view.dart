import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';

class DateofbirthView extends StatefulWidget {
  const DateofbirthView({super.key});

  @override
  State<DateofbirthView> createState() => _DateofbirthViewState();
}

class _DateofbirthViewState extends State<DateofbirthView> {
  final ProfileServiceController profileService = Get.find<ProfileServiceController>();

  late RxString selectedDay;
  late RxString selectedMonth;
  late RxString selectedYear;
  final RxBool isLoading = false.obs;
  final RxBool isFetching = false.obs;

  final List<String> days = List.generate(
    31,
    (index) => (index + 1).toString().padLeft(2, '0'),
  );

  final List<String> months = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> years = List.generate(
    100,
    (index) => (DateTime.now().year - index).toString(),
  );

  @override
  void initState() {
    super.initState();
    selectedDay = '01'.obs;
    selectedMonth = 'January'.obs;
    selectedYear = '1999'.obs;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBirthday();
    });
  }

  String _parseDateString(String dateString) {
    try {
      if (dateString.isEmpty) return dateString;

      if (dateString.contains('T')) {
        final parts = dateString.split('T');
        if (parts.isNotEmpty) {
          return parts[0];
        }
      }

      if (dateString.contains('-') && dateString.length >= 10) {
        return dateString.substring(0, 10);
      }

      return dateString;
    } catch (e) {
      print('❌ Error parsing date: $e');
      return dateString;
    }
  }

  void _loadBirthday() {
    try {
      isFetching.value = true;

      final birthday = profileService.profile.value.birthday;

      print('📤 Loading birthday: $birthday');

      if (birthday != null && birthday.isNotEmpty) {
        final cleanedDate = _parseDateString(birthday);
        print('📤 Cleaned date: $cleanedDate');

        final parts = cleanedDate.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final month = int.parse(parts[1]);
          final day = parts[2];

          selectedYear.value = year;
          selectedDay.value = day;

          if (month >= 1 && month <= 12) {
            selectedMonth.value = months[month - 1];
          }

          print('✅ Birthday loaded: $year-${month.toString().padLeft(2, '0')}-$day');
        } else {
          print('⚠️ Invalid date format: $cleanedDate');
          _setDefaultDate();
        }
      } else {
        print('ℹ️ No birthday found in profile');
        _setDefaultDate();
      }

      isFetching.value = false;
    } catch (e) {
      print('❌ Error loading birthday: $e');
      isFetching.value = false;
      _setDefaultDate();
    }
  }

  void _setDefaultDate() {
    final now = DateTime.now();
    final defaultYear = (now.year - 25).toString();
    selectedYear.value = defaultYear;
    selectedDay.value = '01';
    selectedMonth.value = 'January';
  }

  int getAge() {
    try {
      final monthIndex = months.indexOf(selectedMonth.value);
      if (monthIndex == -1) return 0;

      final birthDate = DateTime(
        int.parse(selectedYear.value),
        monthIndex + 1,
        int.parse(selectedDay.value),
      );

      final now = DateTime.now();

      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age >= 0 ? age : 0;
    } catch (e) {
      print('❌ Error calculating age: $e');
      return 0;
    }
  }

  Future<void> updateDateOfBirth() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final monthIndex = months.indexOf(selectedMonth.value);
      if (monthIndex == -1) {
        CustomToast.error('Invalid month selected');
        isLoading.value = false;
        return;
      }

      final day = int.parse(selectedDay.value);
      final month = monthIndex + 1;
      final year = int.parse(selectedYear.value);

      final birthDate = DateTime(year, month, day);
      final age = getAge();

      if (age < 18) {
        CustomToast.warning('You must be at least 18 years old');
        isLoading.value = false;
        return;
      }

      final formattedBirthday =
          "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

      print('📤 Updating birthday to: $formattedBirthday');
      print('📤 Age: $age years');

      profileService.updateBirthday(formattedBirthday);

      bool success = await profileService.updateProfile();

      isLoading.value = false;

      if (success) {
        await profileService.fetchMyProfile();
        _loadBirthday();

        CustomToast.success('Date of birth updated successfully! 🎉');

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back();
        });
      } else {
        CustomToast.error(profileService.errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      CustomToast.error('Failed to update date of birth: $e');
      print('❌ Error updating date of birth: $e');
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
      backgroundColor: const Color(0xffFAFAFA),
      appBar: CustomAppBar(
        title: "Date of Birth",
        onBackPressed: () {
          Get.back();
        },
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
              // ✅ FIX: Route-name matching unreliable tha, seedha safe navigation
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
                        'Loading birthday...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25.h),
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5.w,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff3B3B3B),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Select your date of birth',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // ✅ FIX: Flex ratios balance kiye — Day/Year ko barabar space,
                      // Month ko zyada space (lambe naam jaise "September" ke liye)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildDropdown(
                              title: 'Day',
                              value: selectedDay,
                              items: days,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 5,
                            child: _buildDropdown(
                              title: 'Month',
                              value: selectedMonth,
                              items: months,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            flex: 3,
                            child: _buildDropdown(
                              title: 'Year',
                              value: selectedYear,
                              items: years,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      Container(
                        height: 48.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF0E6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xffFFE0CC),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          'You are ${getAge()} years old',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff3A3A3A),
                          ),
                        ),
                      ),

                      if (profileService.profile.value.birthday != null &&
                          profileService.profile.value.birthday!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Text(
                            'Current: ${_parseDateString(profileService.profile.value.birthday!)}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // ✅ FIX: overflow safety
                          ),
                        ),

                      const Spacer(),

                      CustomButton(
                        text: "Update",
                        onPressed: isLoading.value ? () {} : updateDateOfBirth,
                        isLoading: isLoading.value,
                        backgroundColor: const Color(0xffFF6B00),
                      ),
                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String title,
    required RxString value,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff2F2F2F),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xffE5E5E5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.value,
              isExpanded: true, // ✅ Overflow prevent karta hai
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 18.sp,
              ),
              style: GoogleFonts.poppins(
                fontSize: 13.sp, // ✅ FIX: thoda chhota kiya taaki lambe month names fit ho jaayen
                color: const Color(0xff666666),
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis, // ✅ FIX: overflow safety
                        maxLines: 1,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading.value
                  ? null
                  : (val) {
                      if (val != null) {
                        value.value = val;
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }
}