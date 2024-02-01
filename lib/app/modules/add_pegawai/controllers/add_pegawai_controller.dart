import 'dart:io';
import 'dart:math';

import 'package:absensi/app/services/service_api.dart';
import 'package:absensi/app/model/level_model.dart';
import 'package:absensi/app/modules/profil/views/update_password.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:xml/xml.dart' as xml;
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helper/loading_dialog.dart';
import '../../../model/cabang_model.dart';
import '../../../model/cek_user_model.dart';
import '../../../model/foto_profil_model.dart';

class AddPegawaiController extends GetxController {
  late TextEditingController nip, name, username, pass, store, telp, level;
  final FocusNode focusNodecabang = FocusNode();
  final FocusNode focusNodelevel = FocusNode();
  final GlobalKey autocompleteKeyBrand = GlobalKey();
  final GlobalKey autocompleteKey = GlobalKey();
  final GlobalKey autocompleteKeyLevel = GlobalKey();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  FilePickerResult? fileResult;
  File file = File("zz");
  Map<String, dynamic> imgUpl = {};
  Uint8List webImage = Uint8List(0);
  String fileName = "";

  var cabang = <Cabang>[].obs;
  var levelUser = <Level>[].obs;
  var selectedCabang = "".obs;
  var selectedLevel = "".obs;
  var cekDataUser = <CekUser>[].obs;
  var fotoProfil = "".obs;
  var newPhone = "".obs;
  var listBrand = <Cabang>[].obs;
  var brandCabang = "".obs;
  var downloadProgress = 0.0.obs;
  var updateList = [];
  var currVer = "";
  var latestVer = "";
  @override
  void onInit() async {
    super.onInit();
    nip = TextEditingController();
    name = TextEditingController();
    username = TextEditingController();
    pass = TextEditingController();
    store = TextEditingController();
    telp = TextEditingController();
    level = TextEditingController();
    getBrandCabang();
    getLevel();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      // String appName = packageInfo.appName;
      // String packageName = packageInfo.packageName;
      currVer = packageInfo.version;
      // String buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void onClose() {
    super.dispose();
    nip.dispose();
    name.dispose();
    username.dispose();
    pass.dispose();
    store.dispose();
    telp.dispose();
    level.dispose();
  }

  getBrandCabang() async {
    final response = await ServiceApi().getBrandCabang();
    return listBrand.value = response;
  }

