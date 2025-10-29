import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/currency_format.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/payslip_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/app_colors.dart';

class PaySlipDesc extends StatelessWidget {
  const PaySlipDesc({super.key, required this.data});
  final PayslipModel data;

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
                                    DateFormat.yMMMM(
                                      'id',
                                    ).format(DateTime.parse(data.createdAt!)),
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
                                  data.totalWorkDay!,
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
                                    '${data.empName!.capitalize}',
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
                                  '${FormatWaktu.formatShortEng(tanggal: (DateTime.parse(data.joinDate!)))}',
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
                          '${data.position!.capitalize}',
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
                            int.parse(data.basicSalary!),
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
                            int.parse(data.allowance!),
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
                            int.parse(data.refund!),
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
                      vertical: 4,
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
                            int.parse(data.totalReceipts!),
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
                                'x ${data.totalLate!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.lateCut!),
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
                                'x ${data.totalAbsent!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.absentCut!),
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
                                'x ${data.totalSick!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.sickCut!),
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
                                'x ${data.totalClearance!}',
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                CurrencyFormat.convertToIdr(
                                  int.parse(data.clearanceCut!),
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
                          CurrencyFormat.convertToIdr(int.parse(data.bpjs!), 0),
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
                          data.customCutName ?? '',
                          style: subtitleTextStyle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          data.totalCustomCut!.isEmpty
                              ? ''
                              : CurrencyFormat.convertToIdr(
                                int.parse(data.totalCustomCut!),
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
                            int.parse(data.totalCut!),
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
              width: double.infinity, // agar lebarnya penuh
              decoration: const BoxDecoration(
                color:
                    AppColors
                        .itemsBackground, // warna background abu dengan penuh
                // borderRadius: BorderRadius.only(
                //   bottomLeft: Radius.circular(10),
                //   bottomRight: Radius.circular(10),
                // ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ), // beri padding supaya text tidak mepet
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL DITERIMA',
                    style: titleTextStyle.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    CurrencyFormat.convertToIdr(
                      int.parse(data.totalReceivedByEmp!),
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
        );
      },
    );
  }
}
