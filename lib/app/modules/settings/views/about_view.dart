import 'dart:io';
import 'dart:math' as math;
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:absensi/app/modules/settings/controllers/settings_controller.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/helper/const.dart';
import '../../../data/helper/helper_ui.dart';
import '../../../data/helper/loading_platform.dart';
import '../../../data/helper/shorebird_helper.dart';
import '../../home/controllers/home_controller.dart';

class AboutView extends GetView {
  AboutView({super.key});
  final homeC = Get.find<HomeController>();
  final setC = Get.put(SettingsController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('About', style: titleTextStyle.copyWith(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        // iconTheme: const IconThemeData(color: Colors.black,),
        // centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: AppColors.mainGradient(
                context: context,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 110, left: 15.0, right: 15.0),
            child: Card(
              elevation: 4,
              child: SizedBox(
                height: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_download_rounded),
                      title: const Text('Check for app updates'),
                      onTap: () {
                        if (Platform.isAndroid) {
                          homeC.checkForUpdates("about");
                          // launchUrl(
                          //     Uri.parse('http://103.156.15.61/update apk/absensiApp.apk'));
                        } else {
                          launchUrl(
                            Uri.parse(
                              'https://apps.apple.com/us/app/urbanco-spot/id6476486235',
                            ),
                          );
                          // showToast("Fitur ini hanya untuk Android");
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Application version'),
                      subtitle: Text(
                        'V${homeC.currVer}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListTile(
                      title: const Text('Check Available Patch'),
                      subtitle: Obx(
                        () => Text(
                          'Current ${homeC.currPatchVer.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () async {
                        final status = await ShorebirdHelper.checkStatus();

                        if (status == null) return;

                        switch (status) {
                          case UpdateStatus.outdated:
                            Get.defaultDialog(
                              title: "Patch tersedia",
                              middleText:
                                  "Patch saat ini : ${homeC.currPatchVer}\n\n"
                                  "Patch baru tersedia.\n\nApakah ingin mengunduh sekarang?",
                              textCancel: "Nanti",
                              textConfirm: "Download",
                              onCancel: () => Get.back(),
                              onConfirm: () async {
                                Get.back();

                                final success =
                                    await ShorebirdHelper.downloadPatch();

                                if (success) {
                                  homeC.currPatchVer.value =
                                      await ShorebirdHelper.currentPatchVersion();
                                  dialogMsgScsUpd(
                                    "Patch berhasil diunduh",
                                    "Silakan tutup dan buka kembali aplikasi.",
                                  );
                                }
                              },
                              barrierDismissible: false,
                            );
                            break;

                          case UpdateStatus.restartRequired:
                            dialogMsgScsUpd(
                              "Restart diperlukan",
                              "Patch sudah terpasang.\nSilakan tutup dan buka kembali aplikasi.",
                            );
                            break;

                          case UpdateStatus.upToDate:
                          case UpdateStatus.unavailable:
                            // Tidak menampilkan popup apa pun
                            break;
                        }
                      },
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Changelog',
                        style: titleTextStyle.copyWith(fontSize: 18),
                      ),
                    ),
                    Obx(
                      () =>
                          setC.isLoading.value
                              ? Center(child: platFormDevice())
                              : Expanded(
                                child: buildChangelog(setC.changelog, setC),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildChangelog(
  List<Map<String, dynamic>> changelog,
  SettingsController setC,
) {
  return CustomMaterialIndicator(
    onRefresh: () async {
      setC.isLoading.value = true;
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.61/update_apk/changeLog.xml'))
          .timeout(const Duration(seconds: 20));
      await setC.parseChangelogXml(readDoc.body);
      showToast('Page Refreshed');
    },
    indicatorBuilder: (context, controller) {
      return Padding(
        padding: const EdgeInsets.all(6.0),
        child:
            Platform.isAndroid
                ? CircularProgressIndicator(
                  color: AppColors.itemsBackground,
                  value:
                      controller.state.isLoading
                          ? null
                          : math.min(controller.value, 1.0),
                )
                : const CupertinoActivityIndicator(),
      );
    },
    child: ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: changelog.length,
      itemBuilder: (context, index) {
        final versionData = changelog[index];
        final version = versionData['version'];
        final releaseDate = versionData['release_date'];
        final updates = versionData['updates'] as List<dynamic>;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version', style: subtitleTextStyle),
                      Text(
                        'V$version',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Release Date', style: subtitleTextStyle),
                      Text(
                        releaseDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...updates.map((update) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        getIcon(update['icon']),
                        color: Color(int.parse(update['color'])),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              update['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              update['desc'],
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(thickness: 1),
            ],
          ),
        );
      },
    ),
  );
}
