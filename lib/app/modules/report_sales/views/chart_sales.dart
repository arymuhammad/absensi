import 'package:absensi/app/model/report_sales_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Widget chartSales(List<ReportSales> dataSales) {
  return ListView(
    children: [
      const SizedBox(
        height: 10.0,
      ),
      Center(
        child: Container(
          height: 8,
          width: 35,
          decoration: BoxDecoration(
              color: Colors.blueAccent[700],
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 300,
          // width: 300,
          child: SfCircularChart(
              // primaryXAxis: CategoryAxis(
              //     labelRotation: 40,
              //     labelPlacement: LabelPlacement.onTicks,
              //    placeLabelsNearAxisLine: true,arrangeByIndex: true
              //    ),
              // primaryYAxis: NumericAxis(
              //     numberFormat: NumberFormat.compact(locale: 'id')),
              // // Chart title
              title: ChartTitle(text: 'Grafik Report Sales'),
              // // Enable legend
              legend: const Legend(isVisible: true),
              // // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CircularSeries<ReportSales, String>>[
                DoughnutSeries<ReportSales, String>(
                    dataSource: dataSales,
                    xValueMapper: (ReportSales sales, _) => sales.alias,
                    yValueMapper: (ReportSales sales, _) =>
                        int.parse(sales.salesAmount!),
                    name: 'Sales',
                    dataLabelMapper: (ReportSales sales, _) =>
                        sales.salesAmount!,
                    enableTooltip: true
                    // color: Colors.blue,
                    // Enable data label
                    // dataLabelSettings: DataLabelSettings(
                    //   isVisible: true,
                    // )
                    )
              ]),
        ),
      )
    ],
  );
}
