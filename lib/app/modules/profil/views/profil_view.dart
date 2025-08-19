import 'package:absensi/app/data/helper/app_colors.dart';
import 'package:absensi/app/data/helper/const.dart';
import 'package:absensi/app/data/model/login_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/services/service_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../../data/helper/custom_dialog.dart';
import '../../add_pegawai/controllers/add_pegawai_controller.dart';
import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  ProfilView({super.key, this.listDataUser});
  final auth = Get.find<LoginController>();
  final user = Get.put(AddPegawaiController());
  final Data? listDataUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // const CsBgImg(),
          Container(
            height: 180,
            decoration: const BoxDecoration(color: AppColors.itemsBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 115, left: 8.0, right: 8.0),
            child: Column(
              children: [
                Container(
                  height:
                      130, // sedikit lebih besar dari ukuran ClipOval supaya border terlihat
                  width: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ), // border putih tebal 4
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.black,
                                insetPadding: const EdgeInsets.all(0),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: PhotoView(
                                    imageProvider: NetworkImage(
                                      '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                                    ),
                                    backgroundDecoration: const BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    minScale: PhotoViewComputedScale.contained,
                                    maxScale:
                                        PhotoViewComputedScale.covered * 3,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Image.network(
                                "https://ui-avatars.com/api/?name=${listDataUser!.nama}",
                                fit: BoxFit.cover,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  listDataUser!.nama!,
                  style: titleTextStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listDataUser!.id!, style: subtitleTextStyle),
                    Text(' - ', style: subtitleTextStyle),
                    Text(listDataUser!.levelUser!, style: subtitleTextStyle),
                    Visibility(
                      visible: listDataUser!.idRegion! != "" ? true : false,
                      child: Row(
                        children: [
                          Text(' - ', style: subtitleTextStyle),
                          Text(
                            listDataUser!.idRegion!,
                            style: subtitleTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: 250,
                        child: Card(
                          color: AppColors.contentColorWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              ListTile(
                                title: Text(
                                  'Phone No.',
                                  style: subtitleTextStyle,
                                ),
                                trailing: Text(
                                  listDataUser!.noTelp!,
                                  style: titleTextStyle,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                dense: true,
                              ),
                              const Divider(
                                indent: 15,
                                endIndent: 15,
                                height: 0,
                              ),
                              ListTile(
                                title: Text(
                                  'Registered In',
                                  style: subtitleTextStyle,
                                ),
                                trailing: Text(
                                  listDataUser!.namaCabang!.capitalize!,
                                  style: titleTextStyle,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                dense: true,
                              ),
                              const Divider(
                                indent: 15,
                                endIndent: 15,
                                height: 0,
                              ),
                              ListTile(
                                title: Text(
                                  'Registered At',
                                  style: subtitleTextStyle,
                                ),
                                trailing: Text(
                                  listDataUser!.createdAt != ""
                                      ? listDataUser!.createdAt!.capitalize!
                                      : '-',
                                  style: titleTextStyle,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                dense: true,
                              ),
                              const Divider(
                                indent: 15,
                                endIndent: 15,
                                height: 0,
                              ),
                              ListTile(
                                title: Text(
                                  'Username',
                                  style: subtitleTextStyle,
                                ),
                                trailing: Text(
                                  listDataUser!.username!,
                                  style: titleTextStyle,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                dense: true,
                              ),
                              const Divider(
                                indent: 15,
                                endIndent: 15,
                                height: 0,
                              ),
                              ListTile(
                                title: Text(
                                  'Password',
                                  style: subtitleTextStyle,
                                ),
                                trailing: Text(
                                  '********',
                                  style: titleTextStyle,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                dense: true,
                              ),
                              const Divider(
                                indent: 15,
                                endIndent: 15,
                                height: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          onTap: () {
                            promptDialog(
                              context: context,
                              title: 'LOG OUT',
                              desc: 'Anda yakin ingin keluar?',
                              btnOkOnPress: () => auth.logout(),
                            );
                          },
                          leading: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: bgContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.power_settings_new_sharp,
                              color: Colors.redAccent[700],
                            ),
                          ),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // subtitle: Text(
                          //   'exit app',
                          //   style: TextStyle(
                          //     color: subTitleColor,
                          //     fontSize: 13,
                          //   ),
                          // ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: subTitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card(
                //   color: Colors.transparent,
                //   elevation: 4,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: Container(
                //     height: 220,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10),
                //       image: const DecorationImage(
                //         image: AssetImage('assets/image/bg_card.jpg'),
                //       ),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(19, 19, 19, 0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             'URBAN&CO',
                //             style: titleTextStyle.copyWith(
                //               color: AppColors.contentColorYellow,
                //             ),
                //           ),
                //           const SizedBox(height: 10),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     listDataUser!.nama!,
                //                     style: titleTextStyle.copyWith(
                //                       color: AppColors.contentColorYellow,
                //                       fontSize: 18,
                //                     ),
                //                   ),
                //                   Text(
                //                     listDataUser!.levelUser!,
                //                     style: const TextStyle(
                //                       color: Colors.white,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 20),
                //                   Row(
                //                     children: [
                //                       const Icon(
                //                         FontAwesome.id_badge,
                //                         color: AppColors.contentColorBlue,
                //                         size: 12,
                //                       ),
                //                       const SizedBox(width: 5),
                //                       Text(
                //                         listDataUser!.id!,
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 12,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   const SizedBox(height: 5),
                //                   Row(
                //                     children: [
                //                       const Icon(
                //                         HeroIcons.phone,
                //                         color: AppColors.contentColorBlue,
                //                         size: 12,
                //                       ),
                //                       const SizedBox(width: 5),
                //                       Text(
                //                         listDataUser!.noTelp!,
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 12,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   const SizedBox(height: 5),
                //                   Row(
                //                     children: [
                //                       const Icon(
                //                         HeroIcons.user,
                //                         color: AppColors.contentColorBlue,
                //                         size: 12,
                //                       ),
                //                       const SizedBox(width: 5),
                //                       Text(
                //                         '@${listDataUser!.username!}',
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 12,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                   const SizedBox(height: 5),
                //                   Row(
                //                     children: [
                //                       const Icon(
                //                         HeroIcons.map_pin,
                //                         color: AppColors.contentColorBlue,
                //                         size: 12,
                //                       ),
                //                       const SizedBox(width: 5),
                //                       Text(
                //                         listDataUser!.namaCabang!,
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 12,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //               ClipOval(
                //                 child: SizedBox(
                //                   height: 70,
                //                   width: 70,
                //                   child: WidgetZoom(
                //                     heroAnimationTag: 'customTag',
                //                     zoomWidget: Image.network(
                //                       '${ServiceApi().baseUrl}${listDataUser!.foto!}',
                //                       fit: BoxFit.cover,
                //                       errorBuilder:
                //                           (
                //                             context,
                //                             error,
                //                             stackTrace,
                //                           ) => Image.network(
                //                             "https://ui-avatars.com/api/?name=${listDataUser!.nama}",
                //                             fit: BoxFit.cover,
                //                           ),
                //                       loadingBuilder: (
                //                         context,
                //                         child,
                //                         loadingProgress,
                //                       ) {
                //                         if (loadingProgress == null)
                //                           return child;
                //                         return Center(
                //                           child: CircularProgressIndicator(
                //                             value:
                //                                 loadingProgress
                //                                             .expectedTotalBytes !=
                //                                         null
                //                                     ? loadingProgress
                //                                             .cumulativeBytesLoaded /
                //                                         loadingProgress
                //                                             .expectedTotalBytes!
                //                                     : null,
                //                           ),
                //                         );
                //                       },
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 25,
                      color: AppColors.contentColorWhite,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Profile',
                      style: titleTextStyle.copyWith(
                        fontSize: 18,
                        color: AppColors.contentColorWhite,
                      ),
                    ),
                  ],
                ),
                // IconButton(
                //   onPressed: () {
                //     promptDialog(context, 'Anda yakin ingin keluar?');
                //   },
                //   icon: const Icon(
                //     Iconsax.logout_1_outline,
                //     color: Colors.black,
                //     size: 30,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
