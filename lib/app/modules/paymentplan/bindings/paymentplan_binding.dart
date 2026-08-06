import 'package:get/get.dart';

import '../controllers/paymentplan_controller.dart';

class PaymentplanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentplanController>(
      () => PaymentplanController(),
    );
  }
}
