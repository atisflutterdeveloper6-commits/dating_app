
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/modules/otp/views/otp_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'countrypicker.dart';

class LoginView extends StatefulWidget {
const LoginView({super.key});

@override
State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
with SingleTickerProviderStateMixin {
late AnimationController controller;

final TextEditingController phoneController =
TextEditingController();
String selectedFlagEmoji = '🇮🇳'; // default India
String selectedDialCode = '+91';

bool isLoading = false;

final FirebaseAuth _auth = FirebaseAuth.instance;

// ============================================================
// COLORS — 2ND CODE
// ============================================================

static const Color primaryColor = Color(0xffFF6B00);

static const Color lightBackground = Color(0xffFFF0E6);

static const Color mainTextColor = Color(0xff555555);

static const Color lightGreyText = Color(0xff8D8D8D);

static const Color inputBackground = Color(0xffffffff);

static const Color inputBorder = Color(0xffececec);

// ============================================================
// POPPINS
// ============================================================

TextStyle poppins({
double size = 14,
FontWeight weight = FontWeight.w400,
Color color = mainTextColor,
}) {
return GoogleFonts.poppins(
fontSize: size.sp,
fontWeight: weight,
color: color,
);
}

// ============================================================
// INIT
// ============================================================

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
final String phone = phoneController.text.trim();

if (phone.isEmpty || phone.length < 10) {
CustomToast.error(
'Please enter a valid phone number',
);
return;
}

final String fullPhoneNumber =
'$selectedDialCode$phone';

if (mounted) {
setState(() {
isLoading = true;
});
}

try {
await _auth.verifyPhoneNumber(
phoneNumber: fullPhoneNumber,
timeout: const Duration(seconds: 60),

// ========================================================
// AUTO VERIFICATION
// ========================================================

verificationCompleted:
(PhoneAuthCredential credential) async {
if (!mounted) return;

setState(() {
isLoading = false;
});

try {
final UserCredential userCredential =
await _auth.signInWithCredential(
credential,
);

final User? user = userCredential.user;

if (user != null) {
print('UID: ${user.uid}');
}

Get.offAllNamed('/dashboard');
} on FirebaseAuthException catch (e) {
CustomToast.error(
e.message ?? 'Auto verification failed.',
);
} catch (e) {
CustomToast.error(
'Auto verification failed.',
);
}
},

// ========================================================
// VERIFICATION FAILED
// ========================================================

verificationFailed:
(FirebaseAuthException e) {
if (!mounted) return;

setState(() {
isLoading = false;
});

String errorMessage =
'Verification failed. Please try again.';

switch (e.code) {
case 'invalid-phone-number':
errorMessage =
'Invalid phone number. Please check your number.';
break;

case 'too-many-requests':
errorMessage =
'Too many attempts. Please try again later.';
break;

case 'app-not-authorized':
errorMessage =
'App is not authorized. Please check Firebase SHA-1 and SHA-256.';
break;

case 'operation-not-allowed':
errorMessage =
'Phone Authentication is disabled in Firebase.';
break;

case 'billing-not-enabled':
errorMessage =
'Firebase billing is not enabled for Phone Authentication.';
break;

case 'quota-exceeded':
errorMessage =
'OTP quota exceeded. Please try again later.';
break;

case 'invalid-credential':
errorMessage =
'Invalid Firebase credential.';
break;

case 'captcha-check-failed':
errorMessage =
'App verification failed. Please try again.';
break;

case 'network-request-failed':
errorMessage =
'Network error. Please check your internet connection.';
break;

default:
errorMessage =
e.message ??
'Verification failed. Please try again.';
}

CustomToast.error(errorMessage);
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

Get.to(
() => OtpView(
verificationId: verificationId,
phoneNumber: fullPhoneNumber,
),
);
},

// ========================================================
// TIMEOUT
// ========================================================

codeAutoRetrievalTimeout:
(String verificationId) {
if (!mounted) return;

setState(() {
isLoading = false;
});

CustomToast.warning(
'OTP retrieval timed out. Please enter OTP manually.',
);
},
);
} on FirebaseAuthException catch (e) {
if (!mounted) return;

setState(() {
isLoading = false;
});

CustomToast.error(
e.message ??
'Something went wrong. Please try again.',
);
} catch (e) {
if (!mounted) return;

setState(() {
isLoading = false;
});

CustomToast.error(
'Something went wrong. Please try again.',
);
}
}

// ============================================================
// FEATURE ITEM
// ============================================================

Widget _featureItem({
required IconData icon,
required String title,
required String subtitle,
}) {
return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
height: 28.h,
width: 28.w,
decoration: BoxDecoration(
color: primaryColor.withOpacity(0.10),
shape: BoxShape.circle,
),
child: Icon(
icon,
size: 15.sp,
color: primaryColor,
),
),

SizedBox(width: 8.w),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
title,
style: poppins(
size: 9.5,
weight: FontWeight.w700,
color: mainTextColor,
),
),

