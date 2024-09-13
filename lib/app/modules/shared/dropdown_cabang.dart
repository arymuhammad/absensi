import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../absen/controllers/absen_controller.dart';

class CsDropdownCabang extends StatelessWidget {
  final String? hintText;
  final String? value;
  CsDropdownCabang({super.key, this.hintText, this.value});

  final absC = Get.find<AbsenController>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: absC.getCabang(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var dataCabang = snapshot.data!;
          return DropdownButtonFormField(
            decoration: InputDecoration(
                border: const OutlineInputBorder(), hintText: hintText),
            value: value,
            onChanged: (data) {
              absC.selectedCabang.value = data!;

              for (int i = 0; i < dataCabang.length; i++) {
                if (dataCabang[i].kodeCabang == data) {
                  absC.lat.value = dataCabang[i].lat!;
                  absC.long.value = dataCabang[i].long!;
                }
              }
            },
            items: dataCabang
                .map((e) => DropdownMenuItem(
                    value: e.kodeCabang, child: Text(e.namaCabang.toString())))
                .toList(),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CupertinoActivityIndicator();
      },
    );
  }
}
