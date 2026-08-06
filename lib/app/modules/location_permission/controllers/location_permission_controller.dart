import 'package:get/get.dart';

class LocationPermissionController extends GetxController {
  /// false = Enable Location Screen
  /// true = Turn On Location Screen
  RxBool isGpsOff = false.obs;

  void showGpsOffScreen() {
    isGpsOff.value = true;
  }

  void showPermissionScreen() {
    isGpsOff.value = false;
  }
}