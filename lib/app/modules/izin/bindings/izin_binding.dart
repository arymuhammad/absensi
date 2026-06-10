import 'package:get/get.dart';

import '../controllers/izin_controller.dart';

class IzinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IzinController>(
      () => IzinController(),
    );
  }
}
