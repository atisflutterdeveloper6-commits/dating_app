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

  String verificationId;          // ← mutable (resend ke liye zaroori)
  final String phoneNumber;

  int secondsRemaining = 60;
  bool isVerifying = false;
  bool isResending = false;
  String otpError = '';
  Timer? _timer;

  final StorageService _storage = StorageService();

  OtpController({
    required this.verificationId,
    required this.phoneNumber,
  }) {
    print('📱 OTP Controller initialized for: $phoneNumber');
  }

  // ============ TIMER ============
  void startTimer() {
    secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!hasListeners) {
        timer.cancel();
        return;
      }
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  String get formattedTime {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ============ SAVE FIREBASE TOKEN ============
  Future<void> _saveFirebaseToken(User user) async {
    try {
      final idToken = await user.getIdToken(true);
      if (idToken == null || idToken.isEmpty) return;

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

      // Zego init (safe)
      try {
        final existingProfileId = _storage.getProfileId();
        if (existingProfileId != null && existingProfileId.isNotEmpty) {
          await CallInvitationService.ensureInit(
            userId: existingProfileId,
            userName: user.phoneNumber ?? existingProfileId,
          );
        }
      } catch (e) {
        print('⚠️ CallInvitationService init failed: $e');
      }

      await NotificationService.instance.saveFCMToken();
      print('✅ Firebase token & user data saved');
    } catch (e) {
      print('❌ Error saving Firebase token: $e');
    }
  }

  String _decodeBase64Url(String input) {
    try {
      String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      return utf8.decode(base64Decode(normalized));
    } catch (e) {
      return 'Failed to decode: $e';
    }
  }

  // ============ VERIFY OTP ============
  Future<void> verifyOTP(String otpCode) async {
    if (otpCode.length < 6) {
      otpError = 'Please enter complete 6-digit OTP';
      notifyListeners();
      CustomToast.error(otpError);
      return;
    }

    isVerifying = true;
    otpError = '';
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('✅ Firebase Auth Successful → UID: ${user.uid}');
        await _saveFirebaseToken(user);

        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        await _handleNavigation(isNewUser);
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
        case 'session-expired':
          errorMessage = 'Session expired. Please request a new OTP.';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed. Please try again.';
      }

      otpError = errorMessage;
      notifyListeners();
      CustomToast.error(errorMessage);
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
    } catch (e) {
      isVerifying = false;
      otpError = 'Something went wrong. Please try again.';
      notifyListeners();
      CustomToast.error(otpError);
      print('❌ Error: $e');
    }
  }

  // Navigation logic (safe)
 Future<void> _handleNavigation(bool isNewUser) async {
  isVerifying = false;
  notifyListeners();

  if (isNewUser) {
    Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
    return;
  }

  try {
    bool hasProfile = _storage.isProfileCreated();
    String? profileId = _storage.getProfileId();
    final isLoggedIn = _storage.isLoggedIn();

    if (!hasProfile || profileId == null || profileId.isEmpty) {
      print('⚠️ Local profile missing — trying recovery...');
      try {
        if (Get.isRegistered<ProfileServiceController>()) {
          final profileController = Get.find<ProfileServiceController>();
          final recovered = await profileController.recoverProfileByPhone(phoneNumber);
          if (recovered) {
            hasProfile = true;
            profileId = _storage.getProfileId();
            print('✅ Profile recovered');
          }
        }
      } catch (e) {
        print('❌ Recovery failed: $e');
      }
    }

    if (hasProfile && profileId != null && profileId.isNotEmpty && isLoggedIn) {
      try {
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().currentIndex.value = 0;
        }
      } catch (_) {}

      Get.offAllNamed('/dashboard');

      // ✅ CRITICAL FIX: profileId ab guaranteed available hai (recovery ke baad bhi),
      // isliye yahan reliably Zego init call karo — login/recovery ke turant baad
      try {
        if (Get.isRegistered<DashboardController>()) {
          final ready = await Get.find<DashboardController>().ensureCallServiceReady();
          print(ready
              ? '✅ Call service ready after login for $profileId'
              : '❌ Call service still not ready after login for $profileId');
        }
      } catch (e) {
        print('⚠️ Could not init call service after login: $e');
      }

      try {
        if (Get.isRegistered<ChatService>()) {
          await Get.find<ChatService>().saveUserProfileToFirestore();
        }
      } catch (e) {
        print('⚠️ Could not save to Firestore: $e');
      }
    } else {
      Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
    }
  } catch (e) {
    print('❌ Navigation error: $e');
    Get.offAllNamed('/loginconfirmation', arguments: phoneNumber);
  }
}
  // ============ RESEND OTP ============
  Future<void> resendCode() async {
    if (secondsRemaining != 0) {
      CustomToast.warning('Please wait $secondsRemaining seconds');
      return;
    }

    isResending = true;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          isResending = false;
          notifyListeners();
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              await _saveFirebaseToken(user);
              final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
              await _handleNavigation(isNewUser);
            }
          } catch (e) {
            print('❌ Auto-verification error: $e');
            CustomToast.error('Auto-verification failed');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isResending = false;
          notifyListeners();
          CustomToast.error(e.message ?? 'Failed to resend OTP');
        },
        codeSent: (String newVerificationId, int? resendToken) {
          verificationId = newVerificationId;   // ← IMPORTANT
          isResending = false;
          startTimer();
          notifyListeners();
          CustomToast.success('OTP resent successfully');
          print('✅ OTP resent. New Verification ID updated');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isResending = false;
          notifyListeners();
        },
      );
    } catch (e) {
      isResending = false;
      notifyListeners();
      CustomToast.error('Failed to resend OTP');
      print('❌ Resend error: $e');
    }
  }

  void clearError() {
    otpError = '';
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}