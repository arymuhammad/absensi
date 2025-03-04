import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../../data/helper/const.dart';
import '../../../shared/elevated_button.dart';

class UptShift extends StatelessWidget {
  UptShift({super.key, required this.data});
  final ReqApp data;
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS',
                  style: subtiteTextStyle,
                ),
                Text(
                  data.status!.replaceAll('_', ' ').toUpperCase(),
                  style: titeTextStyle,
                ),
                Row(
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      data.namaShift!,
                      style: titeTextStyle,
                    ),
                  ],
                )
              ],
            ),
            // SizedBox(
            //     height: 70,
            //     width: 70,
            //     child: WidgetZoom(
            //       heroAnimationTag:
            //           data.status == "update_masuk" ? 'fotoMasuk' : 'fotoPulang',
            //       zoomWidget: Image.network(
            //           '${ServiceApi().baseUrl}${data.status == "update_masuk" ? data.fotoMasuk : data.fotoPulang}'),
            //     )),
          ],
        ),
        const Divider(
          thickness: 2,
        ),
        Visibility(
          visible: data.accept == "" ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CsElevatedButton(
                fontsize: 15,
                label: 'Accept',
                color: Colors.greenAccent[700]!,
                onPressed: () {
                  var dataUptApp = {
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
                    "jam_masuk":data.jamMasuk,
                    "jam_pulang":data.jamPulang
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
