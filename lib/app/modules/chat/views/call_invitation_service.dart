import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class CallInvitationService {
  static const int appID = 1942834838;
  static const String appSign =
      "830600e1aec734077af9ee7710252b772f9333f69eb77e2f31bd9c76ecf2cdac";

  static bool _isInitialized = false;
  static String? _initializedForUserId;
  static String? _initializedForUserName;
  static bool _isFullyReady = false;

  // Lock — only one init/uninit cycle runs at a time
  static Completer<bool>? _initCompleter;

  static final Map<String, String> userAvatars = {};

  static Future<bool> ensureInit({
    required String userId,
    required String userName,
    bool forceRefresh = false,
  }) async {
    // 🔍 DEBUG: log every call so you can see, per-user, whether ensureInit
    // is even being invoked for the failing account.
    print('🔍 ensureInit called — userId: "$userId", userName: "$userName", forceRefresh: $forceRefresh');

    if (userId.isEmpty) {
      print('❌ Zego init skipped — userId empty');
      return false;
    }

    // ⚠️ Sanity check: Zego userIDs may ONLY contain numbers, letters, and
    // underscores. If the failing user's Firebase UID (or whatever ID
    // you're passing) contains anything else — dashes, dots, spaces,
    // non-ASCII characters — Zego's login will silently misbehave and the
    // signaling connection will never stabilize, which looks exactly like
    // your `disconnected` errors.
    final validIdPattern = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validIdPattern.hasMatch(userId)) {
      print(
        '❌ Zego userId "$userId" contains invalid characters! '
        'Only letters, numbers, and underscores are allowed by Zego. '
        'This WILL cause login/signaling failures for this specific user.',
      );
      // Not returning false here on purpose — still attempt it, but this
      // print is your primary suspect if only one user fails.
    }

    // Already ready for this user — return immediately UNLESS the caller
    // explicitly wants a forced fresh login (e.g. because a real send()
    // attempt just failed with `disconnected`, proving the cached "ready"
    // state is stale).
    if (!forceRefresh &&
        _isInitialized &&
        _initializedForUserId == userId &&
        _isFullyReady) {
      print('✅ ensureInit: already ready for "$userId", skipping');
      return true;
    }

    // If an init is already in progress, wait for its result instead of
    // starting a second uninit/init cycle (avoids race conditions)
    if (_initCompleter != null) {
      print('⏳ Zego init already in progress, waiting for it...');
      return _initCompleter!.future;
    }

    _initCompleter = Completer<bool>();

    try {
      // Uninit if previously initialized for a DIFFERENT user, OR if the
      // caller forced a fresh login for the SAME user (stale-ready case)
      if (_isInitialized && (_initializedForUserId != userId || forceRefresh)) {
        try {
          await ZegoUIKitPrebuiltCallInvitationService().uninit();
          print('🔄 Uninit before fresh login (forceRefresh=$forceRefresh, previous user: $_initializedForUserId)');
        } catch (e) {
          print('⚠️ uninit failed (safe to ignore): $e');
        }
        _isInitialized = false;
        _initializedForUserId = null;
        _initializedForUserName = null;
        _isFullyReady = false;
      }

      // Safety uninit to reset the SDK's internal _isInit flag if a
      // previous attempt failed
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
      _initializedForUserName = userName;

      // NOTE: there is no public API to synchronously "wait until signaling
      // is connected" — ZegoUIKitSignalingPluginImpl does not expose a
      // connection-state stream in this package version. init() completing
      // only means the SDK *started* logging in; the actual signaling
      // login still finishes asynchronously in the background.
      //
      // So instead of guessing at internal state, we give it a reasonable
      // grace period here, and — more importantly — wrap every actual
      // sendInvitation call in a retry (see `sendInvitationWithRetry`
      // below), since that's the only place the SDK tells us, via a real
      // return value, whether signaling was ready.
      await Future.delayed(const Duration(milliseconds: 2500));

      _isFullyReady = true;
      print('✅ ZEGO LOGIN CONFIRMED — user "$userId" (${DateTime.now()})');

      _initCompleter!.complete(true);
      return true;
    } catch (e, stack) {
      _isInitialized = false;
      _initializedForUserId = null;
      _initializedForUserName = null;
      _isFullyReady = false;
      print('❌ ZEGO LOGIN FAILED for $userId: $e');
      print('❌ Stack trace: $stack');

      _initCompleter!.complete(false);
      return false;
    } finally {
      _initCompleter = null;
    }
  }

  /// Forces a fresh signaling login for the currently-tracked user, by
  /// fully uninit-ing and re-running init(). Use this when send() keeps
  /// failing with `disconnected` — a state a simple retry loop can't fix
  /// on its own, since the SDK may not be actively reconnecting.
  ///
  /// Returns false immediately (without side effects) if we don't have a
  /// remembered user to reconnect as — this happens if ensureInit() was
  /// never called successfully in this app session.
  static Future<bool> forceReconnect() async {
    final userId = _initializedForUserId;
    final userName = _initializedForUserName;

    if (userId == null || userName == null) {
      print(
        '❌ forceReconnect skipped — no previously initialized user to '
        'restore. This means ensureInit() was never successfully called '
        'in this app session. Check your login flow for this user.',
      );
      return false;
    }

    print('🔄 Forcing Zego reconnect for user "$userId"...');
    return ensureInit(userId: userId, userName: userName, forceRefresh: true);
  }

  /// Sends a call invitation, retrying with backoff if the SDK reports
  /// failure. Covers two distinct failure modes:
  ///
  /// 1. Signaling is still `connecting` right after init() — a plain
  ///    retry after a short delay is usually enough.
  /// 2. Signaling is `disconnected` — a plain retry won't help here, so
  ///    after [attemptsBeforeReconnect] failed tries this calls
  ///    [forceReconnect] once and then keeps retrying.
  ///
  /// Built entirely on the documented, real `send()` API (returns
  /// Future<bool>) — no internal connection-state introspection.
  ///
  /// Returns true once send() succeeds, or false if it still fails after
  /// [maxAttempts] tries.
  static Future<bool> sendInvitationWithRetry({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
    int maxAttempts = 6,
    int attemptsBeforeReconnect = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    var delay = initialDelay;
    var hasTriedReconnect = false;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final success = await ZegoUIKitPrebuiltCallInvitationService().send(
          invitees: invitees,
          isVideoCall: isVideoCall,
          customData: customData,
          callID: callID,
          resourceID: resourceID,
          notificationTitle: notificationTitle,
          notificationMessage: notificationMessage,
          timeoutSeconds: timeoutSeconds,
        );

        if (success) {
          if (attempt > 1) {
            print('✅ sendInvitation succeeded on attempt $attempt');
          }
          return true;
        }

        print('⚠️ sendInvitation returned false (attempt $attempt/$maxAttempts)');
      } catch (e) {
        print('⚠️ sendInvitation threw on attempt $attempt/$maxAttempts: $e');
      }

      if (attempt >= attemptsBeforeReconnect && !hasTriedReconnect) {
        // Repeated failures this early usually mean signaling is
        // `disconnected`, not just `connecting` — a plain retry won't
        // fix that, so force a fresh login once.
        hasTriedReconnect = true;
        final reconnected = await forceReconnect();
        print(reconnected
            ? '✅ forceReconnect succeeded, resuming retries'
            : '⚠️ forceReconnect failed, will keep retrying anyway');
      }

      if (attempt < maxAttempts) {
        await Future.delayed(delay);
        // simple backoff, capped at 3s
        delay = Duration(
          milliseconds: (delay.inMilliseconds * 1.5).clamp(500, 3000).toInt(),
        );
      }
    }

    print('❌ sendInvitation failed after $maxAttempts attempts');
    return false;
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
    _initializedForUserName = null;
    _isFullyReady = false;
    print('🔄 Zego uninit — user data removed from Zego signaling');
  }

  static bool isCurrentUserRegisteredWithZego(String userId) {
    return _isInitialized && _initializedForUserId == userId && _isFullyReady;
  }

  // ---------------------------------------------------------------------
  // If you're using ZegoSendCallInvitationButton instead of calling
  // send() yourself, that widget doesn't return a bool — it reports
  // success/failure via its `onPressed(code, message, errorInvitees)`
  // callback. Use this helper INSIDE that callback to retry on the
  // specific "not connected yet" / "disconnected" failures.
  //
  // Example:
  //
  // ZegoSendCallInvitationButton(
  //   isVideoCall: true,
  //   invitees: [ZegoUIKitUser(id: targetId, name: targetName)],
  //   onPressed: (code, message, errorInvitees) {
  //     CallInvitationService.handleInvitationButtonResult(
  //       code: code,
  //       message: message,
  //       errorInvitees: errorInvitees,
  //       retry: () {
  //         // Re-trigger the same button press logic, e.g. by calling
  //         // send() directly here, or by programmatically tapping
  //         // the button again via a GlobalKey if you've wrapped it.
  //       },
  //     );
  //   },
  // )
  static void handleInvitationButtonResult({
    required String code,
    required String message,
    required List<String> errorInvitees,
    required VoidCallback retry,
    int attempt = 1,
    int maxAttempts = 5,
  }) {
    if (code.isEmpty && errorInvitees.isEmpty) {
      // success
      return;
    }

    final lowerMessage = message.toLowerCase();
    final looksLikeSignalingIssue = lowerMessage.contains('not connected') ||
        lowerMessage.contains('connecting') ||
        lowerMessage.contains('disconnected');

    if (looksLikeSignalingIssue && attempt < maxAttempts) {
      final delayMs = (500 * attempt).clamp(500, 3000);
      print(
        '⚠️ Invitation failed (attempt $attempt/$maxAttempts): '
        'code=$code message=$message — retrying in ${delayMs}ms',
      );

      // If it looks like `disconnected` specifically, force a reconnect
      // before retrying — a plain retry won't fix a dead connection.
      if (lowerMessage.contains('disconnected')) {
        Future.delayed(Duration(milliseconds: delayMs), () async {
          await forceReconnect();
          retry();
        });
      } else {
        Future.delayed(Duration(milliseconds: delayMs), retry);
      }
    } else {
      print(
        '❌ Invitation failed permanently: code=$code message=$message '
        'errorInvitees=$errorInvitees',
      );
    }
  }
}