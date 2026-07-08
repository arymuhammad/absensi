import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/model/absen_model.dart';

class SemuaAbsenController extends GetxController {
  var isLoading = true.obs;
  var dataAllAbsen = <Absen>[].obs;
  var searchDate = "".obs;
  var selectedCabang = "".obs;
  var selectedUserCabang = "".obs;
  var userMonitor = "".obs;
  late TextEditingController date1, date2, store, userCab, rndLoc;
  final TextEditingController filterAbsen = TextEditingController();
  final Rxn<DateTimeRange> pickedRange = Rxn<DateTimeRange>();
  final Rx<DateTime> pickedMonth = DateTime.now().obs;

  @override
  void onInit() async {
    super.onInit();
    date1 = TextEditingController();
    date2 = TextEditingController();
    store = TextEditingController();
    userCab = TextEditingController();
    rndLoc = TextEditingController();
  }

  @override
  void onClose() {
    date1.dispose();
    date2.dispose();
    store.dispose();
    userCab.dispose();
    rndLoc.dispose();

    filterAbsen.dispose();
    super.onClose();
  }
}
