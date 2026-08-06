import 'package:get/get.dart';

import '../controllers/tellmeaboutyou_controller.dart';

class TellmeaboutyouBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TellmeaboutyouController>(
      () => TellmeaboutyouController(),
    );
  }
}
