import 'package:get/get.dart';

import '../controllers/editphoto_controller.dart';

class EditphotoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditphotoController>(
      () => EditphotoController(),
    );
  }
}
