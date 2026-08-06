import 'package:dating_app/app/custom_widget/custom_button.dart';
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
  late String phoneNumber;
  
  // State variables
  String otpError = '';
  String formattedTime = '';
  int secondsRemaining = 0;
  bool isVerifying = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    phoneNumber = widget.phoneNumber;
    controller = OtpController(
      verificationId: widget.verificationId,
      phoneNumber: widget.phoneNumber,
    );
    
    // Add listener to update UI when controller state changes
    controller.addListener(_updateUI);
    
    // Initial UI update
    _updateUI();
    
    // 🔥 START TIMER AUTOMATICALLY AS SOON AS SCREEN LOADS 🔥
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🟢 Screen loaded - Starting timer automatically');
        controller.startTimer();
        // Force UI update immediately
        _updateUI();
      }
    });
  }

  @override
  void dispose() {
    controller.removeListener(_updateUI);
    controller.dispose();
    super.dispose();
  }

  // 🔥 This method updates all UI states with setState
  void _updateUI() {
    if (mounted) {
      setState(() {
        // 🔥 FIXED: Removed .value from all variables
        otpError = controller.otpError;
        formattedTime = controller.formattedTime;
        secondsRemaining = controller.secondsRemaining;
        isVerifying = controller.isVerifying;
        isResending = controller.isResending;
      });
      print('🔄 UI Updated - Timer: $formattedTime, Seconds: $secondsRemaining');
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

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Image
                          Container(
                            width: double.infinity,
                            height: isKeyboardOpen ? 360.h : 450.h,
                            child: Image.asset(
                              "assets/images/loginBack.png",
                              fit: !isKeyboardOpen ? BoxFit.cover : BoxFit.contain,
                            ),
                          ),
                          isKeyboardOpen ? const SizedBox.shrink() : SizedBox(height: 30.h),

                          // Phone number display
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Text(
                              'OTP sent to $phoneNumber',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 16.h),

              
                          SizedBox(height: 12.h),

                          // OTP Input
                          Pinput(
                            length: 6,
                            autofocus: true,
                            defaultPinTheme: PinTheme(
                              width: 40.w,
                              height: 40.h,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffC9C9C9),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffEFEFEF),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xffDDDDDD)),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 40.w,
                              height: 40.h,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xffF5A3AF),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xffFF6B00), width: 1.5),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 40.w,
                              height: 40.h,
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffFF6B00),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            separatorBuilder: (index) => SizedBox(width: 8.w),
                            pinAnimationType: PinAnimationType.scale,
                            onCompleted: (pin) {
                              controller.clearError();
                              _updateUI();
                              controller.verifyOTP(pin);
                            },
                            onChanged: (pin) {
                              if (otpError.isNotEmpty) {
                                controller.clearError();
                                _updateUI();
                              }
                            },
                          ),
                         
                          SizedBox(height: 16.h),

                          // 🔥 TIMER DISPLAY - Updates every second with setState
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: secondsRemaining > 0 
                                  ? Colors.orange.shade50 
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: secondsRemaining > 0 
                                    ? Colors.orange.shade200 
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10.sp, 
                                color: secondsRemaining > 0 
                                    ? Colors.orange.shade700 
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [const FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Text & Resend
                          if (!isKeyboardOpen)
                            Column(
                              children: [
                                Text(
                                  'Type The Verification Code\nWe\'ve Sent You',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xff555555),
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                GestureDetector(
                                  onTap: secondsRemaining == 0
                                      ? () {
                                          controller.resendCode();
                                          _updateUI();
                                        }
                                      : null,
                                  child: isResending
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: const Color(0xffFF6B00),
                                          ),
                                        )
                                      : Text(
                                          'Send Again',
                                          style: TextStyle(
                                            letterSpacing: 1.2.w,
                                            color: secondsRemaining == 0
                                                ? const Color(0xffFF6B00)
                                                : Colors.grey,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                SizedBox(height: 40.h),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Verify Button
              if (!isKeyboardOpen)
                Container(
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: 15.h,
                  ),
                  child: CustomButton(
                    text: isVerifying ? "Verifying..." : "Verify",
                    onPressed: isVerifying 
                        ? () {} 
                        : () {
                            // Optional: Get pin from Pinput controller
                          },
                    isLoading: isVerifying,
                    backgroundColor: const Color(0xffFF6B00),
                    textColor: Colors.white,
                    height: 50.h,
                    borderRadius: 35.r,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    prefixIcon: isVerifying 
                        ? null 
                        : Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}