SizedBox(height: 1.h),

Text(
subtitle,
style: poppins(
size: 7.5,
weight: FontWeight.w400,
color: lightGreyText,
).copyWith(
height: 1.25,
),
),
],
),
),
],
);
}

// ============================================================
// PHONE FIELD
// ============================================================

  Widget _phoneField(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: inputBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showCustomCountryPicker(
                context: context,
                onSelect: (country) {
                  setState(() {
                    selectedDialCode = '+${country.phoneCode}';
                    selectedFlagEmoji = country.flagEmoji; // niche state var add karo
                  });
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedFlagEmoji,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    selectedDialCode,
                    style: poppins(size: 12, weight: FontWeight.w500),
                  ),
                  Icon(Icons.arrow_drop_down, size: 18.sp, color: lightGreyText),
                ],
              ),
            ),
          ),

          Container(
            width: 1.w,
            height: 28.h,
            color: Colors.grey.shade300,
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,

              style: poppins(
                size: 13,
                weight: FontWeight.w500,
                color: mainTextColor,
              ),

              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                hintText: 'Enter Phone Number',

                hintStyle: poppins(
                  size: 12,
                  color: lightGreyText,
                ),

                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          SizedBox(width: 14.w),
        ],
      ),
    );
  }
// ============================================================
// SOCIAL BUTTON
// ============================================================

