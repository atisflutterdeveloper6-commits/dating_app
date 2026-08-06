import 'package:get/get.dart';

import '../controllers/gender_controller.dart';

class GenderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GenderController>(
      () => GenderController(),
    );
  }
}
