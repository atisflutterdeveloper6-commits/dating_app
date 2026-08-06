import 'package:get/get.dart';

import '../controllers/termsandconditions_controller.dart';

class TermsandconditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsandconditionsController>(
      () => TermsandconditionsController(),
    );
  }
}
