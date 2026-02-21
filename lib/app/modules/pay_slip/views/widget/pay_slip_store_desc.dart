import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/helper/currency_format.dart';
import 'package:absensi/app/data/helper/format_waktu.dart';
import 'package:absensi/app/data/model/payslip_result_model.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import '../../../shared/container_main_color.dart';
import 'dash_divider.dart';
import 'receipt_clipper.dart';
import 'watermark_slip.dart';

class PaySlipStoreDesc extends StatelessWidget {
  const PaySlipStoreDesc({super.key, required this.data});
  final PayslipResult data;

  @override
  Widget build(BuildContext context) {
    final model = data.payslipStoreModel!;
    const blue = Color(0xFF4E73A8);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Material(
          elevation: 16,
          shadowColor: Colors.black.withOpacity(.3),
          color: Colors.transparent,
          child: ClipPath(
            clipper: ReceiptClipper(),
            child: Container(
              color: const Color(0xFFFFFDF7),
              child: Stack(
                children: [
                  /// 🔹 WATERMARK
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: RepeatedWatermark(
                        text: 'URBAN&CO',
                        // alternatif:
                        // text: model.empName!.toUpperCase(),
                        // text: 'SLIP GAJI',
                      ),
                    ),
                  ),

                  /// 🔹 KONTEN UTAMA
                  Column(
                    children: [
                      /// ================= HEADER =================
                      ContainerMainColor(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        radius: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                          // color: blue.withOpacity(.95),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${model.periode!.capitalize} ${DateFormat.y().format(DateTime.parse(model.createdAt!))}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 6,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white.withOpacity(.25),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: Text(
                              //     '${model.tk} Hari',
                              //     style: const TextStyle(color: Colors.white),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),

                      /// ================= BODY =================
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// --- INFO ---
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _info('Nama Karyawan', model.empName!),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _info(
                                    'Tanggal Gabung',
                                    FormatWaktu.formatShortEng(
                                      tanggal: DateTime.parse(model.joinDate!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _info(
                                    'Jabatan',
                                    model.position!.capitalize!,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Expanded(
                                //   child: _info(
                                //     'Status Karyawan',
                                //     model.empStat ?? '',
                                //   ),
                                // ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const DashedDivider(),

                            /// ================= PENERIMAAN =================
                            const SizedBox(height: 14),
                            _sectionTitle('Penerimaan'),
                            _rowIcon(
                              Icons.payments,
                              Colors.green,
                              'Gaji Pokok',
                              model.basicSalary!,
                            ),
                            _rowIcon(
                              Icons.add_circle,
                              Colors.orange,
                              'Tj Jabatan',
                              model.allowance!,
                            ),

                            _rowIcon(
                              Icons.calendar_month
                              ,
                              Colors.lightBlue,
                              'Tj Kehadiran',
                              model.presenceAllowance!,
                            ),
                            _rowIcon(
                              Icons.transfer_within_a_station_outlined,
                              Colors.red,
                              'Tj Kejauhan',
                              model.rangeSubsidy!,
                            ),
                            _rowIcon(
                              Icons.home,
                              Colors.purpleAccent,
                              'Tj Kost',
                              model.boardingAllowance!,
                            ),
                            _rowIcon(
                              Icons.attach_money_rounded,
                              Colors.yellow,
                              'Bonus',
                              model.bonus!,
                            ),
                            _rowIcon(
                              Icons.sync,
                              Colors.blue,
                              'Refund',
                              model.refund!,
                            ),
                            const SizedBox(height: 12),
                            _totalBar(
                              'Total Penerimaan',
                              model.totalIncome!,
                              green!,
                            ),

                            const SizedBox(height: 16),
                            const DashedDivider(),

                            /// ================= POTONGAN =================
                            const SizedBox(height: 14),
                            _sectionTitle('Potongan'),
                            _rowCount(
                              Icons.person_off,
                              Colors.deepOrange,
                              'A / I / S',
                              // model.totalLate!,
                              model.ais!,
                            ),
                            _rowCount(
                              Icons.schedule,
                             Colors.redAccent,
                              'Telat',
                              // model.totalLate!,
                              model.late!,
                            ),
                            _rowCount(
                              Icons.badge,
                              Colors.indigo,
                              'Seragam / ID',
                              // model.totalLate!,
                              model.uniform!,
                            ),
                            _rowCount(
                              Icons.fact_check,
                              Colors.teal,
                              'SO',
                              // model.totalLate!,
                              model.so!,
                            ),
                            _rowCount(
                              Icons.wallet,
                              Colors.green,
                              'Deposit',
                              // model.totalLate!,
                              model.deposit!,
                            ),
                            const SizedBox(height: 8),
                            _totalBar('Total Potongan', model.totalCut!, red!),
                            // const SizedBox(height: 50),
                           
                          ],
                        ),
                      ), const DashedDivider(),
                            const SizedBox(height: 12),

                            /// ================= TOTAL DITERIMA =================
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: _totalBar(
                                'Total Diterima',
                                model.netSalaryRoundTf!,
                                blue,
                                big: true,
                              ),
                            ),

                            const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= COMPONENTS =================

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _rowIcon(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(
            CurrencyFormat.convertToIdr(int.parse(value), 0),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _rowCount(
    IconData icon,
    Color color,
    String label,
    // String count,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          // Text('x $count'),
          // const SizedBox(width: 12),
          Text(
            CurrencyFormat.convertToIdr(int.parse(value), 0),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _totalBar(
    String title,
    String value,
    Color color, {
    bool big = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      // color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              // color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            CurrencyFormat.convertToIdr(int.parse(value), 0),
            style: TextStyle(
              color: color,
              fontSize: big ? 25 : 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
