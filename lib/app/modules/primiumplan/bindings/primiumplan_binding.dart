import 'package:get/get.dart';

import '../controllers/primiumplan_controller.dart';

class PrimiumplanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrimiumplanController>(
      () => PrimiumplanController(),
    );
  }
}
