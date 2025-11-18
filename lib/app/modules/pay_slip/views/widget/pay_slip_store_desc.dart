import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/currency_format.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/payslip_result_model.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/app_colors.dart';

class PaySlipStoreDesc extends StatelessWidget {
  const PaySlipStoreDesc({super.key, required this.data});
  final PayslipResult data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              // padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      'SLIP GAJI KARYAWAN',
                      style: titleTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth / 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Periode',
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    '  ${data.payslipStoreModel!.periode!.capitalize} ${DateFormat.y('id').format(DateTime.parse(data.payslipStoreModel!.createdAt!))}',
                                    style: titleTextStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jabatan',
                                  style: subtitleTextStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  data.payslipStoreModel!.position!,
                                  style: titleTextStyle.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth / 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama Karyawan',
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    data.payslipStoreModel!.empName!,
                                    style: titleTextStyle.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tanggal Gabung',
                                  style: subtitleTextStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),

                                Text(
                                  '${FormatWaktu.formatShortEng(tanggal: (DateTime.parse(data.payslipStoreModel!.joinDate!)))}',
                                  style: titleTextStyle.copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PENERIMAAN',
                          style: titleTextStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gaji Pokok',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.basicSalary!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tj Jabatan',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.allowance!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tj Kehadiran',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(
                              data.payslipStoreModel!.presenceAllowance!,
                            ),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tj Kejauhan',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.rangeSubsidy!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tj Kost',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(
                              data.payslipStoreModel!.boardingAllowance!,
                            ),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bonus',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.bonus!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Refund',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.refund!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lembur',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.overtime!),
                            0,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity, // agar lebarnya penuh
                    decoration: const BoxDecoration(
                      color:
                          AppColors
                              .itemsBackground, // warna background abu dengan penuh
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ), // beri padding supaya text tidak mepet
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL PENERIMAAN',
                          style: titleTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.totalIncome!),
                            0,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            Container(
              // padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center(child: Text('SLIP GAJI KARYAWAN'),)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'POTONGAN',
                          style: titleTextStyle.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A / I / S',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            CurrencyFormat.convertToIdr(
                              int.parse(data.payslipStoreModel!.ais!),
                              0,
                            ),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Telat',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            CurrencyFormat.convertToIdr(
                              int.parse(data.payslipStoreModel!.late!),
                              0,
                            ),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seragam / ID',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            CurrencyFormat.convertToIdr(
                              int.parse(data.payslipStoreModel!.uniform!),
                              0,
                            ),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SO',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            CurrencyFormat.convertToIdr(
                              int.parse(data.payslipStoreModel!.so!),
                              0,
                            ),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deposit',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),

                        SizedBox(
                          width: 100,
                          child: Text(
                            CurrencyFormat.convertToIdr(
                              int.parse(data.payslipStoreModel!.deposit!),
                              0,
                            ),
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity, // agar lebarnya penuh
                    decoration: const BoxDecoration(
                      color:
                          AppColors
                              .itemsBackground, // warna background abu dengan penuh
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ), // beri padding supaya text tidak mepet
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL POTONGAN',
                          style: titleTextStyle.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipStoreModel!.totalCut!),
                            0,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            // Container(
            //   width: double.infinity, // agar lebarnya penuh
            //   decoration: const BoxDecoration(
            //     color:
            //         AppColors
            //             .itemsBackground, // warna background abu dengan penuh
            //     // borderRadius: BorderRadius.only(
            //     //   bottomLeft: Radius.circular(10),
            //     //   bottomRight: Radius.circular(10),
            //     // ),
            //   ),
            //   padding: const EdgeInsets.symmetric(
            //     vertical: 8,
            //     horizontal: 10,
            //   ), // beri padding supaya text tidak mepet
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         'TOTAL DITERIMA',
            //         style: titleTextStyle.copyWith(
            //           fontSize: 16,
            //           color: Colors.white,
            //         ),
            //       ),
            //       Text(
            //         CurrencyFormat.convertToIdr(
            //           int.parse(data.payslipStoreModel!.netSalaryRoundTf!),
            //           0,
            //         ),
            //         style: const TextStyle(
            //           fontSize: 16,
            //           color: Colors.white,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
