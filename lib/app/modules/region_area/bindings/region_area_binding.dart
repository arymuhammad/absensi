import 'package:get/get.dart';

import '../controllers/region_area_controller.dart';

class RegionAreaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegionAreaController>(
      () => RegionAreaController(),
    );
  }
}
