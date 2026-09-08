import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:get/get.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

class DashboardController extends GetxController {
  var currentIndex = 0.obs;

  // ✅ Call service ka init state track karne ke liye (UI mein use kar sakte ho
  // agar call button ko init hone tak disable karna ho).
  //
  // ⚠️ IMPORTANT: is flag ko "permanent truth" mat maano. Zego SDK ka koi
  // public API nahi hai jo live connection state batae, isliye ye flag sirf
  // "last known state" hai. Jab bhi ek actual call send() fail ho (khaas kar
  // `disconnected` error ke saath), turant is flag ko false mark karo aur
  // markCallServiceUnavailable() call karo — warna ye flag hamesha ke liye
  // stale `true` reh sakta hai jabki underlying signaling actually disconnected ho.
  var isCallServiceReady = false.obs;

  final StorageService _storage = StorageService();

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();

    NotificationService.instance.saveFCMToken();

    // ✅ Already-logged-in user ke liye Zego call service init karo
    _initCallService();
  }

  /// Zego call invitation service ko init karta hai.
  /// Agar pehli baar fail ho jaye, ek retry bhi karta hai (network/timing issues cover karne ke liye).
  Future<void> _initCallService() async {
    final profileId = _storage.getProfileId();
    final isLoggedIn = _storage.isLoggedIn();
    final userName = _storage.getPhoneNumber() ?? profileId;

    print('📞 Dashboard: Checking call service init — profileId=$profileId, isLoggedIn=$isLoggedIn');

    if (profileId == null || profileId.isEmpty || !isLoggedIn) {
      print('⚠️ Dashboard: Skipping call service init — missing profileId or not logged in');
      isCallServiceReady.value = false;
      return;
    }

    final success = await CallInvitationService.ensureInit(
      userId: profileId,
      userName: userName ?? profileId,
    );

    if (success) {
      isCallServiceReady.value = true;
      print('✅ Dashboard: Call service ready for $profileId');
      return;
    }

    // First attempt failed — retry once after a short delay
    print('⚠️ Dashboard: Call service init failed, retrying in 2s...');
    await Future.delayed(const Duration(seconds: 2));

    final retrySuccess = await CallInvitationService.ensureInit(
      userId: profileId,
      userName: userName ?? profileId,
    );

    isCallServiceReady.value = retrySuccess;

    if (retrySuccess) {
      print('✅ Dashboard: Call service ready after retry for $profileId');
    } else {
      print('❌ Dashboard: Call service init failed after retry for $profileId');
    }
  }

  /// Kisi bhi jagah se call bhejne/receive karne se PEHLE ye call karo taaki
  /// guarantee ho jaaye ki Zego service init hai.
  ///
  /// FIX: pehle ye sirf `if (isCallServiceReady.value) return true;` karta
  /// tha — jisse ek baar `true` hone ke baad ye kabhi actually verify nahi
  /// karta tha, chahe signaling baad mein disconnect ho jaye. Ab, agar flag
  /// `true` hai to bhi hum use trust karte hain (koi live-check API nahi hai),
  /// LEKIN jab bhi koi caller [markCallServiceUnavailable] call karta hai
  /// (matlab ek real send() fail ho chuka hai), ye flag `false` ho jaata hai
  /// aur agli baar ye method ek FORCED fresh reconnect karega — sirf normal
  /// ensureInit ka stale short-circuit nahi.
  Future<bool> ensureCallServiceReady() async {
    if (isCallServiceReady.value) return true;

    final profileId = _storage.getProfileId();
    if (profileId == null || profileId.isEmpty) {
      print('❌ ensureCallServiceReady: profileId missing');
      return false;
    }

    final userName = _storage.getPhoneNumber() ?? profileId;

    // Try a forced reconnect first — this correctly handles the "was
    // marked ready earlier, but signaling actually dropped" case, since it
    // does a full uninit + re-login instead of trusting cached state.
    bool success = await CallInvitationService.forceReconnect();

    // forceReconnect() returns false without attempting anything if there's
    // no previously-tracked user (e.g. very first call this app session) —
    // fall back to a normal ensureInit in that case.
    if (!success) {
      success = await CallInvitationService.ensureInit(
        userId: profileId,
        userName: userName,
        forceRefresh: true,
      );
    }

    isCallServiceReady.value = success;
    return success;
  }

  /// Call this the moment an actual call-send attempt fails with a
  /// signaling error (e.g. "disconnected", "not connected"). This clears
  /// the stale "ready" flag so the NEXT `ensureCallServiceReady()` call
  /// forces a real reconnect instead of short-circuiting on cached state.
  void markCallServiceUnavailable() {
    print('⚠️ Dashboard: marking call service as unavailable (was previously ready)');
    isCallServiceReady.value = false;
  }
}