import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_sales_controller.dart';

class ReportSalesView extends GetView<ReportSalesController> {
  ReportSalesView({super.key});
  final salesCtr = Get.put(ReportSalesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Sales'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/bgapp.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(
                () => salesCtr.isLoading.value
                    ? const Center(
                        child: CupertinoActivityIndicator(),
                      )
                    : ListView.builder(
                        controller: salesCtr.scrCtrl,
                        itemCount: salesCtr.sales.length + 1,
                        itemBuilder: (context, i) {
                          if (i < salesCtr.sales.length) {
                            print(salesCtr.sales[i].cabang!);
                            return Card(
                              child: Row(
                                children: [
                                  Text(
                                    salesCtr.sales[i].cabang!,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return salesCtr.hasMore.value
                                ? const Center(
                                    child: CupertinoActivityIndicator())
                                : const Text('Tidak ada data lagi');
                          }
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
