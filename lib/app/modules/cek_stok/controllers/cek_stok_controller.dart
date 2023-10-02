import 'package:absensi/app/Repo/service_api.dart';
import 'package:absensi/app/helper/loading_dialog.dart';
import 'package:absensi/app/model/cek_stok_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CekStokController extends GetxController {
  var dataStok = <CekStok>[].obs;
  var isLoading = true.obs;
  var elapsedTime = 0.obs;
  TextEditingController cariArtikel = TextEditingController();

  final bool running = true;
  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onClose() {
    super.dispose();
    // cariArtikel.dispose();
  }

  Future<List<CekStok>> fetchDataStok(cabang) async {
    // loadingDialog("Loading data ...", "");
    Get.defaultDialog(
        title: '',
        content: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 10,
            ),
            const Text("Loading data ..."),
            // StreamBuilder(
            //   stream: getElapsed(),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Obx(() => Text(elapsedTime.value.toString()));
            //     }
            //     return const Center(
            //       child: CupertinoActivityIndicator(),
            //     );
            //   },
            // )
          ],
        )),
        barrierDismissible: false);
    var tgl1 = DateFormat('yyyy-MM-dd')
        .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
    var tgl2 = DateFormat('yyyy-MM-dd')
        .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
    var data = {
      "kode_cabang": cabang,
      "merk": cariArtikel.text,
      "date1": tgl1,
      "date2": tgl2,
    };
    // print(data);
    final response = await ServiceApi().getDataStok(data);
    dataStok.value = response;
    Get.back();
    return dataStok;
  }

  // Stream getElapsed() async* {
  //   final Stopwatch stopwatch = Stopwatch()..start();
  //   while (running) {
  //     // await Future.delayed(const Duration(seconds: 1));
  //     elapsedTime.value = stopwatch.elapsed.inSeconds;
  //     print(stopwatch.elapsed.inSeconds);
  //     stopwatch.stop();
  //     yield elapsedTime.value = stopwatch.elapsed.inSeconds;
  //   }
  // }
}
