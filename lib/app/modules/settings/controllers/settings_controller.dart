import 'dart:async';
import 'package:absensi/app/data/model/server_api_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;


class SettingsController extends GetxController {
  var serverList = <ServerApi>[].obs;
  var serverSelected = "".obs;
  // var updateList = [<String, dynamic>{}].obs;
  var changelog = <Map<String, dynamic>>[].obs;

  var currVer = "";
  var latestVer = "";
  var isLoading = true.obs;

  @override
  void onInit() async {
    super.onInit();
    final readDoc = await http
        .get(Uri.parse('http://103.156.15.61/update apk/changeLog.xml'))
        .timeout(const Duration(seconds: 20));
    parseChangelogXml(readDoc.body);
  }

  // getChangelog() async {
  //   try {
  //     final readDoc = await http
  //         .get(Uri.parse('http://103.156.15.61/update apk/changeLog.xml'))
  //         .timeout(const Duration(seconds: 20));

  //     if (readDoc.statusCode == 200) {
  //       // updateList.clear();
  //       //parsing readDoc
  //       final document = xml.XmlDocument.parse(readDoc.body);
  //       final itemsNode = document.findElements('items').first;
  //       final updates = itemsNode.findElements('update');
  //       latestVer = itemsNode.findElements('versi').first.innerText;
  //       //start looping item on readDoc
  //       // updateList.clear();
  //       // for (final listUpdates in updates) {
  //       //   // final version = listUpdates.findElements('versi');
  //       //   final name = listUpdates.findElements('name').first.innerText;
  //       //   final desc = listUpdates.findElements('desc').first.innerText;
  //       //   final icon = listUpdates.findElements('icon').first.innerText;
  //       //   final color = listUpdates.findElements('color').first.innerText;

  //         // updateList.add({
  //         //   'versi': latestVer,
  //         //   'name': name,
  //         //   'desc': desc,
  //         //   'icon': icon,
  //         //   'color': color,
  //         // });
  //         // isLoading.value = false;
  //         // update();
  //       // }
  //       // print(updateList);
  //       //end loop item on readDoc
  //       // if (compareVersion(latestVer, currVer) <= 0) {
  //       //   // dialogUpdateApp();
  //       // }
  //     } else {
  //       isLoading.value = false;
  //       showToast("URL was not found.");
  //     }
  //   } on SocketException catch (e) {
  //     isLoading.value = false;
  //     Get.defaultDialog(
  //       title: e.toString(),
  //       middleText: 'Check your internet connection',
  //       textConfirm: 'Refresh',
  //       confirmTextColor: Colors.white,
  //       onConfirm: () {
  //         getChangelog();
  //         Get.back(closeOverlays: true);
  //       },
  //     );
  //   } on TimeoutException catch (_) {
  //     isLoading.value = false;
  //     showToast("The connection to the server has timed out.");
  //   }
  // }

  Future<List<Map<String, dynamic>>> parseChangelogXml(String xmlString) async {
    final document = xml.XmlDocument.parse(xmlString);
    final items = document.findElements('items').first;

    // List<Map<String, dynamic>> changelog = [];

    // parsing manual dengan asumsi versi dan update berdampingan
    changelog.clear();
    String currentVersion = '';
    String releaseDate = '';
    List<Map<String, dynamic>> updates = [];
    for (final node in items.children) {
      if (node is xml.XmlElement) {
        //  releaseDate =
        //      node.findElements('tgl').first.innerText
        //
        if (node.name.local == 'versi') {
          if (currentVersion != '') {
            changelog.add({
              'version': currentVersion,
              'release_date': releaseDate,
              'updates': updates,
            });
            updates = []; // reset untuk versi baru
          }
          currentVersion = node.innerText.trim();

          releaseDate = '';
        } else if (node.name.local == 'tgl') {
          releaseDate = node.innerText.trim();
        } else if (node.name.local == 'update') {
          final name = node.findElements('name').first.innerText;
          final desc = node.findElements('desc').first.innerText;
          final icon = node.findElements('icon').first.innerText;
          final color = node.findElements('color').first.innerText;

          // if (changelog.isNotEmpty) {
            updates.add({
              'name': name,
              'desc': desc,
              'icon': icon,
              'color': color,
            });
            isLoading.value = false;

            // update();
          // }
        }
      }
    }
    if (currentVersion != '') {
      changelog.add({
        'version': currentVersion,
        'release_date': releaseDate,
        'updates': updates,
      });
    }
    return changelog;
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
