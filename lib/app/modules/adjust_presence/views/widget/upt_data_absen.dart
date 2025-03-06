import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../data/helper/const.dart';
import '../../../../data/model/req_app_model.dart';
import '../../../../services/service_api.dart';
import '../../../shared/elevated_button.dart';
import '../../../shared/text_field.dart';

class UptDataAbsen extends StatelessWidget {
  UptDataAbsen({super.key, required this.data, this.dataUser});
  final ReqApp data;
  final Data? dataUser;
  final adjCtrl = Get.put(AdjustPresenceController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${data.jamAbsenMasuk!} (IN)',
                      style: titleTextStyle,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
                height: 70,
                width: 70,
                child: WidgetZoom(
                  heroAnimationTag: 'fotoMasuk',
                  zoomWidget:
                      Image.network('${ServiceApi().baseUrl}${data.fotoMasuk}'),
                )),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.clock_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${data.jamAbsenPulang!} (OUT)',
                      style: titleTextStyle,
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
                height: 70,
                width: 70,
                child: WidgetZoom(
                  heroAnimationTag: 'fotoPulang',
                  zoomWidget: Image.network(
                      '${ServiceApi().baseUrl}${data.fotoPulang}'),
                )),
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
        Visibility(
          visible: data.accept == "" && dataUser!.level == "1" ? true : false,
          child: SizedBox(
              height: 45,
              child: CsTextField(
                  controller: adjCtrl.keteranganApp, label: 'Keterangan')),
        ),
        const SizedBox(
          height: 5,
        ),
        Visibility(
            visible: data.accept == "0" ? true : false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keterangan',
                  style: titleTextStyle.copyWith(fontSize: 18),
                ),
                Text(
                  data.keterangan!,
                  style: subtitleTextStyle,
                ),
              ],
            )),
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

                  //////////
                  var dataUptAbs = {
                    "status": data.status,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    "tgl_pulang": data.tglPulang,
                    "jam_absen_masuk": data.jamAbsenMasuk,
                    "foto_masuk": data.fotoMasuk,
                    "jam_absen_pulang": data.jamAbsenPulang,
                    "foto_pulang": data.fotoPulang,
                    "lat_out": data.latOut,
                    "long_out": data.longOut,
                    "device_info2": data.devInfo
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