  checkForUpdate(context, status) async {
    if (status != "onInit") {
      loadingDialog("Memeriksa pembaruan...", "");
    }

    try {
      final readDoc = await http
          .get(Uri.parse('http://103.156.15.60/update apk/updateLog.xml'));

      final response = await http
          .head(Uri.parse('http://103.156.15.60/update apk/absensiApp.apk'))
          .timeout(const Duration(seconds: 3));
      Get.back();
      if (response.statusCode == 200) {
        //parsing readDoc
        final document = xml.XmlDocument.parse(readDoc.body);
        final itemsNode = document.findElements('items').first;
        final updates = itemsNode.findElements('update');
        latestVer = itemsNode.findElements('versi').first.innerText;
        //start looping item on readDoc
        updateList.clear();
        for (final listUpdates in updates) {
          final name = listUpdates.findElements('name').first.innerText;
          final desc = listUpdates.findElements('desc').first.innerText;
          final icon = listUpdates.findElements('icon').first.innerText;
          final color = listUpdates.findElements('color').first.innerText;

          updateList
              .add({'name': name, 'desc': desc, 'icon': icon, 'color': color});
        }
        //end loop item on readDoc
        if (latestVer == currVer) {
          // Get.back();
          succesDialog(context, "N", "Tidak ada pembaruan sistem");
          // dialogMsgScsUpd("", "Tidak ada pembaruan sistem");
        } else {
          Get.defaultDialog(
              radius: 2,
              onWillPop: () async {
                return false;
              },
              title: 'Pembaruan Tersedia',
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apa yang baru',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  for (var i in updateList)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              IconData(int.parse(i['icon']),
                                  fontFamily: 'MaterialIcons'),
                              color: Color(int.parse(i['color'])),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text('${i['name']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        Text(
                          i['desc'],
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )
                ],
              ),
              
              textConfirm: 'Unduh Pembaruan',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back(closeOverlays: true);
                try {
                  Get.defaultDialog(
                      title: 'Pembaruan perangkat lunak',
                      radius: 2,
                      barrierDismissible: false,
                      onWillPop: () async {
                        return false;
                      },
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text('Mengunduh pembaruan...'),
                          Obx(
                            () => Text('${(downloadProgress.value).toInt()}%'),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(
                            () => LinearPercentIndicator(
                                lineHeight: 10.0,
                                percent: downloadProgress.value / 100,
                                backgroundColor: Colors.grey[220],
                                progressColor: Colors.blue,
                                barRadius: const Radius.circular(5)),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ));
                  //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
                  OtaUpdate()
                      .execute(
                    'http://103.156.15.60/update apk/absensiApp.apk',
                    // OPTIONAL
                    // destinationFilename: '/',
                    //OPTIONAL, ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
                    // sha256checksum:
                    //     "d6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478",
                  )
                      .listen(
                    (OtaEvent event) {
                      downloadProgress.value = double.parse(event.value!);
                    },
                    // onError: errorHandle(Error()),
                    onDone: () => Get.back(),
                  );
                } on http.ClientException catch (e) {
                  print('Failed to make OTA update. Details: $e');
                }
              });
        }
      } else {
        Get.defaultDialog(
            title: 'Pesan',
            middleText:
                'Tidak ada pembaruan aplikasi. \nSistem anda sudah yang terbaru',
            onCancel: () => Get.back(),
            textCancel: 'Tutup');
      }
    } on SocketException catch (e) {
      Get.back(closeOverlays: true);
      Get.defaultDialog(
        title: e.toString(),
        middleText: 'Periksa koneksi internet anda',
        textConfirm: 'Refresh',
        confirmTextColor: Colors.white,
        onConfirm: () {
          checkForUpdate(context, "");
          Get.back(closeOverlays: true);
        },
      );
    }
  }

  Future<List<Cabang>> getCabang() async {
    var data = {"brand": brandCabang.value};
    final response = await ServiceApi().getCabang(data);
    return cabang.value = response;
  }

  Future<List<Level>> getLevel() async {
    final response = await ServiceApi().getLevel();
    return levelUser.value = response;
  }

  void uploadImageProfile() async {
    if (kIsWeb) {
      fileResult = await FilePicker.platform.pickFiles(
          withReadStream: true,
          // // this will return PlatformFile object with read stream
          allowCompression: true);
    } else {
      image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        update();
      } else {}
    }
  }

  addUpdatePegawai(context, String mode, List<dynamic> dataUser) async {
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final response = await ServiceApi().getUser();
    cekDataUser.value = response;

    var lstUser = [];
    cekDataUser.map((e) {
      lstUser.add(e.username!);
    }).toList();
    var lstPhone = [];
    cekDataUser.map((e) {
      lstPhone.add(e.notelp!);
    }).toList();
    if (mode == "add") {
      if (selectedCabang.isNotEmpty &&
          username.text != "" &&
          pass.text != "" &&
          name.text != "" &&
          telp.text != "" &&
          selectedCabang.isNotEmpty &&
          selectedLevel.isNotEmpty) {
        if (image != null && image!.name.split(".").last == "jpg" ||
            image != null && image!.name.split(".").last == "jpeg" ||
            image != null && image!.name.split(".").last == "png" ||
            fileResult != null) {
          var data = {
            "status": mode,
            "id": '${selectedCabang.value}000$randomNumber',
            "username": username.text,
            "password": pass.text,
            "nama": name.text,
            "no_telp": telp.text,
            "kode_cabang": selectedCabang.value,
            "level": selectedLevel.value,
            "foto":
                kIsWeb ? fileResult!.files.single : File(image!.path.toString())
          };

          if (lstUser.contains(username.text) && lstPhone.contains(telp.text)) {
            dialogMsg("",
                "Username dan No Telp sudah terdaftar\nSilahkan ubah Username dan No Telp ");
          } else if (lstUser.contains(username.text)) {
            dialogMsg("",
                "Username sudah terdaftar\nSilahkan ubah dengan Username lain");
          } else if (lstPhone.contains(telp.text)) {
            dialogMsg("",
                "No Telp ini sudah terdaftar pada akun lain\nSilahkan masukkan No Telp lain");
          } else {
            succesDialog(context, "N", "Data berhasil disimpan");

            await ServiceApi().addUpdatePegawai(data);
            selectedCabang.value = "";
            username.clear();
            store.clear();
            level.clear();
            pass.clear();
            name.clear();
            telp.clear();
            selectedLevel.value = "";
            brandCabang.value = "";
            lstUser.clear();
            lstPhone.clear();
          }
        } else {
          var data = {
            "status": mode,
            "id": '${selectedCabang.value}000$randomNumber',
            "username": username.text,
            "password": pass.text,
            "nama": name.text,
            "no_telp": telp.text,
            "kode_cabang": selectedCabang.value,
            "level": selectedLevel.value,
          };
          if (lstUser.contains(username.text) && lstPhone.contains(telp.text)) {
            dialogMsg("",
                "Username dan No Telp sudah terdaftar\nSilahkan ubah Username dan No Telp ");
          } else if (lstUser.contains(username.text)) {
            dialogMsg("",
                "Username sudah terdaftar\nSilahkan ubah dengan Username lain");
          } else if (lstPhone.contains(telp.text)) {
            dialogMsg("",
                "No Telp ini sudah terdaftar\nSilahkan masukkan No Telp lain");
          } else {
            dialogMsgScsUpd(
                "Sukses", "Data berhasil disimpan. Silahkan login untuk masuk");
            await ServiceApi().addUpdatePegawai(data);
            selectedCabang.value = "";
            username.clear();
            store.clear();
            level.clear();
            pass.clear();
            name.clear();
            telp.clear();
            selectedLevel.value = "";
            brandCabang.value = "";
            lstUser.clear();
            lstPhone.clear();
          }
        }
      } else {
        dialogMsg("Kesalahan", "Harap mengisi data pada semua kolom");
      }
    } else {
      if (image != null && image!.name.split(".").last == "jpg" ||
          image != null && image!.name.split(".").last == "jpeg" ||
          image != null && image!.name.split(".").last == "png" ||
          fileResult != null) {
        var data = {
          "status": mode,
          "id": dataUser[0],
          "username": dataUser[10],
          "nama": name.text != "" ? name.text : dataUser[1],
          "no_telp": telp.text != "" ? telp.text : dataUser[3],
          "kode_cabang":
              selectedCabang.value != "" ? selectedCabang.value : dataUser[8],
          "level":
              selectedLevel.value != "" ? selectedLevel.value : dataUser[9],
          "foto":
              kIsWeb ? fileResult!.files.single : File(image!.path.toString())
        };

        if (lstPhone.contains(telp.text)) {
          dialogMsg("",
              "No Telp ini sudah terdaftar\nSilahkan masukkan No Telp lain");
        } else {
          dialogMsgScsUpd("Sukses", "Data berhasil disimpan");
          await ServiceApi().addUpdatePegawai(data);
          newPhone.value = telp.text;

          var idUser = {"id": dataUser[0]};
          FotoProfil foto = await ServiceApi().getFotoProfil(idUser);
          SharedPreferences pref = await SharedPreferences.getInstance();
          await pref.setString("fotoProfil", foto.foto!);
          fotoProfil.value = pref.getString("fotoProfil")!;
          selectedCabang.value = "";
          username.clear();
          store.clear();
          level.clear();
          pass.clear();
          name.clear();
          telp.clear();
          selectedLevel.value = "";
          brandCabang.value = "";
          lstPhone.clear();
        }
        // Get.back();
      } else {
        var data = {
          "status": mode,
          "id": dataUser[0],
          "nama": name.text != "" ? name.text : dataUser[1],
          "no_telp": telp.text != "" ? telp.text : dataUser[3],
          "kode_cabang":
              selectedCabang.value != "" ? selectedCabang.value : dataUser[8],
          "level": selectedLevel.value != "" ? selectedLevel.value : dataUser[9]
        };
        if (lstPhone.contains(telp.text)) {
          dialogMsg("",
              "No Telp ini sudah terdaftar\nSilahkan masukkan No Telp lain");
        } else {
          dialogMsgScsUpd("Sukses", "Data berhasil disimpan");
          await ServiceApi().addUpdatePegawai(data);
          newPhone.value = telp.text;

          selectedCabang.value = "";
          username.clear();
          store.clear();
          level.clear();
          pass.clear();
          name.clear();
          telp.clear();
          selectedLevel.value = "";
          brandCabang.value = "";
          lstPhone.clear();
        }
      }
    }
  }

  void cekUser(context) async {
    var data = {"no_telp": telp.text};
    if (telp.text != "") {
      loadingDialog("Sedang mencari data user", "");
      final response = await ServiceApi().cekUser(data);
      cekDataUser.value = response;
      Get.back();
      if (cekDataUser.isNotEmpty) {
        telp.clear();

        Get.to(() => UpdatePassword(), arguments: {
          "id_user": cekDataUser[0].id,
          "username": cekDataUser[0].username,
          "nama": cekDataUser[0].nama,
          "no_telp": cekDataUser[0].notelp,
          "foto": cekDataUser[0].foto,
        });
      } else {
        failedDialog(context, "Peringatan",
            "Tidak ditemukan user dengan No Telp ${telp.text}. Pastikan No Telp yang diinput sudah sesuai");
      }
    } else {
      showToast("Anda harus mengisi kolom No Telp");
    }
  }

  updatePassword(context, String id, String username) async {
    var data = {"id": id, "username": username, "password": pass.text};
    if (pass.text != "") {
      loadingDialog("Memperbarui data user...", "");
      final response = await ServiceApi().updatePasswordUser(data);
      Future.delayed(Duration.zero, () {
        succesDialog(context, "N",
            "Password berhasil diperbarui\nSilahkan melakukan login ulang");
      });
      cekDataUser.value = response;
      pass.clear();
      Get.back();
      if (cekDataUser.isNotEmpty) {
      } else {
        dialogMsg(
            "Terjadi Kesalahan", "Tidak dapat memperbarui password. Coba lagi");
      }
    } else {
      showToast("Anda belum mengisi kolom Password");
    }
  }
}
