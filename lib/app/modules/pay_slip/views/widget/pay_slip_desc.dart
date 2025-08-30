import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/currency_format.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/payslip_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/helper/app_colors.dart';

class PaySlipDesc extends StatelessWidget {
  const PaySlipDesc({super.key, required this.data});
  final PayslipModel data;

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 10),
               Center(child: Text('SLIP GAJI KARYAWAN', style: titleTextStyle.copyWith(fontSize: 16),)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Periode')),
                        Text(
                          ': ${DateFormat.yMMMM('id').format(DateTime.parse(data.createdAt!))}',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Nama Karyawan')),
                        Text(': ${data.empName!}'),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Jabatan')),
                        Text(': ${data.position!}'),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text('Tanggal Masuk')),
                        Text(
                          ': ${FormatWaktu.formatIndo(tanggal: (DateTime.parse(data.joinDate!)))}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Penerimaan',
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
              const SizedBox(height: 5),
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
              const SizedBox(height: 5),
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
                      CurrencyFormat.convertToIdr(int.parse(data.refund!), 0),
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
                      'Total Penerimaan',
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
                      'Pemotongan',
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
                    Text(
                      CurrencyFormat.convertToIdr(int.parse(data.lateCut!), 0),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
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
                    Text(
                      CurrencyFormat.convertToIdr(
                        int.parse(data.absentCut!),
                        0,
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
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
                    Text(
                      CurrencyFormat.convertToIdr(int.parse(data.sickCut!), 0),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
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
                    Text(
                      CurrencyFormat.convertToIdr(
                        int.parse(data.clearanceCut!),
                        0,
                      ),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
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
                      'Total Pemotongan',
                      style: titleTextStyle.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(int.parse(data.totalCut!), 0),
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
                AppColors.itemsBackground, // warna background abu dengan penuh
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
                'Total Diterima',
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
  }
}
