import 'package:get/get.dart';

import '../controllers/like2_controller.dart';

class Like2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Like2Controller>(
      () => Like2Controller(),
    );
  }
}
