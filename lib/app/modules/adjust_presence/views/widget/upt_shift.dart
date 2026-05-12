import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/helper/const.dart';
import '../../../login/controllers/login_controller.dart';
import '../../../shared/elevated_button.dart';
import '../../../shared/text_field.dart';

class UptShift extends StatelessWidget {
  UptShift({super.key, required this.data, required this.isInbox});
  final ReqApp data;
  final bool isInbox;
  final auth = Get.find<LoginController>();
  final adjCtrl = Get.put(AdjustPresenceController());
  final homeC = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final levelId = dataUser.level;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATUS', style: subtitleTextStyle),
                Text(
                  data.status!.replaceAll('_', ' ').toUpperCase(),
                  style: titleTextStyle.copyWith(fontSize: 14),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(width: 5),
                    Text(data.namaShift!, style: titleTextStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Alasan Perubahan Data', style: titleTextStyle),
        Text(data.alasan!, style: subtitleTextStyle),
        const SizedBox(height: 10),
        Obx(() {
          final dataUser = auth.logUser.value;
          return Visibility(
            visible:
                data.statusExcep == "pending" &&
                        data.keterangan == "" &&
                        ([
                          '1',
                          '17',
                          '18',
                          '19',
                          '20',
                          '39',
                          '26',
                          '96',
                        ]).contains(dataUser.level)
                    ? true
                    : false,
            child: SizedBox(
              height: 45,
              child: CsTextField(
                enabled: true,
                controller: adjCtrl.keteranganApp,
                label: 'Keterangan',
                isDark: isDark,
              ),
            ),
          );
        }),
        const SizedBox(height: 5),
        Visibility(
          visible: data.statusExcep == "reject" ? true : false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keterangan', style: titleTextStyle.copyWith(fontSize: 18)),
              Text(data.keterangan!, style: subtitleTextStyle),
            ],
          ),
        ),
        Obx(() {
          final dataUser = auth.logUser.value;
          return Visibility(
            visible:
                data.statusExcep == "pending" &&
                        ([
                          '1',
                          '17',
                          '18',
                          '19',
                          '20',
                          '39',
                          '26',
                          '96',
                        ]).contains(dataUser.level)
                    ? true
                    : false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CsElevatedButton(
                  fontsize: 15,
                  label: 'Accept',
                  color: Colors.greenAccent[700]!,
                  onPressed: () {
                    final dataUser = auth.logUser.value;
                    var dataUptApp = {
                      {
                            "1": "acc_4",
                            "17": "acc_4",
                            "18": "acc_4",
                            "39": "acc_4",
                            "96": "acc_3",
                            "26": "acc_2",
                            "19": "acc_1",
                            "20": "acc_1",
                          }[dataUser.level]!:
                          "approved",
                      "uid": data.id,
                      "level": dataUser.level,
                      "keterangan":
                          data.keterangan ?? adjCtrl.keteranganApp.text,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      "status": data.status,
                    };
                    /////////
                    var dataUptAbs = {
                      "status": data.status,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      "id_shift": data.idShift,
                      "jam_masuk": data.jamMasuk,
                      "jam_pulang": data.jamPulang,
                    };
                    adjCtrl.appAbs(dataUptApp, dataUptAbs, isInbox);
                    homeC.getPendingAdj(
                      idUser: dataUser.id!,
                      idCabang: dataUser.kodeCabang!,
                      level: dataUser.level!,
                    );
                  },
                ),
                const SizedBox(width: 5),
                CsElevatedButton(
                  fontsize: 15,
                  label: 'Reject',
                  color: Colors.redAccent[700]!,
                  onPressed: () {
                    final dataUser = auth.logUser.value;
                    var dataUptApp = {
                      {
                            "1": "acc_4",
                            "17": "acc_4",
                            "18": "acc_4",
                            "39": "acc_4",
                            "96": "acc_3",
                            "26": "acc_2",
                            "19": "acc_1",
                            "20": "acc_1",
                          }[dataUser.level]!:
                          "reject",
                      "uid": data.id,
                      "level": dataUser.level,
                      "keterangan":
                          data.keterangan ?? adjCtrl.keteranganApp.text,
                      "id_user": data.idUser,
                      "tgl_masuk": data.tglMasuk,
                      "status": data.status,
                    };
                    adjCtrl.appAbs(dataUptApp, {}, isInbox);
                    homeC.getPendingAdj(
                      idUser: dataUser.id!,
                      idCabang: dataUser.kodeCabang!,
                      level: dataUser.level!,
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
