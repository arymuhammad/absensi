import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:absensi/app/Repo/service_api.dart';
import 'package:absensi/app/model/level_model.dart';
import 'package:absensi/app/modules/login/controllers/login_controller.dart';
import 'package:absensi/app/modules/login/views/login_view.dart';
import 'package:absensi/app/modules/profil/views/update_password.dart';
import 'package:absensi/app/routes/app_pages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helper/loading_dialog.dart';
import '../../../model/cabang_model.dart';
import '../../../model/cek_user_model.dart';

class AddPegawaiController extends GetxController {
  late TextEditingController nip;
  late TextEditingController name;
  late TextEditingController username;
  late TextEditingController pass;
  late TextEditingController store;
  late TextEditingController telp;
  late TextEditingController level;

  final FocusNode focusNodecabang = FocusNode();
  final FocusNode focusNodelevel = FocusNode();
  final GlobalKey autocompleteKey = GlobalKey();
  final GlobalKey autocompleteKeyLevel = GlobalKey();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  FilePickerResult? fileResult;
  // File file = File("zz");
  Uint8List webImage = Uint8List(0);
  String fileName = "";

  var cabang = <Cabang>[].obs;
  var levelUser = <Level>[].obs;
  var selectedCabang = "".obs;
  var selectedLevel = "".obs;
  var cekDataUser = <CekUser>[].obs;
  @override
  void onInit() {
    super.onInit();
    nip = TextEditingController();
    name = TextEditingController();
    username = TextEditingController();
    pass = TextEditingController();
    store = TextEditingController();
    telp = TextEditingController();
    level = TextEditingController();

    getCabang();
    getLevel();
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

  Future<List<Cabang>> getCabang() async {
    final response = await ServiceApi().getCabang();
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
      // File file = File(imageWeb!.files.single.toString());
      // if (fileResult != null) {
      //   fileName = fileResult!.files.first.name;
      //   webImage = fileResult!.files.single.bytes!;
      //   // print(fileResult!);
      //   // print(fileName);
      //   update();
      // }
      // final ImagePicker picker = ImagePicker();
      // XFile? image = await picker.pickImage(source: ImageSource.gallery);
      // if (image != null) {
      //   var f = await image.readAsBytes();
      //   // setState(() {
      //   file = File("a");
      //   webImage = f;
      //   update();
      //   // });
      // } else {
      //   showToast("No file selected");
      // }
    } else {
      image = await picker.pickImage(source: ImageSource.gallery);
      print(image!.name);
      print(image!.path);
      if (image != null) {
        update();
      } else {
        print(image);
      }
    }
  }

  addUpdatePegawai(String mode, List<dynamic> dataUser) async {
    // image = File(image!.path);
    // print('add pegawai');
    Random random = Random();
    int randomNumber = random.nextInt(100);
    if (mode == "add") {
      // if (image != null && image!.name.split(".").last == "jpg" ||
      //     image != null && image!.name.split(".").last == "jpeg" ||
      //     image != null && image!.name.split(".").last == "png" ||
      //     webImage.isNotEmpty) {
      var data = {
        "status": mode,
        "id": '${selectedCabang.value}000$randomNumber',
        "username": username.text,
        "password": pass.text,
        "nama": name.text,
        "no_telp": telp.text,
        "kode_cabang": selectedCabang.value,
        "level": selectedLevel.value,
        "foto": kIsWeb ? fileResult!.files.single : File(image!.path.toString())
      };
      // print(data);
      dialogMsgScsUpd("Sukses", "Data berhasil disimpan");
      await ServiceApi().addUpdatePegawai(data);
      selectedCabang.value = "";
      username.clear();
      store.clear();
      level.clear();
      pass.clear();
      name.clear();
      telp.clear();
      selectedLevel.value = "";
      // } else {
      //   dialogMsg("Terjadi Kesalahan",
      //       "Ekstensi file tidak diizinkan.\nHarap memilih file dengan format\njpg, jpeg, png");
      // }
    } else {
      if (image != null && image!.name.split(".").last == "jpg" ||
          image != null && image!.name.split(".").last == "jpeg" ||
          image != null && image!.name.split(".").last == "png" ||
          fileResult != null) {
        var data = {
          "status": mode,
          "id": dataUser[0],
          "nama": name.text != "" ? name.text : dataUser[1],
          "no_telp": telp.text != "" ? telp.text : dataUser[3],
          "kode_cabang":
              selectedCabang.value != "" ? selectedCabang.value : dataUser[8],
          "level":
              selectedLevel.value != "" ? selectedLevel.value : dataUser[9],
          "foto":
              kIsWeb ? fileResult!.files.single : File(image!.path.toString())
        };
        // print(data);
        dialogMsgScsUpd("Sukses", "Data berhasil disimpan");
        await ServiceApi().addUpdatePegawai(data);
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
        dialogMsgScsUpd("Sukses", "Data berhasil disimpan");
        await ServiceApi().addUpdatePegawai(data);
        // Get.back();
      }
    }
    // print(data);

    // update();
  }

  void cekUser() async {
    var data = {"no_telp": telp.text};
    if (telp.text != "") {
      loadingDialog("Sedang mencari data user", "");
      final response = await ServiceApi().cekUser(data);
      cekDataUser.value = response;
      Get.back();
      if (cekDataUser.isNotEmpty) {
        telp.clear();
        // print(cekDataUser.length);
        Get.to(() => UpdatePassword(), arguments: {
          "id_user": cekDataUser[0].id,
          "username": cekDataUser[0].username,
          "nama": cekDataUser[0].nama,
          "no_telp": cekDataUser[0].notelp,
          "foto": cekDataUser[0].foto,
        });
      } else {
        dialogMsg("Terjadi Kesalahan",
            "Tidak ditemukan user dengan No Telp ${telp.text}. Pastikan No Telp yang diinput sudah sesuai");
      }
    } else {
      showToast("Anda harus mengisi kolom No Telp");
    }
  }

  updatePassword(String id, String username) async {
    var data = {"id": id, "username": username, "password": pass.text};
    if (pass.text != "") {
      dialogMsgAbsen("Sukses",
          "Password berhasil diperbarui\nSilahkan melakukan login ulang");
      loadingDialog("Memperbarui data user...", "");
      final response = await ServiceApi().updatePasswordUser(data);
      cekDataUser.value = response;
      Get.back();
      if (cekDataUser.isNotEmpty) {
        // print(cekDataUser.length);
      } else {
        dialogMsg(
            "Terjadi Kesalahan", "Tidak dapat memperbarui password. Coba lagi");
      }
    } else {
      showToast("Anda belum mengisi kolom Password");
    }
  }
}
