import 'package:get/get.dart';

import '../controllers/intrestedin_controller.dart';

class IntrestedinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntrestedinController>(
      () => IntrestedinController(),
    );
  }
}
