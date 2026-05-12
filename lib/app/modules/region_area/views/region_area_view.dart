import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/helper/app_colors.dart';
import '../controllers/region_area_controller.dart';

/// =======================
/// VIEW
/// =======================
class RegionAreaView extends StatelessWidget {
  RegionAreaView({super.key});

  final ctrl = Get.put(RegionAreaController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Region Area"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient(
              context: context,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.regions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Card(
              child: CustomMaterialIndicator(
                onRefresh: () {
                  return ctrl.getRegions();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Icon(Icons.inbox, size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Center(child: Text('Data kosong')),
                  ],
                ),
              ),
            ),
          );
        }

        return CustomMaterialIndicator(
          onRefresh: () {
            return ctrl.getRegions();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: ctrl.regions.length,
              itemBuilder: (context, index) {
                final data = ctrl.regions[index];
            
                return Card(
                  // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: ListTile(
                    title: Text(
                      data['id'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      data['store'] ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ctrl.openDetail(data, context, isDark),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
