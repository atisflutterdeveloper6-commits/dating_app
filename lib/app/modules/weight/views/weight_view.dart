
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
final ProfileServiceController profileService =
Get.find<ProfileServiceController>();

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

WidgetsBinding.instance.addPostFrameCallback((_) {
_loadWeight();
});
}

void _loadWeight() {
try {
isFetching.value = true;

final weight = profileService.profile.value.weight;

debugPrint('📤 Loading weight: $weight');

if (weight != null && weight.isNotEmpty) {
if (weights.contains(weight)) {
selectedWeight.value = weight;

debugPrint('✅ Weight loaded: $weight');
} else {
final matchingWeight = weights.firstWhere(
(w) => w.contains(weight) || weight.contains(w),
orElse: () => weights.first,
);

selectedWeight.value = matchingWeight;

debugPrint(
'✅ Using matching weight: $matchingWeight',
);
}
} else {
selectedWeight.value = null;
}

isFetching.value = false;
} catch (e) {
debugPrint('❌ Error loading weight: $e');

isFetching.value = false;
selectedWeight.value = null;
}
}

Future<void> updateWeight() async {
if (isLoading.value) return;

if (selectedWeight.value == null) {
CustomToast.warning('Please select your weight');
return;
}

isLoading.value = true;

try {
final weight = selectedWeight.value!;

debugPrint('========================================');
debugPrint('📤 UPDATING WEIGHT');
debugPrint('📤 Selected Weight: $weight');
debugPrint(
'📤 Current weight: '
'${profileService.profile.value.weight}',
);
debugPrint('========================================');

profileService.updateWeight(weight);

final success = await profileService.updateProfile();

debugPrint('📤 Update profile success: $success');
debugPrint(
'📤 Profile weight after update: '
'${profileService.profile.value.weight}',
);
debugPrint(
'📤 Error message: '
'${profileService.errorMessage.value}',
);

isLoading.value = false;

if (success) {
await profileService.fetchMyProfile();

_loadWeight();

CustomToast.success(
'Weight updated successfully! 🎉',
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

_loadWeight();
}
} catch (e) {
isLoading.value = false;

CustomToast.error(
'Failed to update weight: $e',
);

debugPrint('❌ Error updating weight: $e');
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

// ======================================================
// APP BAR
// ======================================================

appBar: CustomAppBar(
title: "Weight",
subtitle: "Update your weight",
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

// ======================================================
// BODY
// ======================================================

body: Stack(
children: [

// ======================================================
// BACKGROUND IMAGE
// ======================================================

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

// ======================================================
// MAIN CONTENT
// ======================================================

SafeArea(
child: Obx(
() {
if (isFetching.value) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(
width: 24.w,
height: 24.w,
child: const CircularProgressIndicator(
color: Color(0xffFF6A00),
),
),
SizedBox(height: 16.h),
Text(
'Loading weight...',
style: GoogleFonts.poppins(
color: Colors.grey,
fontSize: 12.sp,
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

      // ==========================================
      // CENTER CONTENT
      // ==========================================

      Expanded(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ==========================================
                // HEADER - WHITE BOX KE JUST UPAR
                // ==========================================

                SizedBox(
                  width: 320.w,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFE0CC),
                            width: 1.2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.monitor_weight_outlined,
                          color: const Color(0xFFFF6B00),
                          size: 22.sp,
                        ),
                      ),

                      SizedBox(width: 14.w),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Weight",
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            "Update your weight.",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Header → White Box gap
                SizedBox(height: 12.h),

                // ==========================================
                // WHITE CENTER BOX
                // ==========================================

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
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFF1E8E4),
                      width: 0.8.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 12.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // ==========================================
                      // LABEL
                      // ==========================================

                      Text(
                        'Select your weight',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff1F1F1F),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ==========================================
                      // WEIGHT DROPDOWN
                      // ==========================================

                      Container(
                        height: 50.h,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
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
                          child: DropdownButton<String?>(
                            value: selectedWeight.value,
                            isExpanded: true,

                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20.sp,
                              color: const Color(0xff555555),
                            ),

                            style: GoogleFonts.poppins(
                              fontSize: 13.sp,
                              color: const Color(0xff444444),
                            ),

                            hint: Text(
                              'Select your weight',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: const Color(0xff999999),
                              ),
                            ),

                            items: weights.map((weight) {
                              return DropdownMenuItem<String?>(
                                value: weight,
                                child: Text(
                                  weight,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: isLoading.value
                                ? null
                                : (newValue) {
                              if (newValue != null) {
                                selectedWeight.value =
                                    newValue;
                              }
                            },
                          ),
                        ),
                      ),

                      // ==========================================
                      // CURRENT WEIGHT
                      // ==========================================

                      if (profileService
                          .profile
                          .value
                          .weight !=
                          null &&
                          profileService
                              .profile
                              .value
                              .weight!
                              .isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                            top: 12.h,
                          ),
                          child: Text(
                            'Current: ${profileService.profile.value.weight}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

      // ==========================================
      // UPDATE BUTTON
      // ==========================================

      SafeArea(
        top: false,
        child: Obx(
              () => CustomButton(
            text: "Update",

            onPressed:
            selectedWeight.value == null ||
                isLoading.value
                ? () {}
                : updateWeight,

            isLoading: isLoading.value,

            backgroundColor:
            selectedWeight.value != null
                ? const Color(0xffFF6B00)
                : Colors.grey,

            textColor: Colors.white,

            borderRadius: 30.r,

            fontSize: 11.sp,

            fontWeight: FontWeight.w600,

            letterSpacing: 0,

            showArrow: true,
          ),
        ),
      ),

      SizedBox(height: 90.h),
    ],
  ),
);
},
),
),

// ======================================================
// LOADING OVERLAY
// ======================================================

Obx(
() {
if (!isLoading.value) {
return const SizedBox.shrink();
}

return Container(
color:
Colors.white.withOpacity(0.75),
child: Center(
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [

SizedBox(
width: 28.w,
height: 28.w,
child:
const CircularProgressIndicator(
color:
Color(0xffFF6A00),
),
),

SizedBox(height: 16.h),

Text(
'Updating weight...',
style:
GoogleFonts.poppins(
color: Colors.grey,
fontSize: 12.sp,
),
),
],
),
),
);
},
),

// ======================================================
// ERROR CARD
// ======================================================

Obx(
() {
if (profileService
    .errorMessage
    .value
    .isEmpty ||
isLoading.value) {
return const SizedBox.shrink();
}

return Positioned(
left: 32.w,
right: 32.w,
bottom: 100.h,
child: Container(
padding:
EdgeInsets.all(16.w),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(12.r),
boxShadow: [
BoxShadow(
color: Colors.black
    .withOpacity(0.08),
blurRadius: 10.r,
),
],
),
child: Column(
mainAxisSize:
MainAxisSize.min,
children: [

Icon(
Icons.error_outline,
size: 40.sp,
color: Colors.red[300],
),

SizedBox(height: 8.h),

Text(
profileService
    .errorMessage.value,
style:
GoogleFonts.poppins(
fontSize: 13.sp,
color: Colors.red,
),
textAlign:
TextAlign.center,
),

SizedBox(height: 12.h),

ElevatedButton(
onPressed:
_loadWeight,
style:
ElevatedButton.styleFrom(
backgroundColor:
const Color(
0xffFF6A00),
elevation: 0,
shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
30.r),
),
),
child: Text(
"Retry",
style:
GoogleFonts.poppins(
fontSize: 13.sp,
fontWeight:
FontWeight.w600,
color:
Colors.white,
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
}

