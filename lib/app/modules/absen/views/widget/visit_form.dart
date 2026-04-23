import 'package:absensi/app/modules/absen/controllers/absen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/model/login_model.dart';
import '../../../shared/dropdown_cabang.dart';

// final absC = Get.find<AbsenController>();
Widget buildVisit({
  required BuildContext context,
  required Data? data,
  required AbsenController controller,
  required bool isDark,
}) {
  return Column(
    children: [
      SizedBox(height: 40,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            fillColor: isDark ? Theme.of(context).canvasColor : Colors.white,
            filled: true,
            // isDense: true, // 🔑 biar tinggi tetap rapih
            contentPadding: const EdgeInsets.all(5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  isDark
                      ? BorderSide(color: Colors.white.withOpacity(0.15))
                      : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  isDark
                      ? BorderSide(color: Colors.white.withOpacity(0.15))
                      : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  isDark
                      ? const BorderSide(
                        color: Colors.blueAccent, // 🔥 biar ada feedback focus
                        width: 1.2,
                      )
                      : BorderSide.none,
            ),
            label: const Text('Select one'),
          ),
          value:
              controller.stsAbsenSelected.isEmpty
                  ? null
                  : controller.stsAbsenSelected.value,
          items:
              controller.stsAbsen
                  .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                  .toList(),
          onChanged: (val) {
            if (val != null) {
              controller.stsAbsenSelected.value = val;
            }
          },
        ),
      ),
      const SizedBox(height: 5),
      Obx(
        () => Visibility(
          visible: controller.optVisitVisible.value ? true : false,
          child: SizedBox(
            height: 40,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                fillColor: isDark ? Theme.of(context).canvasColor : Colors.white,
                filled: true,
                // isDense: true, // 🔑 biar tinggi tetap rapih
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
                hintText: 'Select RND / Visit',
              ),
              items:
                  controller.optVisit
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) {
                controller.rndLoc.clear();
                if (val != null) {
                  controller.optVisitSelected.value = val;
                  // controller.getLoc(data);
                }
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Obx(() {
        return Visibility(
          visible:
              controller.optVisitSelected.value == "Research and Development"
                  ? true
                  : false,
          child: SizedBox(height: 40,
            child: TextField(
              controller: controller.rndLoc,
              decoration: InputDecoration(
                fillColor: isDark ? Theme.of(context).canvasColor : Colors.white,
                filled: true,
                // isDense: true, // 🔑 biar tinggi tetap rapih
                contentPadding: const EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      isDark
                          ? BorderSide(color: Colors.white.withOpacity(0.15))
                          : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      isDark
                          ? BorderSide(color: Colors.white.withOpacity(0.15))
                          : BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      isDark
                          ? const BorderSide(
                            color:
                                Colors.blueAccent, // 🔥 biar ada feedback focus
                            width: 1.2,
                          )
                          : BorderSide.none,
                ),
                labelText: 'Mall/City',
                hintText: 'Cth : AEON MALL - SENTUL',
              ),
            ),
          ),
        );
      }),
      Obx(() {
        return Visibility(
          visible:
              controller.optVisitSelected.value == "Store Visit" ? true : false,
          child: CsDropdownCabang(
            context: context,
            isDark: isDark,
            hintText: data!.namaCabang,
            dataUser: data,
            value:
                controller.selectedCabangVisit.value.isEmpty
                    ? null
                    : controller.selectedCabangVisit.value,
          ),

          // FutureBuilder(
          //   future: absC.getCabang(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       var dataCabang = snapshot.data!;
          //       // Pastikan tidak ada duplikat (optional)
          //       var uniqueCabang = <Cabang>[];
          //       var seenKode = <String>{};
          //       for (var cabang in dataCabang) {
          //         if (!seenKode.contains(cabang.kodeCabang)) {
          //           uniqueCabang.add(cabang);
          //           seenKode.add(cabang.kodeCabang!);
          //         }
          //       }
          //       // Validasi value dropdown dengan list dataCabang
          //       final hasValueInItems = uniqueCabang.any(
          //         (e) => e.kodeCabang == absC.selectedCabangVisit.value,
          //       );
          //       final dropdownValue =
          //           hasValueInItems ? absC.selectedCabangVisit.value : null;

          //       return DropdownButtonFormField(
          //         decoration: InputDecoration(
          //           fillColor: Colors.white,
          //         filled: true,
          //         isDense: true, // 🔑 biar tinggi tetap rapih
          //         contentPadding: const EdgeInsets.all(5),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none,
          //         ),
          //         enabledBorder: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none,
          //         ),
          //         focusedBorder: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //           borderSide: BorderSide.none,
          //         ),
          //           hintText: data!.namaCabang,
          //         ),
          //         value: dropdownValue,
          //         onChanged: (val) async{
          //           if (val == null) return;
          //           absC.selectedCabangVisit.value = val;

          //           for (var cabang in uniqueCabang) {
          //             if (cabang.kodeCabang == val) {
          //               absC.lat.value = cabang.lat!;
          //               absC.long.value = cabang.long!;
          //               break;
          //             }
          //           }
          //           absC.isLoading.value = true;
          //           // loadingDialog('verify your location', '');
          //           await absC.getLoc(data);
          //           // Get.back();
          //         },
          //         items:
          //             uniqueCabang
          //                 .map(
          //                   (e) => DropdownMenuItem(
          //                     value: e.kodeCabang,
          //                     child: Text(e.namaCabang.toString()),
          //                   ),
          //                 )
          //                 .toList(),
          //       );
          //     } else if (snapshot.hasError) {
          //       return Text('${snapshot.error}');
          //     }
          //     return const CupertinoActivityIndicator();
          //   },
          // ),
        );
      }),
    ],
  );
}
