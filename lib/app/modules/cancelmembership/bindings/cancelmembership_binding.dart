import 'package:get/get.dart';

import '../controllers/cancelmembership_controller.dart';

class CancelmembershipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CancelmembershipController>(
      () => CancelmembershipController(),
    );
  }
}
