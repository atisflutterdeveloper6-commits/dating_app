import 'package:dating_app/app/modules/profilesetup/views/profilesetup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentsuccessView extends StatelessWidget {
  const PaymentsuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil (Recommended to do this in build if not already initialized globally)
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Your design base (e.g., iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilesetupView(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0E6),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilesetupView(),
                      ),
                    );
                  },
                  child: Container(
                    width: 50.w,
                    height: 50.w, // Using .w for square shape
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6A00),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 42.w,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // Title
                Text(
                  "Payment Successful!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 1.5.w,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  "Your 1 Day Premium Trial Has Been\nActivated.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}