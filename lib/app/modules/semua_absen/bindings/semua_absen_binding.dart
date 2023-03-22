import 'package:get/get.dart';

import '../controllers/semua_absen_controller.dart';

class SemuaAbsenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SemuaAbsenController>(
      () => SemuaAbsenController(),
    );
  }
}
