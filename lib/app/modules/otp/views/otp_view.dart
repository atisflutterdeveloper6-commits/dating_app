import 'dart:async';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

class OtpView extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpView({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  late OtpController controller;
  final TextEditingController pinController = TextEditingController();

  String otpError = '';
  String formattedTime = '01:00';
  int secondsRemaining = 60;
  bool isVerifying = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    controller = OtpController(
      verificationId: widget.verificationId,
      phoneNumber: widget.phoneNumber,
    );

    controller.addListener(_updateUI);
    _updateUI();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.startTimer();
    });
  }

  void _updateUI() {
    if (!mounted) return;
    setState(() {
      otpError = controller.otpError;
      formattedTime = controller.formattedTime;
      secondsRemaining = controller.secondsRemaining;
      isVerifying = controller.isVerifying;
      isResending = controller.isResending;
    });
  }

  @override
  void dispose() {
    controller.removeListener(_updateUI);
    controller.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    const primaryColor = Color(0xffFF6B00);

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFA),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0E6), Color(0xFFFFF0E6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: isKeyboardOpen ? 360.h : 450.h,
                        child: Image.asset(
                          "assets/images/loginBack.png",
                          fit: isKeyboardOpen ? BoxFit.contain : BoxFit.cover,
                        ),
                      ),
                      if (!isKeyboardOpen) SizedBox(height: 30.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          'OTP sent to ${widget.phoneNumber}',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ✅ Simple Pinput — koi smsRetriever nahi, sirf manual entry
                      Pinput(
                        length: 6,
                        controller: pinController,
                        autofocus: true,
                        defaultPinTheme: PinTheme(
                          width: 40.w,
                          height: 40.h,
                          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xffC9C9C9)),
                          decoration: BoxDecoration(
                            color: const Color(0xffEFEFEF),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xffDDDDDD)),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 40.w,
                          height: 40.h,
                          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xffF5A3AF)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: primaryColor, width: 1.5),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 40.w,
                          height: 40.h,
                          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        separatorBuilder: (index) => SizedBox(width: 8.w),
                        pinAnimationType: PinAnimationType.scale,
                        onCompleted: (pin) {
                          controller.clearError();
                          controller.verifyOTP(pin);
                        },
                        onChanged: (pin) {
                          if (otpError.isNotEmpty) {
                            controller.clearError();
                          }
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Timer
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: secondsRemaining > 0 ? Colors.orange.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: secondsRemaining > 0 ? Colors.orange.shade200 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: secondsRemaining > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      if (!isKeyboardOpen) ...[
                        Text(
                          'Type The Verification Code\nWe\'ve Sent You',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xff555555), height: 1.4),
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: secondsRemaining == 0 && !isResending
                              ? () => controller.resendCode()
                              : null,
                          child: isResending
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: primaryColor,
                                  ),
                                )
                              : Text(
                                  'Send Again',
                                  style: TextStyle(
                                    letterSpacing: 1.2,
                                    color: secondsRemaining == 0 ? primaryColor : Colors.grey,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ],
                  ),
                ),
              ),

              // Verify Button
              if (!isKeyboardOpen)
                Container(
                  padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 15.h),
                  child: CustomButton(
                    text: isVerifying ? "Verifying..." : "Verify",
                    onPressed: isVerifying
                        ? () {}
                        : () {
                            final pin = pinController.text.trim();
                            if (pin.length == 6) {
                              controller.clearError();
                              controller.verifyOTP(pin);
                            } else {
                              CustomToast.error('Please enter complete 6-digit OTP');
                            }
                          },
                    isLoading: isVerifying,
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
                    height: 50.h,
                    borderRadius: 35.r,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    prefixIcon: isVerifying
                        ? null
                        : Icon(Icons.verified, color: Colors.white, size: 20.sp),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}