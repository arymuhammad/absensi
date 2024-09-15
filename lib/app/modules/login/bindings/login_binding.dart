import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
    // Get.put(()=>AlarmController());
    Get.put(()=>AbsenController());
  }
}
