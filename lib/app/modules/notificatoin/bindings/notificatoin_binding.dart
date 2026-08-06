import 'package:get/get.dart';

import '../controllers/notificatoin_controller.dart';

class NotificatoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificatoinController>(
      () => NotificatoinController(),
    );
  }
}
