import 'dart:async';
import 'dart:convert';
import 'package:dating_app/app/custom_widget/custom_toast.dart';
import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:dating_app/app/custom_widget/profile_service_controller.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/modules/chat/views/chat_service.dart';
import 'package:dating_app/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String verificationId;
  final String phoneNumber;

  int secondsRemaining = 60;
  bool isVerifying = false;
  bool isResending = false;
  String otpError = '';
  Timer? _timer;

  // 🔥 FIX: guard flag so we never call notifyListeners() after dispose().
  // Calling notifyListeners() on a disposed ChangeNotifier throws in debug
  // mode and can crash release builds too if it happens after the widget
  // that owns this controller (OtpView) has already navigated away.
  bool _disposed = false;

  // 🔥 AUTOFILL HOOK — set by OtpView.initState(), cleared in dispose().
  // Firebase Auth's OWN SMS auto-retrieval (started by verifyPhoneNumber()
  // in LoginView) is the only SMS listener in the app; when it fires, its
  // `credential.smsCode` is forwarded here so whichever OtpView is
  // currently on screen can fill its pin field and verify — without ever
  // registering a second/competing SMS listener (that's what crashed
  // before, see otp_view.dart for details).
  static void Function(String smsCode)? onAutoRetrievedCode;

  // Storage service instance
  final StorageService _storage = StorageService();

  OtpController({
    required this.verificationId,
    required this.phoneNumber,
  }) {
    print('📱 OTP Controller initialized for: $phoneNumber');
    print('🔑 Verification ID: $verificationId');
  }

  // 🔥 FIX: safe wrapper — every notifyListeners() call in this file now
  // goes through here.
  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ============ TIMER METHODS ============

  void startTimer() {
    print('⏰ Starting timer...');
    secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      if (secondsRemaining > 0) {
        secondsRemaining--;
        print('⏱️ Timer: $secondsRemaining seconds remaining');
        _safeNotify();
      } else {
        _timer?.cancel();
        print('⏰ Timer finished!');
        _safeNotify();
      }
    });
    _safeNotify();
  }

  String get formattedTime {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ============ SAVE FIREBASE TOKEN ============

  Future<void> _saveFirebaseToken(User user) async {
    try {
      print('========================================');
      print('🔑 SAVING FIREBASE TOKEN');
      print('========================================');

      String? idToken = await user.getIdToken(true);

      if (idToken != null && idToken.isNotEmpty) {
        print('✅ FIREBASE TOKEN OBTAINED');
        print('========================================');
        print('📝 Token Length: ${idToken.length} characters');

        // 🔥 FIX: guard substring() so a short/unexpected token can't
        // throw a RangeError here.
        if (idToken.length > 50) {
          print('📝 Token Prefix: ${idToken.substring(0, 50)}...');
          print('📝 Token Suffix: ...${idToken.substring(idToken.length - 50)}');
        } else {
          print('📝 Token (short, printing full): $idToken');
        }
        print('========================================');

        // Get token details
        IdTokenResult tokenResult = await user.getIdTokenResult();
        print('📄 TOKEN DETAILS:');
        print('   Expiration Time: ${tokenResult.expirationTime}');
        print('   Issued At: ${tokenResult.issuedAtTime}');
        print('   Auth Time: ${tokenResult.authTime}');
        print('   Sign-in Provider: ${tokenResult.signInProvider}');
        print('   Claims: ${tokenResult.claims}');
        print('========================================');

        // Parse token to get payload (JWT parts)
        final parts = idToken.split('.');
        if (parts.length == 3) {
          String header = _decodeBase64Url(parts[0]);
          print('📋 TOKEN HEADER:');
          print(header);

          String payload = _decodeBase64Url(parts[1]);
          print('📋 TOKEN PAYLOAD:');
          print(payload);

          try {
            Map<String, dynamic> payloadData = jsonDecode(payload);
            print('👤 USER INFO FROM TOKEN:');
            print('   User ID: ${payloadData['user_id']}');
            print('   Phone: ${payloadData['phone_number']}');
            print('   Email: ${payloadData['email']}');
            print('   Issuer: ${payloadData['iss']}');
            print('   Audience: ${payloadData['aud']}');
            // 🔥 FIX: guard against missing/null 'exp' claim before using it
            final exp = payloadData['exp'];
            if (exp != null) {
              print('   Expires: ${DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000)}');
            }
          } catch (e) {
            print('⚠️ Could not parse payload: $e');
          }
        }
        print('========================================');

        // Save login session
        await _storage.saveLoginSession(
          token: idToken,
          userData: {
            'uid': user.uid,
            'phoneNumber': user.phoneNumber,
            'email': user.email,
            'displayName': user.displayName,
            'isNewUser': false,
            'creationTime': user.metadata.creationTime?.toIso8601String(),
            'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
          },
        );

        if (user.phoneNumber != null) {
          await _storage.savePhoneNumber(user.phoneNumber!);
        }

        await _storage.saveUserId(user.uid);
        await _storage.saveToken(idToken);
        await _storage.setLoggedIn(true);

        // 🔥 FIX: this native SDK (ZegoCloud) init is the most likely real
        // crash source — a native-layer crash here bypasses Dart's
        // try/catch entirely. Isolating it in its own try/catch at least
        // stops any *Dart-side* exception from aborting token save/login.
        // If crashes persist after this fix, check adb logcat for a
        // FATAL EXCEPTION / SIGSEGV coming from Zego — that means the
        // native SDK itself is crashing (e.g. bad appID/appSign, or
        // double-init) and must be fixed in CallInvitationService.
        try {
          final existingProfileId = _storage.getProfileId();
          if (existingProfileId != null && existingProfileId.isNotEmpty) {
            await CallInvitationService.ensureInit(
              userId: existingProfileId,
              userName: user.phoneNumber ?? existingProfileId,
            );
          }
        } catch (e, st) {
          print('⚠️ CallInvitationService.ensureInit failed (non-fatal): $e');
          print(st);
        }

        print('✅ Firebase token and user data saved successfully');
        print('========================================');

        // 🔥 FIX: FCM save also isolated so a failure here can't take
        // down the whole login flow.
        try {
          await NotificationService.instance.saveFCMToken();
        } catch (e, st) {
          print('⚠️ saveFCMToken failed (non-fatal): $e');
          print(st);
        }

        _storage.debugPrintAllData();
      } else {
        print('⚠️ No Firebase ID token received');
      }
    } catch (e, st) {
      print('❌ Error saving Firebase token: $e');
      print(st);
    }
  }

  String _decodeBase64Url(String input) {
    try {
      String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      List<int> bytes = base64Decode(normalized);
      return utf8.decode(bytes);
    } catch (e) {
      return 'Failed to decode: $e';
    }
  }

  // ============ OTP VERIFICATION ============

  Future<void> verifyOTP(String otpCode) async {
    if (otpCode.length < 6) {
      otpError = 'Please enter complete 6-digit OTP';
      _safeNotify();
      CustomToast.error('Please enter complete 6-digit OTP');
      return;
    }

    isVerifying = true;
    otpError = '';
    _safeNotify();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        print('✅ FIREBASE AUTH SUCCESSFUL — UID: ${user.uid}');
        await _saveFirebaseToken(user);
      }

      isVerifying = false;
      _safeNotify();

      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      print('👤 Is New User: $isNewUser');

      if (isNewUser) {
        print('✅ New user registered - navigating to profile creation');
        Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
      } else {
        try {
          bool hasProfile = _storage.isProfileCreated();
          String? profileId = _storage.getProfileId();
          final bool isLoggedIn = _storage.isLoggedIn();

          print('📊 User Status Check: hasProfile=$hasProfile, profileId=$profileId, isLoggedIn=$isLoggedIn');

          if (!hasProfile || profileId == null || profileId.isEmpty) {
            print('⚠️ Local profile data missing — attempting backend recovery...');
            try {
              final profileController = Get.find<ProfileServiceController>();
              final recovered = await profileController.recoverProfileByPhone(phoneNumber);
              if (recovered) {
                hasProfile = true;
                profileId = _storage.getProfileId();
                print('✅ Profile recovered from backend');
              }
            } catch (e) {
              print('❌ Recovery attempt failed: $e');
            }
          }

          if (hasProfile && profileId != null && profileId.isNotEmpty && isLoggedIn) {
            print('✅ Existing user with profile - navigating to dashboard');
            try {
              Get.find<DashboardController>().currentIndex.value = 0;
            } catch (e) {
              print('⚠️ Could not reset dashboard index: $e');
            }

            // 🔥 FIX: do the Firestore save *before* navigating away, not
            // after. Firing an await after Get.offAllNamed() means this
            // code keeps running against a route/controller tree that may
            // already be torn down — safer to finish all work first, then
            // navigate last.
            try {
              await Get.find<ChatService>().saveUserProfileToFirestore();
            } catch (e) {
              print('⚠️ Could not save user profile to Firestore: $e');
            }

            Get.offAllNamed('/dashboard');
          } else {
            print('✅ Existing user without profile - navigating to profile creation');
            Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
          }
        } catch (e) {
          print('❌ Error checking profile: $e');
          Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
        }
      }
    } on FirebaseAuthException catch (e) {
      isVerifying = false;

      String errorMessage = 'Invalid OTP. Please try again.';

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP code. Please check and try again.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'credential-already-in-use':
          errorMessage = 'This phone number is already registered.';
          break;
        case 'session-expired':
          errorMessage = 'Session expired. Please request a new OTP.';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed. Please try again.';
      }

      otpError = errorMessage;
      _safeNotify();

      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      CustomToast.error(errorMessage);
    } catch (e, st) {
      isVerifying = false;
      otpError = 'Something went wrong. Please try again.';
      _safeNotify();

      print('❌ Error: $e');
      print('❌ Stack trace: $st');
      CustomToast.error('Something went wrong. Please try again.');
    }
  }

  // ============ RESEND OTP ============

  Future<void> resendCode() async {
    if (secondsRemaining != 0) {
      CustomToast.warning('Please wait $secondsRemaining seconds');
      return;
    }

    isResending = true;
    _safeNotify();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          isResending = false;
          _safeNotify();

          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            User? user = userCredential.user;

            if (user != null) {
              print('✅ Auto-verification successful');
              await _saveFirebaseToken(user);
            }

            bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
            if (isNewUser) {
              Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
            } else {
              bool hasProfile = _storage.isProfileCreated() && _storage.getProfileId() != null;

              if (!hasProfile) {
                try {
                  final profileController = Get.find<ProfileServiceController>();
                  hasProfile = await profileController.recoverProfileByPhone(phoneNumber);
                } catch (e) {
                  print('❌ Recovery attempt failed: $e');
                }
              }

              if (hasProfile) {
                try {
                  await Get.find<ChatService>().saveUserProfileToFirestore();
                } catch (e) {
                  print('⚠️ Could not save user profile to Firestore: $e');
                }
                Get.offAllNamed('/dashboard');
              } else {
                Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
              }
            }
          } catch (e) {
            print('❌ Auto-verification error: $e');
            CustomToast.error('Auto-verification failed. Please try again.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isResending = false;
          _safeNotify();
          String errorMessage = e.message ?? 'Failed to resend OTP';
          print('❌ Resend failed: ${e.code} - ${e.message}');
          CustomToast.error(errorMessage);
        },
        codeSent: (String newVerificationId, int? resendToken) {
          isResending = false;
          startTimer();
          print('✅ OTP resent successfully to: $phoneNumber');
          CustomToast.success('OTP resent successfully 📨');
          _safeNotify();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isResending = false;
          _safeNotify();
          print('⏰ Auto-retrieval timeout for: $verificationId');
        },
      );
    } catch (e, st) {
      isResending = false;
      _safeNotify();
      print('❌ Error resending code: $e');
      print('❌ Stack trace: $st');
      CustomToast.error('Failed to resend OTP. Please try again.');
    }
  }

  // ============ HELPER METHODS ============

  void clearError() {
    otpError = '';
    _safeNotify();
  }

  User? get currentUser => _auth.currentUser;

  Future<String?> getFirebaseToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await user.getIdToken(true);
        return token;
      }
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
    }
    return null;
  }

  String? getStoredToken() => _storage.getToken();

  String? getStoredLoginToken() => _storage.getLoginToken();

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _storage.clearAll();
      print('✅ User signed out and storage cleared');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true; // 🔥 FIX: set before cancelling timer / super.dispose()
    _timer?.cancel();
    super.dispose();
  }
}