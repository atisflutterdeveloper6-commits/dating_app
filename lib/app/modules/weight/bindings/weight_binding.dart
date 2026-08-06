import 'package:get/get.dart';

import '../controllers/weight_controller.dart';

class WeightBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeightController>(
      () => WeightController(),
    );
  }
}
