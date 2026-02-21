import 'package:absensi/app/data/model/login_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/cabang_model.dart';
import '../absen/controllers/absen_controller.dart';

class CsDropdownCabang extends StatelessWidget {
  final String? hintText;
  final String? value;
  final Data? dataUser;
  CsDropdownCabang({super.key, this.hintText, this.value, this.dataUser});

  final absC = Get.find<AbsenController>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: absC.getCabang(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var dataCabang = snapshot.data!;
          // Pastikan tidak ada duplikat (optional)
          var uniqueCabang = <Cabang>[];
          var seenKode = <String>{};
          for (var cabang in dataCabang) {
            if (!seenKode.contains(cabang.kodeCabang)) {
              uniqueCabang.add(cabang);
              seenKode.add(cabang.kodeCabang!);
            }
          }

          // Validasi value dropdown dengan list dataCabang
          final hasValueInItems = uniqueCabang.any(
            (e) => e.kodeCabang == value,
          );
          final dropdownValue = hasValueInItems ? value : null;

          return SizedBox(
            height: 40,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true, // 🔑 biar tinggi tetap rapih
                contentPadding: const EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: hintText,
              ),
              value: dropdownValue,
              onChanged: (data) async {
                if (data == null) return;
                // if (dataUser!.visit == "1") {
                //   absC.selectedCabangVisit.value = data;
                // } else {
                //   absC.selectedCabang.value = data;
                // }
                final cabang = uniqueCabang.firstWhere(
                  (e) => e.kodeCabang == data,
                );

                absC.changeCabang(cabang, dataUser!);
                // for (int i = 0; i < uniqueCabang.length; i++) {
                //   if (uniqueCabang[i].kodeCabang == data) {
                //     absC.lat.value = uniqueCabang[i].lat!;
                //     absC.long.value = uniqueCabang[i].long!;
                //     break;
                //   }
                // }
                // absC.lastZoomMode = ""; // reset supaya zoom pasti trigger
                // absC.isLoading.value = true;
                // await absC.getLoc(dataUser!);
              },
              items:
                  uniqueCabang
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.kodeCabang,
                          child: Text(e.namaCabang.toString()),
                        ),
                      )
                      .toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CupertinoActivityIndicator();
      },
    );
  }
}
