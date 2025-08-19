import 'dart:async';
import 'dart:io';

import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../../../data/helper/custom_dialog.dart';

class SettingsController extends GetxController {
  var serverList = <ServerApi>[].obs;
  var serverSelected = "".obs;
  var updateList = [<String, dynamic>{}].obs;
  var currVer = "";
  var latestVer = "";
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getChangelog();
  }

  getChangelog() async {
    try {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.61/update apk/changeLog.xml'))
          .timeout(const Duration(seconds: 20));

      if (readDoc.statusCode == 200) {
        updateList.clear();
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final itemsNode = document.findElements('items').first;
        final updates = itemsNode.findElements('update');
        latestVer = itemsNode.findElements('versi').first.innerText;
        //start looping item on readDoc
        updateList.clear();
        for (final listUpdates in updates) {
          final name = listUpdates.findElements('name').first.innerText;
          final desc = listUpdates.findElements('desc').first.innerText;
          final icon = listUpdates.findElements('icon').first.innerText;
          final color = listUpdates.findElements('color').first.innerText;

          updateList.add({
            'name': name,
            'desc': desc,
            'icon': icon,
            'color': color,
          });
          isLoading.value = false;
          update();
        }
        //end loop item on readDoc
        // if (compareVersion(latestVer, currVer) <= 0) {
        //   // dialogUpdateApp();
        // }
      } else {
        isLoading.value = false;
        showToast("URL was not found.");
      }
    } on SocketException catch (e) {
      isLoading.value = false;
      Get.defaultDialog(
        title: e.toString(),
        middleText: 'Check your internet connection',
        textConfirm: 'Refresh',
        confirmTextColor: Colors.white,
        onConfirm: () {
          getChangelog();
          Get.back(closeOverlays: true);
        },
      );
    } on TimeoutException catch (_) {
      isLoading.value = false;
      showToast("The connection to the server has timed out.");
    }
  }

  int compareVersion(String v1, String v2) {
    List<String> parts1 = v1.split('.');
    List<String> parts2 = v2.split('.');

    int length =
        (parts1.length > parts2.length) ? parts1.length : parts2.length;

    for (int i = 0; i < length; i++) {
      int p1 = (i < parts1.length) ? int.tryParse(parts1[i]) ?? 0 : 0;
      int p2 = (i < parts2.length) ? int.tryParse(parts2[i]) ?? 0 : 0;

      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0; // sama
  }
}
