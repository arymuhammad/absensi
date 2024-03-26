import 'package:absensi/app/data/helper/loading_dialog.dart';
import 'package:absensi/app/data/model/report_sales_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportSalesController extends GetxController
    with GetTickerProviderStateMixin {
  var sales = <ReportSales>[].obs;
  var isLoading = true.obs;
  // var start = 0.obs;
  // var limit = 8;
  // var hasMore = true.obs;
  var searchDate = "".obs;
  var isSortQty = false.obs;
  var isSortGt = false.obs;
  var today = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  var searchCab = List<ReportSales>.empty(growable: true).obs;
  final ScrollController scrCtrl = ScrollController();
  TextEditingController dateFiltered = TextEditingController();
  TextEditingController searchData = TextEditingController();
  late AnimationController ctrAnimated;

  @override
  void onInit() async {
    ctrAnimated = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    ctrAnimated.forward();
    ctrAnimated.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ctrAnimated.reset();
        ctrAnimated.forward();
      }
    });
    searchCab.value = sales;
    
    // scrCtrl.addListener(() async {
    //   if (scrCtrl.position.maxScrollExtent == scrCtrl.offset) {
    //     if (searchDate.value != "") {
    //       loadingWithIcon();
    //       await salesReportFilter();
    //       SmartDialog.dismiss();
    //     } else {
    //       loadingWithIcon();
    //       await fetchSalesReport();
    //       SmartDialog.dismiss();
    //     }
    //   }
    // });
    super.onInit();
  }

  @override
  void onClose() {
    // dateFiltered.dispose();
    scrCtrl.dispose();
    ctrAnimated.dispose();
    super.onClose();
  }

  @override
  Future refresh()  {
    isLoading.value = true;
    // hasMore.value = true;
    // start.value = 0;
    sales.clear();
    searchDate.value = "";
    dateFiltered.clear();
    // loadingWithIcon();
    return fetchSalesReport();
    // SmartDialog.dismiss();
  }

  Future<List<ReportSales>> fetchSalesReport() async {

    var data = {
      "tanggal1": today,
      "tanggal2": today,
      // "start": start.value.toString(),
      // "limit": limit.toString()
    };

    final response = await ServiceApi().fetchSalesReport(data);
    // if (response.isNotEmpty) {
      sales.addAll(response);
      // start.value += 8;
      // if (response.length < limit) {
      //   hasMore.value = false;
      // }
    // }

    isLoading.value = false;
    return sales;
  }

  Future<List<ReportSales>> salesReportFilter() async {
    // print('filter');

    searchDate.value = dateFiltered.text;
    var data = {
      "tanggal1": dateFiltered.text,
      "tanggal2": dateFiltered.text,
      // "start": start.value.toString(),
      // "limit": limit.toString()
    };

    final response = await ServiceApi().fetchSalesReport(data);
    // if (response.isNotEmpty) {
      sales.addAll(response);
    //   start.value += 8;
    //   if (response.length < limit) {
    //     hasMore.value = false;
    //   }
    // }
    isLoading.value = false;
    // dateFiltered.clear();

    return sales;
  }

  filterDataSales(String data) {
    List<ReportSales> result = [];

    if (data.isEmpty) {
      result = sales;
    } else {
      result = sales
          .where((e) =>
              e.cabang.toString().toLowerCase().contains(data.toLowerCase()))
          .toList();
    }
    searchCab.value = result;
  }
}
