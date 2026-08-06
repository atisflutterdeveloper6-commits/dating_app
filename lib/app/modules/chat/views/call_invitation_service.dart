import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class CallInvitationService {
  static const int appID = 2066486365;
  static const String appSign =
      "fb45aa80806682acc67d38fc2eefc23a9d9144b6a82cc51f4b1f0c2dea901a4d";

  static bool _isInitialized = false;
  static String? _initializedForUserId;

  static final Map<String, String> userAvatars = {};

  static Future<bool> ensureInit({
    required String userId,
    required String userName,
  }) async {
    if (userId.isEmpty) {
      print('❌ Zego init skipped — userId empty');
      return false;
    }

    if (_isInitialized && _initializedForUserId == userId) {
      print('ℹ️ CallInvitationService already initialized for $userId');
      return true;
    }

    if (_isInitialized && _initializedForUserId != userId) {
      await uninit();
    }

    try {
      print('📤 Attempting Zego login for userId: $userId, userName: $userName');
      
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appID,
        appSign: appSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
        requireConfig: (ZegoCallInvitationData data) {
          final config = data.type == ZegoCallInvitationType.videoCall
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

          config.avatarBuilder = (context, size, user, extraInfo) {
            final imageUrl = userAvatars[user?.id ?? ''] ?? '';
            return SizedBox(
              width: size.width,
              height: size.height,
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            size: size.width * 0.6,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          size: size.width * 0.6,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          };
          return config;
        },
      );

      // ✅ init() call successfully complete hui — matlab Zego ne user register kar liya
      _isInitialized = true;
      _initializedForUserId = userId;
      print('✅ ZEGO LOGIN CONFIRMED — user "$userId" ka data ab Zego ke paas hai (${DateTime.now()})');
      return true;
      
    } catch (e, stack) {
      // ❌ Yahan pata chalega agar Zego ne register nahi kiya
      _isInitialized = false;
      _initializedForUserId = null;
      print('❌ ZEGO LOGIN FAILED for $userId: $e');
      print('❌ Stack trace: $stack');
      return false;
    }
  }

  static Future<void> uninit() async {
    if (!_isInitialized) return;
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _isInitialized = false;
    _initializedForUserId = null;
    print('🔄 Zego uninit — user ka data ab Zego signaling se hata diya gaya');
  }

  // ✅ NAYA — current state check karne ke liye, kisi bhi jagah se puch sakte ho
  static bool isCurrentUserRegisteredWithZego(String userId) {
    return _isInitialized && _initializedForUserId == userId;
  }
}