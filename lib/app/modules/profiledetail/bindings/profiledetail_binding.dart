import 'package:get/get.dart';

import '../controllers/profiledetail_controller.dart';

class ProfiledetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfiledetailController>(
      () => ProfiledetailController(),
    );
  }
}
