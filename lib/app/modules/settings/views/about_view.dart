import 'dart:io';
import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:absensi/app/modules/settings/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/helper/const.dart';

class AboutView extends GetView {
  AboutView({super.key});
  final absC = Get.put(AbsenController());
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
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150, left: 15.0, right: 15.0),
            child: Card(
              elevation: 4,
              child: SizedBox(
                height: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.cloud_download_rounded),
                      title: const Text('Check for app updates'),
                      onTap: () {
                        if (Platform.isAndroid) {
                          absC.checkForUpdates("about");
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
                        'V${absC.currVer}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Changelog', style: titleTextStyle.copyWith(fontSize: 18),),
                    ),
                    Obx(
                      () =>
                          setC.isLoading.value
                              ? const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Loading data...  '),
                                    SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ],
                                ),
                              )
                              : Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final data = setC.updateList[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('V${setC.latestVer}',style: titleTextStyle),
                                          const SizedBox(height: 5,),
                                          Row(
                                            children: [
                                              Icon(
                                                IconData(
                                                  int.parse(data['icon']),
                                                  fontFamily: 'MaterialIcons',
                                                ),
                                                color: Color(
                                                  int.parse(data['color']),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${data['name']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            data['desc'],
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (context, index) => const Divider(),
                                  itemCount: setC.updateList.length,
                                ),
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
