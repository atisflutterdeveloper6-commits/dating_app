import 'package:get/get.dart';

import '../controllers/birthday_controller.dart';

class BirthdayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BirthdayController>(
      () => BirthdayController(),
    );
  }
}
