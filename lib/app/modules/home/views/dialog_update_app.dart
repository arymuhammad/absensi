import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:http/http.dart' as http;
import '../controllers/home_controller.dart';
// import 'package:url_launcher/url_launcher.dart';

// final absC = Get.put(AbsenController());
final homeC = Get.find<HomeController>();
final logC = Get.put(LoginController());

dialogUpdateApp() {
  Get.defaultDialog(
    radius: 5,
    barrierDismissible: false,
    title: 'Available Updates',
    titleStyle: const TextStyle(fontWeight: FontWeight.bold),
    content: SizedBox(
      height: 350, // batasi tinggi dialog sesuai kebutuhan
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(thickness: 1),
            const Text(
              "What's new",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              'version ${homeC.latestVer}',
              style: TextStyle(color: subTitleColor),
            ),
            const SizedBox(height: 5),
            for (var i in homeC.updateList)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconData(
                          int.parse(i['icon']),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Color(int.parse(i['color'])),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${i['name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Text(i['desc'], style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            // const SizedBox(height: 20),
            // const Text(
            //   'Download langsung via browser (install manual)\nHarap tekan salah satu link',
            // ),
            // const SizedBox(height: 10),
            // TextButton(
            //   onPressed: () {
            //     launchUrl(
            //       Uri.parse('http://103.156.15.61/update apk/absensiApp.apk'),
            //     );
            //   },
            //   child: Row(
            //     children: [
            //       const Icon(Icons.file_download_outlined),
            //       const SizedBox(width: 5),
            //       Text('Download', style: TextStyle(color: Colors.blue[500])),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 5),
            // TextButton(
            //   onPressed: () {
            //     launchUrl(
            //       Uri.parse(
            //         'http://103.156.15.61/update apk/absensiApp.arm64v8a.apk',
            //       ),
            //     );
            //   },
            //   child: Row(
            //     children: [
            //       const Icon(Icons.file_download_outlined),
            //       const SizedBox(width: 5),
            //       Text(
            //         'Download\n(opsional, jika link \ndiatas tidak support di hp anda)',
            //         style: TextStyle(color: Colors.blue[500]),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    ),

    // textCancel: 'Batal',
    // onCancel: () => Get.back(),
    textConfirm: 'DOWNLOAD',
    confirmTextColor: Colors.white,
    onConfirm: () {
      Get.back(closeOverlays: true);
      homeC.resetToken(); // 🔥 penting
      homeC.downloadApk();
      try {
        Get.defaultDialog(
          title: 'UPDATE APP',
          radius: 5,
          barrierDismissible: false,
          onWillPop: () async {
            return false;
          },
          content: Obx(() {
            final progress = homeC.downloadProgress.value;

            String formatBytes(int bytes) {
              double kb = bytes / 1024;
              double mb = kb / 1024;
              return "${mb.toStringAsFixed(1)} MB";
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(thickness: 1),

                const Text(
                  'Downloading updates',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.insert_drive_file),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'latest.apk',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          LinearPercentIndicator(
                            percent: progress / 100,
                            lineHeight: 14,
                            barRadius: const Radius.circular(10),
                            backgroundColor: Colors.grey[300],
                            progressColor: Colors.blue,
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "${formatBytes(homeC.downloadedBytes.value)} / ${formatBytes(homeC.totalBytes.value)}",
                            style: const TextStyle(fontSize: 12),
                          ),

                          Text(
                            "${homeC.speed.value} • ${homeC.eta.value}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    /// 🔥 INI DIA TEMPATNYA
                    // Obx(() {
                       IconButton(
                        icon: Icon(
                          homeC.isPaused ? Icons.play_arrow : Icons.pause,
                        ),
                        onPressed: () {
                          if (homeC.isPaused) {
                            homeC.resumeDownload();
                          } else {
                            homeC.pauseDownload();
                          }
                        },
                      )
                    // }),
                  ],
                ),
              ],
            );
          }),
          textConfirm: 'CANCEL',
          confirmTextColor: Colors.white,
          onConfirm: () {
            homeC.cancelDownload(homeC.currentFilePath);
            showToast('Download dibatalkan');
            Get.back();
          },
        );
        //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES

        // onError: errorHandle(Error()),
      } on http.ClientException catch (e) {
        showToast('Failed to make OTA update. Details: $e');
      }
    },
  );
}
