import 'package:get/get.dart';

import '../controllers/height_controller.dart';

class HeightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HeightController>(
      () => HeightController(),
    );
  }
}
