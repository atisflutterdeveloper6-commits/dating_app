import 'package:get/get.dart';

import '../controllers/profilesetup_controller.dart';

class ProfilesetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilesetupController>(
      () => ProfilesetupController(),
    );
  }
}
