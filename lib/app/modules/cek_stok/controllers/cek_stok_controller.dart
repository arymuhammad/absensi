import 'package:absensi/app/services/service_api.dart';
import 'package:absensi/app/data/model/cek_stok_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
    SmartDialog.dismiss();
    return dataStok;
  }

}
