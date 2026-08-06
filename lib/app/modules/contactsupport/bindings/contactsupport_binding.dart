import 'package:get/get.dart';

import '../controllers/contactsupport_controller.dart';

class ContactsupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactsupportController>(
      () => ContactsupportController(),
    );
  }
}
