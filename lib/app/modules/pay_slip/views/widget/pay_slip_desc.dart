import 'package:absensi/app/data/helper/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/helper/currency_format.dart';
import '../../../../data/helper/format_waktu.dart';
import '../../../../data/model/payslip_result_model.dart';
import 'dash_divider.dart';
import 'receipt_clipper.dart';
import 'watermark_slip.dart';

class PaySlipDesc extends StatelessWidget {
  const PaySlipDesc({super.key, required this.data});
  final PayslipResult data;

  @override
  Widget build(BuildContext context) {
    final model = data.payslipModel!;
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
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                        color: blue.withOpacity(.95),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${model.totalWorkDay} Hari',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
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
                                Expanded(
                                  child: _info(
                                    'Status Karyawan',
                                    model.empStat ?? '',
                                  ),
                                ),
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
                              'Tunjangan',
                              model.allowance!,
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
                              model.totalReceipts!,
                              green!,
                            ),

                            const SizedBox(height: 16),
                            const DashedDivider(),

                            /// ================= POTONGAN =================
                            const SizedBox(height: 14),
                            _sectionTitle('Potongan'),

                            _rowCount(
                              Icons.schedule,
                              Colors.red,
                              'Telat',
                              model.totalLate!,
                              model.lateCut!,
                            ),
                            _rowCount(
                              Icons.close,
                              Colors.orange,
                              'Alpa',
                              model.totalAbsent!,
                              model.absentCut!,
                            ),
                            _rowCount(
                              Icons.add,
                              Colors.blue,
                              'Sakit',
                              model.totalSick!,
                              model.sickCut!,
                            ),
                            _rowCount(
                              Icons.assignment,
                              Colors.green,
                              'Izin',
                              model.totalClearance!,
                              model.clearanceCut!,
                            ),

                            _rowIcon(
                              Icons.health_and_safety,
                              Colors.blue,
                              'BPJS Kesehatan',
                              model.bpjs!,
                            ),

                            Visibility(
                              visible: model.customCutName!.isNotEmpty,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  _sectionTitle('Lainnya'),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _rowIcon(
                                          Icons.money_off_rounded,
                                          Colors.grey,
                                          model.customCutName!,
                                          model.totalCustomCut!.isNotEmpty
                                              ? model.totalCustomCut!
                                              : '0',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                            _totalBar('Total Potongan', model.totalCut!, red!),
                          ],
                        ),
                      ),

                      const DashedDivider(),
                      const SizedBox(height: 12),

                      /// ================= TOTAL DITERIMA =================
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: _totalBar(
                          'Total Diterima',
                          model.totalReceivedByEmp!,
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
    String count,
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
          Text('x $count'),
          const SizedBox(width: 12),
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
