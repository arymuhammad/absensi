import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/currency_format.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/payslip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/app_colors.dart';
import '../../../../data/model/payslip_result_model.dart';

class PaySlipDesc extends StatelessWidget {
  const PaySlipDesc({super.key, required this.data});
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
                                    '${data.payslipModel!.periode!.capitalize} ${DateFormat.y('id').format(DateTime.parse(data.payslipModel!.createdAt!))}',
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
                                  'Total Hari Kerja',
                                  style: subtitleTextStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  data.payslipModel!.totalWorkDay!,
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
                                    '${data.payslipModel!.empName!.capitalize}',
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
                                  '${FormatWaktu.formatShortEng(tanggal: (DateTime.parse(data.payslipModel!.joinDate!)))}',
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
                        Text(
                          'Jabatan',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${data.payslipModel!.position!.capitalize}',
                          style: titleTextStyle.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                            int.parse(data.payslipModel!.basicSalary!),
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
                          'Tunjangan',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipModel!.allowance!),
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
                          'Refund',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipModel!.refund!),
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
                            int.parse(data.payslipModel!.totalReceipts!),
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
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                'x ${data.payslipModel!.totalLate!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.payslipModel!.lateCut!),
                                  0,
                                ),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
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
                          'Alpa',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                'x ${data.payslipModel!.totalAbsent!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.payslipModel!.absentCut!),
                                  0,
                                ),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
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
                          'Sakit',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                'x ${data.payslipModel!.totalSick!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.payslipModel!.sickCut!),
                                  0,
                                ),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
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
                          'Izin',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                'x ${data.payslipModel!.totalClearance!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.payslipModel!.clearanceCut!),
                                  0,
                                ),
                                style: const TextStyle(fontSize: 15),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
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
                          'BPJS Kesehatan',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          CurrencyFormat.convertToIdr(
                            int.parse(data.payslipModel!.bpjs!),
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
                          data.payslipModel!.customCutName ?? '',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          data.payslipModel!.totalCustomCut!.isEmpty
                              ? ''
                              : CurrencyFormat.convertToIdr(
                                int.parse(data.payslipModel!.totalCustomCut!),
                                0,
                              ),
                          style: const TextStyle(fontSize: 15),
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
                            int.parse(data.payslipModel!.totalCut!),
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
            //           int.parse(data.payslipModel!.totalReceivedByEmp!),
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
