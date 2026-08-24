import 'dart:async';

import 'package:dating_app/app/modules/profilesetup/views/profilesetup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentsuccessView extends StatefulWidget {
  const PaymentsuccessView({super.key});

  @override
  State<PaymentsuccessView> createState() => _PaymentsuccessViewState();
}

class _PaymentsuccessViewState extends State<PaymentsuccessView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Payment Success screen 1 second ke liye show hogi
    _timer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilesetupView(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      backgroundColor: const Color(0xFFFFF0E6),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6A00),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 42.w,
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
    );
  }
}