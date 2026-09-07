import 'package:absensi/app/data/helper/custom_dialog.dart';
import 'package:flutter/material.dart';

Widget liveRemove(
  BuildContext context,
  String desc,
  String title,
  dynamic Function()? onPress,
) {
  return SizedBox(
    height: 30,
    child: PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
      tooltip: 'Opsi',
      onSelected: (value) {
        if (value == 'delete') {
          promptDialog(
            context: context,
            desc: desc,
            title: title,
            btnOkOnPress: onPress,
          );
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text('Hapus pengajuan', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
    ),
  );
}
