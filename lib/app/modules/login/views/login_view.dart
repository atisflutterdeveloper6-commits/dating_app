import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/modules/otp/views/otp_view.dart';
 // ✅ Import CustomToast
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final TextEditingController phoneController = TextEditingController();
  String selectedDialCode = '+91';
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendOTP() async {
    // Validate phone number
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      CustomToast.error('Please enter a valid phone number'); // ✅ Changed
      return;
    }

    setState(() {
      isLoading = true;
    });

    String fullPhoneNumber = '$selectedDialCode$phone';
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification for Android
          setState(() {
            isLoading = false;
          });
          await _auth.signInWithCredential(credential);
          Get.offAllNamed('/dashboard');
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false;
          });
          String errorMessage = 'Verification failed. Please try again.';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format. Please check and try again.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts. Please try again later.';
          }
          CustomToast.error(errorMessage); // ✅ Changed
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            isLoading = false;
          });
          // Navigate to OTP screen with verification ID
          Get.to(() => OtpView(
            verificationId: verificationId,
            phoneNumber: fullPhoneNumber,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            isLoading = false;
          });
          CustomToast.warning('OTP retrieval timed out. Please try again.'); // ✅ Changed
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      CustomToast.error('Something went wrong. Please try again.'); // ✅ Changed
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;
    
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E6),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: Column(
            children: [
              // Image Section
              Expanded(
                child: Image.asset(
                  "assets/images/loginBack.png",
                  fit: isKeyboardOpen ? BoxFit.contain : BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              // Bottom White Section
              Container(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: 10.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phone number label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Phone Number",
                        style: TextStyle(
                          letterSpacing: 1.5,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2E2E2E),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    // Phone input with country code picker
                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (country) {
                              selectedDialCode = country.dialCode ?? '+91';
                            },
                            initialSelection: 'IN',
                            favorite: const ['+91', 'IN'],
                            showCountryOnly: false,
                            dialogTextStyle: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.black,
                            ),
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 30.h,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Phone Number",
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                counterText: '', // Hide character counter
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Custom Login Button with Loading State
                    CustomButton(
                      text: "Login",
                      onPressed: sendOTP,
                      isLoading: isLoading,
                      backgroundColor: const Color(0xffFF6B00),
                      textColor: Colors.white,
                      height: 50.h,
                      borderRadius: 35.r,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    SizedBox(height: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}