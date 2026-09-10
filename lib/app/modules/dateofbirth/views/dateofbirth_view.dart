
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
final ProfileServiceController profileService =
Get.find<ProfileServiceController>();

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
return dateString.split('T')[0];
}

if (dateString.contains('-') && dateString.length >= 10) {
return dateString.substring(0, 10);
}

return dateString;
} catch (e) {
debugPrint('❌ Error parsing date: $e');
return dateString;
}
}

void _loadBirthday() {
try {
isFetching.value = true;

final birthday = profileService.profile.value.birthday;

debugPrint('📤 Loading birthday: $birthday');

if (birthday != null && birthday.isNotEmpty) {
final cleanedDate = _parseDateString(birthday);

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

debugPrint(
'✅ Birthday loaded: '
'$year-${month.toString().padLeft(2, '0')}-$day',
);
} else {
debugPrint('⚠️ Invalid date format: $cleanedDate');
_setDefaultDate();
}
} else {
_setDefaultDate();
}

isFetching.value = false;
} catch (e) {
debugPrint('❌ Error loading birthday: $e');
isFetching.value = false;
_setDefaultDate();
}
}

void _setDefaultDate() {
final now = DateTime.now();

selectedYear.value = (now.year - 25).toString();
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
debugPrint('❌ Error calculating age: $e');
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
CustomToast.warning(
'You must be at least 18 years old',
);
isLoading.value = false;
return;
}

final formattedBirthday =
"$year-${month.toString().padLeft(2, '0')}-"
"${day.toString().padLeft(2, '0')}";

debugPrint('📤 Updating birthday to: $formattedBirthday');
debugPrint('📤 Age: $age years');

profileService.updateBirthday(formattedBirthday);

final success = await profileService.updateProfile();

isLoading.value = false;

if (success) {
await profileService.fetchMyProfile();

_loadBirthday();

CustomToast.success(
'Date of birth updated successfully! 🎉',
);

Future.delayed(
const Duration(milliseconds: 500),
() {
Get.back();
},
);
} else {
CustomToast.error(
profileService.errorMessage.value,
);
}
} catch (e) {
isLoading.value = false;

CustomToast.error(
'Failed to update date of birth: $e',
);

debugPrint('❌ Error updating date of birth: $e');
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
extendBodyBehindAppBar: true,
backgroundColor: Colors.transparent,
resizeToAvoidBottomInset: true,

appBar: CustomAppBar(
title: "Date of Birth",
subtitle: "Update your date of birth",
onBackPressed: () {
Get.back();
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
// Background

  Positioned.fill(
    child: Image.asset(
      "assets/images/LoginBack2.png",
      fit: BoxFit.cover,
    ),
  ),

// ======================================================
// WHITE OVERLAY
// ======================================================

  Positioned.fill(
    child: Container(
      color: Colors.white.withOpacity(0.70),
    ),
  ),


SafeArea(
child: Obx(
() {
if (isFetching.value) {
return const Center(
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
);
}

return Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 28.w,
  ),
  child: Column(
    children: [
      // ==================================================
      // CENTER CONTENT
      // ==================================================

      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                SizedBox(
                  width: 320.w,
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFE0CC),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.cake_outlined,
                          color: const Color(0xFFFF6B00),
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date of Birth",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            Text(
                              "Update your date of birth.",
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                color: Colors.black54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // ==================================================
                // WHITE CONTENT CARD
                // ==================================================

                Container(
                  width: 320.w,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    30.h,
                    16.w,
                    30.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFF1E8E4),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(0.035),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        'Select your date of birth',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1F1F1F),
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // ==================================================
                      // DOB DROPDOWNS
                      // ==================================================

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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

                      SizedBox(height: 22.h),

                      // ==================================================
                      // AGE CARD
                      // ==================================================

                      Obx(
                            () => Container(
                          height: 48.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                          ),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF0E6),
                            borderRadius:
                            BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                              const Color(0xffFFE0CC),
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            'You are ${getAge()} years old',
                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color:
                              const Color(0xff3A3A3A),
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // CURRENT DOB
                      // ==================================================

                      if (profileService
                          .profile
                          .value
                          .birthday !=
                          null &&
                          profileService
                              .profile
                              .value
                              .birthday!
                              .isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 12.h,
                          ),
                          child: Text(
                            'Current: ${_parseDateString(profileService.profile.value.birthday!)}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                              fontStyle:
                              FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ==================================================
      // UPDATE BUTTON
      // ==================================================

      SafeArea(
        top: false,
        child: CustomButton(
          text: "Update",
          onPressed: isLoading.value
              ? () {}
              : updateDateOfBirth,
          isLoading: isLoading.value,
          backgroundColor:
          const Color(0xffFF6B00),
          textColor: Colors.white,
          borderRadius: 30.r,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          showArrow: true,
        ),
      ),

      SizedBox(height: 90.h),
    ],
  ),
);
},
),
),

// Loading overlay
Obx(
() {
if (!isLoading.value) {
return const SizedBox.shrink();
}

return Container(
color: Colors.white.withOpacity(0.75),
child: const Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
CircularProgressIndicator(
color: Color(0xffFF6A00),
),
SizedBox(height: 16),
Text(
'Updating date of birth...',
style: TextStyle(
color: Colors.grey,
fontSize: 14,
),
),
],
),
),
);
},
),

// Error message
Obx(
() {
if (profileService
    .errorMessage.value.isEmpty ||
isLoading.value) {
return const SizedBox.shrink();
}

return Positioned(
left: 32.w,
right: 32.w,
bottom: 100.h,
child: Container(
padding: EdgeInsets.all(16.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(12.r),
boxShadow: [
BoxShadow(
color:
Colors.black.withOpacity(0.08),
blurRadius: 10,
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.error_outline,
size: 40.sp,
color: Colors.red[300],
),

SizedBox(height: 8.h),

Text(
profileService.errorMessage.value,
style: GoogleFonts.poppins(
fontSize: 13.sp,
color: Colors.red,
),
textAlign: TextAlign.center,
),

SizedBox(height: 12.h),

ElevatedButton(
onPressed: () {
_loadBirthday();
},
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(0xffFF6A00),
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(
30.r,
),
),
),
child: Text(
"Retry",
style: GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight:
FontWeight.w600,
color: Colors.white,
),
),
),
],
),
),
);
},
),
],
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
fontSize: 12.sp,
fontWeight: FontWeight.w500,
color: const Color(0xff2F2F2F),
),
),

SizedBox(height: 8.h),

Container(
height: 48.h,
padding: EdgeInsets.symmetric(
horizontal: 10.w,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(12.r),
border: Border.all(
color: const Color(0xffDCDCDC),
),
),
child: DropdownButtonHideUnderline(
child: DropdownButton<String>(
value: value.value,
isExpanded: true,
icon: Icon(
Icons.keyboard_arrow_down,
size: 18.sp,
color: const Color(0xff555555),
),
style: GoogleFonts.poppins(
fontSize: 12.sp,
color: const Color(0xff666666),
),
items: items
    .map(
(e) => DropdownMenuItem<String>(
value: e,
child: Text(
e,
maxLines: 1,
overflow:
TextOverflow.ellipsis,
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

