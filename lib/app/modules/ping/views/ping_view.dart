import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ping_controller.dart';

class PingIndicator extends StatelessWidget {
  final String host;
  final Duration interval;
  final String tag;

  const PingIndicator({
    super.key,
    required this.host,
    this.interval = const Duration(seconds: 3),
    this.tag = 'ping-indicator',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PingController(host: host, interval: interval),
      tag: tag,
    );

    return Obx(
      () => Row(
       crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 10,
            height: 10,
            child: Icon(Icons.signal_cellular_alt_sharp, color: controller.pingColor, size: 15,),
          ),
          const SizedBox(width:5),
          Text(
            controller.pingLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: controller.pingColor,
            ),
          ),
        ],
      ),
    );
  }
}
