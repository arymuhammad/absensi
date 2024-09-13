import 'package:get/get.dart';

import '../controllers/adjust_presence_controller.dart';

class AdjustPresenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdjustPresenceController>(
      () => AdjustPresenceController(),
    );
  }
}
