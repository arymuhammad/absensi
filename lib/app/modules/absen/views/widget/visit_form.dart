import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/model/cabang_model.dart';
import '../../../../data/model/login_model.dart';

final absC = Get.find<AbsenController>();
Widget buildVisit({required Data? data}) {
  return Column(
    children: [
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          label: Text('Select one'),
        ),
        value:
            absC.stsAbsenSelected.isEmpty
                ? null
                : absC.stsAbsenSelected.value,
        items:
            absC.stsAbsen
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
        onChanged: (val) {
          if (val != null) {
            absC.stsAbsenSelected.value = val;
          }
        },
      ),
      const SizedBox(height: 5),
      Obx(
        () => Visibility(
          visible: absC.optVisitVisible.value ? true : false,
          child: DropdownButtonFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select RND / Visit',
            ),
            items:
                absC.optVisit
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
            onChanged: (val) {
              absC.rndLoc.clear();
              if (val != null) {
                absC.optVisitSelected.value = val;
              }
            },
          ),
        ),
      ),
      const SizedBox(height: 5),
      Obx(() {
        return Visibility(
          visible:
              absC.optVisitSelected.value == "Research and Development"
                  ? true
                  : false,
          child: TextField(
            controller: absC.rndLoc,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mall/City',
              hintText: 'Cth : AEON MALL - SENTUL',
            ),
          ),
        );
      }),
      Obx(() {
        return Visibility(
          visible: absC.optVisitSelected.value == "Store Visit" ? true : false,
          child: FutureBuilder(
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
                  (e) => e.kodeCabang == absC.selectedCabangVisit.value,
                );
                final dropdownValue =
                    hasValueInItems ? absC.selectedCabangVisit.value : null;

                return DropdownButtonFormField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: data!.namaCabang,
                  ),
                  value: dropdownValue,
                  onChanged: (val) {
                    if (val == null) return;
                    absC.selectedCabangVisit.value = val;

                    for (var cabang in uniqueCabang) {
                      if (cabang.kodeCabang == val) {
                        absC.lat.value = cabang.lat!;
                        absC.long.value = cabang.long!;
                        break;
                      }
                    }
                    absC.isLoading.value = true;
                    absC.getLoc(data);
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
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CupertinoActivityIndicator();
            },
          ),
        );
      }),
    ],
  );
}
