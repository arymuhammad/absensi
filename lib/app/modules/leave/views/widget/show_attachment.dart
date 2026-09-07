import 'package:absensi/app/data/helper/helper_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../data/helper/custom_dialog.dart';
import '../../../../data/model/req_leave_model.dart';
import '../../../../services/service_api.dart';

showAttchment(BuildContext context, ReqLeaveModel leave) {
  final files = parseLampiran(leave.attachFile);

  if (files.isEmpty) {
    showToast("Tidak ada lampiran");
    return;
  }

  showDialog(
    context: context,
    builder:
        (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  // print(
                  //   '${ServiceApi().baseUrl}${files[index]}',
                  // );
                  return PhotoView(
                    imageProvider: NetworkImage(
                      '${ServiceApi().baseUrl}${files[index]}',
                    ),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Gagal memuat lampiran',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                },
              ),

              Positioned(
                top: 35,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

              if (files.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Geser untuk melihat ${files.length} lampiran',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
  );
}
