import 'package:get/get.dart';

import '../controllers/ping_controller.dart';

class PingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PingController>(
      () => PingController(host: ''),
    );
  }
}
