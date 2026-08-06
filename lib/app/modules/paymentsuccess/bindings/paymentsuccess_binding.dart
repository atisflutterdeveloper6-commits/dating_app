import 'package:get/get.dart';

import '../controllers/paymentsuccess_controller.dart';

class PaymentsuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentsuccessController>(
      () => PaymentsuccessController(),
    );
  }
}
