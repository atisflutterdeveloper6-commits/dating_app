import 'package:get/get.dart';

import '../controllers/paymentoption_controller.dart';

class PaymentoptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentoptionController>(
      () => PaymentoptionController(),
    );
  }
}
