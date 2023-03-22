import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:absensi/app/Repo/service_api.dart';
import 'package:absensi/app/model/level_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../helper/toast.dart';
import '../../../model/cabang_model.dart';
import '../../../model/cabang_model.dart';

class AddPegawaiController extends GetxController {
  late TextEditingController nip;
  late TextEditingController name;
  late TextEditingController username;
  late TextEditingController pass;
  late TextEditingController store;
  late TextEditingController telp;
  late TextEditingController level;
  late TextEditingController fileFoto;
  final FocusNode focusNodecabang = FocusNode();
  final FocusNode focusNodelevel = FocusNode();
  final GlobalKey autocompleteKey = GlobalKey();
  final GlobalKey autocompleteKeyLevel = GlobalKey();
  final ImagePicker picker = ImagePicker();
  XFile? image;

  File? pathfileBanner;
  File? pathfileProposal;
  var cabang = <Cabang>[].obs;
  var levelUser = <Level>[].obs;
  var selectedCabang = "".obs;
  var selectedLevel = "".obs;
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
    fileFoto = TextEditingController();
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
    fileFoto.dispose();
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
    image = await picker.pickImage(source: ImageSource.gallery);
    print(image!.name);
    print(image!.path);
    if (image != null) {
      update();
    } else {
      print(image);
    }
  }

  addUpdatePegawai(String mode, List<dynamic> dataUser) async {
    // image = File(image!.path);
    // print('add pegawai');
    Random random = Random();
    int randomNumber = random.nextInt(100);
    if (image != null && image!.name.split(".").last == "jpg" ||
        image != null && image!.name.split(".").last == "jpeg" ||
        image != null && image!.name.split(".").last == "png") {
      if (mode == "add") {
        var data = {
          "mode": "add",
          "id": '${selectedCabang.value}000$randomNumber',
          "username": username.text,
          "password": pass.text,
          "nama": name.text,
          "no_telp": telp.text,
          "kode_cabang": selectedCabang.value,
          "level": selectedLevel.value,
          "foto": File(image!.path.toString())
        };
        await ServiceApi().addUpdatePegawai(data);
      } else {
        if (image != null && image!.name.split(".").last == "jpg" ||
            image != null && image!.name.split(".").last == "jpeg" ||
            image != null && image!.name.split(".").last == "png") {
          var data = {
            "mode": "update",
            "id": dataUser[0],
            "nama": name.text != "" ? name.text : dataUser[1],
            "no_telp": telp.text != "" ? telp.text : dataUser[3],
            "kode_cabang":
                selectedCabang.value != "" ? selectedCabang.value : dataUser[8],
            "level":
                selectedLevel.value != "" ? selectedLevel.value : dataUser[4],
            "foto": File(image!.path.toString())
          };
          await ServiceApi().addUpdatePegawai(data);
        } else {
          var data = {
            "mode": "update",
            "id": dataUser[0],
            "nama": name.text != "" ? name.text : dataUser[1],
            "no_telp": telp.text != "" ? telp.text : dataUser[3],
            "kode_cabang":
                selectedCabang.value != "" ? selectedCabang.value : dataUser[8],
            "level":
                selectedLevel.value != "" ? selectedLevel.value : dataUser[4],
          };
          await ServiceApi().addUpdatePegawai(data);
        }
      }
      // print(data);
      dialogMsg("Sukses", "Data Berhasil Disimpan");
      selectedCabang.value = "";
      username.clear();
      pass.clear();
      name.clear();
      telp.clear();
      selectedLevel.value = "";
      update();
    } else {
      dialogMsg("Terjadi Kesalahan",
          "Ekstensi file tidak diizinkan.\nHarap memilih file dengan format\njpg, jpeg, png");
    }
  }

  // uploadFoto() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'pdf', 'doc'],
  //   );
  //   // final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  //   // // setState(() {
  //   // _image = File(pickedImage!.path);
  //   // });
  //   if (result != null) {
  //     PlatformFile file = result.files.first;
  //     fileFoto.text = file.name;
  //     pathfileBanner = File(result.files.single.path.toString());
  //     // print(file.name);
  //     // print(file.bytes);
  //     // print(file.size);
  //     // print(file.extension);
  //     // print(file.path);
  //   } else {
  //     // print('No file selected');
  //   }
  // }
  // FirebaseAuth auth = FirebaseAuth.instance;
  // FirebaseFirestore firestore = FirebaseFirestore.instance;

  // void addPegawai() async {
  //   if (nip.text.isNotEmpty && name.text.isNotEmpty && email.text.isNotEmpty) {
  //     try {
  //       UserCredential userCredential =
  //           await auth.createUserWithEmailAndPassword(
  //               email: email.text, password: "password");
  //       if (userCredential.user != null) {
  //         String uid = userCredential.user!.uid;
  //         firestore.collection("pegawai").doc(uid).set(
  //           {
  //             "email":email.text,
  //             "nama":name.text,
  //             "nip":nip.text,
  //             "createdAt":DateTime.now().toIso8601String(),
  //             "uid":uid

  //           }
  //         );
  //       }
  //     } on FirebaseException catch (e) {
  //       if (e.code == 'weak-password') {
  //         log('The password provided is too weak.');
  //         showToast("failed", "Password terlalu lemah");
  //       } else if (e.code == 'email-already-in-use') {
  //         log('The account already exists for that email.');
  //         showToast("failed", "Email ini sudah terdaftar");
  //         Get.snackbar("Error", "Terjadi kesalahan");
  //       }
  //     }
  //   } else {
  //     showToast("failed", "Terjadi kesalahan saat mengirim data ke server");
  //   }
  // }
}