Widget _socialButton({
required Widget child,
required VoidCallback? onTap,
}) {
return GestureDetector(
onTap: onTap,
child: Container(
height: 42.h,
width: 42.w,
decoration: BoxDecoration(
color: Colors.white,
shape: BoxShape.circle,

border: Border.all(
color: inputBorder,
width: 1,
),

boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 8,
offset: const Offset(0, 3),
),
],
),
child: Center(
child: child,
),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
ScreenUtil.init(
context,
designSize: const Size(375, 812),
minTextAdapt: true,
splitScreenMode: true,
);

final size = MediaQuery.sizeOf(context);
final screenHeight = size.height;

final keyboardHeight =
MediaQuery.of(context).viewInsets.bottom;

final bool isKeyboardOpen =
keyboardHeight > 0;

final double topSectionHeight =
isKeyboardOpen
? screenHeight * 0.40
    : screenHeight * 0.44;

return Scaffold(
backgroundColor: lightBackground,
resizeToAvoidBottomInset: true,

body: Stack(
children: [
// ======================================================
// BACKGROUND — FIRST UI
// ======================================================

  Positioned.fill(
    child: Opacity(
      opacity: 0.7, // 0.0 = fully transparent, 1.0 = original
      child: Image.asset(
        'assets/images/LoginBack2.png',
        fit: BoxFit.cover,
      ),
    ),
  ),

// ======================================================
// SOFT ORANGE OVERLAY
// ======================================================

Positioned.fill(
child: Container(
color: lightBackground.withOpacity(0.10),
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
constraints: BoxConstraints(
minHeight:
constraints.maxHeight,
),

child: Column(
children: [
// ==================================================
// TOP SECTION
// ==================================================

SizedBox(
width: double.infinity,
height: topSectionHeight,

child: Padding(
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
vertical: 10.h,
),

child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,

children: [
// ==========================================
// LEFT SIDE
// ==========================================

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
// ----------------------------------
// WELCOME
// ----------------------------------

RichText(
text:
TextSpan(
children: [
TextSpan(
text:
'Welcome! ',
style:
poppins(
size: 20,
weight:
FontWeight.w700,
color:
mainTextColor,
),
),

TextSpan(
text: '♥',
style:
poppins(
size: 20,
weight:
FontWeight.w700,
color:
primaryColor,
),
),
],
),
),

SizedBox(
height: 2.h),

// ----------------------------------
// LET'S GET YOU
// ----------------------------------

Text(
"Let's get you",
style:
poppins(
size: 20,
weight:
FontWeight
    .w700,
color:
mainTextColor,
),
),

// ----------------------------------
// CONNECTED
// ----------------------------------

Text(
'connected',
style:
poppins(
size: 20,
weight:
FontWeight
    .w700,
color:
primaryColor,
),
),

SizedBox(
height: 8.h),

// ----------------------------------
// DESCRIPTION
// ----------------------------------

Text(
'Enter your phone number\n'
'to receive a verification\n'
'code and continue',

style:
poppins(
size: 8,
weight:
FontWeight
    .w400,
color:
lightGreyText,
).copyWith(
height: 1.35,
),
),

SizedBox(
height: 24.h),

// ----------------------------------
// FEATURE 1
// ----------------------------------

_featureItem(
icon: Icons
    .verified_user_rounded,
title:
'Safe & Secure',
subtitle:
'Your privacy is our priority',
),

SizedBox(
height: 7.h),

// ----------------------------------
// FEATURE 2
// ----------------------------------

_featureItem(
icon: Icons
    .bolt_rounded,
title:
'Quick & Easy',
subtitle:
'Get started in seconds',
),

SizedBox(
height: 7.h),

// ----------------------------------
// FEATURE 3
// ----------------------------------

_featureItem(
icon: Icons
    .favorite_rounded,
title:
'Find Real Connections',
subtitle:
'Meaningful relationships\n'
'start here',
),
],
),
),
),

// ==========================================
// RIGHT IMAGE
// ==========================================

Expanded(
flex: 50,

child: Padding(
padding:
EdgeInsets.only(
top:
screenHeight *
0.040,
),

child:
Image.asset(
'assets/images/loginback.png',

height:
isKeyboardOpen
? screenHeight *
0.30
    : screenHeight *
0.80,

width:
double.infinity,

fit: BoxFit.contain,

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

SizedBox(height: 10.h),

// ==================================================
// LOGIN CARD
// ==================================================

Padding(
padding:
EdgeInsets.symmetric(
horizontal: 14.w,
),

child: Container(
width: double.infinity,

padding:
EdgeInsets.fromLTRB(
20.w,
20.h,
20.w,
18.h,
),

decoration:
BoxDecoration(
color: Colors.white,

borderRadius:
BorderRadius
    .circular(20.r),

border: Border.all(
color: inputBorder,
width: 0.7,
),

boxShadow: [
BoxShadow(
color: primaryColor
    .withOpacity(
0.10),
blurRadius: 25,
spreadRadius: 2,
offset:
const Offset(
0,
7,
),
),
],
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
// ==========================================
// MOBILE NUMBER
// ==========================================

Text(
'Mobile Number',
style: poppins(
size: 12.5,
weight:
FontWeight.w700,
color:
mainTextColor,
),
),

SizedBox(height: 2.h),

Text(
'We will send you a 6 digit OTP',
style: poppins(
size: 9.5,
color:
lightGreyText,
),
),

SizedBox(
height: 12.h),

// ==========================================
// PHONE FIELD
// ==========================================

_phoneField(context),

SizedBox(
height: 14.h),

// ==========================================
// SEND OTP BUTTON
// ==========================================

SizedBox(
width:
double.infinity,
height: 43.h,

child: Container(
decoration:
BoxDecoration(
gradient:
const LinearGradient(
begin: Alignment
    .centerLeft,
end: Alignment
    .centerRight,

colors: [
primaryColor,
primaryColor,
Color(
0xFFFFA23A),
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
35.r,
),

boxShadow: [
BoxShadow(
color:
primaryColor
    .withOpacity(
0.22,
),
blurRadius: 12,
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
isLoading
? null
    : sendOTP,

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

elevation: 0,

padding:
EdgeInsets
    .zero,

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius
    .circular(
35.r,
),
),
),

child: isLoading
? SizedBox(
height: 20.h,
width: 20.w,
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
    .lock_rounded,
color: Colors
    .white,
size: 18.sp,
),

SizedBox(
width:
10.w),

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
11.w),

Text(
'Send OTP',
style:
poppins(
size: 12,
weight:
FontWeight
    .w700,
color: Colors
    .white,
),
),
],
),
),
),
),

SizedBox(
height: 13.h),

// ==========================================
// OR CONTINUE
// ==========================================

Row(
children: [
Expanded(
child: Divider(
color:
inputBorder,
thickness: 1,
),
),

Padding(
padding:
EdgeInsets
    .symmetric(
horizontal: 10.w,
),

child: Text(
'or continue with',
style:
poppins(
size: 9.5,
color:
lightGreyText,
),
),
),

Expanded(
child: Divider(
color:
inputBorder,
thickness: 1,
),
),
],
),

SizedBox(
height: 12.h),

// ==========================================
// GOOGLE
// ==========================================

Row(
mainAxisAlignment:
MainAxisAlignment
    .center,

children: [
_socialButton(
child:
Image.asset(
'assets/icons/google.png',
height: 18.h,
width: 18.w,
),

onTap: () {
// Google Login
},
),
],
),
],
),
),
),
// ==================================================
// PRIVACY / SAFE NUMBER
// ==================================================

  Center(
    child: Padding(
      padding: EdgeInsets.only(
        top: 12.h,
        left: 20.w,
        right: 20.w,
        bottom: 8.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 15.sp,
            color: const Color(0xFF9699A0),
          ),

          SizedBox(width: 7.w),

          Flexible(
            child: Text(
              "Your number is safe with us. We never share it with anyone.",
              textAlign: TextAlign.center,
              style: poppins(
                size: 8,
                color: Colors.black,
              ).copyWith(
                height: 1.35,
              ),
            ),
          ),
        ],
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
],
),
);
}


}

