import 'package:get/get.dart';

import '../controllers/snotifications_controller.dart';

class SnotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SnotificationsController>(
      () => SnotificationsController(),
    );
  }
}
