import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // ============================================================
  // CONTROLLER
  // ============================================================

  late OtpController controller;

  final TextEditingController otpController =
  TextEditingController();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color bgColor =
  Color(0xFFFFF0E6);

  static const Color orange =
  Color(0xFFFF6B00);

  static const Color orangeLight =
  Color(0xFFFFA23A);

  static const Color darkText =
  Color(0xFF172033);

  static const Color greyText =
  Color(0xFF85858F);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller = OtpController(
      verificationId: widget.verificationId,
      phoneNumber: widget.phoneNumber,
    );

    controller.addListener(
      _controllerListener,
    );

    controller.startTimer();
  }

  // ============================================================
  // CONTROLLER LISTENER
  // ============================================================

  void _controllerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controller.removeListener(
      _controllerListener,
    );

    controller.dispose();

    otpController.dispose();

    super.dispose();
  }

  // ============================================================
  // POPPINS
  // ============================================================

  TextStyle poppins({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = darkText,
  }) {
    return GoogleFonts.poppins(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
    );
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _verifyOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      return;
    }

    if (otp.length != 6) {
      return;
    }

    await controller.verifyOTP(otp);
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _resendOtp() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (controller.secondsRemaining != 0) {
      return;
    }

    await controller.resendCode();

    if (mounted) {
      otpController.clear();
    }
  }

  // ============================================================
  // PHONE DISPLAY
  // ============================================================

  String get displayPhoneNumber {
    if (widget.phoneNumber.startsWith('+')) {
      return widget.phoneNumber;
    }

    return "+91 ${widget.phoneNumber}";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // SCREEN UTIL
    // ============================================================

    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
    );

    final size =
    MediaQuery.sizeOf(context);

    final screenHeight =
        size.height;

    final keyboardHeight =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    final bool isKeyboardOpen =
        keyboardHeight > 0;

    // ============================================================
    // TOP SECTION HEIGHT
    // ============================================================

    final double topSectionHeight =
    isKeyboardOpen
        ? screenHeight * 0.34
        : screenHeight * 0.44;

    // ============================================================
    // SCAFFOLD
    // ============================================================

    return Scaffold(
      backgroundColor: bgColor,

      resizeToAvoidBottomInset: true,

      // ==========================================================
      // BODY
      // ==========================================================

      body: Stack(
        children: [

          // ======================================================
          // BACKGROUND IMAGE
          // ======================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/LoginBack2.png',

              fit: BoxFit.cover,

              errorBuilder:
                  (context, error, stackTrace) {
                return Container(
                  decoration:
                  const BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end:
                      Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFF0E6),
                        Color(0xFFFFF8F3),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ======================================================
          // SOFT ORANGE OVERLAY
          // ======================================================

          Positioned.fill(
            child: Container(
              color:
              bgColor.withOpacity(0.10),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (
                  BuildContext context,
                  BoxConstraints constraints,
                  ) {
                return SingleChildScrollView(
                  physics:
                  const BouncingScrollPhysics(),

                  child: ConstrainedBox(
                    constraints:
                    BoxConstraints(
                      minHeight:
                      constraints.maxHeight,
                    ),

                    child: Column(
                      children: [

                        // ==================================================
                        // TOP SECTION
                        // ==================================================

                        SizedBox(
                          width:
                          double.infinity,

                          height:
                          topSectionHeight,

                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),

                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                // ==================================================
                                // LEFT SIDE
                                // ==================================================

                                Expanded(
                                  flex: 50,

                                  child: Padding(
                                    padding:
                                    EdgeInsets.only(
                                      left: 8.w,

                                      top:
                                      isKeyboardOpen
                                          ? screenHeight *
                                          0.025
                                          : screenHeight *
                                          0.060,
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                      children: [
SizedBox(height: 60.h,),
                                        // ==========================================
                                        // TITLE
                                        // ==========================================

                                        Text(
                                          "Verify your",

                                          style:
                                          poppins(
                                            size: 20,
                                            weight:
                                            FontWeight
                                                .w700,
                                          ),
                                        ),

                                        // ==========================================
                                        // NUMBER + ICON
                                        // ==========================================

                                        Row(
                                          mainAxisSize:
                                          MainAxisSize
                                              .min,

                                          children: [

                                            Text(
                                              "number",

                                              style:
                                              poppins(
                                                size: 20,
                                                weight:
                                                FontWeight
                                                    .w700,
                                                color:
                                                orange,
                                              ),
                                            ),

                                            SizedBox(
                                              width: 6.w,
                                            ),

                                            Icon(
                                              Icons
                                                  .verified_user_outlined,

                                              color:
                                              orange,

                                              size:
                                              19.sp,
                                            ),
                                          ],
                                        ),

                                        SizedBox(
                                          height: 8.h,
                                        ),

                                        // ==========================================
                                        // DESCRIPTION
                                        // ==========================================

                                        Text(
                                          "We have sent a 6 digit\n"
                                              "verification code to",

                                          style:
                                          poppins(
                                            size: 8.5,
                                            color:
                                            greyText,
                                          ).copyWith(
                                            height:
                                            1.45,
                                          ),
                                        ),

                                        SizedBox(
                                          height: 12.h,
                                        ),

                                        // ==========================================
                                        // PHONE NUMBER
                                        // ==========================================

                                        Container(
                                          padding:
                                          EdgeInsets.symmetric(
                                            horizontal:
                                            9.w,
                                            vertical:
                                            8.h,
                                          ),

                                          decoration:
                                          BoxDecoration(
                                            color:
                                            Colors.white,

                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              25.r,
                                            ),

                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors
                                                    .black
                                                    .withOpacity(
                                                  0.06,
                                                ),
                                                blurRadius:
                                                12,
                                                offset:
                                                const Offset(
                                                  0,
                                                  4,
                                                ),
                                              ),
                                            ],
                                          ),

                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize
                                                .min,

                                            children: [

                                              Icon(
                                                Icons
                                                    .phone_in_talk_outlined,
                                                size:
                                                13.sp,
                                                color:
                                                darkText,
                                              ),

                                              SizedBox(
                                                width:
                                                5.w,
                                              ),

                                              Flexible(
                                                child:
                                                Text(
                                                  displayPhoneNumber,

                                                  overflow:
                                                  TextOverflow
                                                      .ellipsis,

                                                  style:
                                                  poppins(
                                                    size:
                                                    8.5,
                                                    weight:
                                                    FontWeight
                                                        .w500,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(
                                                width:
                                                8.w,
                                              ),

                                              Container(
                                                height:
                                                12.h,
                                                width:
                                                0.7.w,
                                                color: Colors
                                                    .black
                                                    .withOpacity(
                                                  0.25,
                                                ),
                                              ),

                                              SizedBox(
                                                width:
                                                8.w,
                                              ),

                                              // ==================================
                                              // EDIT
                                              // ==================================

                                              GestureDetector(
                                                onTap: () {
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus();

                                                  Get.back();
                                                },

                                                child:
                                                Text(
                                                  "Edit",

                                                  style:
                                                  poppins(
                                                    size:
                                                    8.5,
                                                    weight:
                                                    FontWeight
                                                        .w600,
                                                    color:
                                                    orange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // ==================================================
                                // RIGHT SIDE IMAGE
                                // ==================================================

                                Expanded(
                                  flex: 40,

                                  child: Padding(
                                    padding:
                                    EdgeInsets.only(
                                      top:
                                      isKeyboardOpen
                                          ? screenHeight *
                                          0.025
                                          : screenHeight *
                                          0.080,
                                    ),

                                    child: Image.asset(
                                      'assets/images/loginback.png',

                                      height:
                                      isKeyboardOpen
                                          ? screenHeight *
                                          0.30
                                          : screenHeight *
                                          0.40,

                                      width:
                                      double.infinity,

                                      fit:
                                      BoxFit.contain,

                                      alignment:
                                      Alignment
                                          .topCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ==================================================
                        // SMALL GAP
                        // ==================================================

                        SizedBox(
                          height:
                          isKeyboardOpen
                              ? 8.h
                              : 5.h,
                        ),

                        // ==================================================
                        // OTP WHITE CARD
                        // ==================================================

                        Transform.translate(
                          offset:
                          Offset(
                            0,
                            -12.h,
                          ),

                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal: 14.w,
                            ),

                            child: Container(
                              width:
                              double.infinity,

                              padding:
                              EdgeInsets.fromLTRB(
                                16.w,
                                5.h,
                                16.w,
                                16.h,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                Colors.white,

                                borderRadius:
                                BorderRadius
                                    .circular(
                                  20.r,
                                ),

                                border:
                                Border.all(
                                  color:
                                  const Color(
                                    0xFFE5E5E8,
                                  ),
                                  width:
                                  0.7,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color:
                                    orange
                                        .withOpacity(
                                      0.10,
                                    ),
                                    blurRadius:
                                    25,
                                    spreadRadius:
                                    2,
                                    offset:
                                    const Offset(
                                      0,
                                      7,
                                    ),
                                  ),
                                ],
                              ),

                              child:
                              Column(
                                children: [

                                  // ========================================
                                  // SECURITY IMAGE
                                  // ========================================

                                  SizedBox(
                                    height:
                                    68.w,

                                    width:
                                    68.w,

                                    child:
                                    Image.asset(
                                      "assets/otpSecure.png",

                                      fit:
                                      BoxFit.contain,

                                      errorBuilder:
                                          (
                                          context,
                                          error,
                                          stackTrace,
                                          ) {
                                        return Container(
                                          decoration:
                                          BoxDecoration(
                                            color: orange
                                                .withOpacity(
                                              0.08,
                                            ),
                                            shape:
                                            BoxShape
                                                .circle,
                                          ),

                                          child:
                                          Icon(
                                            Icons
                                                .lock_outline,
                                            color:
                                            orange,
                                            size:
                                            32.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                    2.h,
                                  ),

                                  // ========================================
                                  // TITLE
                                  // ========================================

                                  Text(
                                    "Enter 6 digit code",

                                    textAlign:
                                    TextAlign
                                        .center,

                                    style:
                                    poppins(
                                      size:
                                      13,
                                      weight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                    3.h,
                                  ),

                                  // ========================================
                                  // SUBTITLE
                                  // ========================================

                                  RichText(
                                    textAlign:
                                    TextAlign
                                        .center,

                                    text:
                                    TextSpan(
                                      children: [

                                        TextSpan(
                                          text:
                                          "OTP has been sent to ",

                                          style:
                                          poppins(
                                            size:
                                            8,
                                            color:
                                            greyText,
                                          ),
                                        ),

                                        TextSpan(
                                          text:
                                          displayPhoneNumber,

                                          style:
                                          poppins(
                                            size:
                                            8,
                                            color:
                                            orange,
                                            weight:
                                            FontWeight
                                                .w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                    17.h,
                                  ),

                                  // ========================================
                                  // OTP INPUT
                                  // ========================================

                                  Pinput(
                                    length:
                                    6,

                                    controller:
                                    otpController,

                                    autofocus:
                                    true,

                                    keyboardType:
                                    TextInputType
                                        .number,

                                    autofillHints:
                                    const [
                                      AutofillHints
                                          .oneTimeCode,
                                    ],

                                    defaultPinTheme:
                                    PinTheme(
                                      width:
                                      40.w,

                                      height:
                                      40.w,

                                      textStyle:
                                      poppins(
                                        size:
                                        16,
                                        weight:
                                        FontWeight
                                            .w600,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Colors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          8.r,
                                        ),

                                        border:
                                        Border.all(
                                          color:
                                          const Color(
                                            0xFFE5E5E8,
                                          ),
                                          width:
                                          1,
                                        ),
                                      ),
                                    ),

                                    focusedPinTheme:
                                    PinTheme(
                                      width:
                                      40.w,

                                      height:
                                      40.w,

                                      textStyle:
                                      poppins(
                                        size:
                                        16,
                                        weight:
                                        FontWeight
                                            .w600,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Colors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          8.r,
                                        ),

                                        border:
                                        Border.all(
                                          color:
                                          orange,
                                          width:
                                          1.4,
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color: orange
                                                .withOpacity(
                                              0.10,
                                            ),
                                            blurRadius:
                                            6,
                                          ),
                                        ],
                                      ),
                                    ),

                                    submittedPinTheme:
                                    PinTheme(
                                      width:
                                      40.w,

                                      height:
                                      40.w,

                                      textStyle:
                                      poppins(
                                        size:
                                        16,
                                        weight:
                                        FontWeight
                                            .w600,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Colors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          8.r,
                                        ),

                                        border:
                                        Border.all(
                                          color:
                                          orange,
                                          width:
                                          1,
                                        ),
                                      ),
                                    ),

                                    followingPinTheme:
                                    PinTheme(
                                      width:
                                      40.w,

                                      height:
                                      40.w,

                                      textStyle:
                                      poppins(
                                        size:
                                        16,
                                        weight:
                                        FontWeight
                                            .w600,
                                      ),

                                      decoration:
                                      BoxDecoration(
                                        color:
                                        Colors.white,

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          8.r,
                                        ),

                                        border:
                                        Border.all(
                                          color:
                                          const Color(
                                            0xFFE5E5E8,
                                          ),
                                          width:
                                          1,
                                        ),
                                      ),
                                    ),

                                    separatorBuilder:
                                        (index) {
                                      return SizedBox(
                                        width:
                                        7.w,
                                      );
                                    },

                                    cursor:
                                    Container(
                                      width:
                                      1.5.w,

                                      height:
                                      22.h,

                                      color:
                                      orange,
                                    ),

                                    pinAnimationType:
                                    PinAnimationType
                                        .scale,

                                    // ======================================
                                    // AUTO VERIFY
                                    // ======================================

                                    onCompleted:
                                        (pin) async {
                                      await controller
                                          .verifyOTP(
                                        pin,
                                      );
                                    },
                                  ),

                                  // ========================================
                                  // ERROR
                                  // ========================================

                                  if (controller
                                      .otpError
                                      .isNotEmpty) ...[
                                    SizedBox(
                                      height:
                                      8.h,
                                    ),

                                    Text(
                                      controller
                                          .otpError,

                                      textAlign:
                                      TextAlign
                                          .center,

                                      style:
                                      poppins(
                                        size:
                                        8,
                                        weight:
                                        FontWeight
                                            .w500,
                                        color:
                                        Colors.red,
                                      ),
                                    ),
                                  ],

                                  SizedBox(
                                    height:
                                    14.h,
                                  ),

                                  // ========================================
                                  // TIMER
                                  // ========================================

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                    children: [

                                      Text(
                                        "Resend code in ",

                                        style:
                                        poppins(
                                          size:
                                          9,
                                          color:
                                          const Color(
                                            0xFF9999A2,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        controller
                                            .formattedTime,

                                        style:
                                        poppins(
                                          size:
                                          9,
                                          color:
                                          orange,
                                          weight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height:
                                    16.h,
                                  ),

                                  // ========================================
                                  // VERIFY BUTTON
                                  // ========================================

                                  SizedBox(
                                    width:
                                    double.infinity,

                                    height:
                                    42.h,

                                    child:
                                    Container(
                                      decoration:
                                      BoxDecoration(
                                        gradient:
                                        const LinearGradient(
                                          begin:
                                          Alignment
                                              .centerLeft,
                                          end:
                                          Alignment
                                              .centerRight,

                                          colors: [
                                            orange,
                                            orange,
                                            orangeLight,
                                          ],

                                          stops: [
                                            0.0,
                                            0.72,
                                            1.0,
                                          ],
                                        ),

                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                          30.r,
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color: orange
                                                .withOpacity(
                                              0.22,
                                            ),
                                            blurRadius:
                                            12,
                                            offset:
                                            const Offset(
                                              0,
                                              5,
                                            ),
                                          ),
                                        ],
                                      ),

                                      child:
                                      ElevatedButton(
                                        onPressed:
                                        controller
                                            .isVerifying
                                            ? null
                                            : _verifyOtp,

                                        style:
                                        ElevatedButton
                                            .styleFrom(
                                          backgroundColor:
                                          Colors
                                              .transparent,

                                          disabledBackgroundColor:
                                          Colors
                                              .transparent,

                                          shadowColor:
                                          Colors
                                              .transparent,

                                          elevation:
                                          0,

                                          padding:
                                          EdgeInsets
                                              .zero,

                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              30.r,
                                            ),
                                          ),
                                        ),

                                        child:
                                        controller
                                            .isVerifying
                                            ? SizedBox(
                                          height:
                                          20.w,
                                          width:
                                          20.w,

                                          child:
                                          const CircularProgressIndicator(
                                            strokeWidth:
                                            2,
                                            color:
                                            Colors.white,
                                          ),
                                        )
                                            : Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,

                                          children: [

                                            Icon(
                                              Icons
                                                  .shield_outlined,
                                              color:
                                              Colors.white,
                                              size:
                                              18.sp,
                                            ),

                                            SizedBox(
                                              width:
                                              10.w,
                                            ),

                                            Container(
                                              height:
                                              20.h,
                                              width:
                                              0.7.w,
                                              color: Colors
                                                  .white
                                                  .withOpacity(
                                                0.45,
                                              ),
                                            ),

                                            SizedBox(
                                              width:
                                              10.w,
                                            ),

                                            Text(
                                              "Verify & Continue",

                                              style:
                                              poppins(
                                                size:
                                                11.5,
                                                weight:
                                                FontWeight
                                                    .w700,
                                                color:
                                                Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height:
                                    15.h,
                                  ),

                                  // ========================================
                                  // RESEND
                                  // ========================================

                                  GestureDetector(
                                    onTap:
                                    controller
                                        .secondsRemaining ==
                                        0 &&
                                        !controller
                                            .isResending
                                        ? _resendOtp
                                        : null,

                                    child:
                                    controller
                                        .isResending
                                        ? SizedBox(
                                      height:
                                      18.h,
                                      width:
                                      18.h,

                                      child:
                                      const CircularProgressIndicator(
                                        strokeWidth:
                                        2,
                                        color:
                                        orange,
                                      ),
                                    )
                                        : Text(
                                      "Resend code",

                                      style:
                                      poppins(
                                        size:
                                        10,
                                        weight:
                                        FontWeight
                                            .w600,
                                        color:
                                        controller.secondsRemaining ==
                                            0
                                            ? orange
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ==================================================
                        // SECURITY TEXT
                        // ==================================================

                        Transform.translate(
                          offset:
                          Offset(
                            0,
                            -5.h,
                          ),

                          child: Padding(
                            padding:
                            EdgeInsets.symmetric(
                              horizontal: 25.w,
                            ),

                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                Icon(
                                  Icons
                                      .lock_outline,

                                  size:
                                  13.sp,

                                  color:
                                  orange,
                                ),

                                SizedBox(
                                  width:
                                  5.w,
                                ),

                                Flexible(
                                  child:
                                  Text(
                                    "Your verification code is secure and will expire in 10 minutes.",

                                    textAlign:
                                    TextAlign
                                        .center,

                                    style:
                                    poppins(
                                      size:
                                      8,
                                      color:
                                      Colors.black,
                                    ).copyWith(
                                      height:
                                      1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height:
                          15.h,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}