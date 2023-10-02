import 'package:get/get.dart';

import '../controllers/cek_stok_controller.dart';

class CekStokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CekStokController>(
      () => CekStokController(),
    );
  }
}
