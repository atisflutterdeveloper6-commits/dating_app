import 'package:get/get.dart';

import '../controllers/profilegender_controller.dart';

class ProfilegenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilegenderController>(
      () => ProfilegenderController(),
    );
  }
}
