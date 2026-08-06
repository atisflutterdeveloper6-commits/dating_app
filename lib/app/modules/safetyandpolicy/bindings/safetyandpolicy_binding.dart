import 'package:get/get.dart';

import '../controllers/safetyandpolicy_controller.dart';

class SafetyandpolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafetyandpolicyController>(
      () => SafetyandpolicyController(),
    );
  }
}
