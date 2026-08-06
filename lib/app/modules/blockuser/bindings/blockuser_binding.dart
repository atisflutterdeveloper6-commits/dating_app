import 'package:get/get.dart';

import '../controllers/blockuser_controller.dart';

class BlockuserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockuserController>(
      () => BlockuserController(),
    );
  }
}
