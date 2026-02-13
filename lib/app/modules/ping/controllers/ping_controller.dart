import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';

import '../../../data/helper/ping_helper.dart';

class PingController extends GetxController {
  final String host;
  final Duration interval;

  PingController({
    required this.host,
    this.interval = const Duration(seconds: 3),
  });

  Timer? _timer;

  final RxBool isOnline = false.obs;
  final RxnInt pingMs = RxnInt();

  @override
  void onInit() {
    super.onInit();
    _startPing();
  }

  void _startPing() {
    _timer = Timer.periodic(interval, (_) async {
      final result = await PingHelper.ping(host);
      isOnline.value = result.success;
      pingMs.value = result.latencyMs;
    });
  }

  Color get pingColor {
    if (!isOnline.value || pingMs.value == null) {
      return const Color(0xFFE74C3C);
    }
    if (pingMs.value! < 80) return const Color(0xFF2ECC71); // hijau
    if (pingMs.value! < 150) return const Color(0xFFF39C12); // kuning
    return const Color(0xFFE74C3C); // merah
  }

  String get pingLabel {
    if (!isOnline.value) return 'Offline';
    if (pingMs.value == null) return '-- ms';
    return '${pingMs.value} ms';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
