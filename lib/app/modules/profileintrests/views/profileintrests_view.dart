import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:dating_app/app/modules/settings/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileintrestsView extends StatefulWidget {
  const ProfileintrestsView({super.key});

  @override
  State<ProfileintrestsView> createState() => _ProfileintrestsViewState();
}

class _ProfileintrestsViewState extends State<ProfileintrestsView> {
  List<String> selectedInterests = ['Shopping', 'Run', 'Traveling'];

  final List<Map<String, dynamic>> interests = const [
    {'title': 'Photography', 'icon': Icons.camera_alt_outlined},
    {'title': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    {'title': 'Karaoke', 'icon': Icons.mic_none_outlined},
    {'title': 'Yoga', 'icon': Icons.self_improvement_outlined},
    {'title': 'Cooking', 'icon': Icons.soup_kitchen_outlined},
    {'title': 'Tennis', 'icon': Icons.sports_tennis_outlined},
    {'title': 'Run', 'icon': Icons.directions_run_outlined},
    {'title': 'Swimming', 'icon': Icons.waves_outlined},
    {'title': 'Art', 'icon': Icons.palette_outlined},
    {'title': 'Traveling', 'icon': Icons.landscape_outlined},
    {'title': 'Extreme', 'icon': Icons.diamond_outlined},
    {'title': 'Music', 'icon': Icons.music_note_outlined},
    {'title': 'Drink', 'icon': Icons.wine_bar_outlined},
    {'title': 'Video games', 'icon': Icons.sports_esports_outlined},
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
        title: "Your Interests",
        actions: [
          GestureDetector(
            onTap: () {
              Get.find<DashboardController>().changeTab(6);
              Get.until((route) => route.settings.name == '/dashboard' || Get.currentRoute == '/dashboard');
            },
            child: const Icon(
              Icons.settings,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 22.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select A Few Of Your Interests And Let Everyone Know\nWhat You\'re Passionate About.',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                height: 1.7,
                color: const Color(0xff7D7D7D),
              ),
            ),
            SizedBox(height: 24.h),

            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: interests.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (context, index) {
                  final item = interests[index];
                  final isSelected = selectedInterests.contains(item['title']);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedInterests.remove(item['title']);
                        } else {
                          selectedInterests.add(item['title']);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xfffff2e8) // Light orange background from LookingFor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          width: isSelected ? 1.5.w : 1.w,
                          color: isSelected
                              ? const Color(0xffFF6B00) // Orange border when selected
                              : const Color(0xffECECEC),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'],
                            size: 18.sp,
                            color: isSelected
                                ? const Color(0xffFF6B00) // Orange icon when selected
                                : const Color(0xffFF6B00), // Always orange
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item['title'],
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700 // Bold when selected (like LookingFor)
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xffFF6B00) // Orange text when selected
                                    : const Color(0xff333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Optional: Add Next button at bottom like LookingFor
            SizedBox(height: 16.h),
            SafeArea(
              child: CustomButton(
                text: "Continue",
                onPressed: () {
                  // Add your navigation logic here
                  // Get.to(() => NextScreen());
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}