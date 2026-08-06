import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:get/get.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

class DashboardController extends GetxController {
  var currentIndex = 0.obs;

  // ✅ Call service ka init state track karne ke liye (UI mein use kar sakte ho
  // agar call button ko init hone tak disable karna ho)
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
  /// guarantee ho jaaye ki Zego service init hai. Agar already init hai to
  /// ye instantly return ho jaayega (ensureInit khud idempotent hai).
  Future<bool> ensureCallServiceReady() async {
    if (isCallServiceReady.value) return true;

    final profileId = _storage.getProfileId();
    if (profileId == null || profileId.isEmpty) {
      print('❌ ensureCallServiceReady: profileId missing');
      return false;
    }

    final success = await CallInvitationService.ensureInit(
      userId: profileId,
      userName: _storage.getPhoneNumber() ?? profileId,
    );
    isCallServiceReady.value = success;
    return success;
  }
}