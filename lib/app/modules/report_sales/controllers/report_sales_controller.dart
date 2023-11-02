import 'package:absensi/app/model/report_sales_model.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportSalesController extends GetxController {
  var sales = <ReportSales>[].obs;
  var isLoading = true.obs;
  var start = 0.obs;
  var limit = 6;
  var hasMore = true.obs;
  var today = DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  var searchCab = List<ReportSales>.empty(growable: true).obs;
  final ScrollController scrCtrl = ScrollController();

  @override
  void onInit() {
    super.onInit();
    searchCab.value = sales;
    fetchSalesReport();
    scrCtrl.addListener(() {
      if (scrCtrl.position.maxScrollExtent == scrCtrl.offset) {
        fetchSalesReport();
      }
    });
  }
  
  @override
  void onClose() {
    super.onClose();
    scrCtrl.dispose();
  }

  Future<List<ReportSales>>fetchSalesReport() async {
    var data = {
      "tanggal1": today,
      "tanggal2": today,
      "start": start.value.toString(),
      "limit": limit.toString()
    };
    final response = await ServiceApi().fetchSalesReport(data);
    // sales.value = response;
    if (sales.isNotEmpty) {
      sales.addAll(response);
      start.value += 6;
      if (sales.length < limit) {
        hasMore.value = false;
      }
    }
    isLoading.value = false;
    return sales;
  }

}
