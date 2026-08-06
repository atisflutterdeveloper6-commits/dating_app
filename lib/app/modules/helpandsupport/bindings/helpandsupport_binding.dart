import 'package:get/get.dart';

import '../controllers/helpandsupport_controller.dart';

class HelpandsupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpandsupportController>(
      () => HelpandsupportController(),
    );
  }
}
