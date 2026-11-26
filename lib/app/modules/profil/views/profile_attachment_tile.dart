import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/container_main_color.dart';

class ProfileAttachmentTile extends StatelessWidget {
  const ProfileAttachmentTile({
    super.key,
    required this.isDark,
    required this.title,
    required this.icon,
    required this.color,
    required this.fileName,
    this.onPressed,
    required this.data,
  });

  final bool isDark;
  final String title;
  final IconData icon;
  final Color color;
  final RxString fileName;
  final VoidCallback? onPressed;
  final String data;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark
            ? const Color(0xFF1E293B).withOpacity(0.78)
            : Colors.white.withOpacity(0.82);

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle:
            data.isNotEmpty
                ? const Text(
                  'Exist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.contentColorBlue),
                )
                : Obx(
                  () => Text(
                    fileName.value.isEmpty ? 'No file yet' : fileName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
        trailing: ContainerMainColor(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          radius: 10,
          child: SizedBox(
            height: 35,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(data.isNotEmpty ? 'Change' : 'Browse'),
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
