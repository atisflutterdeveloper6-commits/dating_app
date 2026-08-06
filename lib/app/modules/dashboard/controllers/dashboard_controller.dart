import 'package:dating_app/app/custom_widget/notification_services.dart';
import 'package:get/get.dart';
import 'package:dating_app/app/modules/chat/views/call_invitation_service.dart';
import 'package:dating_app/app/custom_widget/storage_services.dart';

class DashboardController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
NotificationService.instance.saveFCMToken();
    // ✅ Already-logged-in user ke liye Zego call service init karo
    final storage = StorageService();
    final profileId = storage.getProfileId();
    if (profileId != null && profileId.isNotEmpty && storage.isLoggedIn()) {
      CallInvitationService.ensureInit(
        userId: profileId,
        userName: storage.getPhoneNumber() ?? profileId,
    
      );
      
    }
    
    
  }
}