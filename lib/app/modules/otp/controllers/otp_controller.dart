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

  // Storage service instance
  final StorageService _storage = StorageService();

  // Constructor with required parameters
  OtpController({
    required this.verificationId,
    required this.phoneNumber,
  }) {
    print('📱 OTP Controller initialized for: $phoneNumber');
    print('🔑 Verification ID: $verificationId');
  }

  // ============ TIMER METHODS ============
  
  void startTimer() {
    print('⏰ Starting timer...');
    secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        print('⏱️ Timer: $secondsRemaining seconds remaining');
        notifyListeners();
      } else {
        _timer?.cancel();
        print('⏰ Timer finished!');
        notifyListeners();
      }
    });
    notifyListeners();
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
      
      // Get Firebase ID Token - TRUE means force refresh
      String? idToken = await user.getIdToken(true);
      
      if (idToken != null && idToken.isNotEmpty) {
        // ============================================
        // 🔥 PRINT FULL TOKEN
        // ============================================
        print('✅ FIREBASE TOKEN OBTAINED');
        print('========================================');
        print('🔑 FULL TOKEN:');
        print(idToken);
        print('========================================');
        print('📝 Token Length: ${idToken.length} characters');
        print('📝 Token Prefix: ${idToken.substring(0, 50)}...');
        print('📝 Token Suffix: ...${idToken.substring(idToken.length - 50)}');
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
          // Header
          String header = _decodeBase64Url(parts[0]);
          print('📋 TOKEN HEADER:');
          print(header);
          
          // Payload
          String payload = _decodeBase64Url(parts[1]);
          print('📋 TOKEN PAYLOAD:');
          print(payload);
          
          // Parse payload to get user info
          try {
            Map<String, dynamic> payloadData = jsonDecode(payload);
            print('👤 USER INFO FROM TOKEN:');
            print('   User ID: ${payloadData['user_id']}');
            print('   Phone: ${payloadData['phone_number']}');
            print('   Email: ${payloadData['email']}');
            print('   Issuer: ${payloadData['iss']}');
            print('   Audience: ${payloadData['aud']}');
            print('   Expires: ${DateTime.fromMillisecondsSinceEpoch(payloadData['exp'] * 1000)}');
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
        
        // Save phone number
        if (user.phoneNumber != null) {
          await _storage.savePhoneNumber(user.phoneNumber!);
        }
        
        // Save user ID
        await _storage.saveUserId(user.uid);
        
        // Also save token in legacy location for compatibility
        await _storage.saveToken(idToken);
        
        
        // Set logged in status
        await _storage.setLoggedIn(true);
            // ✅ Init ZegoCloud call service so this user can send/receive calls
      final existingProfileId = _storage.getProfileId();
        if (existingProfileId != null && existingProfileId.isNotEmpty) {
          await CallInvitationService.ensureInit(
            userId: existingProfileId,
            userName: user.phoneNumber ?? existingProfileId,
          );
        }
        print('✅ Firebase token and user data saved successfully');
        print('✅ Token saved in storage: ${_storage.getToken() != null ? "Yes" : "No"}');
        print('✅ Login token saved: ${_storage.getLoginToken() != null ? "Yes" : "No"}');
        print('✅ Phone saved: ${_storage.getPhoneNumber()}');
        print('✅ User ID saved: ${_storage.getUserId()}');
        print('✅ Logged in status: ${_storage.isLoggedIn()}');
        print('========================================');
        await NotificationService.instance.saveFCMToken(); 
        // Debug: Print all stored dataR
        _storage.debugPrintAllData();
        
        // 🔥 Also print the stored token to verify
        print('📂 STORED TOKEN:');
        print(_storage.getToken());
        print('========================================');
        
      } else {
        print('⚠️ No Firebase ID token received');
      }
    } catch (e) {
      print('❌ Error saving Firebase token: $e');
    }
  }

  // Helper to decode Base64Url
  String _decodeBase64Url(String input) {
    try {
      // Add padding if needed
      String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      // Decode from base64
      List<int> bytes = base64Decode(normalized);
      return utf8.decode(bytes);
    } catch (e) {
      return 'Failed to decode: $e';
    }
  }

  // ============ OTP VERIFICATION ============
  
  Future<void> verifyOTP(String otpCode) async {
    // Validate OTP length
    if (otpCode.length < 6) {
      otpError = 'Please enter complete 6-digit OTP';
      notifyListeners();
      CustomToast.error('Please enter complete 6-digit OTP');
      return;
    }

    // Show loading state
    isVerifying = true;
    otpError = '';
    notifyListeners();

    try {
      // Create credential from OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Sign in with credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // ================= FIREBASE RESPONSE =================
      User? user = userCredential.user;

      if (user != null) {
        print("========================================");
        print("✅ FIREBASE AUTH SUCCESSFUL");
        print("========================================");
        print("🆔 Firebase UID: ${user.uid}");
        print("📱 Phone Number: ${user.phoneNumber}");
        print("📧 Email: ${user.email}");
        print("👤 Name: ${user.displayName}");
        print("🙋 Is Anonymous: ${user.isAnonymous}");
        print("✅ Email Verified: ${user.emailVerified}");
        print("📅 Account Created: ${user.metadata.creationTime}");
        print("🕒 Last Sign In: ${user.metadata.lastSignInTime}");
        print("========================================");

        // 🔥 SAVE FIREBASE TOKEN
        await _saveFirebaseToken(user);

        // Check if user is new
        bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        print('👤 Is New User: $isNewUser');
        print("========================================");
      }

      // Success - verification complete
      isVerifying = false;
      notifyListeners();

      // Check if user is new
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      // Navigate based on user status
      if (isNewUser) {
        print('✅ New user registered - navigating to profile creation');
        Get.offAllNamed(
          '/loginconfirmation',
          arguments: phoneNumber,
        );
} else {
        // Existing user - check if profile exists
        try {
          bool hasProfile = _storage.isProfileCreated();
          String? profileId = _storage.getProfileId();
          final bool isLoggedIn = _storage.isLoggedIn();
          
          print('📊 User Status Check:');
          print('   Has Profile: $hasProfile');
          print('   Profile ID: $profileId');
          print('   Is Logged In: $isLoggedIn');

          // ✅ Local storage me profile nahi mila (jaise logout ke baad clear ho gaya) —
          // backend se recover karne ki koshish karo pehle, seedha profile-creation pe mat bhejo
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
            // 🔥 DashboardController app-lifetime me persist karta hai — agar
            // user pehle kisi aur tab par tha, wo state yahan tak carry ho
            // sakti hai. Login hote hi hamesha index 0 (Home) pe le jao.
            try {
              Get.find<DashboardController>().currentIndex.value = 0;
            } catch (e) {
              print('⚠️ Could not reset dashboard index: $e');
            }
            Get.offAllNamed('/dashboard');
            try {
              await Get.find<ChatService>().saveUserProfileToFirestore();
            } catch (e) {
              print('⚠️ Could not save user profile to Firestore: $e');
            }
          } else {
            print('✅ Existing user without profile - navigating to profile creation');
            Get.offAllNamed(
              '/loginconfirmation',
              arguments: phoneNumber,
            );
          }
        } catch (e) {
          print('❌ Error checking profile: $e');
          Get.offAllNamed(
            '/loginconfirmation',
            arguments: phoneNumber,
          );
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
      notifyListeners();

      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      print('❌ Full error: $e');
      CustomToast.error(errorMessage);

    } catch (e) {
      isVerifying = false;
      otpError = 'Something went wrong. Please try again.';
      notifyListeners();

      print("❌ Error: $e");
      print("❌ Stack trace: ${StackTrace.current}");
      CustomToast.error('Something went wrong. Please try again.');
    }
  }

  // ============ RESEND OTP ============

  Future<void> resendCode() async {
    // Only allow resend if timer has finished
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
          // Auto-verification
          isResending = false;
          notifyListeners();
          
          try {
            UserCredential userCredential = await _auth.signInWithCredential(credential);
            User? user = userCredential.user;
            
            if (user != null) {
              print('✅ Auto-verification successful');
              // 🔥 SAVE TOKEN ON AUTO-VERIFICATION
              await _saveFirebaseToken(user);
            }
            
       // Navigate based on user status
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
          notifyListeners();
          String errorMessage = e.message ?? 'Failed to resend OTP';
          print('❌ Resend failed: ${e.code} - ${e.message}');
          print('❌ Full error: $e');
          CustomToast.error(errorMessage);
        },
        codeSent: (String newVerificationId, int? resendToken) {
          isResending = false;
          // 🔥 Restart timer when OTP is resent
          startTimer();
          print('✅ OTP resent successfully to: $phoneNumber');
          print('📱 New Verification ID: $newVerificationId');
          CustomToast.success('OTP resent successfully 📨');
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isResending = false;
          notifyListeners();
          print('⏰ Auto-retrieval timeout for: $verificationId');
        },
      );
    } catch (e) {
      isResending = false;
      notifyListeners();
      print('❌ Error resending code: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      CustomToast.error('Failed to resend OTP. Please try again.');
    }
  }

  // ============ HELPER METHODS ============
  
  // Clear OTP error
  void clearError() {
    otpError = '';
    notifyListeners();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get Firebase token (for debugging)
  Future<String?> getFirebaseToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await user.getIdToken(true);
        print('🔑 Token: $token');
        return token;
      }
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
    }
    return null;
  }

  // Debug method to print token
  Future<void> debugPrintToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String? token = await user.getIdToken(true);
        print('========================================');
        print('🔑 FIREBASE TOKEN DEBUG');
        print('========================================');
        print('firebasetoken');
        print(token);
        print('========================================');
        print('Token Length: ${token?.length ?? 0}');
        print('User UID: ${user.uid}');
        print('Phone: ${user.phoneNumber}');
        print('========================================');
        
        // Decode token parts
        if (token != null) {
          final parts = token.split('.');
          if (parts.length == 3) {
            print('HEADER:');
            print(_decodeBase64Url(parts[0]));
            print('========================================');
            print('PAYLOAD:');
            print(_decodeBase64Url(parts[1]));
            print('========================================');
          }
        }
      } else {
        print('⚠️ No user logged in');
      }
    } catch (e) {
      print('❌ Error getting token: $e');
    }
  }

  // Get stored token from storage
  String? getStoredToken() {
    return _storage.getToken();
  }

  // Get stored login token
  String? getStoredLoginToken() {
    return _storage.getLoginToken();
  }

  // Print all stored tokens
  void printStoredTokens() {
    print('========================================');
    print('📂 STORED TOKENS');
    print('========================================');
    print('Legacy Token: ${_storage.getToken() ?? 'Not found'}');
    print('Login Token: ${_storage.getLoginToken() ?? 'Not found'}');
    print('========================================');
  }

  // Sign out (optional)
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
    _timer?.cancel();
    super.dispose();
  }
}