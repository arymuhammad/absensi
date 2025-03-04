import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/helper/custom_dialog.dart';
import '../../../data/model/absen_model.dart';
import '../../shared/elevated_button_icon.dart';
import '../../shared/text_field.dart';

class ExpandedDataAbsen extends StatelessWidget {
  final Absen data;
  ExpandedDataAbsen({super.key, required this.data});

  final ctrl = Get.put(AdjustPresenceController());
  @override
  Widget build(BuildContext context) {
    return data.idUser != null
        ? Expanded(
            child: ListView(children: [
            ExpansionTileGroup(
                toggleType: ToggleType.expandOnlyCurrent,
                spaceBetweenItem: 10,
                children: [
                  ExpansionTileItem(
                      controlAffinity: ListTileControlAffinity.trailing,
                      border: Border.all(),
                      isHasBottomBorder: true,
                      isHasTopBorder: true,
                      isHasLeftBorder: true,
                      isHasRightBorder: true,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      title: Text(data.nama!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.idUser!),
                          Text(DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(data.tanggalMasuk!)))
                        ],
                      ),
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.size.width / 2,
                                  child: DateTimeField(
                                      controller: ctrl.datePulangupd
                                        ..text = data.tanggalPulang != null
                                            ? data.tanggalPulang!
                                            : "",
                                      style: const TextStyle(fontSize: 16),
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(0.5),
                                          prefixIcon: Icon(
                                              Icons.calendar_month_outlined),
                                          hintText: 'Tanggal Pulang',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder()),
                                      format: DateFormat("yyyy-MM-dd"),
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                            context: context,
                                            firstDate: DateTime(1900),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate: DateTime(2100));
                                      }),
                                ),
                                CsElevatedButtonIcon(
                                  label: '',
                                  icon: const Icon(Icons.save_as_rounded),
                                  onPressed: () => ctrl.updateDataAbsen(
                                      data.idUser, data.tanggalMasuk!),
                                  size: Size(Get.mediaQuery.size.width / 3, 50),
                                  fontSize: 18,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            FutureBuilder(
                              future: ctrl.getShift(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var dataShift = snapshot.data!;
                                  return DropdownButtonFormField(
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Pilih Shift Absen'),
                                    value: ctrl.selectedShift.value == ""
                                        ? data.idShift != ""
                                            ? data.idShift!
                                            : null
                                        : ctrl.selectedShift.value,
                                    onChanged: (data) {
                                      ctrl.selectedShift.value = data!;

                                      if (ctrl.selectedShift.value == "5") {
                                        ctrl.jamMasuk.value = ctrl.timeNow;
                                        ctrl.jamPulang.value =
                                            DateFormat("HH:mm").format(DateTime
                                                    .parse(ctrl.dateNowServer)
                                                .add(const Duration(hours: 8)));
                                      } else {
                                        for (int i = 0;
                                            i < dataShift.length;
                                            i++) {
                                          if (dataShift[i].id == data) {
                                            ctrl.jamMasuk.value =
                                                dataShift[i].jamMasuk!;
                                            ctrl.jamPulang.value =
                                                dataShift[i].jamPulang!;
                                          }
                                        }
                                      }
                                      dialogMsg('Info',
                                          'Pastikan Shift Kerja yang dipilih\nsudah sesuai');
                                    },
                                    items: dataShift
                                        .map((e) => DropdownMenuItem(
                                            value: e.id,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  e.namaShift.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  ' (${e.jamMasuk!} - ${e.jamPulang!})',
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            )))
                                        .toList(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const CupertinoActivityIndicator();
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.size.width / 2.3,
                                  child: CsTextField(
                                      controller: ctrl.jamMasukUpdate
                                        ..text = data.jamAbsenMasuk!,
                                      label: 'Jam Masuk'),
                                ),
                                SizedBox(
                                  width: Get.size.width / 2.3,
                                  child: CsTextField(
                                      controller: ctrl.jamPulangUpdate
                                        ..text = data.jamAbsenPulang!,
                                      label: 'Jam Pulang'),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CsTextField(
                                controller: ctrl.foto..text = data.fotoPulang! !="" ?data.fotoPulang!:'',
                                label: 'Foto'),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: Get.size.width / 2.3,
                                  child: CsTextField(
                                      controller: ctrl.lat
                                        ..text = data.latMasuk!,
                                      label: 'Lat'),
                                ),
                                SizedBox(
                                  width: Get.size.width / 2.3,
                                  child: CsTextField(
                                      controller: ctrl.long
                                        ..text = data.longMasuk!,
                                      label: 'Long'),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            CsTextField(
                                controller: ctrl.device..text = data.devInfo!,
                                label: 'Device'),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        )
                      ])
                ])
          ]))
        : const Center(
            child: Text('Belum ada data'),
          );
  }
}
