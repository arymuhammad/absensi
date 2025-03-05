import 'package:absensi/app/data/model/req_app_model.dart';
import 'package:absensi/app/modules/adjust_presence/controllers/adjust_presence_controller.dart';
import 'package:absensi/app/modules/shared/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../../../data/helper/const.dart';
import '../../../../services/service_api.dart';
import '../../../shared/elevated_button.dart';

class UptMasukPulang extends StatelessWidget {
  UptMasukPulang({super.key, required this.data});
  final ReqApp data;
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
                      data.status == "update_masuk"
                          ? data.jamAbsenMasuk!
                          : data.jamAbsenPulang!,
                      style: titleTextStyle,
                    ),
                  ],
                ),
                Visibility(
                  visible: data.status == "update_masuk" ? false : true,
                  child: Row(
                    children: [
                      const Icon(Iconsax.calendar_2_outline),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data.tglPulang!,
                        style: titleTextStyle,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
                height: 70,
                width: 70,
                child: WidgetZoom(
                  heroAnimationTag: data.status == "update_masuk"
                      ? 'fotoMasuk'
                      : 'fotoPulang',
                  zoomWidget: Image.network(
                      '${ServiceApi().baseUrl}${data.status == "update_masuk" ? data.fotoMasuk : data.fotoPulang}'),
                )),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Visibility(
          visible: data.accept == "" ? true : false,
          child: SizedBox(
              height: 45,
              child: CsTextField(
                  controller: adjCtrl.keteranganApp, label: 'Keterangan')),
        ),
        const SizedBox(height: 5,),
        Visibility(
            visible: data.accept == "0" ? true : false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keterangan', style: titleTextStyle.copyWith(fontSize: 18),),
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
                    "uid":data.id,
                    "accept": "1",
                    "keterangan": adjCtrl.keteranganApp.text,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    "status": data.status
                  };
                  /////////
                  var keyJamAbsen = "";
                  var keyFotoAbsen = "";
                  if (data.status == "update_masuk") {
                    keyJamAbsen = "jam_absen_masuk";
                    keyFotoAbsen = "foto_masuk";
                  } else {
                    keyJamAbsen = "jam_absen_pulang";
                    keyFotoAbsen = "foto_pulang";
                  }
                  //////////
                  var dataUptAbs = {
                    "status": data.status,
                    "id_user": data.idUser,
                    "tgl_masuk": data.tglMasuk,
                    keyJamAbsen: data.status == "update_masuk"
                        ? data.jamAbsenMasuk
                        : data.jamAbsenPulang,
                    keyFotoAbsen: data.status == "update_masuk"
                        ? data.fotoMasuk
                        : data.fotoPulang,
                    "tgl_pulang": data.tglPulang,
                    "lat_out":data.latOut,
                    "long_out":data.longOut,
                    "device_info2":data.devInfo
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
                    "uid":data.id,
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
