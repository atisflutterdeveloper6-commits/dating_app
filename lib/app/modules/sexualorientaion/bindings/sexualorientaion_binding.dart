import 'package:get/get.dart';

import '../controllers/sexualorientaion_controller.dart';

class SexualorientaionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SexualorientaionController>(
      () => SexualorientaionController(),
    );
  }
}
