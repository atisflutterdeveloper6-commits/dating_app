import 'package:get/get.dart';

import '../controllers/privacypolicy_controller.dart';

class PrivacypolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacypolicyController>(
      () => PrivacypolicyController(),
    );
  }
}
