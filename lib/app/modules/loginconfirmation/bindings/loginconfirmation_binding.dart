import 'package:get/get.dart';

import '../controllers/loginconfirmation_controller.dart';

class LoginconfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginconfirmationController>(
      () => LoginconfirmationController(),
    );
  }
}
