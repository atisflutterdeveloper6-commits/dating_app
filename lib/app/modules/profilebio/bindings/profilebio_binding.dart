import 'package:get/get.dart';

import '../controllers/profilebio_controller.dart';

class ProfilebioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilebioController>(
      () => ProfilebioController(),
    );
  }
}
