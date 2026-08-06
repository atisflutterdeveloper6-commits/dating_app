import 'package:get/get.dart';
import '../controllers/otp_controller.dart';

class OtpBinding extends Bindings {
  final String verificationId;
  final String phoneNumber;

  OtpBinding({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController(
      verificationId: verificationId,
      phoneNumber: phoneNumber,
    ));
  }
}