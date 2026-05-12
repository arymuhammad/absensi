import 'dart:convert';

import 'package:absensi/app/modules/shared/container_main_color.dart';
import 'package:absensi/app/modules/shared/elevated_button.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/model/cabang_model.dart';

/// =======================
/// CONTROLLER
/// =======================
class RegionAreaController extends GetxController {
  var isLoading = false.obs;
  var cabang = <Cabang>[].obs;
  var regions = <Map<String, dynamic>>[].obs;
  final searchC = TextEditingController();
  var filteredCabang = <Cabang>[].obs;
  var selectedStores = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCabang();
    getRegions();
    filteredCabang.value = cabang;
  }

  Future<List<Cabang>> getCabang() async {
    final response = await ServiceApi().getCabang({});
    cabang.value = response;

    filteredCabang.value = response;

    return cabang.toList();
  }

  void filterStore(String value) {
    if (value.isEmpty) {
      filteredCabang.value = cabang;
    } else {
      filteredCabang.value =
          cabang.where((e) {
            final nama = e.namaCabang?.toLowerCase() ?? '';
            final kode = e.kodeCabang?.toLowerCase() ?? '';
            final keyword = value.toLowerCase();

            return nama.contains(keyword) || kode.contains(keyword);
          }).toList();
    }
  }

  /// =======================
  /// GET REGION
  /// =======================
  Future<void> getRegions() async {
    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("${ServiceApi().baseUrl}region_area"),
        body: {"type": "list_region"},
      );

      final res = jsonDecode(response.body);

      if (res['success']) {
        regions.value = List<Map<String, dynamic>>.from(res['data']);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Detail store
  void openDetail(
    Map<String, dynamic> data,
    BuildContext context,
    bool isDark,
  ) {
    selectedStores.clear();

    searchC.clear();

    filteredCabang.value = cabang;

    if (data['store'] != null && data['store'] != "") {
      selectedStores.value = data['store'].toString().split(',');
    }

    Get.bottomSheet(
      Container(
        height: Get.height * .85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              data['id'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            /// =======================
            /// SEARCH FIELD
            /// =======================
            SizedBox(
              height: 44,
              child: TextField(
                controller: searchC,
                onChanged: filterStore,
                decoration: InputDecoration(
                  hintText: 'Cari store...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffix: IconButton(
                    onPressed: () {
                      searchC.clear();
                      filterStore('');
                    },
                    icon: const Icon(Icons.highlight_remove_rounded, size: 20),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: filteredCabang.length,
                  itemBuilder: (context, index) {
                    final store = filteredCabang[index];

                    return Obx(() {
                      final selected = selectedStores.contains(
                        store.kodeCabang!,
                      );

                      return CheckboxListTile(
                        value: selected,
                        title: Text(store.namaCabang!.capitalize!),
                        subtitle: Text(store.kodeCabang!),
                        onChanged: (val) {
                          if (selected) {
                            selectedStores.remove(store.kodeCabang!);
                          } else {
                            selectedStores.add(store.kodeCabang!);
                          }

                          selectedStores.refresh();
                        },
                      );
                    });
                  },
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ContainerMainColor(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                radius: 30,
                child: CsElevatedButton(
                  onPressed: () => updateStore(data['id']),
                  label: "SAVE",
                  color: Colors.transparent,
                  fontsize: 16,
                  
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// =======================
  /// UPDATE STORE
  /// =======================
  Future<void> updateStore(String id) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await http.post(
        Uri.parse("${ServiceApi().baseUrl}region_area"),
        body: {
          "type": "update_store",
          "id": id,
          "stores": jsonEncode(selectedStores.toList()),
        },
      );

      final res = jsonDecode(response.body);

      Get.back();

      if (res['success']) {
        Get.back();

        Get.snackbar(
          "Sukses",
          "Store berhasil diupdate",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        getRegions();
      } else {
        Get.snackbar(
          "Error",
          res['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
