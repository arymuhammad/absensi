import 'package:get/get.dart';

import '../controllers/pay_slip_controller.dart';

class PaySlipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaySlipController>(
      () => PaySlipController(),
    );
  }
}
