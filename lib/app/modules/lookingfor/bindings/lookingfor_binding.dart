import 'package:get/get.dart';

import '../controllers/lookingfor_controller.dart';

class LookingforBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LookingforController>(
      () => LookingforController(),
    );
  }
}
