import 'dart:async';
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
  static bool _isFullyReady = false;

  // ✅ CRITICAL FIX: Lock — ek waqt mein sirf ek hi init/uninit cycle chale
  static Completer<bool>? _initCompleter;

  static final Map<String, String> userAvatars = {};

  static Future<bool> ensureInit({
    required String userId,
    required String userName,
  }) async {
    if (userId.isEmpty) {
      print('❌ Zego init skipped — userId empty');
      return false;
    }

    // Already ready hai isi user ke liye — turant return karo
    if (_isInitialized && _initializedForUserId == userId && _isFullyReady) {
      return true;
    }

    // ✅ Agar ek init already chal raha hai, uska result wait karo —
    // dobara uninit/init cycle mat chalao, warna race condition hoga
    if (_initCompleter != null) {
      print('⏳ Zego init already in progress, waiting for it...');
      return _initCompleter!.future;
    }

    _initCompleter = Completer<bool>();

    try {
      // ✅ Sirf tab uninit karo jab pehle kisi doosre user ke liye init tha
      if (_isInitialized && _initializedForUserId != userId) {
        try {
          await ZegoUIKitPrebuiltCallInvitationService().uninit();
          print('🔄 Uninit for previous user: $_initializedForUserId');
        } catch (e) {
          print('⚠️ uninit failed (safe to ignore): $e');
        }
        _isInitialized = false;
        _initializedForUserId = null;
        _isFullyReady = false;
      }

      // ✅ Agar bilkul fresh state hai lekin pehle kabhi fail ho chuka tha,
      // ek safety uninit() karo (SDK ka internal _isInit flag reset karne ke liye)
      if (!_isInitialized) {
        try {
          await ZegoUIKitPrebuiltCallInvitationService().uninit();
        } catch (e) {
          print('⚠️ Safety uninit failed (safe to ignore): $e');
        }
      }

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

      await Future.delayed(const Duration(milliseconds: 2000));

      _isFullyReady = true;
      print('✅ ZEGO LOGIN CONFIRMED — user "$userId" (${DateTime.now()})');

      _initCompleter!.complete(true);
      return true;

    } catch (e, stack) {
      _isInitialized = false;
      _initializedForUserId = null;
      _isFullyReady = false;
      print('❌ ZEGO LOGIN FAILED for $userId: $e');
      print('❌ Stack trace: $stack');

      _initCompleter!.complete(false);
      return false;
    } finally {
      _initCompleter = null;
    }
  }

  static Future<void> uninit() async {
    if (!_isInitialized) return;
    try {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
    } catch (e) {
      print('⚠️ Error during uninit: $e');
    }
    _isInitialized = false;
    _initializedForUserId = null;
    _isFullyReady = false;
    print('🔄 Zego uninit — user ka data ab Zego signaling se hata diya gaya');
  }

  static bool isCurrentUserRegisteredWithZego(String userId) {
    return _isInitialized && _initializedForUserId == userId && _isFullyReady;
  }
}