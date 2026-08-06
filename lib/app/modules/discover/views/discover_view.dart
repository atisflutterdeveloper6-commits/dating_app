import 'package:dating_app/app/custom_widget/custom_appbar.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final List<Map<String, dynamic>> _profiles = [
    {
      'name': 'G. Srivalli',
      'age': 25,
      'location': 'Pune, Maharashtra',
      'image': 'assets/images/hprofile.png',
      'verified': true,
      'distance': '2.3 km',
      'interests': ['Travelling', 'Books', 'Music'],
      'profession': 'Professional Model',
      'bio': 'My Name Is G. Srivalli And I Enjoy Meeting New People...',
      'likeCount': 24000,
    },
    {
      'name': 'Riya Sharma',
      'age': 24,
      'location': 'Mumbai, Maharashtra',
      'image': 'assets/images/hprofile.png',
      'verified': true,
      'distance': '4.1 km',
      'interests': ['Dancing', 'Music', 'Fitness'],
      'profession': 'Dancer & Choreographer',
      'bio': 'Love dancing, music and long drives...',
      'likeCount': 18500,
    },
    {
      'name': 'Ananya Verma',
      'age': 26,
      'location': 'Bangalore, Karnataka',
      'image': 'assets/images/hprofile.png',
      'verified': false,
      'distance': '1.8 km',
      'interests': ['Reading', 'Travel', 'Photography'],
      'profession': 'Content Creator',
      'bio': 'Coffee lover | Bookworm | Adventure seeker',
      'likeCount': 32000,
    },
    {
      'name': 'Priya Patel',
      'age': 23,
      'location': 'Ahmedabad, Gujarat',
      'image': 'assets/images/hprofile.png',
      'verified': true,
      'distance': '5.6 km',
      'interests': ['Gym', 'Cooking', 'Yoga'],
      'profession': 'Fitness Trainer',
      'bio': 'Fitness enthusiast and foodie...',
      'likeCount': 15600,
    },
    {
      'name': 'Sneha Reddy',
      'age': 28,
      'location': 'Hyderabad, Telangana',
      'image': 'assets/images/hprofile.png',
      'verified': false,
      'distance': '3.2 km',
      'interests': ['Music', 'Pets', 'Food'],
      'profession': 'Music Teacher',
      'bio': 'Music lover | Pet parent | Foodie',
      'likeCount': 27800,
    },
    {
      'name': 'Neha Kapoor',
      'age': 27,
      'location': 'Delhi, NCR',
      'image': 'assets/images/hprofile.png',
      'verified': true,
      'distance': '6.8 km',
      'interests': ['Art', 'Writing', 'Cafe Hopping'],
      'profession': 'Content Writer',
      'bio': 'Exploring the world through words and art...',
      'likeCount': 19800,
    },
    {
      'name': 'Kavya Singh',
      'age': 22,
      'location': 'Jaipur, Rajasthan',
      'image': 'assets/images/hprofile.png',
      'verified': false,
      'distance': '2.9 km',
      'interests': ['Photography', 'Travel', 'Food'],
      'profession': 'Photographer',
      'bio': 'Capturing moments and creating memories...',
      'likeCount': 21300,
    },
    {
      'name': 'Meera Nair',
      'age': 29,
      'location': 'Chennai, Tamil Nadu',
      'image': 'assets/images/hprofile.png',
      'verified': true,
      'distance': '4.5 km',
      'interests': ['Yoga', 'Meditation', 'Cooking'],
      'profession': 'Yoga Instructor',
      'bio': 'Find your inner peace and balance...',
      'likeCount': 16700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      appBar:  CustomAppBar(
        title: "Match Profile",
        onBackPressed: () {
          // Navigate to Dashboard Homepage (index 0)
          Get.find<DashboardController>().changeTab(0);
          // Optionally pop the current view if it's a separate route
          // Get.back();
      },),
      backgroundColor: const Color(0xffF5F5F5),
      body: Column(
        children: [
          // ─── Header ───
       
          SizedBox(height: 16.h),

          // ─── Profile Cards ───
          Expanded(
            child: _profiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80.sp,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No More Profiles",
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Check back later for new matches",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Reset profiles (in a real app, this would fetch new ones)
                              Get.snackbar(
                                "Refreshing",
                                "Finding new profiles for you...",
                                backgroundColor: const Color(0xffFF6B00),
                                colorText: Colors.white,
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF6B00),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            "Refresh",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _profiles.length,
                    itemBuilder: (context, index) {
                      final profile = _profiles[index];
                      return _profileCard(profile, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(Map<String, dynamic> profile, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Profile Image ───
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.asset(
                    profile['image'],
                    width: 110.w,
                    height: 130.h,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 110.w,
                        height: 130.h,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (profile['verified'])
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              Positioned(
                bottom: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 10.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        profile['distance'],
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 12.w),

          // ─── Profile Info ───
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Age
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff1A1A1A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${profile['age']}",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (profile['verified'])
                              Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.verified,
                                  size: 14.sp,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF0E6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          profile['distance'],
                          style: GoogleFonts.poppins(
                            fontSize: 9.sp,
                            color: const Color(0xffFF6B00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Profession
                  Text(
                    profile['profession'] ?? 'Looking for connections',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          profile['location'],
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Interests
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: (profile['interests'] as List<String>).take(3).map((interest) {
                      return _interestChip(interest);
                    }).toList(),
                  ),

                  SizedBox(height: 8.h),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _actionButton(
                        Icons.close,
                        Colors.grey.shade100,
                        Colors.grey.shade700,
                        onTap: () {
                          _swipeCard(index, 'dislike');
                        },
                      ),
                      SizedBox(width: 8.w),
                      _actionButton(
                        Icons.favorite,
                        const Color(0xffFF6B00),
                        Colors.white,
                        onTap: () {
                          _swipeCard(index, 'like');
                        },
                      ),
                      SizedBox(width: 8.w),
                      _actionButton(
                        Icons.star,
                        Colors.amber.shade100,
                        Colors.amber.shade700,
                        onTap: () {
                          Get.snackbar(
                            "Super Like!",
                            "You super liked ${profile['name']}",
                            backgroundColor: Colors.amber,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 1),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 8.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32.w,
        width: 32.w,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: iconColor,
        ),
      ),
    );
  }

  void _swipeCard(int index, String action) {
    final profile = _profiles[index];
    
    // Show feedback
    Get.snackbar(
      action == 'like' ? "❤️ Liked!" : "✖️ Passed",
      action == 'like' 
          ? "You liked ${profile['name']}"
          : "You passed on ${profile['name']}",
      backgroundColor: action == 'like' 
          ? const Color(0xffFF6B00) 
          : Colors.grey.shade600,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 800),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );

    // Remove the card after swipe with animation
    setState(() {
      _profiles.removeAt(index);
    });
  }
}