import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_sales_controller.dart';

class ReportSalesView extends GetView<ReportSalesController> {
  const ReportSalesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Sales'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/image/bgapp.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'CekSalesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
