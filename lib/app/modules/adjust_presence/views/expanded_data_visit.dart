import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/shared/elevated_button_icon.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/text_field.dart';

class ExpandedDataVisit extends StatelessWidget {
  final RxList dataVisit;
  ExpandedDataVisit({super.key, required this.dataVisit});

  final ctrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return dataVisit.isNotEmpty
        ? Obx(
            () => Expanded(
                child: ListView(children: [
              ExpansionTileGroup(
                  toggleType: ToggleType.expandOnlyCurrent,
                  spaceBetweenItem: 10,
                  children: [
                    for (var i in dataVisit)
                      ExpansionTileItem(
                          controlAffinity: ListTileControlAffinity.trailing,
                          border: Border.all(),
                          isHasBottomBorder: true,
                          isHasTopBorder: true,
                          isHasLeftBorder: true,
                          isHasRightBorder: true,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          title: Text(i.nama!),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(i.id!),
                              Text(DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(i.tglVisit!)))
                            ],
                          ),
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Get.size.width / 2,
                                      child: DateTimeField(
                                          controller: ctrl.datePulangupd
                                            ..text = i.tglVisit != null
                                                ? i.tglVisit!
                                                : "",
                                          style: const TextStyle(fontSize: 16),
                                          decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(0.5),
                                              prefixIcon: Icon(Icons
                                                  .calendar_month_outlined),
                                              hintText: 'Tanggal Visit',
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder()),
                                          format: DateFormat("yyyy-MM-dd"),
                                          onShowPicker:
                                              (context, currentValue) {
                                            return showDatePicker(
                                                context: context,
                                                firstDate: DateTime(1900),
                                                initialDate: currentValue ??
                                                    DateTime.now(),
                                                lastDate: DateTime(2100));
                                          }),
                                    ),
                                    CsElevatedButtonIcon(
                                      icon: const Icon(Icons.save_as_rounded),
                                      onPressed: () => ctrl.updateDataVisit(
                                          i.id, i.tglVisit, i.visitIn),
                                      size: Size(
                                          Get.mediaQuery.size.width / 3, 50),
                                          fontSize: 18,
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CsTextField(
                                    controller: ctrl.visit..text = i.visitIn!,
                                    label: 'Visit'),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Get.size.width / 2.3,
                                      child: CsTextField(
                                          controller: ctrl.jamIn
                                            ..text = i.jamIn!,
                                          label: 'IN'),
                                    ),
                                    SizedBox(
                                      width: Get.size.width / 2.3,
                                      child: CsTextField(
                                          controller: ctrl.jamOut
                                            ..text = i.jamOut!,
                                          label: 'OUT'),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CsTextField(
                                    controller: ctrl.foto..text = i.fotoIn!,
                                    label: 'Foto'),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: Get.size.width / 2.3,
                                      child: CsTextField(
                                          controller: ctrl.lat..text = i.latIn!,
                                          label: 'Lat'),
                                    ),
                                    SizedBox(
                                      width: Get.size.width / 2.3,
                                      child: CsTextField(
                                          controller: ctrl.long
                                            ..text = i.longIn!,
                                          label: 'Long'),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                CsTextField(
                                    controller: ctrl.device
                                      ..text = i.deviceInfo!,
                                    label: 'Device'),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            )
                          ])
                  ])
            ])),
          )
        : const Center(
            child: Text('Belum ada data'),
          );
  }
}
