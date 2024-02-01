import 'package:absensi/app/helper/app_colors.dart';
import 'package:absensi/app/helper/currency_format.dart';
import 'package:absensi/app/modules/report_sales/views/chart_sales.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import '../controllers/report_sales_controller.dart';
import 'date_filter.dart';

class ReportSalesView extends GetView<ReportSalesController> {
  ReportSalesView({super.key});
  final salesCtr = Get.put(ReportSalesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.mainTextColor1),
        title: const Text('Laporan Sales', style: TextStyle(color: AppColors.mainTextColor1),),
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
      body: SlidingUpPanel(
        backdropEnabled: true,
        minHeight: 25,
        maxHeight: 350,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        panelBuilder: () => MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Obx(()=> chartSales(salesCtr.searchCab.toSet().toList()))),
        body: Center(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            'Periode  ${DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.parse(salesCtr.searchDate.value != "" ? salesCtr.searchDate.value : salesCtr.today))}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // sortBySection()
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: salesCtr.searchData,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                          ),
                          labelText: 'Cari Berdasarkan Cabang',
                          fillColor: Colors.white,
                          filled: true),
                      onChanged: (value) => salesCtr.filterDataSales(value),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Obx(
                      () => Expanded(
                        child: RefreshIndicator(
                            onRefresh: () => salesCtr.refresh(),
                            child: salesCtr.isLoading.value
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // CupertinoActivityIndicator(),
                                        Text('Memuat data...')
                                      ],
                                    ),
                                  )
                                : salesCtr.searchCab.isEmpty
                                    ? const Center(
                                        child: Text('Belum ada data'),
                                      )
                                    : ListView.builder(
                                        controller: salesCtr.scrCtrl,
                                        shrinkWrap: true,
                                        itemCount:
                                            salesCtr.searchCab.toSet().length,
                                        itemBuilder: (context, i) {
                                          if (i < salesCtr.searchCab.length) {
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      salesCtr
                                                          .searchCab[i].cabang!,
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Sales Qty ',
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          salesCtr.searchCab[i]
                                                              .sales!,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Text(
                                                          'Grand Total ',
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          CurrencyFormat.convertToIdr(
                                                              int.parse(salesCtr
                                                                  .searchCab[i]
                                                                  .salesAmount!),
                                                              0),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return  const Center(
                                                    child: Text(
                                                        'Tidak ada data lagi'));
                                          }
                                        },
                                      )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.contentDefBtn,
        onPressed: () => dateFilter(),
        child: const Icon(Iconsax.calendar, color: AppColors.mainTextColor1,),
      ),
    );
  }
}
