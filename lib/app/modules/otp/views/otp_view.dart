import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

// ✅ AUTOFILL — no smart_auth, no custom SMS listener, zero crash risk.
//
// pinput >=5.0.0 removed its smart_auth-based androidSmsAutofillMethod
// entirely (see pinput changelog: "Removed smart_auth dependency ...
// it was causing some issues") — so that option no longer exists on
// pinput 6.x, and isn't what we want anyway: ANY second SMS listener is
// what raced with Firebase Auth's own internal SMS auto-retrieval
// session and caused the earlier native crash
// (com.google.android.gms.internal.firebase-auth-api.zzafs NPE).
//
// Instead: Firebase Auth already runs its OWN SMS auto-retrieval the
// moment verifyPhoneNumber() is called (in LoginView). When it detects
// the code, `verificationCompleted` fires with a PhoneAuthCredential
// that exposes the raw code via `credential.smsCode`. We just read that
// and drop it into this screen's pin field — see
// `OtpController.onAutoRetrievedCode` and how LoginView forwards to it.
// This uses ONLY Firebase's own listener; nothing extra is registered.

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

  final TextEditingController pinController = TextEditingController();

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

    controller.addListener(_updateUI);
    _updateUI();

    // 🔥 AUTOFILL: if Firebase auto-retrieves the SMS code while this
    // screen is open, LoginView's verificationCompleted forwards the raw
    // code here via this static hook. We fill the boxes and verify —
    // exact same code path as if the user typed it and it auto-submitted.
    OtpController.onAutoRetrievedCode = (code) {
      if (!mounted) return;
      print('📩 Auto-retrieved SMS code: $code');
      pinController.setText(code);
      controller.clearError();
      controller.verifyOTP(code);
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🟢 Screen loaded - Starting timer automatically');
        controller.startTimer();
        _updateUI();
      }
    });
  }

  @override
  void dispose() {
    // 🔥 Unregister so a later auto-retrieval (e.g. after leaving this
    // screen) doesn't try to touch a disposed controller/pinController.
    OtpController.onAutoRetrievedCode = null;
    controller.removeListener(_updateUI);
    controller.dispose();
    pinController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) {
      setState(() {
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
                          Container(
                            width: double.infinity,
                            height: isKeyboardOpen ? 360.h : 450.h,
                            child: Image.asset(
                              "assets/images/loginBack.png",
                              fit: !isKeyboardOpen ? BoxFit.cover : BoxFit.contain,
                            ),
                          ),
                          isKeyboardOpen ? const SizedBox.shrink() : SizedBox(height: 30.h),

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

                          // OTP Input — plain Pinput, no SMS listener.
                          // Autofill is handled separately (see initState)
                          // by forwarding Firebase's own auto-retrieved
                          // code into pinController + controller.verifyOTP.
                          Pinput(
                            length: 6,
                            controller: pinController,
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

                          // Timer display
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
                            final pin = pinController.text;
                            if (pin.length == 6) {
                              controller.clearError();
                              _updateUI();
                              controller.verifyOTP(pin);
                            } else {
                              CustomToast.error('Please enter complete 6-digit OTP');
                            }
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