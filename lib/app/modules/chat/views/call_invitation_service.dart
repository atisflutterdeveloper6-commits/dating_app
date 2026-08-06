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
  static bool _isFullyReady = false;  // ✅ NAYA — signaling ready confirm karne ke liye

  static final Map<String, String> userAvatars = {};

  static Future<bool> ensureInit({
    required String userId,
    required String userName,
  }) async {
    if (userId.isEmpty) {
      print('❌ Zego init skipped — userId empty');
      return false;
    }

    // ✅ Agar already init + fully ready hai, turant true return karo
    if (_isInitialized && _initializedForUserId == userId && _isFullyReady) {
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
                          child: Icon(Icons.person, size: size.width * 0.6, color: Colors.white),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: Icon(Icons.person, size: size.width * 0.6, color: Colors.white),
                      ),
              ),
            );
          };
          return config;
        },
      );

      _isInitialized = true;
      _initializedForUserId = userId;

      // ✅ FIX: init() Future resolve hone ke baad bhi Zego ka internal
      // pageManager/signaling connection background me settle ho raha hota hai.
      // Isliye ek chhota settle-delay do taaki turant send() call fail na ho.
      await Future.delayed(const Duration(milliseconds: 2000));

      _isFullyReady = true;
      print('✅ ZEGO LOGIN CONFIRMED aur signaling settle ho gaya — user "$userId" (${DateTime.now()})');
      return true;

    } catch (e, stack) {
      _isInitialized = false;
      _initializedForUserId = null;
      _isFullyReady = false;
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
    _isFullyReady = false;  // ✅ reset karo
    print('🔄 Zego uninit — user ka data ab Zego signaling se hata diya gaya');
  }

  static bool isCurrentUserRegisteredWithZego(String userId) {
    return _isInitialized && _initializedForUserId == userId && _isFullyReady;  // ✅ _isFullyReady bhi check karo
  }
}