import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/helper/const.dart';
import '../../../shared/elevated_button.dart';

class UptShift extends StatelessWidget {
  UptShift({super.key, required this.data, this.dataUser});
  final ReqApp data;
  final Data? dataUser;
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS',
                  style: subtitleTextStyle,
                ),
                Text(
                  data.status!.replaceAll('_', ' ').toUpperCase(),
                  style: titleTextStyle,
                ),
                Row(
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      data.namaShift!,
                      style: titleTextStyle,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Alasan Perubahan Data',
          style: titleTextStyle,
        ),
        Text(
          data.alasan!,
          style: subtitleTextStyle,
        ),
        const Divider(
          thickness: 2,
        ),
        Visibility(
          visible: data.accept == "" && dataUser!.level == "1" ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CsElevatedButton(
                fontsize: 15,
                label: 'Accept',
                color: Colors.greenAccent[700]!,
                onPressed: () {
                  var dataUptApp = {
                    "uid": data.id,
                    "accept": "1",
                    "keterangan": adjCtrl.keteranganApp.text,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    "status": data.status
                  };
                  /////////
                  var dataUptAbs = {
                    "status": data.status,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    "id_shift": data.idShift,
                    "jam_masuk": data.jamMasuk,
                    "jam_pulang": data.jamPulang
                  };
                  adjCtrl.appAbs(dataUptApp, dataUptAbs);
                },
              ),
              CsElevatedButton(
                fontsize: 15,
                label: 'Reject',
                color: Colors.redAccent[700]!,
                onPressed: () {
                  var dataUptApp = {
                    "uid": data.id,
                    "accept": "0",
                    "keterangan": adjCtrl.keteranganApp.text,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    "status": data.status
                  };
                  adjCtrl.appAbs(dataUptApp, {});
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
