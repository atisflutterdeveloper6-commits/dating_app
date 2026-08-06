import 'package:get/get.dart';

import '../controllers/dateofbirth_controller.dart';

class DateofbirthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DateofbirthController>(
      () => DateofbirthController(),
    );
  }
}
