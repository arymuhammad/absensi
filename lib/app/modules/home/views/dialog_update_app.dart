
import 'package:absensi/app/controllers/absen_controller.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ota_update/ota_update.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;

final absC = Get.put(AbsenController());
final logC = Get.put(LoginController());

dialogUpdateApp() {
  Get.defaultDialog(
      radius: 5,
      onWillPop: () async {
        return false;
      },
      title: 'Pembaruan Tersedia',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(Icons.logout_rounded)
          // Colors.red
          const Text(
            'Apa yang baru',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(
            height: 5,
          ),
          Text('versi ${absC.latestVer}',
              style: TextStyle(color: subTitleColor)),
          const SizedBox(
            height: 5,
          ),
          for (var i in absC.updateList)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      IconData(int.parse(i['icon']),
                          fontFamily: 'MaterialIcons'),
                      color: Color(int.parse(i['color'])),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text('${i['name']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Text(
                  i['desc'],
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            )
        ],
      ),
      // textCancel: 'Batal',
      // onCancel: () => Get.back(),
      textConfirm: 'DOWNLOAD',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(closeOverlays: true);
        try {
          
          Get.defaultDialog(
              title: 'Pembaruan perangkat lunak',
              radius: 2,
              barrierDismissible: false,
              onWillPop: () async {
                return false;
              },
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text('Mengunduh pembaruan...'),
                  Obx(
                    () => Text('${(absC.downloadProgress.value).toInt()}%'),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Obx(
                    () => LinearPercentIndicator(
                        lineHeight: 10.0,
                        percent: absC.downloadProgress.value / 100,
                        backgroundColor: Colors.grey[220],
                        progressColor: Colors.blue,
                        barRadius: const Radius.circular(5)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ));
          //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
          OtaUpdate()
              .execute(
            'http://103.156.15.60/update apk/absensiApp.apk',
            // OPTIONAL
            // destinationFilename: '/',
            //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
            // sha256checksum:
            //     "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
          )
              .listen(
            (OtaEvent event) {
              absC.downloadProgress.value = double.parse(event.value!);
            },
            // onError: errorHandle(Error()),
            onDone: logC.logout,
          );
          
        } on http.ClientException catch (e) {
          print('Failed to make OTA update. Details: $e');
        }
        
      });
}
