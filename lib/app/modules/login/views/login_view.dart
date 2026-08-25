import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/app/custom_widget/custom_button.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/modules/otp/views/otp_view.dart';
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

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();

    // ------------------------------------------------------------
    // Validate phone
    // ------------------------------------------------------------

    if (phone.isEmpty || phone.length < 10) {
      print('❌ INVALID PHONE NUMBER');
      print('📱 Entered phone: $phone');

      CustomToast.error(
        'Please enter a valid phone number',
      );

      return;
    }

    final String fullPhoneNumber = '$selectedDialCode$phone';

    print('');
    print('========================================');
    print('🚀 SEND OTP STARTED');
    print('========================================');
    print('📱 Country Code: $selectedDialCode');
    print('📱 Phone Number: $phone');
    print('📱 Full Phone Number: $fullPhoneNumber');
    print('🔥 Firebase App Name: ${_auth.app.name}');
    print('🔥 Firebase Current User: ${_auth.currentUser?.uid}');
    print('========================================');

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,

        timeout: const Duration(
          seconds: 60,
        ),

        // ========================================================
        // VERIFICATION COMPLETED
        // ========================================================

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          print('');
          print('========================================');
          print('✅ AUTO VERIFICATION COMPLETED');
          print('========================================');
          print('📱 Phone: $fullPhoneNumber');
          print('🔐 Credential received successfully');
          print('========================================');

          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          try {
            print('🔄 Signing in with auto credential...');

            UserCredential userCredential =
                await _auth.signInWithCredential(
              credential,
            );

            final User? user = userCredential.user;

            print('');
            print('========================================');
            print('🎉 AUTO LOGIN SUCCESS');
            print('========================================');

            if (user != null) {
              print('🆔 Firebase UID: ${user.uid}');
              print('📱 Firebase Phone: ${user.phoneNumber}');
              print('📧 Email: ${user.email}');
              print(
                '🆕 Is New User: '
                '${userCredential.additionalUserInfo?.isNewUser}',
              );
            }

            print('========================================');

            Get.offAllNamed('/dashboard');
          } on FirebaseAuthException catch (e, stackTrace) {
            print('');
            print('========================================');
            print('🚨 AUTO LOGIN FIREBASE ERROR');
            print('========================================');
            print('❌ ERROR CODE: ${e.code}');
            print('❌ ERROR MESSAGE: ${e.message}');
            print('❌ ERROR PLUGIN: ${e.plugin}');
            print('❌ FULL ERROR: ${e.toString()}');
            print('📍 STACK TRACE:');
            print(stackTrace);
            print('========================================');

            CustomToast.error(
              e.message ??
                  'Auto verification failed. Please try again.',
            );
          } catch (e, stackTrace) {
            print('');
            print('========================================');
            print('🚨 AUTO LOGIN UNKNOWN ERROR');
            print('========================================');
            print('❌ ERROR: $e');
            print('📍 STACK TRACE:');
            print(stackTrace);
            print('========================================');

            CustomToast.error(
              'Auto verification failed. Please try again.',
            );
          }
        },

        // ========================================================
        // VERIFICATION FAILED
        // ========================================================

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          print('');
          print('========================================');
          print('🚨🚨🚨 FIREBASE PHONE OTP FAILED 🚨🚨🚨');
          print('========================================');
          print('📱 Phone Number: $fullPhoneNumber');
          print('📱 Country Code: $selectedDialCode');
          print('🔥 Firebase App: ${_auth.app.name}');
          print('👤 Current Firebase User: ${_auth.currentUser?.uid}');
          print('');
          print('❌ ERROR CODE: ${e.code}');
          print('❌ ERROR MESSAGE: ${e.message}');
          print('❌ ERROR PLUGIN: ${e.plugin}');
          print('❌ FULL ERROR: ${e.toString()}');
          print('========================================');

          String errorMessage =
              'Verification failed. Please try again.';

          switch (e.code) {
            // ----------------------------------------------------
            // INVALID PHONE
            // ----------------------------------------------------

            case 'invalid-phone-number':
              errorMessage =
                  'Invalid phone number format. Please check and try again.';
              break;

            // ----------------------------------------------------
            // TOO MANY REQUESTS
            // ----------------------------------------------------

            case 'too-many-requests':
              errorMessage =
                  'Too many attempts. Please try again later.';
              break;

            // ----------------------------------------------------
            // APP NOT AUTHORIZED
            // ----------------------------------------------------

            case 'app-not-authorized':
              errorMessage =
                  'App is not authorized. Please check Firebase SHA-1 and SHA-256.';
              break;

            // ----------------------------------------------------
            // PHONE AUTH DISABLED
            // ----------------------------------------------------

            case 'operation-not-allowed':
              errorMessage =
                  'Phone Authentication is disabled in Firebase.';
              break;

            // ----------------------------------------------------
            // BILLING
            // ----------------------------------------------------

            case 'billing-not-enabled':
              errorMessage =
                  'Firebase billing is not enabled for Phone Authentication.';
              break;

            // ----------------------------------------------------
            // QUOTA
            // ----------------------------------------------------

            case 'quota-exceeded':
              errorMessage =
                  'Firebase OTP quota exceeded. Please try again later.';
              break;

            // ----------------------------------------------------
            // INVALID CREDENTIAL
            // ----------------------------------------------------

            case 'invalid-credential':
              errorMessage =
                  'Invalid Firebase credential. Please try again.';
              break;

            // ----------------------------------------------------
            // CAPTCHA / APP VERIFICATION
            // ----------------------------------------------------

            case 'captcha-check-failed':
              errorMessage =
                  'App verification failed. Please try again.';
              break;

            // ----------------------------------------------------
            // NETWORK
            // ----------------------------------------------------

            case 'network-request-failed':
              errorMessage =
                  'Network error. Please check your internet connection.';
              break;

            // ----------------------------------------------------
            // DEFAULT
            // ----------------------------------------------------

            default:
              errorMessage =
                  e.message ??
                  'Verification failed. Please try again.';
          }

          print('');
          print('🎯 USER ERROR MESSAGE:');
          print(errorMessage);
          print('========================================');

          CustomToast.error(
            errorMessage,
          );
        },

        // ========================================================
        // CODE SENT
        // ========================================================

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          print('');
          print('========================================');
          print('✅✅✅ OTP CODE SENT SUCCESSFULLY');
          print('========================================');
          print('📱 Phone Number: $fullPhoneNumber');
          print('🔐 Verification ID received: YES');
          print(
            '🔐 Verification ID Length: '
            '${verificationId.length}',
          );
          print('🔁 Resend Token: $resendToken');
          print('========================================');

          // ------------------------------------------------------
          // Navigate to OTP screen
          // ------------------------------------------------------

          Get.to(
            () => OtpView(
              verificationId: verificationId,
              phoneNumber: fullPhoneNumber,
            ),
          );
        },

        // ========================================================
        // AUTO RETRIEVAL TIMEOUT
        // ========================================================

        codeAutoRetrievalTimeout: (
          String verificationId,
        ) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          print('');
          print('========================================');
          print('⏰ OTP AUTO RETRIEVAL TIMEOUT');
          print('========================================');
          print('📱 Phone: $fullPhoneNumber');
          print(
            '🔐 Verification ID Length: '
            '${verificationId.length}',
          );
          print('========================================');

          CustomToast.warning(
            'OTP retrieval timed out. Please enter OTP manually.',
          );
        },
      );

      print('');
      print('========================================');
      print('📨 verifyPhoneNumber() CALL COMPLETED');
      print('========================================');
    } on FirebaseAuthException catch (e, stackTrace) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      print('');
      print('========================================');
      print('🚨 SEND OTP FIREBASE EXCEPTION');
      print('========================================');
      print('📱 Phone: $fullPhoneNumber');
      print('❌ ERROR CODE: ${e.code}');
      print('❌ ERROR MESSAGE: ${e.message}');
      print('❌ ERROR PLUGIN: ${e.plugin}');
      print('❌ FULL ERROR: ${e.toString()}');
      print('📍 STACK TRACE:');
      print(stackTrace);
      print('========================================');

      CustomToast.error(
        e.message ??
            'Something went wrong. Please try again.',
      );
    } catch (e, stackTrace) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      print('');
      print('========================================');
      print('🚨 SEND OTP UNKNOWN EXCEPTION');
      print('========================================');
      print('📱 Phone: $fullPhoneNumber');
      print('❌ ERROR: $e');
      print('📍 STACK TRACE:');
      print(stackTrace);
      print('========================================');

      CustomToast.error(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    final bool isKeyboardOpen = keyboardHeight > 0;

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
              // ==================================================
              // IMAGE SECTION
              // ==================================================

              Expanded(
                child: Image.asset(
                  "assets/images/loginBack.png",
                  fit: isKeyboardOpen
                      ? BoxFit.contain
                      : BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              // ==================================================
              // BOTTOM WHITE SECTION
              // ==================================================

              Container(
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  bottom: 10.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --------------------------------------------
                    // PHONE LABEL
                    // --------------------------------------------

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

                    // --------------------------------------------
                    // PHONE INPUT
                    // --------------------------------------------

                    Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15.r),
                      ),
                      child: Row(
                        children: [
                          CountryCodePicker(
                            onChanged: (country) {
                              selectedDialCode =
                                  country.dialCode ?? '+91';

                              print(
                                '🌍 Country changed: '
                                '$selectedDialCode',
                              );
                            },
                            initialSelection: 'IN',
                            favorite: const [
                              '+91',
                              'IN',
                            ],
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
                              keyboardType:
                                  TextInputType.phone,
                              maxLength: 10,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    "Enter Phone Number",
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight:
                                      FontWeight.w500,
                                  color: Colors.grey,
                                ),
                                counterText: '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // --------------------------------------------
                    // LOGIN BUTTON
                    // --------------------------------------------

                    CustomButton(
                      text: "Login",
                      onPressed: sendOTP,
                      isLoading: isLoading,
                      backgroundColor:
                          const Color(0xffFF6B00),
                      textColor: Colors.white,
                      height: 50.h,
                      borderRadius: 35.r,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),

                    const SizedBox(height: 0),
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