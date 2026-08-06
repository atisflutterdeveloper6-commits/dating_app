import 'package:get/get.dart';

import '../controllers/profileintrests_controller.dart';

class ProfileintrestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileintrestsController>(
      () => ProfileintrestsController(),
    );
  }
}
